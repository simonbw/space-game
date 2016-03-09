import p2 from 'p2';
import Pixi from 'pixi.js';

import Blueprint from './Blueprint';
import Entity from '../core/Entity';
import Grid from '../gameutil/Grid';
import Hull from './parts/Hull';
import PowerManager from './PowerManager';
import RoomManager from './RoomManager';
import ThrustBalancer from './ThrustBalancer';
import Thruster from './parts/Thruster';
import * as Util from '../gameutil/Util';


const BASE_MASS = 0.1;


/**
 * A space ship.
 *
 * The ship class is the top level of control for multiple systems.
 * First, it is a collection of ship parts.
 * It contains the body and sprite for simulating and rendering all these parts.
 * Second it manages power, through the PowerManger class.
 * It manages how air pressure flows through rooms with the RoomManager.
 * It manages control systems, i.e. thrust through the thrust manager.
 *
 * There are a few different coordinate systems used in relation to ships.
 *   Grid coordinates
 *   Local Coordinates
 *   Sprite Coordinates
 *   World Coordinates
 *
 * @extends Entity
 */
export default class Ship extends Entity {

  /**
   * Create a new ship
   * @param blueprint {Blueprint}
   * @param x {number}
   * @param y {number}
   */
  constructor(blueprint, [x, y]=[0, 0]) {
    super();
    this.blueprint = blueprint || new Blueprint();
    this.layer = 'world';
    this.offset = [0, 0]; // local vector from center of mass to center of grid
    this.partGrid = new Grid();
    this.parts = [];
    this.powerManager = new PowerManager(this);
    this.roomManager = new RoomManager(this);
    this.sprite = new Pixi.Graphics();
    this.thrustBalancer = new ThrustBalancer(this);
    this.tickableParts = [];
    this.body = new p2.Body({
      position: [x, y],
      mass: BASE_MASS,
      angularDamping: 0.01,
      damping: 0.0
    });

    // TODO: Part connections

    // add all the parts from the blueprint
    this.blueprint.parts.forEach((part) => this.addPart(part.clone()));
  }

  get position() {
    return this.body.position;
  }

  /**
   * Called before rendering
   */
  render() {
    this.sprite.clear();
    this.sprite.beginFill(0x00FFFF);
    this.sprite.drawCircle(-this.offset[0], -this.offset[1], 0.1);
    this.sprite.endFill();

    [this.sprite.x, this.sprite.y] = this.gridToWorld([0, 0]);
    this.sprite.rotation = this.body.angle;
  }

  /**
   * Called during tick.
   */
  tick() {
    this.roomManager.tick();
    this.powerManager.tick();
    this.tickableParts.forEach((part) => part.tick(this));
    this.powerManager.afterTick();
  }

  /**
   * Add a Part to this ship
   * @param part {Part}
   */
  addPart(part) {
    this.parts.push(part);
    part.ship = this;
    this.partGrid.set([part.x, part.y], part);
    if (part.tick) {
      this.tickableParts.push(part);
    }

    const angle = (part.directional) ? Math.PI / 2 * part.direction : 0;

    if (part.sprite) {
      this.sprite.addChild(part.sprite);
      this.sprite.rotation = angle;
    }

    this.body.mass += part.mass;

    if (part.shape || part.sensor) {
      const shapePosition = [part.x + this.offset[0], part.y + this.offset[1]];
      if (part.shape) {
        this.body.addShape(part.shape, shapePosition, angle);
      }
      if (part.sensor) {
        this.body.addShape(part.sensor, shapePosition, angle);
      }
      this.recenter();
    }

    this.roomManager.partAdded(part);
    this.powerManager.partAdded(part);
    this.thrustBalancer.partAdded(part);
  }

  /**
   * Remove a part from this ship.
   * @param part {Part}
   */
  removePart(part) {
    this.parts.splice(this.parts.indexOf(part), 1);
    this.partGrid.remove([part.x, part.y]);

    this.roomManager.partRemoved(part);
    this.powerManager.partRemoved(part);
    this.thrustBalancer.partRemoved(part);

    if (part.tick) {
      this.tickableParts.splice(this.tickableParts.indexOf(part), 1);
    }
    if (part.sprite) {
      this.sprite.removeChild(part.sprite);
    }
    if (part.shape) {
      this.body.removeShape(part.shape);
    }
    if (part.sensor) {
      this.body.removeShape(part.sensor);
    }

    this.body.mass -= part.mass;
    this.recenter();
    part.ship = null;
  }

  /**
   * Recalculate the center of mass.
   */
  recenter() {
    const before = [this.body.position[0], this.body.position[1]];
    this.body.adjustCenterOfMass();
    const beforeLocal = this.worldToLocal(before);
    this.offset[0] += beforeLocal[0];
    this.offset[1] += beforeLocal[1];
  }

  /**
   * Convert grid coordinates to local physics coordinates.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  gridToLocal(point) {
    return [point[0] + this.offset[0], point[1] + this.offset[1]];
  }

  /**
   * Convert local physics coordinates to grid coordinates.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  localToGrid(point) {
    return [point[0] - this.offset[0], point[1] - this.offset[1]];
  }

  /**
   * Convert local physics coordinates to world coordinates.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  localToWorld(point) {
    const world = [0, 0];
    this.body.toWorldFrame(world, point);
    return world;
  }

  /**
   * Convert world coordinates to local physics coordinates.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  worldToLocal(point) {
    const local = [0, 0];
    this.body.toLocalFrame(local, point);
    return local;
  }

  /**
   * Convert ship grid coordinates to world coordinates.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  gridToWorld(point) {
    return this.localToWorld(this.gridToLocal(point));
  }

  /**
   * Convert world coordinates to ship grid coordinates.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  worldToGrid(point) {
    return this.localToGrid(this.worldToLocal(point));
  }

  /**
   * Return the part at a grid point or undefined.
   * @param point {Array.<number>}
   * @returns {Part}
   */
  partAtGrid(point) {
    return this.partGrid.get([Math.round(point[0]), Math.round(point[1])]);
  }

  /**
   * Return the part at a local point or undefined.
   * @param point {Array.<number>}
   * @returns {Part}
   */
  partAtLocal(point) {
    return this.partAtGrid(this.localToGrid(point));
  }

  /**
   * Return the part at a world point or undefined.
   * @param point {Array.<number>}
   * @returns {Part}
   */
  partAtWorld(point) {
    return this.partAtGrid(this.worldToGrid(point));
  }

  /**
   * Return the velocity of the ship at a grid point.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  velocityAtGridPoint(point) {
    return this.velocityAtWorldPoint(this.gridToWorld(point));
  }

  /**
   * Return the velocity of the ship at a local point.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  velocityAtLocalPoint(point) {
    return this.velocityAtWorldPoint(this.localToWorld(point));
  }

  /**
   * Return the velocity of the ship at a world point.
   * @param point {Array.<number>}
   * @returns {Array.<number>}
   */
  velocityAtWorldPoint(point) {
    // base linear velocity
    const [xl, yl] = this.body.velocity;

    // relative position
    const x = point[0] - this.body.position[0];
    const y = point[1] - this.body.position[1];

    // relative angle
    const theta = Math.atan2(y, x) + Math.PI / 2;

    // tangential velocity
    const r = Math.hypot(x, y);
    const tangentialSpeed = this.body.angularVelocity * r;
    const xt = Math.cos(theta) * tangentialSpeed;
    const yt = Math.sin(theta) * tangentialSpeed;

    return [xl + xt, yl + yt];
  }
}
