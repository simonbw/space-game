/**
 * Base class for lots of stuff in the game
 */
export default class Entity {
  constructor() {
    /**
     * The game this entity belongs to.
     * @type {Game}
     */
    this.game = null;
    /**
     * @type {Pixi.DisplayObject}
     */
    this.sprite = null;
    /**
     * @type {p2.Body}
     */
    this.body = null;
    /**
     * @type {string}
     */
    this.layer = null;

    // bind all event handlers
    if (this.onClick) {
      /**
       * Called when the mouse is clicked.
       * @method
       */
      this.onClick = this.onClick.bind(this);
    }
    if (this.onMouseDown) {
      /**
       * Called when a mouse button is pressed.
       * @type {function}
       */
      this.onMouseDown = this.onMouseDown.bind(this);
    }
    if (this.onMouseUp) {
      /**
       * Called when a mouse button is released.
       * @type {function}
       */
      this.onMouseUp = this.onMouseUp.bind(this);
    }
    if (this.onRightClick) {
      /**
       * Called when the right mouse button is clicked.
       * @type {function}
       */
      this.onRightClick = this.onRightClick.bind(this);
    }
    if (this.onRightDown) {
      /**
       * Called when the right mouse button is pressed.
       * @type {function}
       */
      this.onRightDown = this.onRightDown.bind(this);
    }
    if (this.onRightUp) {
      /**
       * Called when the right mouse button is released.
       * @type {function}
       */
      this.onRightUp = this.onRightUp.bind(this);
    }
    if (this.onKeyDown) {
      /**
       * Called when a key is pressed.
       * @type {function}
       */
      this.onKeyDown = this.onKeyDown.bind(this);
    }
    if (this.onKeyUp) {
      /**
       * Called when a key is released.
       * @type {function}
       */
      this.onKeyUp = this.onKeyUp.bind(this);
    }
    if (this.onButtonDown) {
      /**
       * Called when a gamepad button is pressed.
       * @type {function}
       */
      this.onButtonDown = this.onButtonDown.bind(this);
    }
    if (this.onButtonUp) {
      /**
       * Called when a gamepad button is released.
       * @type {function}
       */
      this.onButtonUp = this.onButtonUp.bind(this);
    }
  }

  destroy() {
    return this.game.removeEntity(this);
  }
}

/**
 * Called when added to the game.
 * @type {function}
 */
Entity.prototype.added = null;
/**
 * Called right after being added to the game.
 * @type {function}
 */
Entity.prototype.afterAdded = null;
/**
 * Called after the tick happens.
 * @type {function}
 */
Entity.prototype.afterTick = null;
/**
 * Called before the tick happens.
 * @type {function}
 */
Entity.prototype.beforeTick = null;
/**
 * Called before rendering
 * @type {function}
 */
Entity.prototype.render = null;
/**
 * Called during the game's update tick.
 * @type {function}
 */
Entity.prototype.tick = null;
/**
 * Called after being destroyed.
 * @type {function}
 */
Entity.prototype.destroyed = null;
