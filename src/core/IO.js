import * as GamepadAxes from './constants/GamepadAxes';
import * as GamepadButtons from './constants/GamepadButtons';
import * as Keys from './constants/Keys';
import * as MouseButtons from './constants/MouseButtons';

export const IOEvents = {
  BUTTON_DOWN: 'buttondown',
  BUTTON_UP: 'buttonup',
  CLICK: 'click',
  KEY_DOWN: 'keydown',
  KEY_UP: 'keyup',
  MOUSE_DOWN: 'mousedown',
  MOUSE_MOVE: 'mousemove',
  MOUSE_UP: 'mouseup',
  RIGHT_CLICK: 'rightclick',
  RIGHT_DOWN: 'rightdown',
  RIGHT_UP: 'rightup'
};

/**
 * Manages IO
 */
export class IOManager {
  /**
   *
   * @param view
   */
  constructor(view) {
    this.view = view;
    this.usingGamepad = false; // True if the gamepad is the main input device
    this.mousePosition = [0, 0];

    /**
     * @type {Array.<boolean>}
     */
    this.mouseButtons = [false, false, false, false, false, false];

    this.view.onclick = this.onClick.bind(this);
    this.view.onmousedown = this.onMouseDown.bind(this);
    this.view.onmouseup = this.onMouseUp.bind(this);
    this.view.onmousemove = this.onMouseMove.bind(this);
    document.onkeydown = this.onKeyDown.bind(this);
    document.onkeyup = this.onKeyUp.bind(this);
    this.view.oncontextmenu = (e) => {
      e.preventDefault();
      this.onClick(e);
      return false;
    };

    this.keys = [];
    for (var i = 0; i <= 256; i++) {
      this.keys.push(false);
    }

    this.callbacks = {};
    Object.values(IOEvents).forEach((eventName) => {
      this.callbacks[eventName] = [];
    });

    this.lastButtons = []; // buttons pressed last frame. Used for checking differences in state.
    setInterval(() => this.handleGamepads(), 1);
  }

  /**
   * True if the left mouse button is down.
   * @returns {boolean}
   */
  get lmb() {
    return this.mouseButtons[MouseButtons.LEFT];
  }

  /**
   * True if the middle mouse button is down.
   * @returns {boolean}
   */
  get mmb() {
    return this.mouseButtons[MouseButtons.MIDDLE];
  }

  /**
   * True if the right mouse button is down.
   * @returns {boolean}
   */
  get rmb() {
    return this.mouseButtons[MouseButtons.RIGHT];
  }

  /**
   * Fire events for gamepad button presses.
   */
  handleGamepads() {
    const gamepad = navigator.getGamepads()[0];
    if (gamepad) {
      const buttons = gamepad.buttons.map((button) => button.pressed);

      buttons.forEach((button, i) => {
        if (button && !this.lastButtons[i]) {
          this.usingGamepad = true;
          this.callbacks[IOEvents.BUTTON_DOWN].forEach((callback) => callback(i));
        } else if (!button && this.lastButtons[i]) {
          this.callbacks[IOEvents.BUTTON_UP].forEach((callback) => callback(i));
        }
      });
      this.lastButtons = buttons;
    } else {
      this.lastButtons = [];
    }
  }

  /**
   * Add an event handler.
   * @param eventName {string}
   * @param callback {function}
   */
  on(eventName, callback) {
    if (!this.callbacks.hasOwnProperty(eventName)) {
      throw new Error(`Unknown IO event: ${eventName}`);
    }
    this.callbacks[eventName].push(callback);
  }

  /**
   * Add an event handler.
   * @param eventName {string}
   * @param callback {function}
   */
  off(eventName, callback) {
    if (!this.callbacks.hasOwnProperty(eventName)) {
      throw new Error(`Unknown IO event: ${eventName}`);
    }
    this.callbacks[eventName].splice(this.callbacks[eventName].indexOf(callback), 1);
  }

  /**
   * Update the position of the mouse.
   * @param event {MouseEvent}
   */
  onMouseMove(event) {
    this.usingGamepad = false;
    this.mousePosition = [event.clientX, event.clientY];
    this.callbacks[IOEvents.MOUSE_MOVE].forEach((callback) => callback());
  }

  /**
   * Fire all click handlers.
   * @param event {MouseEvent}
   */
  onClick(event) {
    this.usingGamepad = false;
    this.mousePosition = [event.clientX, event.clientY];
    switch (event.button) {
      case MouseButtons.LEFT:
        this.callbacks[IOEvents.CLICK].forEach((callback) => callback());
        break;
      case MouseButtons.RIGHT:
        this.callbacks[IOEvents.RIGHT_CLICK].forEach((callback) => callback());
        break;
    }
  }

  /**
   * Fire all mouse down handlers.
   * @param event {MouseEvent}
   */
  onMouseDown(event) {
    this.usingGamepad = false;
    this.mousePosition = [event.clientX, event.clientY];
    this.mouseButtons[event.button] = true;
    switch (event.button) {
      case MouseButtons.LEFT:
        this.callbacks[IOEvents.MOUSE_DOWN].forEach((callback) => callback());
        break;
      case MouseButtons.RIGHT:
        this.callbacks[IOEvents.RIGHT_DOWN].forEach((callback) => callback());
        break;
    }
  }

  /**
   * Fire all mouse up handlers
   * @param event {MouseEvent}
   */
  onMouseUp(event) {
    this.usingGamepad = false;
    this.mousePosition = [event.clientX, event.clientY];
    this.mouseButtons[event.button] = false;
    switch (event.button) {
      case MouseButtons.LEFT:
        this.callbacks[IOEvents.MOUSE_UP].forEach((callback) => callback());
        break;
      case MouseButtons.RIGHT:
        this.callbacks[IOEvents.RIGHT_UP].forEach((callback) => callback());
        break;
    }
  }

  /**
   * Determine whether or not to prevent the default action of a key press.
   * @param key {number}
   * @returns {boolean}
   */
  shouldPreventDefault(key) {
    if (key === Keys.TAB) {
      return true;
    }
    if (key === 83) { // s for save
      return true;
    }
    return false;
  }

  /**
   * Fire all key down handlers.
   * @param event {KeyboardEvent}
   */
  onKeyDown(event) {
    const key = event.which;
    const wasPressed = this.keys[key];
    this.keys[key] = true;
    if (!wasPressed) {
      this.callbacks[IOEvents.KEY_DOWN].forEach((callback) => callback(key));
    }
    if (this.shouldPreventDefault(key)) {
      event.preventDefault();
      return false;
    }
  }

  /**
   * Fire all key up handlers.
   * @param event {KeyboardEvent}
   */
  onKeyUp(event) {
    const key = /**@type{number}*/ event.which;
    this.keys[key] = false;
    this.callbacks[IOEvents.KEY_UP].forEach((callback) => callback());
    if (this.shouldPreventDefault(key)) {
      event.preventDefault();
      return false;
    }
  }

  /**
   * Return the value of a gamepad axis.
   * @param axis {number}
   * @param threshold {number}
   * @returns {number}
   */
  getAxis(axis, threshold = 0.1) {
    const gamepad = navigator.getGamepads()[0];
    if (gamepad) {
      axis = gamepad.axes[axis];
      if (Math.abs(axis) > threshold) {
        this.usingGamepad = true;
      }
      return axis;
    }
    return 0;
  }

  /**
   * Return the value of a button.
   * @param button {number}
   * @returns {number}
   */
  getButton(button) {
    const gamepad = navigator.getGamepads()[0];
    if (gamepad) {
      return gamepad.buttons[button];
    }
    return 0;
  }
}
