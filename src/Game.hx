import ai.StabilizeShipController;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

import nape.geom.Vec2;
import nape.space.Space;

import ai.PlayerShipController;
import obstacles.Asteroid;
import ship.PrebuiltShips;
import ship.Ship;
import util.MyMath;
import util.Profiler;
import util.Random;

/**
 * The top level control structure for the game.
 */
class Game extends Sprite {
    /** The maximum allowed duration of a single time step */
    static inline var MAX_TIMESTEP = 1/15.0;

    public var profiler:Profiler;
	
	var FOLLOWING:Bool;

    /** The bitmap object that gets drawn to the screen */
    var bitmap:Bitmap;
    /** The main rendering layer */
    var surface:BitmapData;

    public var space:Space;

	var entities:Array<Entity>;
	var updatables:Array<Updatable>;
	var updatables2:Array<Updatable2>;
	var entitiesToRemove:Array<Entity>;
    var ship:Ship;
    var shipController:PlayerShipController;
    var stars:effects.Stars;
    var camera:Camera;

    /**
     * Create a new Game.
     */
    public function new() {
        super();

        profiler = new Profiler();
		FOLLOWING = true;
    }

    /**
     * Call to start the game.
     */
    public function init():Void {
        bitmap = new Bitmap();
        createLayers();
        addChild(bitmap);

		entities = new Array<Entity>();
		entitiesToRemove = new Array<Entity>();
		updatables = new Array<Updatable>();
		updatables2 = new Array<Updatable2>();
		
        space = new Space();
		space.worldLinearDrag = 0;
		space.worldAngularDrag = 0;
        stars = new effects.Stars();
		ship = new Ship(Vec2.get(200, 200));
		shipController = new PlayerShipController(ship);
		addEntity(shipController);
		addEntity(ship);
		if (Random.bool(0.5)) {
			PrebuiltShips.makeFreighter(ship);
		} else if (Random.bool(0.95)){
			PrebuiltShips.makeXWing(ship);
		} else {
			PrebuiltShips.makeRam(ship);
		}
        camera = new Camera();
		
		// initialize modules
		Physics.init(space);

			
        // register event handlers
        flash.Lib.current.addChild(this);
        flash.Lib.current.addEventListener(Event.ENTER_FRAME, update);

        IO.addKeyDownCallback(IO.K_ASTEROID, function():Void {
            try {
                var p = camera.screenToWorld(IO.mousePos);
                // Main.log("Camera at " + camera.position + " mapping: " + IO.mousePos + " => " + "(" + p.x + "," + p.y +")");
                // var asteroid = Asteroid.newRandom(p, space);
                //asteroid.body.applyImpulse(Vec2.get(10000, 0, true));
                // addEntity(asteroid);

				var ship2 = new Ship(p);
				addEntity(ship2);
				if (Random.bool(0.4)) {
					PrebuiltShips.makeFreighter(ship2);
				} else if (Random.bool(0.4)) {
					PrebuiltShips.makeXWing(ship2);
				} else {
					PrebuiltShips.makeCruiser(ship2);
				}
				addEntity(new StabilizeShipController(ship2));
            } catch(error:Dynamic) {
                Main.log(error);
            }
        });
		
		IO.addKeyDownCallback(IO.K_CAMERA_LOCK, function ():Void {
			FOLLOWING = !FOLLOWING;
		});
		
		IO.addKeyDownCallback(IO.K_FULLSCREEN, toggleFullscreen);
    }
	
	public function toggleFullscreen():Void {
		Main.log("toggling fullscreen");

		try {
			if (Lib.current.stage.displayState == StageDisplayState.NORMAL) {
				Lib.current.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				IO.hideMouse();
			} else {
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
				IO.hideMouse();
			}
			createLayers();
		} catch (error:Dynamic) {
			Main.log(error);
		}
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;
	}
	
    /**
     * Create the bitmapdata layers. Call this if the screen size changes.
     */
    public function createLayers(): Void {
		var w:Int;
		var h:Int;
		if (Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN || Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
			w = Lib.current.stage.fullScreenWidth;
			h = Lib.current.stage.fullScreenHeight;
		} else {
			w = Lib.current.stage.stageWidth;
			h = Lib.current.stage.stageHeight;
		}
        surface = new BitmapData(w, h, false, 0x00000000);
		if (bitmap.bitmapData != null) {
			bitmap.bitmapData.dispose();
		}
        bitmap.bitmapData = surface;
    }
	
	public function addEntity(entity:Entity):Void {
		try {
			entities.push(entity);
			entity.init(this);
			if (Std.is(entity, Updatable)) {
				updatables.push(cast(entity, Updatable));
			}
			if (Std.is(entity, Updatable2)) {
				updatables2.push(cast(entity, Updatable2));
			}
		} catch(error:Dynamic) {
			trace("Failed to add entity:" + entity + error);
		}
	}
	
	public function removeEntity(entity:Entity):Void {
		entitiesToRemove.push(entity);
	}

	inline function removeEntityTrue(entity:Entity):Void {
		entities.remove(entity);
		if (Std.is(entity, Updatable)) {
			updatables.remove(cast(entity, Updatable));
		}
		if (Std.is(entity, Updatable2)) {
			updatables2.remove(cast(entity, Updatable2));
		}
	}

	/**
	 * Called every frame.
	 * @param  e 
	 */
    public function update(e:Event = null):Void {
		var timestep = 1 / stage.frameRate;
		
		for (entity in updatables) {
			try {
				entity.update(timestep);
			} catch(error:Dynamic) {
				Main.log("Updating " + entity + "failed: " + error);
			}
		}
		
		// pre-physics removal pass
		for (entity in entitiesToRemove) {
			removeEntityTrue(entity);
		}
		entitiesToRemove.splice(0, entitiesToRemove.length);
		
		try {
			space.step(timestep);
		} catch (error:Dynamic) {
			Main.log("Physics Error: " + error);
		}

		// post-physics removal pass
		for (entity in entitiesToRemove) {
			removeEntityTrue(entity);
		}
		entitiesToRemove.splice(0, entitiesToRemove.length);

		// post physics updates
		for (entity in updatables2) {
			try {
				entity.update2(timestep);
			} catch(error:Dynamic) {
				Main.log("Updating2 " + entity + "failed: " + error);
			}
		}
		
		// pre-render removal pass
		for (entity in entitiesToRemove) {
			removeEntityTrue(entity);
		}
		entitiesToRemove.splice(0, entitiesToRemove.length);

		// Camera Control should be done elsewhere
		if (FOLLOWING) {
			camera.smoothCenter(ship.body.position, 0.5);
		}
		//camera.angle = Math.PI - ship.body.rotation;
		if (IO.keys[IO.K_ZOOM_IN]) {
			camera.zoom *= 1.01;
		}
		if (IO.keys[IO.K_ZOOM_OUT]) {
			camera.zoom *= 0.99;
		}

		Main.log2("speed: " + Std.int(ship.body.velocity.length), 0);
		Main.log2("energy: " + Std.int(ship.energy) + "/" + Std.int(ship.maxEnergy), 1);
		Main.log2("shields: " + Std.int(ship.shield) + "/" + Std.int(ship.maxShield), 2);
		Main.log2("bodies: " + space.bodies.length, 3);
		profiler.update();
        render(e);
    }

    /**
     * Render everything to the screen.
     */
    public function render(e: Event = null):Void {
		try {
			surface.fillRect(surface.rect, 0x000000);
			stars.render(surface, camera);
			for (entity in entities) {
				if (Std.is(entity, Renderable) && !entity.disposed) {
					try {
						cast(entity, Renderable).render(surface, camera);
					} catch (error: Dynamic) {
						Main.log("Render Failed:" + entity + " " + error);
					}
				}
			}
		} catch (error: Dynamic) {
			Main.log("Render Error:" + error);
		}
		profiler.render(surface);
	}
}