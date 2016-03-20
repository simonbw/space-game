import * as p2 from 'p2';
import * as Pixi from 'pixi.js';

import * as CollisionGroups from './CollisionGroups';
import * as Util from './gameutil/Util';
import Entity from './core/Entity';
import Part from './ship/parts/Part';


const RADIUS = 0.3;
const WALK_FORCE = 10;
const WALK_FRICTION = 0.4;
const JETPACK_FORCE = 0.4;
const MAXIMUM_FRICTION = 1.0;


/**
 * @extends Entity
 */
export default class Person extends Entity {

  /**
   * Create a new person.
   * @param position
   * @param ship
   */
  constructor(position = [0, 0], ship = null) {
    super();
    this.body = this.makeBody(position);
    this.chair = null;
    this.interactions = [];
    this.room = null;
    this.ship = ship;
    this.sprite = this.makeSprite();
  }

  get position() {
    return this.body.position;
  }

  get angle() {
    return this.body.angle;
  }

  set angle(val) {
    return this.body.angle = val;
  }

  get x() {
    return this.position[0];
  }

  set x(value) {
    return this.position[0] = value;
  }

  get y() {
    return this.position[1];
  }

  set y(value) {
    return this.position[0] = value;
  }

  /**
   * Create the physics body for the person.
   * @param position - position of the person
   * @returns {p2.Body}
   */
  makeBody(position) {
    const body = new p2.Body({
      position: position,
      mass: 0.1,
      angularDamping: 0.01,
      damping: 0.0
    });
    body.owner = this;
    const shape = new p2.Circle({radius: RADIUS});
    shape.collisionGroup = CollisionGroups.PERSON;
    shape.collisionMask = CollisionGroups.PERSON_MASK;
    shape.owner = this;
    shape.beginContact = (otherShape) => {
      if (otherShape.sensor && otherShape.owner && otherShape.owner.interactive) {
        this.interactions.push(otherShape.owner);
        if (otherShape.owner.personEnter) {
          return otherShape.owner.personEnter(this);
        }
      }
    };
    shape.endContact = (otherShape) => {
      if (otherShape.sensor && otherShape.owner && otherShape.owner.interactive) {
        this.interactions.splice(this.interactions.indexOf(otherShape.owner), 1);
        if (otherShape.owner.personExit) {
          return otherShape.owner.personExit(this);
        }
      }
    };
    body.addShape(shape);
    return body;
  }

  /**
   * @returns {Pixi.Graphics}
   */
  makeSprite() {
    const sprite = new Pixi.Graphics();
    sprite.beginFill(0x00FF00);
    sprite.drawCircle(0, 0, RADIUS);
    sprite.endFill();

    sprite.lineStyle(0.05, 0xFFFFFF);
    sprite.moveTo(0, 0);
    sprite.lineTo(RADIUS, 0);
    return sprite;
  }

  /**
   * Interact with the first part in the list
   */
  interact() {
    if (this.interactions.length > 0) {
      this.interactions[0].interact(this);
    }
  }

  /**
   * Move the thing at the top of the interact list to the bottom
   */
  nextInteraction() {
    if (this.interactions.length > 1) {
      this.interactions.push(this.interactions.shift());
    }
  }

  /**
   * Move the thing at bottom top of the interact list to the top
   */
  previousInteraction() {
    if (this.interactions.length > 1) {
      this.interactions.unshift(this.interactions.pop());
    }
  }

  /**
   * Align physics to those of a different ship.
   * @param ship {Ship}
   */
  board(ship) {
    this.ship = ship;
  }

  /**
   * Apply force to the body to move.
   * @param x {number} - Between -1 and 1
   * @param y {number} - Between -1 and 1
   */
  move([x, y]) {
    if (!(this.chair != null)) {
      const pressure = this.getPressure();
      const speed = pressure > 0.4 ? WALK_FORCE : JETPACK_FORCE;
      const [fx, fy] = [x * speed, y * speed];
      this.body.force[0] += fx;
      this.body.force[1] += fy;
      if (pressure) {
        this.ship.body.applyForce([-fx, -fy]);
      }
    }
  }

  /**
   * Apply torque to rotate the person towards a direction.
   * @param direction {number} - in radians
   * @returns {number}
   */
  rotateTowards(direction) {
    const k = 4.0; // spring constant
    const m = this.body.inertia;
    const d = 0.55; // damping coefficient
    const c = 2 * Math.sqrt(m * k) * d;
    const v = this.body.angularVelocity;
    const x = Util.angleDelta(this.angle, direction);

    this.body.angularForce += k * x - c * v;
  }

  /**
   * Called before rendering.
   */
  render() {
    this.sprite.x = this.body.position[0];
    this.sprite.y = this.body.position[1];
    this.sprite.rotation = this.body.angle;
  }

  /**
   * Return the part the person is currently standing on.
   * @returns {Part}
   */
  getPart() {
    if (!this.ship) {
      return undefined;
    }
    return this.ship.partAtWorld(this.position);
  }

  /**
   * Return the air pressure
   * @returns {*}
   */
  getPressure() {
    const part = this.getPart();
    if (part) {
      return part.getPressure();
    }
    return 0;
  }

  /**
   * Get into a chair.
   * @param chair
   * @returns {*}
   */
  enterChair(chair) {
    console.log('entering chair');
    return this.chair = chair;
  }

  /**
   * Leave the current chair.
   * @returns {null}
   */
  leaveChair() {
    return this.chair = null;
  }

  /**
   * Called every frame.
   */
  tick() {
    // Update Room
    if (this.room) {
      this.room.people.delete(this);
    }
    const part = this.getPart();
    this.room = (part) ? part.room : null;
    if (this.room) {
      this.room.people.add(this);
    }

    // Apply Friction
    if (!this.chair) {
      const pressure = this.getPressure();
      if (pressure > 0.4) {
        const shipVelocity = this.ship.velocityAtWorldPoint(this.position);

        var fx = shipVelocity[0] - this.body.velocity[0];
        var fy = shipVelocity[1] - this.body.velocity[1];

        const friction = WALK_FRICTION;
        fx *= friction;
        fy *= friction;

        const magnitude = Math.sqrt(fx * fx + fy * fy);
        if (magnitude > MAXIMUM_FRICTION) {
          fx *= MAXIMUM_FRICTION / magnitude;
          fy *= MAXIMUM_FRICTION / magnitude;
        }

        fx /= this.body.mass;
        fy /= this.body.mass;

        this.body.force[0] += fx;
        this.body.force[1] += fy;

        // Equal and opposite force on the ship
        this.ship.body.applyForce([-fx, -fy]);
      }
    }
  }

  /**
   * Called after the tick.
   */
  afterTick() {
    if (this.chair) {
      this.body.position = this.chair.getWorldPosition();
      this.body.velocity = this.chair.getVelocity();
      this.body.angle = this.chair.ship.body.angle - Math.PI / 2;
    }
  }
}
