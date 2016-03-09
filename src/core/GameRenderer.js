import * as Pixi from 'pixi.js';

import Camera from './Camera';


/**
 * The base renderer. Handles layers and camera movement.
 */
export default class GameRenderer {

  /**
   * Create a new GameRenderer
   */
  constructor() {
    PIXI.RESOLUTION = window.devicePixelRatio || 1;
    const [w, h] = [window.innerWidth, window.innerHeight];
    this.pixiRenderer = Pixi.autoDetectRenderer(w, h, {
      antialias: false,
      resolution: PIXI.RESOLUTION
    });
    document.body.appendChild(this.pixiRenderer.view);
    this.stage = new Pixi.Container();
    this.camera = new Camera(this);

    this.layerInfos = {
      menu: {scroll: 0},
      hud: {scroll: 0},
      world_overlay: {scroll: 1},
      world_front: {scroll: 1},
      world: {scroll: 1},
      world_back: {scroll: 1}
    };

    const order = ['world_back', 'world', 'world_front', 'world_overlay', 'hud', 'menu'];
    order.forEach(function (name, i) {
      const layerInfo = this.layerInfos[name];
      layerInfo.name = name;
      const layer = new Pixi.Container();
      layerInfo.index = i;
      layerInfo.layer = layer;
      this.stage.addChildAt(layer, i);
    }.bind(this));
  }

  /**
   * Render the current frame.
   */
  render() {
    Object.keys(this.layerInfos).forEach((name) => {
      this.camera.updateLayer(this.layerInfos[name]);
    });
    this.pixiRenderer.render(this.stage);
  }

  /**
   * Add a child to a specific layer.
   * @param sprite {Pixi.DisplayObject}
   * @param layer {string}
   * @returns {Pixi.DisplayObject}
   */
  add(sprite, layer = 'world') {
    this.layerInfos[layer.toLowerCase()].layer.addChild(sprite);
  }

  /**
   * Remove a child from a specific layer.
   * @param sprite {Pixi.DisplayObject}
   * @param layer {string}
   * @returns {Pixi.DisplayObject}
   */
  remove(sprite, layer = 'world') {
    this.layerInfos[layer.toLowerCase()].layer.removeChild(sprite);
  }
}
