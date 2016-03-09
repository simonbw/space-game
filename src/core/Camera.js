import { Matrix, Point } from 'pixi.js';

import Entity from './Entity';


/**
 * Controls the viewport.
 * @extends Entity
 */
export default class Camera extends Entity {
  constructor(renderer, position = [0, 0], z = 25.0, angle = 0) {
    super();
    this.renderer = renderer;
    this.position = position;
    this.z = z;
    this.angle = angle;
    this.velocity = [0, 0];
  }

  get x() {
    return this.position[0];
  }

  set x(value) {
    return this.position[0] = value;
  }

  get y() {
    return this.position[1];
  }

  set y(value) {
    return this.position[1] = value;
  }

  get vx() {
    return this.velocity[0];
  }

  set vx(value) {
    return this.velocity[0] = value;
  }

  get vy() {
    return this.velocity[1];
  }

  set vy(value) {
    return this.velocity[1] = value;
  }

  /**
   * Called before rendering.
   */
  render() {
    this.x += this.vx * this.game.timestep;
    this.y += this.vy * this.game.timestep;
  }

  /**
   * Center the camera on a position
   * @param x {number}
   * @param y {number}
   */
  center([x, y]) {
    this.x = x;
    this.y = y;
  }

  /**
   * Move the camera toward being centered on a position, with a target velocity
   * @param x {number}
   * @param y {number}
   * @param vx {number}
   * @param vy {number}
   * @param smooth {number}
   */
  smoothCenter([x, y], [vx, vy], smooth = 0.9) {
    // TODO: make velocity transition smooth
    const dx = (x - this.x) * this.game.framerate;
    const dy = (y - this.y) * this.game.framerate;
    this.vx = vx + (1 - smooth) * dx;
    this.vy = vy + (1 - smooth) * dy;
  }

  /**
   * Move the camera part of the way to the desired zoom.
   * @param z {number}
   * @param smooth {number}
   */
  smoothZoom(z, smooth = 0.9) {
    this.z = smooth * this.z + (1 - smooth) * z;
  }

  /**
   * Returns [width, height] of the viewport
   * @returns {Array.<number>}
   */
  getViewportSize() {
    return [
      this.renderer.pixiRenderer.width / this.renderer.pixiRenderer.resolution,
      this.renderer.pixiRenderer.height / this.renderer.pixiRenderer.resolution];
  }

  /**
   * Convert screen coordinates to world coordinates
   * @param x {number}
   * @param y {number}
   * @param depth {number}
   * @returns {Array.<number>}
   */
  toWorld([x, y], depth = 1.0) {
    var p = new Point(x, y);
    p = this.getMatrix(depth).applyInverse(p, p);
    return [p.x, p.y];
  }

  /**
   * Convert world coordinates to screen coordinates
   * @param x {number}
   * @param y {number}
   * @param depth {number}
   * @returns {Array.<number>}
   */
  toScreen([x, y], depth = 1.0) {
    var p = new Point(x, y);
    p = this.getMatrix(depth).apply(p, p);
    return [p.x, p.y];
  }

  /**
   * Creates a transformation matrix to go from screen world space to screen space.
   * @param depth {number}
   * @returns {Matrix}
   */
  getMatrix(depth = 1.0) {
    const [w, h] = this.getViewportSize();
    const m = new Matrix();
    m.translate(-this.x * depth, -this.y * depth);
    m.scale(this.z * depth, this.z * depth);
    m.rotate(this.angle);
    m.translate(w / 2, h / 2);
    return m;
  }

  /**
   * Update the properties of a renderer layer to match this camera
   * @param layerInfo {Object}
   */
  updateLayer(layerInfo) {
    const scroll = layerInfo.scroll;
    if (scroll !== 0) {
      const layer = layerInfo.layer;
      [layer.x, layer.y] = this.toScreen([0, 0]);
      layer.rotation = this.angle;
      layer.scale.set(this.z, this.z);
    }
  }
}
