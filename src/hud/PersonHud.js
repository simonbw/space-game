import * as Pixi from 'pixi.js';

import Entity from '../core/Entity';
import InteractionListSprite from './InteractionListSprite'


/**
 * The heads up display that provides information about a person.
 * @extends Entity
 */
export default class PersonHud extends Entity {
  /**
   * Create a new PersonHud.
   * @param person {Person} - The person to display information about
   */
  constructor(person) {
    super();
    this.person = person;
    this.sprite = new Pixi.Container();
    this.layer = 'hud';
    this.text = new Pixi.Text('', {
      font: '14px Arial',
      fill: '#FFFFFF'
    });
    this.sprite.addChild(this.text);
    this.interactionList = new InteractionListSprite(this.person);
  }

  /**
   * Called when added to the game.
   * @returns {Entity}
   */
  added() {
    return this.game.addEntity(this.interactionList);
  }

  /**
   *  Make the string to be displayed by the hud
   * @returns {string}
   */
  makeText() {
    const velocity = this.person.body.velocity;
    const xspeed = Math.round(velocity[0] * 10);
    const yspeed = Math.round(velocity[1] * 10);

    const pressure = Math.round(100 * this.person.getPressure());
    return `pressure: ${pressure}, velocity: <${xspeed}, ${yspeed}>`;
  }

  /**
   * Called before rendering.
   * @returns {string}
   */
  render() {
    this.interactionList.person = this.person;
    this.text.text = this.makeText();
  }

  /**
   * Destroy this instance.
   */
  destroy() {
    this.interactionList.destroy();
    super.destroy();
  }
}
