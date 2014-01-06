import ai.StabilizeShipController;
import flash.display.Sprite;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;
import util.MyMath;
import util.Random;

import nape.space.Space;
import nape.geom.Vec2;

import ship.Ship;
import ai.PlayerShipController;
import obstacles.Asteroid;

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
	var entitiesToRemove:Array<Entity>;
    var ship:Ship;
    var shipController:PlayerShipController;
    var stars:Stars;
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
		
        space = new Space();
		space.worldLinearDrag = 0;
		space.worldAngularDrag = 0;
        stars = new Stars();
		ship = new Ship(Vec2.get(200, 200));
		shipController = new PlayerShipController(ship);
		addEntity(shipController);
		addEntity(ship);
		ship.buildShip1();
        camera = new Camera();
		
		// initialize modules
		Laser.initLaser(space);
		
        // random asteroids
        //for (i in 0...100) {
            //addEntity(Asteroid.newRandom(Vec2.get(Math.random() * 20000 - 10000, Math.random() * 20000 - 10000), space));
        //}
		
		for (i in 0...4) {
			var ship2 = new Ship(Vec2.get(Random.normal(0,1000), Random.normal(0,1000)));
			addEntity(ship2);
			ship2.buildShip2();
			addEntity(new StabilizeShipController(ship2));
		}
		
        // register event handlers
        flash.Lib.current.addChild(this);
        flash.Lib.current.addEventListener(Event.ENTER_FRAME, update);

        IO.addKeyDownCallback(IO.K_ASTEROID, function():Void {
            try {
                var p = camera.screenToWorld(IO.mousePos);
                // Main.log("Camera at " + camera.position + " mapping: " + IO.mousePos + " => " + "(" + p.x + "," + p.y +")");
                var asteroid = Asteroid.newRandom(p, space);
                //asteroid.body.applyImpulse(Vec2.get(10000, 0, true));
                addEntity(asteroid);
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
			} else {
				Lib.current.stage.displayState = StageDisplayState.NORMAL;
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
		} catch(error:Dynamic) {
			trace("Failed to add entity:" + entity + error);
		}
	}
	
	public function removeEntity(entity:Entity):Void {
		entitiesToRemove.push(entity);
	}

	/**
	 * Called every frame.
	 * @param  e 
	 */
    public function update(e:Event = null):Void {
		var timestep = 1 / stage.frameRate;
		
		for (entity in updatables) {
			entity.update(timestep);
		}
		
		// pre-physics removal pass
		for (entity in entitiesToRemove) {
			entities.remove(entity);
			if (Std.is(entity, Updatable)) {
				updatables.remove(cast(entity, Updatable));
			}
		}
		entitiesToRemove = [];
		
		try {
			space.step(timestep);
		} catch (error:Dynamic) {
			Main.log("Physics Error: " + error);
		}
		
		// pre-render removal pass
		for (entity in entitiesToRemove) {
			entities.remove(entity);
			if (Std.is(entity, Updatable)) {
				updatables.remove(cast(entity, Updatable));
			}
		}
		entitiesToRemove = [];

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
		Main.log2("bodies: " + space.bodies.length, 1);
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
					cast(entity, Renderable).render(surface, camera);
				}
			}
            ship.render(surface, camera);
        } catch(error:Dynamic) {
            Main.log("Render Error:" + error);
        }
		profiler.render(surface);
    }
}