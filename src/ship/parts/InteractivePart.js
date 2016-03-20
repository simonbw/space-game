import * as p2 from 'p2';

import Part from "./Part";
import * as CollisionGroups from '../../CollisionGroups';

/**
 * Abstract class for parts that can be interacted with by persons.
 * @extends Part
 */
export default class InteractivePart extends Part {
  /**
   * Create a new InteractivePart.
   * @param position {Array.<number>}
   */
  constructor(position) {
    super(position);
    this.sensor = this.makeSensor();
    this.sensor.owner = this;
  }

  /**
   * @returns {p2.Shape}
   */
  makeSensor() {
    const shape = new p2.Box(this.getSensorSize());
    shape.sensor = true;
    shape.collisionGroup = CollisionGroups.SHIP_SENSOR;
    shape.collisionMask = CollisionGroups.PERSON;
    return shape;
  }

  /**
   * @returns {{width: number, height: number}}
   */
  getSensorSize() {
    return {
      width: this.width + 0.5,
      height: this.height + 0.5
    };
  }

  /**
   * Called when a person interacts with this.
   * @param person
   * @returns {*}
   */
  interact(person) {
    return console.log("interacted");
  }
}

InteractivePart.prototype.interactive = true;
InteractivePart.prototype.name = "Interactive Part";
