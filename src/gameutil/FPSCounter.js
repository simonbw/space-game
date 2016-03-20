import * as Pixi from 'pixi.js';

import Entity from '../core/Entity';

/**
 * Utility class that displays the framerate.
 * @extends Entity
 */
export default class FPSCounter extends Entity {
  /**
   * Create a new FPSCounter.
   */
  constructor() {
    super();
    this.fps = 60;
    this.frame = 0;
    this.lastTick = Date.now();
    this.layer = 'hud';
    this.sprite = new Pixi.Text('', {
      font: '14px Arial',
      fill: '#FFFFFF'
    });
    this.sprite.y = 50;
  }

  /**
   * Called before rendering.
   * @returns {string}
   */
  render() {
    return this.sprite.text = String(Math.round(this.fps));
  }

  /**
   * Called during the tick.
   */
  tick() {
    this.frame++;
    const now = Date.now();
    this.fps = 0.9 * this.fps + 0.1 * (1000 / (now - this.lastTick));
    this.lastTick = now;
  }
}