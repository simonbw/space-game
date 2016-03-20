import Entity from '../core/Entity';


/**
 * Moves the camera around.
 * @extends Entity
 */
export default class CameraController extends Entity {
  /**
   * Create a new camera controller.
   * @param camera {Camera}
   * @param person {Person}
   */
  constructor(camera, person) {
    super();
    this.camera = camera;
    this.person = person;
  }

  /**
   * Called before rendering
   */
  render() {
    var pos;
    var vel;
    var zoom;
    if (this.person.chair) {
      pos = this.person.chair.ship.position;
      vel = this.person.chair.ship.body.velocity;
      zoom = 15;
    } else {
      pos = this.person.position;
      vel = this.person.body.velocity;
      zoom = 30;
    }
    this.camera.smoothCenter(pos, vel);
    this.camera.smoothZoom(zoom);
  }
}
