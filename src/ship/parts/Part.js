import * as p2 from 'p2';
import * as Pixi from 'pixi.js';

import * as CollisionGroups from '../../CollisionGroups';

// A count of all parts created ever
var partCount = 0;

/**
 * Base class for all ship parts
 */
export default class Part {
  /**
   * Create a new part.
   * @param position {Array.<number>}
   * @param otherProperties {Object} - other properties to assign to this part.
   */
  constructor(position, otherProperties = {}) {
    /** @type {number}*/
    this.direction = null;
    /** @type {number}*/
    this.health = this.maxHealth;
    /** @type {number}*/
    this.partId = partCount++;
    /** @type {Array.<number>} */
    this.position = position;
    /** @type {Room} */
    this.room = null;
    /** @type {Ship} */
    this.ship = null;
    /** @type {p2.Shape} */
    this.sensor = null;

    Object.assign(this, otherProperties);

    if (this.makeShape != null) {
      this.shape = this.makeShape();
      this.shape.owner = this;
    }
    if (this.makeSprite != null) {
      this.sprite = this.makeSprite();
      [this.sprite.x, this.sprite.y] = this.position;
    }
  }

  /**
   * Grid x position of this part
   * @returns {number}
   */
  get x() {
    return this.position[0];
  }

  /**
   * Grid x position of this part
   * @param val {number}
   */
  set x(val) {
    this.position[0] = val;
  }

  /**
   * Grid y position of this part
   * @returns {number}
   */
  get y() {
    return this.position[1];
  }

  /**
   * Grid y position of this part
   * @param val {number}
   */
  set y(val) {
    this.position[1] = val;
  }

  /**
   * Create the physics shape.
   * @returns {p2.Shape}
   */
  makeShape() {
    const shape = new p2.Box({width: this.width, height: this.height});
    if (this.interior) {
      shape.collisionGroup = CollisionGroups.SHIP_INTERIOR;
    } else {
      shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR;
    }
    shape.collisionMask = CollisionGroups.ALL;
    return shape;
  }

  /**
   * Create the sprite.
   * @returns {Pixi.Graphics}
   */
  makeSprite() {
    const sprite = new Pixi.Graphics();
    sprite.beginFill(this.color);
    sprite.drawRect(-0.5 * this.width, -0.5 * this.height, this.width, this.height);
    sprite.endFill();
    if (this.directional) {
      sprite.rotation = (this.direction + 2) * Math.PI / 2;
    }
    return sprite;
  }

  /**
   * Return a list of grid points that are adjacent to this part.
   * @returns {Array.<Array<number>>}
   */
  getAdjacentPoints() {
    return [[this.x + 1, this.y], [this.x, this.y + 1], [this.x - 1, this.y], [this.x, this.y - 1]];
  }

  /**
   * Return an array of adjacent parts
   * @param withNull {boolean} - Whether to include null for holes.
   * @returns {Array.<Part>}
   */
  getAdjacentParts(withNull = false) {
    const parts = [];
    this.getAdjacentPoints().forEach((point) => {
      const part = this.ship.partAtGrid(point);
      if (withNull || (typeof part !== "undefined" && part !== null)) {
        parts.push(part);
      }
    });
    return parts;
  }

  /**
   * Return the air pressure of the current part.
   * For parts without an interior, this is 0.
   * @returns {number}
   */
  getPressure() {
    if (this.room) {
      return this.room.pressure;
    }
    return 0;
  }

  /**
   * Return the position of the part in local physics coordinates of the ship.
   * @returns {Array.<number>}
   */
  getLocalPosition() {
    if (this.ship != null) {
      return this.ship.gridToLocal(this.position);
    }
    return null;
  }

  /**
   * Return the position of the part in world physics coordinates.
   * @returns {Array.<number>}
   */
  getWorldPosition() {
    if (this.ship) {
      return this.ship.gridToWorld(this.position);
    }
    return null;
  }

  /**
   * Return the world velocity of this part.
   * @returns {Array.<number>}
   */
  getVelocity() {
    if (this.ship) {
      return this.ship.velocityAtGridPoint(this.position);
    }
    return null;
  }

  /**
   * Return a copy of this part
   * @returns {Part}
   */
  clone() {
    return new this.constructor(this.position);
  }

  /**
   * A nice string of this part
   * @returns {string}
   */
  toString() {
    return `<${this.name} at (${this.position})>`;
  }
}

/**
 * @type {number}
 */
Part.prototype.color = 0xFFFFFF;
/**
 * @type {boolean}
 */
Part.prototype.directional = false;
/**
 * @type {number}
 */
Part.prototype.energyCapacity = null;
/**
 * @type {number}
 */
Part.prototype.height = 1;
/**
 * @type {boolean}
 */
Part.prototype.interior = false;
/**
 * @type {number}
 */
Part.prototype.mass = 1;
/**
 * @type {number}
 */
Part.prototype.maxEnergyDeficit = null;
/**
 * @type {number}
 */
Part.prototype.maxHealth = 100;
/**
 * @type {string}
 */
Part.prototype.name = 'Ship Part';
/**
 * @type {function()}
 */
Part.prototype.tick = null;
/**
 * @type {number}
 */
Part.prototype.width = 1;
