import Pixi from 'pixi.js';

import * as Util from './gameutil/Util';
import Entity from './core/Entity';
import IO from './core/IO';
import Thruster from './ship/parts/Thruster';
import {AirVent, Chair, Core, Door, Generator, Hull, Interior} from './ship/Parts';

class PartLabel extends Entity {
  constructor() {
    super();
    this.layer = 'hud';
    this.sprite = new Pixi.Text('part', {
      font: '20px Arial',
      fill: '#FFFFFF'
    });
  }
}

// KEYS
const K_PREVIOUS_PART = 81; // q
const K_NEXT_PART = 69; // e
const K_ROTATE_LEFT = 65; // a
const K_ROTATE_RIGHT = 68; // d
const K_CLOSE = 32; // space

/**
 * A screen to edit blueprints.
 * @extends Entity
 */
export default class BlueprintEditor extends Entity {

  constructor(blueprint, onclose = null) {
    super();
    this.blueprint = blueprint;
    this.onclose = onclose;
    this.added = this.added.bind(this);
    this.getHoverSquare = this.getHoverSquare.bind(this);
    this.render = this.render.bind(this);
    this.onClick = this.onClick.bind(this);
    this.onRightClick = this.onRightClick.bind(this);
    this.nextPart = this.nextPart.bind(this);
    this.rotate = this.rotate.bind(this);
    this.onKeyDown = this.onKeyDown.bind(this);
    this.close = this.close.bind(this);
    this.destroyed = this.destroyed.bind(this);
    this.sprite = new Pixi.Container();
    this.layer = 'world';
    this.background = new Pixi.Graphics();
    this.background.beginFill(0x111711);
    this.background.endFill();

    this.sprite.addChild(this.background);
    this.sprite.addChild(this.blueprint.sprite);

    this.selector = new Pixi.Graphics();
    this.sprite.addChild(this.selector);

    this.partLabel = new PartLabel();

    this.direction = 0;
    this.partClasses = [Hull, Interior, AirVent, Door, Chair, Thruster, Generator];
    this.partIndex = 0;
    this.nextPart(0);
  }

  /**
   * Called when added to the game.
   */
  added() {
    this.game.addEntity(this.partLabel);
  }

  /**
   * Return the grid coordinates of the square the mouse is over
   * @returns {Array.<number>}
   */
  getHoverSquare() {
    return this.game.camera.toWorld(this.game.io.mousePosition).map(Math.round);
  }

  /**
   * Called before rendering.
   */
  render() {
    this.selector.clear();
    const squarePos = this.getHoverSquare();
    const hoverPart = this.blueprint.partGrid.get(squarePos);
    if (!hoverPart) {
      this.selector.beginFill(this.Part.prototype.color);
      this.selector.drawRect(-0.5, -0.5, 1, 1);
      this.selector.endFill();
    }

    const canAdd = !hoverPart; // TODO: Better canAdd
    var color;
    if (hoverPart) {
      color = 0xFFFFFF;
    } else if (canAdd) {
      color = 0x33FF33;
    } else {
      color = 0xFF3333;
    }

    this.selector.lineStyle(0.05, color);
    this.selector.drawRect(-0.5, -0.5, 1, 1);

    if (this.Part.prototype.directional) {
      this.selector.lineStyle(0.05, 0xFFFFFF, 0.5);
      this.selector.moveTo(0, 0);
      const angle = (this.direction + 3) * Math.PI / 2;
      this.selector.lineTo(Math.cos(angle) * 0.5, Math.sin(angle) * 0.5);
    }

    // painting
    if (game.io.lmb) {
      this.onClick();
    }

    if (game.io.rmb) {
      this.onRightClick();
    }

    return [this.selector.x, this.selector.y] = squarePos;
  }

  /**
   * Add parts on click.
   */
  onClick() {
    const pos = this.getHoverSquare();
    if (this.blueprint.partGrid.get(pos)) {
      const args = [pos];
      if (this.Part.prototype.directional) {
        args.push(this.direction);
      }
      const part = new this.Part(...args);
      this.blueprint.addPart(part);
    }
  }

  /**
   * Remove parts on right click.
   */
  onRightClick() {
    const part = this.blueprint.partGrid.get(this.getHoverSquare());
    if (part && !(part instanceof Core)) {
      return this.blueprint.removePart(part);
    }
  }

  /**
   * Select the next part.
   * @param i {=number} - index to add.
   * @returns {*}
   */
  nextPart(i = 1) {
    this.partIndex = Util.mod(this.partIndex + i, this.partClasses.length);
    this.Part = this.partClasses[this.partIndex];
    this.partLabel.sprite.text = this.Part.prototype.name;
  }

  /**
   * Rotate the current direction.
   * @param i {number} - Amount to rotate by.
   */
  rotate(i = 1) {
    this.direction = Util.mod(this.direction + i, 4);
  }

  /**
   * Handle key presses.
   * @param key {number} - key code
   */
  onKeyDown(key) {
    switch (key) {
      case K_CLOSE:
        return this.close();
      case K_NEXT_PART:
        return this.nextPart(1);
      case K_PREVIOUS_PART:
        return this.nextPart(-1);
      case K_ROTATE_LEFT:
        return this.rotate(-1);
      case K_ROTATE_RIGHT:
        return this.rotate(1);
    }
  }

  /**
   * Try to close the editor.
   */
  close() {
    if (this.blueprint.isValid()) {
      this.destroy();
    } else {
      console.log("invalid blueprint");
    }
  }

  /**
   * Actually close the editor
   */
  destroyed() {
    this.partLabel.destroy();
    if (typeof this.onclose == 'function') {
      this.onclose(this.blueprint);
    }
  }
}
