import p2 from 'p2';

import GameRenderer from '../core/GameRenderer';
import {IOManager, IOEvents} from './IO';

import Entity from './Entity';

// Top Level control structure
/**
 * Top level control structure.
 */
export default class Game {
  /**
   * Create a new Game.
   */
  constructor() {
    /**
     * @type {{all: Array.<Entity>, render: Array.<Entity>, tick: Array.<Entity>, beforeTick: Array.<Entity>, afterTick: Array.<Entity>, toRemove: Array.<Entity>}}
     */
    this.entities = {
      all: [],
      render: [],
      tick: [],
      beforeTick: [],
      afterTick: [],
      toRemove: []
    };
    this.renderer = new GameRenderer();
    this.camera = this.renderer.camera;
    this.world = new p2.World({
      gravity: [0, 0]
    });
    this.world.on('beginContact', this.beginContact.bind(this));
    this.world.on('endContact', this.endContact.bind(this));
    this.world.on('impact', this.endContact.bind(this));
    this.io = new IOManager(this.renderer.pixiRenderer.view);

    this.framerate = 60;
  }

  /**
   * @returns {number} - Number of seconds per frame.
   */
  get timestep() {
    return 1 / this.framerate;
  }

  /**
   * Start the event loop for the game.
   */
  start() {
    this.addEntity(this.camera);
    window.requestAnimationFrame(() => this.loop());
  }

  /**
   * The main event loop. Run one frame of the game.
   */
  loop() {
    window.requestAnimationFrame(() => this.loop());
    this.tick();
    this.world.step(this.timestep);
    this.afterTick();
    this.render();
  }

  /**
   * Add an entity to the game.
   * @param entity {Entity} - The entity to add.
   * @returns {Entity} - the entity added
   */
  addEntity(entity) {
    entity.game = this;
    if (entity.added) {
      entity.added(this);
    }
    this.entities.all.push(entity);
    if (entity.render) {
      this.entities.render.push(entity);
    }
    if (entity.beforeTick) {
      this.entities.beforeTick.push(entity);
    }
    if (entity.tick) {
      this.entities.tick.push(entity);
    }
    if (entity.afterTick) {
      this.entities.afterTick.push(entity);
    }
    if (entity.sprite) {
      if (entity.layer)
        this.renderer.add(entity.sprite, entity.layer);
      else
        this.renderer.add(entity.sprite);
    }
    if (entity.body) {
      this.world.addBody(entity.body);
    }

    if (entity.onClick) {
      this.io.on(IOEvents.CLICK, entity.onClick);
    }
    if (entity.onMouseDown) {
      this.io.on(IOEvents.MOUSE_DOWN, entity.onMouseDown);
    }
    if (entity.onMouseUp) {
      this.io.on(IOEvents.MOUSE_UP, entity.onMouseUp);
    }
    if (entity.onRightClick) {
      this.io.on(IOEvents.RIGHT_CLICK, entity.onRightClick);
    }
    if (entity.onRightDown) {
      this.io.on(IOEvents.RIGHT_DOWN, entity.onRightDown);
    }
    if (entity.onRightUp) {
      this.io.on(IOEvents.RIGHT_UP, entity.onRightUp);
    }
    if (entity.onKeyDown) {
      this.io.on(IOEvents.KEY_DOWN, entity.onKeyDown);
    }
    if (entity.onKeyUp) {
      this.io.on(IOEvents.KEY_UP, entity.onKeyUp);
    }
    if (entity.onButtonDown) {
      this.io.on(IOEvents.BUTTON_DOWN, entity.onButtonDown);
    }
    if (entity.onButtonUp) {
      this.io.on(IOEvents.BUTTON_UP, entity.onButtonUp);
    }

    if (entity.afterAdded) {
      entity.afterAdded(this);
    }
    return entity;
  }

  /**
   * Remove an entity from the game.
   * The entity will actually be removed during the next removal pass.
   *
   * TODO: Why is there a separate pass?
   *
   * @param entity {Entity}
   * @returns {Entity} - The entity removed
   */
  removeEntity(entity) {
    this.entities.toRemove.push(entity);
    return entity;
  }

  /**
   * Actually remove all the entities slated for removal from the game.
   */
  cleanupEntities() {
    while (this.entities.toRemove.length) {
      const entity = this.entities.toRemove.pop();
      this.entities.all.splice(this.entities.all.indexOf(entity), 1);
      if (entity.render) {
        this.entities.render.splice(this.entities.render.indexOf(entity), 1);
      }
      if (entity.tick) {
        this.entities.tick.splice(this.entities.tick.indexOf(entity), 1);
      }
      if (entity.afterTick) {
        this.entities.afterTick.splice(this.entities.afterTick.indexOf(entity), 1);
      }

      if (entity.sprite) {
        this.renderer.remove(entity.sprite, entity.layer);
      }
      if (entity.body) {
        this.world.removeBody(entity.body);
      }

      if (entity.onClick) {
        this.io.off(IOEvents.CLICK, entity.onClick);
      }
      if (entity.onMouseDown) {
        this.io.off(IOEvents.MOUSE_DOWN, entity.onMouseDown);
      }
      if (entity.onMouseUp) {
        this.io.off(IOEvents.MOUSE_UP, entity.onMouseUp);
      }
      if (entity.onRightClick) {
        this.io.off(IOEvents.RIGHT_CLICK, entity.onRightClick);
      }
      if (entity.onRightDown) {
        this.io.off(IOEvents.RIGHT_DOWN, entity.onRightDown);
      }
      if (entity.onRightUp) {
        this.io.off(IOEvents.RIGHT_UP, entity.onRightUp);
      }
      if (entity.onKeyDown) {
        this.io.off(IOEvents.KEY_DOWN, entity.onKeyDown);
      }
      if (entity.onKeyUp) {
        this.io.off(IOEvents.KEY_UP, entity.onKeyUp);
      }
      if (entity.onButtonDown) {
        this.io.off(IOEvents.BUTTON_DOWN, entity.onButtonDown);
      }
      if (entity.onButtonUp) {
        this.io.off(IOEvents.BUTTON_UP, entity.onButtonUp);
      }

      if (entity.destroyed) {
        entity.destroyed(this);
      }
    }
  }

  /**
   * Called before physics.
   */
  tick() {
    this.cleanupEntities();
    this.entities.beforeTick.forEach((entity) => entity.beforeTick());
    this.cleanupEntities();
    this.entities.tick.forEach((entity) => entity.tick());
  }

  /**
   * Called after physics.
   */
  afterTick() {
    this.cleanupEntities();
    this.entities.afterTick.forEach((entity) => entity.afterTick());
  }

  /**
   * Called before actually rendering.
   */
  render() {
    this.cleanupEntities();
    this.entities.render.forEach((entity) => entity.render());
    this.renderer.render();
  }

  /**
   * Handle beginning of collision between things.
   * Fired during narrowphase.
   * @param e {{bodyA: p2.Body, bodyB: p2.Body, shapeA: p2.Shape, shapeB: p2.Shape}}
   */
  beginContact(e) {
    if (e.bodyA.beginContact) {
      e.bodyA.beginContact(e.bodyB);
    }
    if (e.bodyB.beginContact) {
      e.bodyB.beginContact(e.bodyA);
    }

    if (e.shapeA.beginContact) {
      e.shapeA.beginContact(e.shapeB);
    }
    if (e.shapeB.beginContact) {
      e.shapeB.beginContact(e.shapeA);
    }
  }

  /**
   * Handle end of collision between things.
   * Fired during narrowphase.
   * @param e {{bodyA: p2.Body, bodyB: p2.Body, shapeA: p2.Shape, shapeB: p2.Shape}}
   */
  endContact(e) {
    if (e.bodyA.endContact) {
      e.bodyA.endContact(e.bodyB);
    }
    if (e.bodyB.endContact) {
      e.bodyB.endContact(e.bodyA);
    }

    if (e.shapeA.endContact) {
      e.shapeA.endContact(e.shapeB);
    }
    if (e.shapeB.endContact) {
      return e.shapeB.endContact(e.shapeA);
    }
  }

  /**
   * Handle collision between things.
   * Fired after physics step.
   * @param e {{bodyA: p2.Body, bodyB: p2.Body}}
   */
  impact(e) {
    if (e.bodyA.impact) {
      e.bodyA.impact(e.bodyB);
    }
    if (e.bodyB.impact) {
      return e.bodyB.impact(e.bodyA);
    }
  }
}
