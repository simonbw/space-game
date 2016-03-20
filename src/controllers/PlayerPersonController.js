import * as GamepadAxes from '../core/constants/GamepadAxes'
import * as GamepadButtons from '../core/constants/GamepadButtons'
import * as Keys from '../core/constants/Keys'
import * as Util from '../gameutil/Util';
import Entity from '../core/Entity';


const K_FORWARD = Keys.W;
const K_BACKWARD = Keys.S;
const K_LEFT = Keys.A;
const K_RIGHT = Keys.D;
const K_TURN_LEFT = Keys.Q;
const K_TURN_RIGHT = Keys.E;
const K_STABILIZE = Keys.SHIFT;
const K_WALK = Keys.SHIFT;
const K_INTERACT = Keys.SPACE;
const K_NEXT_INTERACT = Keys.TAB;

const A_MOVE_X = GamepadAxes.LEFT_X;
const A_MOVE_Y = GamepadAxes.LEFT_Y;
const A_TURN = GamepadAxes.RIGHT_X;
const A_AIM_X = GamepadAxes.RIGHT_X;
const A_AIM_Y = GamepadAxes.RIGHT_Y;

const B_INTERACT = GamepadButtons.A;
const B_NEXT_INTERACT = GamepadButtons.B;

/**
 * Controls the player's character
 * @extends Entity
 */
export default class PlayerPersonController extends Entity {

  /**
   * Create a new PlayerPersonController.
   * @param person {Person} - the person to control
   */
  constructor(person) {
    super();
    this.onButtonDown = this.onButtonDown.bind(this);
    this.onKeyDown = this.onKeyDown.bind(this);
    this.person = person;
  }

  /**
   * Called before the tick.
   */
  beforeTick() {
    if (this.person.chair) {
      this.controlShip();
    } else {
      this.controlPerson();
    }
  }

  /**
   * Send inputs for the ship the player is in
   */
  controlShip() {
    const ship = this.person.chair.ship;

    const forward = -this.getForward();
    const side = this.getSide();
    var turn = this.getTurn();

    if (this.game.io.keys[K_STABILIZE]) {
      turn = Util.clamp(2 * turn - ship.body.angularVelocity * 2);
    }
    // TODO: Linear Stabilization

    ship.thrustBalancer.balance(forward, side, turn);
  }

  /**
   * Send inputs to control a person not a ship
   */
  controlPerson() {
    const modifier = this.game.io.keys[K_WALK] ? 0.4 : 1;
    var x = this.getSide() * modifier;
    var y = -this.getForward() * modifier;
    const length = Math.hypot(x, y);
    if (length > 1) {
      x /= length;
      y /= length;
    }

    this.person.move([x * modifier, y * modifier]);
    this.person.rotateTowards(this.getAimAngle());
  }

  /**
   * Get the angle the player is aiming.
   * @returns {number} - radians CCW from east.
   */
  getAimAngle() {
    var dx, dy;
    if (this.game.io.usingGamepad) {
      dx = this.game.io.getAxis(A_AIM_X);
      dy = this.game.io.getAxis(A_AIM_Y);
    } else {
      const mouseWorldPosition = this.game.camera.toWorld(this.game.io.mousePosition);
      dx = mouseWorldPosition[0] - this.person.position[0];
      dy = mouseWorldPosition[1] - this.person.position[1];
    }
    return Math.atan2(dy, dx);
  }

  /**
   * The amount of horizontal movement input.
   * @returns {number}
   */
  getSide() {
    return this.game.io.keys[K_RIGHT] - this.game.io.keys[K_LEFT] + this.game.io.getAxis(A_MOVE_X);
  }

  /**
   * The amount of vertical movement input.
   * @returns {number}
   */
  getForward() {
    return this.game.io.keys[K_FORWARD] - this.game.io.keys[K_BACKWARD] - this.game.io.getAxis(A_MOVE_Y);
  }

  /**
   * The amount of turning movement input.
   * @returns {number}
   */
  getTurn() {
    return this.game.io.keys[K_TURN_RIGHT] - this.game.io.keys[K_TURN_LEFT] + this.game.io.getAxis(A_TURN);
  }

  /**
   * Called when a button is pressed.
   * @param button {number}
   */
  onButtonDown(button) {
    switch (button) {
      case B_INTERACT:
        this.person.interact();
        break;
      case B_NEXT_INTERACT:
        if (this.game.io.keys[Keys.SPACE]) {
          this.person.previousInteraction();
        } else {
          this.person.nextInteraction();
        }
        break;
    }
  }

  /**
   * Called when a key is pressed.
   * @param key {number}
   */
  onKeyDown(key) {
    switch (key) {
      case K_INTERACT:
        this.person.interact();
        break;
      case K_NEXT_INTERACT:
        if (this.game.io.keys[16]) {
          this.person.previousInteraction();
        } else {
          this.person.nextInteraction();
        }
        break;
    }
  }
}
