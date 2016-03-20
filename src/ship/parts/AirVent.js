import * as p2 from 'p2';
import * as Pixi from 'pixi.js';

import * as CollisionGroups from '../../CollisionGroups';
import InteractivePart from './InteractivePart';
import Interior from './Interior';

// states
const PRESSURIZE = 0;
const OFF = 1;
const DEPRESSURIZE = 2;

const SPEED = 0.02;

/**
 * Provides air.
 * @extends Part
 */
export default class AirVent extends InteractivePart {
  constructor(pos) {
    super(pos);
    this.setState(OFF);
  }

  /**
   * Called when a person interacts with this
   * @param person {Person}
   */
  interact(person) {
    switch (this.state) {
      case PRESSURIZE:
        this.setState(DEPRESSURIZE);
        break;
      case DEPRESSURIZE:
        this.setState(OFF);
        break;
      case OFF:
        this.setState(PRESSURIZE);
        break;
    }
  }

  /**
   * Set the vent to pressurize, depressurize, or do nothing.
   * @param state
   */
  setState(state) {
    this.state = state;
    this.sprite.pressurizeLight.visible = (this.state === PRESSURIZE);
    this.sprite.depressurizeLight.visible = (this.state === DEPRESSURIZE);
  }

  /**
   *
   * @returns {Pixi.Container}
   */
  makeSprite() {
    const sprite = new Pixi.Container();
    sprite.floor = new Pixi.Graphics();
    sprite.addChild(sprite.floor);
    sprite.vent = new Pixi.Graphics();
    sprite.addChild(sprite.vent);
    sprite.pressurizeLight = new Pixi.Graphics();
    sprite.addChild(sprite.pressurizeLight);
    sprite.depressurizeLight = new Pixi.Graphics();
    sprite.addChild(sprite.depressurizeLight);

    sprite.floor.beginFill(Interior.prototype.color);
    sprite.floor.drawRect(-0.5 * this.width, -0.5 * this.height, this.width, this.height);
    sprite.floor.endFill();

    sprite.vent.beginFill(this.color);
    const w = this.width * 0.8;
    const h = this.height * 0.8;
    sprite.vent.drawRect(-0.5 * w, -0.5 * h, w, h);
    sprite.vent.endFill();

    sprite.pressurizeLight.beginFill(0x00FF00);
    sprite.pressurizeLight.drawCircle(-0.35, -0.35, 0.08);
    sprite.pressurizeLight.endFill();

    sprite.depressurizeLight.beginFill(0xFF0000);
    sprite.depressurizeLight.drawCircle(-0.35, -0.35, 0.08);
    sprite.depressurizeLight.endFill();
    return sprite;
  }

  /**
   *
   * @returns {{width: number, height: number}}
   */
  getSensorSize() {
    return {
      width: this.width,
      height: this.height
    };
  }

  /**
   * Called during the tick.
   */
  tick() {
    if (this.room) {
      if (this.state === PRESSURIZE) {
        this.room.giveAir(SPEED);
      } else if (this.state === DEPRESSURIZE) {
        this.room.giveAir(-SPEED);
      }
    }
  }
}

AirVent.prototype.color = 0xBBBBBB;
AirVent.prototype.interior = true;
AirVent.prototype.maxHealth = 250;
AirVent.prototype.name = 'Air Vent';