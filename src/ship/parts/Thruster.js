import * as p2 from 'p2';
import * as Pixi from 'pixi.js';

import * as Util from '../../gameutil/Util';
import Part from './Part';


/**
 * Provides thrust.
 * @extends Part
 */
export default class Thruster extends Part {

  /**
   * Create a new Thruster.
   * @param position {Array.<number>}
   * @param direction {number}
   */
  constructor(position, direction = 0) {
    super(position, {direction: direction});
    this.throttle = 0;
    this.maxThrust = 200;
    this.energyDeficit = this.maxEnergyDeficit;
  }

  /**
   * @returns {Pixi.Graphics}
   */
  makeSprite() {
    const sprite = super.makeSprite();
    sprite.flame = new Pixi.Graphics();
    sprite.addChild(sprite.flame);
    return sprite;
  }

  /**
   * @param thrust {number}
   * @returns {Pixi.Graphics}
   */
  renderThrust(thrust) {
    this.sprite.flame.clear();
    this.sprite.flame.lineStyle(0.4 * thrust / this.maxThrust, 0xFFAA00);
    this.sprite.flame.moveTo(-0.5, -0.5);
    return this.sprite.flame.lineTo(0.5, -0.5);
  }

  /**
   * Set the throttle.
   * @param value {number} - between 0 and 1.
   */
  setThrottle(value) {
    this.throttle = Util.clamp(value, 0);
  }

  /**
   * Return the amount of thrust to apply based on current state of the thruster.
   * @returns {number}
   */
  getThrust() {
    const target = this.throttle * this.maxThrust;
    const energyLimited = (1 - this.energyDeficit / this.maxEnergyDeficit) * this.maxThrust;
    return Math.min(target, energyLimited);
  }

  /**
   * Called during the tick.
   * @param ship {Ship}
   */
  tick(ship) {
    const forcePoint = p2.vec2.sub([0, 0], this.getWorldPosition(), ship.position);
    const angle = ship.body.angle + (this.direction + 3) * Math.PI / 2;
    const thrust = this.getThrust();
    const force = [Math.cos(angle) * thrust, Math.sin(angle) * thrust];
    ship.body.applyForce(force, forcePoint);
    this.energyDeficit += thrust / this.maxThrust * this.maxEnergyDeficit;
    return this.renderThrust(thrust);
  }

  /**
   * Make a copy of this part.
   * @returns {Thruster}
   */
  clone() {
    return new Thruster(this.position, this.direction);
  }
}

Thruster.prototype.color = 0x555555;
Thruster.prototype.directional = true;
Thruster.prototype.maxEnergyDeficit = 0.5;
Thruster.prototype.maxHealth = 120;
Thruster.prototype.name = 'Thruster';
Thruster.prototype.thruster = true;
