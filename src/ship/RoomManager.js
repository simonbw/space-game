import * as p2 from 'p2';

import Door from './parts/Door';
import Entity from '../core/Entity';
import * as Util from '../gameutil/Util';

var roomCount = 0;

const FLOW_CONSTANT = 1.0; // Stuff breaks when this goes over 1.0.
const SUCTION = 10;
const THRUST = 2000;


/**
 * Represents on contiguous set of interior pieces.
 * Controls air pressure.
 */
class Room {
  constructor(manager) {
    this._doors = new Set();
    this._holes = new Set();
    this.airCapacity = 0;
    this.dirty = true;
    this.manager = manager;
    this.parts = new Set();
    this.people = new Set();
    this.roomId = roomCount++;
    this.totalAir = 0;
  }

  /**
   * @returns {number}
   */
  get pressure() {
    return (this.totalAir / this.airCapacity) || 0;
  }

  /**
   * True if the room is air tight.
   * @returns {boolean}
   */
  get sealed() {
    return this.holes.size === 0;
  }

  /**
   * All the doors that are connected to this room
   * @returns {Set}
   */
  get doors() {
    if (this.dirty) {
      this.findHoles();
    }
    return this._doors;
  }

  /**
   * The set of grid positions where holes are
   * @returns {Set}
   */
  get holes() {
    if (this.dirty) {
      this.findHoles();
    }
    return this._holes;
  }

  /**
   * @returns {Ship}
   */
  get ship() {
    return this.manager.ship;
  }

  /**
   * Update calculations for air and stuff
   */
  tick() {
    // TODO: Balance flow between all holes. This need to happen in a lot of places. Lot's of math cleanup here.

    this.holes.forEach((hole) => {
      const flow = this.giveAir(-FLOW_CONSTANT * this.pressure);

      if (flow !== 0) {
        this.applySuction(hole, [0, 0], -flow);

        const forceDirection = [0, 0];
        if (!this.ship.partAtGrid([hole[0], hole[1] + 1])) {
          forceDirection[1] += -1;
        }
        if (!this.ship.partAtGrid([hole[0], hole[1] - 1])) {
          forceDirection[1] += 1;
        }
        if (!this.ship.partAtGrid([hole[0] + 1, hole[1]])) {
          forceDirection[0] += -1;
        }
        if (!this.ship.partAtGrid([hole[0] - 1, hole[1]])) {
          forceDirection[0] += 1;
        }

        const magnitude = flow * flow * THRUST;
        const angle = Math.atan2(forceDirection[1], forceDirection[0]) + this.ship.body.angle;
        const force = [Math.cos(angle) * magnitude, Math.sin(angle) * magnitude];

        const forcePoint = this.ship.gridToWorld(hole);
        return this.ship.body.applyForce(force, forcePoint);
      }
    });

    return this.doors.forEach((door) => {
      if (door.isOpen) {
        const adjacentRooms = door.getAdjacentRooms();
        return adjacentRooms.forEach((otherRoom) => {
          if ((typeof otherRoom !== "undefined" && otherRoom !== null)) { // door to other room
            const pressureDifference = this.pressure - otherRoom.pressure;
            if (pressureDifference > 0.001) {
              const flowRate = -pressureDifference * FLOW_CONSTANT;
              const change = this.giveAir(flowRate);
              otherRoom.giveAir(-change);
              return this.applySuction(door.position, [0, 0], -change);
            }
          } else { // door to outside
            const flow = this.giveAir(-FLOW_CONSTANT * this.pressure);
            this.applySuction(door.position, [0, 0], -flow);

            // TODO: Don't repeat code
            const forceDirection = [0, 0];
            if (!this.ship.partAtGrid([door.position[0], door.position[1] + 1])) {
              forceDirection[1] += -1;
            }
            if (!this.ship.partAtGrid([door.position[0], door.position[1] - 1])) {
              forceDirection[1] += 1;
            }
            if (!this.ship.partAtGrid([door.position[0] + 1, door.position[1]])) {
              forceDirection[0] += -1;
            }
            if (!this.ship.partAtGrid([door.position[0] - 1, door.position[1]])) {
              forceDirection[0] += 1;
            }

            const magnitude = flow * flow * THRUST;
            const angle = Math.atan2(forceDirection[1], forceDirection[0]) + this.ship.body.angle;
            const force = [Math.cos(angle) * magnitude, Math.sin(angle) * magnitude];

            const forcePoint = this.ship.gridToLocal(door.position);
            return this.ship.body.applyForce(force, forcePoint);
          }
        });
      }
    });
  }

  /**
   * Apply a suction force to everyone in the room
   * @param position {Array.<number>}
   * @param direction {Array.<number>}
   * @param flow {number}
   */
  applySuction(position, direction, flow) {
    position = this.ship.gridToWorld(position);
    this.people.forEach((person) => {
      var dx = position[0] - person.x;
      var dy = position[1] - person.y;
      const l = p2.vec2.length([dx, dy]);
      dx = dx / l || 0;
      dy = dy / l || 0;
      person.body.force[0] += dx * flow * SUCTION / l;
      person.body.force[1] += dy * flow * SUCTION / l;
    });
  }

  /**
   * Include a part in this room
   * @param part {Part}
   * @returns {number}
   */
  addPart(part) {
    if (!part) {
      throw new Error(`Bad Part: ${part}`);
    }
    this.parts.add(part);
    part.room = this;
    this.dirty = true;
    return this.airCapacity += 1;
  }

  /**
   * Remove a part from this room.
   *
   * TODO: Possibly splits room
   *
   * @param part
   * @returns {number}
   */
  removePart(part) {
    this.parts.delete(part);
    if (part.room === this) {
      part.room = null;
    }
    this.dirty = true;
    return this.airCapacity -= 1;
  }

  /**
   * True if the part is part of this room
   * @param part {Part}
   * @returns {boolean}
   */
  hasPart(part) {
    return this.parts.has(part);
  }

  /**
   * Recalculate the positions of all the holes.
   */
  findHoles() {
    this._holes.clear();

    this.parts.forEach((part) => {
      part.getAdjacentPoints().forEach((pos) => {
        const adjacentPart = this.ship.partAtGrid(pos);
        if (!adjacentPart) {
          this._holes.add(pos);
        } else if (adjacentPart instanceof Door) {
          this._doors.add(adjacentPart);
        }
      });
    });
  }

  /**
   * Add an amount of air into the room (can be negative)
   * @param amount
   * @returns {number} - the amount of air actually added
   */
  giveAir(amount) {
    const old = this.totalAir;
    this.totalAir += amount;
    this.totalAir = Util.clamp(this.totalAir, 0, this.airCapacity);
    return this.totalAir - old;
  }

  /**
   * Join this room with another, keeping this room, destroying the other.
   * @param other {Room}
   */
  join(other) {
    if (other === this) {
      throw new Error(`Joining room ${this.roomId} with itself`);
    }
    other.parts.forEach((part) => {
      this.addPart(part);
    });
    this.giveAir(other.totalAir);
  }

  /**
   * Destroy this.
   */
  destroy() {
    this.parts.forEach((part) => {
      part.room = null;
    });
    return this.parts.clear();
  }

  /**
   * @returns {string}
   */
  toString() {
    return `<Room size: ${this.parts.size}>`;
  }
}


/**
 * Keeps track of rooms on a ship
 */
export default class RoomManager extends Entity {
  /**
   * Create a new RoomManager
   * @param ship {Ship}
   */
  constructor(ship) {
    super();
    this.parts = []; // list of all parts
    this.partSet = new Set(); // set of all parts this has (I don't know why there are both)
    this.rooms = [];
    this.ship = ship;
    this.calculateRooms();
  }

  /**
   * Called when any part is added
   * @param part {Part}
   */
  partAdded(part) {
    if (part.interior) {
      this.parts.push(part);
      this.partSet.add(part);

      const adjacentRooms = this.getAdjacentRooms(part);

      if (adjacentRooms.length === 0) {
        const room = new Room(this);
        room.addPart(part);
        this.rooms.push(room);
      } else if (adjacentRooms.length === 1) {
        adjacentRooms[0].addPart(part);
      } else {
        const room = adjacentRooms.pop();
        room.addPart(part);
        for (var i = 0, otherRoom; i < adjacentRooms.length; i++) {
          otherRoom = adjacentRooms[i];
          room.join(otherRoom);
          this.rooms.splice(this.rooms.indexOf(otherRoom), 1);
        }
      }
    }

    this.getAdjacentRooms(part).forEach((room) => room.dirty = true);
  }

  /**
   * Called when any part is removed
   * @param part {Part}
   */
  partRemoved(part) {
    if (this.partSet.has(part)) {
      this.parts.splice(this.parts.indexOf(part), 1);
      this.calculateRooms(); // TODO: Don't be dumb
    }
    this.rooms.forEach((room) => room.dirty = true);
  }

  /**
   * Called during the tick.
   */
  tick() {
    this.rooms.forEach((room) => room.tick());
  }

  /**
   * Return all the rooms adjacent to a part
   * @param part {Part}
   * @returns {Array.<Room>}
   */
  getAdjacentRooms(part) {
    const adjacentRooms = new Set();
    part.getAdjacentParts().forEach((p) => {
      if (this.partSet.has(p)) {
        this.rooms.forEach((room) => {
          if (room.hasPart(p)) {
            adjacentRooms.add(room)
          }
        });
      }
    });
    return Array.from(adjacentRooms);
  }

  /**
   * Calculate which rooms exist
   */
  calculateRooms() {
    while (this.rooms.length) {
      this.rooms.pop().destroy(); // remove all existing rooms so we can start fresh
    }

    const remaining = new Set(this.parts);

    while (remaining.size > 0) {
      const room = new Room(this);
      this.rooms.push(room);

      const queue = [remaining.values().next().value];

      while (queue.length > 0) {
        const currentPart = queue.pop();

        room.addPart(currentPart);
        remaining.delete(currentPart);

        currentPart.getAdjacentParts().forEach((adjacentPart) => {
          if (remaining.has(adjacentPart)) {
            queue.push(adjacentPart);
          }
        });
      }
    }
  }
}
