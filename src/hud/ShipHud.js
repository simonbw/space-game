import * as Pixi from 'pixi.js';

import Entity from '../core/Entity';

/**
 * The HUD drawn while in a ship.
 * @extends Entity
 */
export default class ShipHud extends Entity {
  /**
   * Create a new ShipHud
   * @param ship {Ship}
   */
  constructor(ship) {
    super();
    this.ship = ship;
    this.sprite = new Pixi.Container();
    this.layer = 'hud';
    this.text = new Pixi.Text('', {
      font: '14px Arial',
      fill: '#FFFFFF'
    });
    this.text.y = 18;
    this.sprite.addChild(this.text);
  }

  /**
   * Make the string to be displayed by the hud
   * @returns {string}
   */
  makeText() {
    const velocity = this.ship.body.velocity;
    const xspeed = Math.round(velocity[0]);
    const yspeed = Math.round(velocity[1]);
    const energy = this.ship.powerManager.energy;
    const capacity = this.ship.powerManager.capacity;
    return `Velocity: <${xspeed}, ${yspeed}>\nEnergy: ${energy}/${capacity}`;
  }

  /**
   * Called before rendering.
   */
  render() {
    this.text.text = this.makeText();
  }
}
