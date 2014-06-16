import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.Sprite;
import flash.display.StageDisplayState;
import flash.display.StageScaleMode;
import flash.events.Event;
import flash.Lib;

import flash.external.ExternalInterface;
import nape.geom.Vec2;
import nape.space.Space;

import ai.PlayerShipController;
import ai.StabilizeShipController;
import obstacles.Asteroid;
import ship.PrebuiltShips;
import ship.Ship;
import util.MyMath;
import util.Input;
import util.Profiler;
import util.Random;

/**
 * The top level control structure for the game.
 */
class Game extends Sprite {
	/** The maximum allowed duration of a single time step */
	static inline var MAX_TIMESTEP = 1 / 15.0;

	public var profiler: Profiler;

	var following: Bool;

	/** The bitmap object that gets drawn to the screen */
	var bitmap: Bitmap;
	/** The main rendering layer */
	var surface: BitmapData;
	public var space: Space;
	var camera:Camera;
	var entities:Array<Entity>;
	var entitiesToRemove:Array<Entity>;
	var ship:Ship;
	var shipController:PlayerShipController;
	var stars:effects.Stars;
	var updatables2:Array<Updatable2>;
	var updatables:Array<Updatable>;
	public var input:Input;

	/**
	 * Create a new Game.
	 */
	public function new() {
		super();

		profiler = new Profiler();
		following = true;
	}

	/**
	 * Call to start the game.
	 */
	public function init(): Void {
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
		addEntity(stars);
		input = new Input();
		addEntity(input);
		camera = new Camera();

		// initialize modules
		Physics.init(space);

		// register event handlers
		flash.Lib.current.addChild(this);
		flash.Lib.current.addEventListener(Event.ENTER_FRAME, update);

		// profiling stuff
		profiler.addSection("update");
		profiler.addSection("physics");
		profiler.addSection("render");
		profiler.addSection("system");


		// test code junk
		ship = new Ship(Vec2.get(200, 200));
		shipController = new PlayerShipController(ship);
		addEntity(shipController);
		addEntity(ship);
		if (Random.bool(0.4)) {
			PrebuiltShips.makeFreighter(ship);
		} else if (Random.bool(0.99)) {
			PrebuiltShips.makeXWing(ship);
		} else {
			PrebuiltShips.makeCruiser(ship);
		}
		// Main.log(ship.serialize());
		addEntity(new ui.EnergyMeter(ship));

		var station = new ship.SpaceStation(Vec2.get(1000, 500));
		PrebuiltShips.makeTradingStation(station);
		addEntity(station);

		IO.addKeyDownCallback(IO.K_ASTEROID, function(): Void {
			try {
				var p = camera.screenToWorld(IO.mousePos);
				// Main.log("Camera at " + camera.position + " mapping: " + IO.mousePos + " => " + "(" + p.x + "," + p.y +")");
				// var asteroid = Asteroid.newRandom(p, space);
				//asteroid.body.applyImpulse(Vec2.get(10000, 0, true));
				// addEntity(asteroid);

				var ship2 = new Ship(p);
				addEntity(ship2);
				if (Random.bool(0.6)) {
					PrebuiltShips.makeFreighter(ship2);
				} else if (Random.bool(0.99)) {
					PrebuiltShips.makeXWing(ship2);
				} else {
					PrebuiltShips.makeCruiser(ship2);
				}
				addEntity(new StabilizeShipController(ship2));
			} catch (error: Dynamic) {
				Main.log(error);
			}
		});

		IO.addKeyDownCallback(IO.K_CAMERA_LOCK, function(): Void {
			following = !following;
		});

		IO.addKeyDownCallback(IO.K_FULLSCREEN, toggleFullscreen);
	}

	public function toggleFullscreen(): Void {
		Main.log("toggling fullscreen");

		try {
			if (Main.stage.displayState == StageDisplayState.NORMAL) {
				Main.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
			} else {
				Main.stage.displayState = StageDisplayState.NORMAL;
			}
			createLayers();
		} catch (error: Dynamic) {
			Main.log(error);
		}
		Main.stage.scaleMode = StageScaleMode.NO_SCALE;
	}

	/**
	 * Create the bitmapdata layers. Call this if the screen size changes.
	 */
	public function createLayers(): Void {
		var w: Int;
		var h: Int;
		if (Main.stage.displayState == StageDisplayState.FULL_SCREEN || Main.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
			w = Main.stage.fullScreenWidth;
			h = Main.stage.fullScreenHeight;
		} else {
			w = Main.stage.stageWidth;
			h = Main.stage.stageHeight;
		}
		surface = new BitmapData(w, h, false, 0x00000000);
		if (bitmap.bitmapData != null) {
			bitmap.bitmapData.dispose();
		}
		bitmap.bitmapData = surface;
	}

	public function addEntity(entity: Entity): Void {
		try {
			entities.push(entity);
			entity.init(this);
			if (Std.is(entity, Updatable)) {
				updatables.push(cast(entity, Updatable));
			}
			if (Std.is(entity, Updatable2)) {
				updatables2.push(cast(entity, Updatable2));
			}
		} catch (error: Dynamic) {
			trace("Failed to add entity:" + entity + error);
		}
	}

	public function removeEntity(entity: Entity): Void {
		entitiesToRemove.push(entity);
	}

	inline function removeEntityTrue(entity: Entity): Void {
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
	public function update(e: Event = null): Void {
		profiler.endSection("system");
		profiler.startSection("update");
		var timestep = 1 / stage.frameRate;

		for (entity in updatables) {
			try {
				entity.update(timestep);
			} catch (error: Dynamic) {
				Main.log("Updating " + entity + "failed: " + error);
			}
		}

		// pre-physics removal pass
		for (entity in entitiesToRemove) {
			removeEntityTrue(entity);
		}
		entitiesToRemove.splice(0, entitiesToRemove.length);
		profiler.endSection("update");
		
		profiler.startSection("physics");
		try {
			space.step(timestep, 10, 10);
		} catch (error: Dynamic) {
			Main.log("Physics Error: " + error);
		}
		profiler.endSection("physics");

		// post-physics removal pass
		for (entity in entitiesToRemove) {
			removeEntityTrue(entity);
		}
		entitiesToRemove.splice(0, entitiesToRemove.length);

		// post physics updates
		for (entity in updatables2) {
			try {
				entity.update2(timestep);
			} catch (error: Dynamic) {
				Main.log("Updating2 " + entity + "failed: " + error);
			}
		}

		// pre-render removal pass
		for (entity in entitiesToRemove) {
			removeEntityTrue(entity);
		}
		entitiesToRemove.splice(0, entitiesToRemove.length);

		// Camera Control should be done elsewhere
		if (following) {
			camera.smoothCenter(ship.body.position, 0.5);
		}
		
		SoundManager.setEarPosition(camera.position.copy());

		//camera.angle = Math.PI - ship.body.rotation;
		if (IO.keys[IO.K_ZOOM_IN]) {
			camera.zoom *= 1.01;
		}
		if (IO.keys[IO.K_ZOOM_OUT]) {
			camera.zoom *= 0.99;
		}

		Main.log2("bodies: " + space.bodies.length, 0);
		Main.log2("speed: " + Std.int(ship.body.velocity.length), 1);
		profiler.update();
		profiler.startSection("render");
		render(e);
		profiler.endSection("render");
		profiler.startSection("system");
	}

	/**
	 * Render everything to the screen.
	 */
	public function render(e: Event = null): Void {
		try {
			surface.fillRect(surface.rect, 0x000000);
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

	public function dispose(): Void {
		flash.Lib.current.removeEventListener(Event.ENTER_FRAME, update);
		flash.Lib.current.removeChild(this);
		IO.clearAllKeyDownCallbacks();

		for (e in entities) {
			e.dispose();
		}
		for (e in entitiesToRemove) {
			removeEntityTrue(e);
		}

		profiler = null;
		bitmap = null;
		surface.dispose();
		surface = null;
		space = null;
		entities = null;
		updatables = null;
		updatables2 = null;
		entitiesToRemove = null;
		ship = null;
		shipController = null;
		stars = null;
		camera = null;
	}
}