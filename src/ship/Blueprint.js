import * as Pixi from 'pixi.js';

import Core from './parts/Core';
import Entity from '../core/Entity';
import Grid from '../gameutil/Grid';


/**
 * A blueprint for the layout of parts on a ship
 */
export default class Blueprint extends Entity {
  /**
   * Create a nee Blueprint.
   * @param x
   * @param y
   */
  constructor([x, y] = [0, 0]) {
    super();
    this.sprite = new Pixi.Graphics();
    this.layer = 'world';
    this.parts = [];
    this.partGrid = new Grid();
    this.core = this.addPart(new Core([0, 0]));
  }

  /**
   * Add a Part to this blueprint
   * @param part {Part}
   * @returns {Part} - the part added
   */
  addPart(part) {
    this.parts.push(part);
    if ((part.sprite != null)) {
      this.sprite.addChild(part.sprite);
    }

    this.partGrid.set([part.x, part.y], part);
    return part;
  }

  /**
   * Take a part off this blueprint
   * @param part {Part}
   * @returns {Part} - the part removed
   */
  removePart(part) {
    this.parts.splice(this.parts.indexOf(part), 1);
    if ((part.sprite != null)) {
      this.sprite.removeChild(part.sprite);
    }
    this.partGrid.remove([part.x, part.y]);
    return part;
  }

  /**
   * Returns true if this blueprint would make a valid ship.
   * @returns {boolean}
   */
  isValid() {
    const connected = new Set();

    const queue = [this.core];
    while (queue.length) {
      const current = queue.pop();
      connected.add(current);
      const [x, y] = current.position;
      [[x + 1, y], [x, y + 1], [x - 1, y], [x, y - 1]].forEach((adjacentPoint)=> {
        const adjacentPart = this.partGrid.get(adjacentPoint);
        if ((typeof adjacentPart !== "undefined" && adjacentPart !== null) && !connected.has(adjacentPart)) {
          queue.push(adjacentPart);
        }
      });
    }
    for (var j = 0; j < this.parts.length; j++) {
      if (!connected.has(this.parts[j])) {
        return false;
      }
    }
    return true;
  }
}
