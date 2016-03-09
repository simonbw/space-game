import * as Pixi from 'pixi.js';

import Entity from '../core/Entity';


const HEIGHT = 15;
const BIG_SIZE = 16;
const SMALL_SIZE = 12;

/**
 * Displays possible interactions of a player.
 * @extends Entity
 */
export default class InteractionListSprite extends Entity {
  /**
   * Create a new InteractionListSprite
   * @param person {Person}
   */
  constructor(person) {
    super();
    this.person = person;
    this.makeTextBox = this.makeTextBox.bind(this);
    this.render = this.render.bind(this);
    this.sprite = new Pixi.Container();
    this.layer = 'hud';
    this.texts = [];
  }

  /**
   * Create a new textbox for rendering in.
   */
  makeTextBox() {
    const size = this.texts.length === 0 ? BIG_SIZE : SMALL_SIZE;
    const text = new Pixi.Text('', {
      font: `${size}px Arial`,
      fill: '#FFFFFF'
    });
    text.y = this.texts.length * HEIGHT;
    this.texts.push(text);
    this.sprite.addChild(text);
    console.log(`New new textbox ${this.texts.length}, ${text.resolution}`);
  }

  /**
   * Called before rendering.
   */
  render() {
    // make sure there are the right number of text boxes
    while (this.texts.length > this.person.interactions.length) {
      this.sprite.removeChild(this.texts.pop());
    }
    while (this.texts.length < this.person.interactions.length) {
      this.makeTextBox();
    }

    this.person.interactions.forEach((part, i) => this.texts[i].text = `${part.name}`);

    const [x, y] = this.game.camera.toScreen(this.person.position);
    this.sprite.x = x + 20;
    this.sprite.y = y - this.texts.length * HEIGHT / 2;
  }
}