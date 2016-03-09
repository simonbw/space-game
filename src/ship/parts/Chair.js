import * as p2 from 'p2';
import * as Pixi from 'pixi.js';

import InteractivePart from './InteractivePart';
import Interior from './Interior';

/**
 * A chair to sit in to control a ship.
 * @extends InteractivePart
 */
export default class Chair extends InteractivePart {

  /**
   * Create a new chair
   * @param position {Array.<number>}
   */
  constructor(position) {
    super(position);
    this.isOpen = false;
    this.timer = 0;
    this.person = null;
  }

  /**
   * @returns {Pixi.Container}
   * @extends Part
   */
  makeSprite() {
    const sprite = new Pixi.Container();
    sprite.floor = new Pixi.Graphics();
    sprite.addChild(sprite.floor);
    sprite.chair = new Pixi.Graphics();
    sprite.addChild(sprite.chair);

    sprite.floor.beginFill(Interior.prototype.color);
    sprite.floor.drawRect(-0.5 * this.width, -0.5 * this.height, this.width, this.height);
    sprite.floor.endFill();

    sprite.chair.beginFill(this.color);
    const w = this.width * 0.6;
    const h = this.height * 0.6;
    sprite.chair.drawRect(-0.5 * w, -0.5 * h, w, h);
    sprite.chair.endFill();
    return sprite;
  }

  /**
   * @returns {{width: number, height: number}}
   */
  getSensorSize() {
    return {
      width: this.width,
      height: this.height
    };
  }

  /**
   * @param person {Person}
   */
  interact(person) {
    if (!this.person) {
      person.enterChair(this);
      this.person = person;
    } else {
      if (this.person === person) {
        this.person.leaveChair();
        this.person = null;
      } else {
        console.log("Chair Full");
      }
    }
  }
}

Chair.prototype.color = 0x333333;
Chair.prototype.interior = true;
Chair.prototype.maxHealth = 250;
Chair.prototype.name = 'Chair';
