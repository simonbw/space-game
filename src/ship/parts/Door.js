import * as p2 from 'p2';
import * as Pixi from 'pixi.js';

import * as CollisionGroups from '../../CollisionGroups';
import InteractivePart from './InteractivePart';
import Interior from './Interior';

const TIME = -1; // -1 for infinite

/**
 * Open and close. to keep air out.
 * @extends InteractivePart
 */
export default class Door extends InteractivePart {
  constructor(pos) {
    super(pos);
    this.isOpen = false;
    this.timer = 0;
    this.people = new Set();
    this.automatic = true;
  }

  /**
   * Called when a person interacts with this
   * @param person {Person}
   * @returns {*}
   */
  interact(person) {
    if (this.isOpen) {
      this.close();
    } else {
      this.open(TIME);
    }
  }

  /**
   * Called when a person enters the sensor range.
   * @param person {Person}
   */
  personEnter(person) {
    this.people.add(person);
    if (this.automatic && !this.isOpen) {
      return this.open();
    }
  }

  /**
   * Called when a person exits the sensor range.
   * @param person {Person}
   */
  personExit(person) {
    this.people.delete(person);
    if (this.automatic) {
      return this.close();
    }
  }

  /**
   * @returns {Pixi.Container}
   */
  makeSprite() {
    const sprite = new Pixi.Container();
    sprite.floor = new Pixi.Graphics();
    sprite.addChild(sprite.floor);
    sprite.door = new Pixi.Graphics();
    sprite.addChild(sprite.door);
    sprite.floor.beginFill(Interior.prototype.color);
    sprite.floor.drawRect(-0.5 * this.width, -0.5 * this.height, this.width, this.height);
    sprite.floor.endFill();
    sprite.door.beginFill(this.color);
    sprite.door.drawRect(-0.5 * this.width, -0.5 * this.height, this.width, this.height);
    sprite.door.endFill();
    return sprite;
  }

  /**
   * Open the door
   * @param time {number} - Milliseconds to stay open. Negative for infinite.
   */
  open(time = -1) {
    this.sprite.door.visible = false;
    this.isOpen = true;
    this.shape.collisionGroup = CollisionGroups.SHIP_INTERIOR;
    this.timer = time;
  }

  /**
   * Close the door.
   */
  close() {
    if (this.people.size === 0) {
      this.sprite.door.visible = true;
      this.isOpen = false;
      this.shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR;
    } else {
      console.log("Cannot close, person in the way");
    }
  }

  /**
   * Returns the air pressure averaged between connected rooms.
   * @returns {number}
   */
  getPressure() {
    var totalPressure = 0;

    const adjacentRooms = this.getAdjacentRooms();
    adjacentRooms.forEach((room) => {
      if (room) {
        totalPressure += room.pressure;
      }
    });
    return (totalPressure / adjacentRooms.length) || 0;
  }

  /**
   * Returns a set of rooms this door is attached to.
   * A null room means its attached to outer space
   * @returns {Array.<Room>}
   */
  getAdjacentRooms() {
    const result = [];
    this.getAdjacentParts(true).forEach((part) => {
      if (!(typeof part !== "undefined" && part !== null)) {
        result.push(null);
      } else if ((part.room != null)) {
        result.push(part.room);
      }
    });
    return result;
  }

  /**
   * Called during the tick.
   */
  tick() {
    if (this.timer > 0) {
      this.timer--;
      if (this.timer === 0) {
        this.close();
      }
    }
  }
}

Door.prototype.color = 0x999999;
Door.prototype.maxHealth = 250;
Door.prototype.name = 'Door';
