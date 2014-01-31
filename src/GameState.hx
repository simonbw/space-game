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
class GameState extends Sprite {
	/** The maximum allowed duration of a single time step */
	public var profiler: Profiler;

	/** The bitmap object that gets drawn to the screen */
	var bitmap: Bitmap;
	/** The main rendering layer */
	var surface: BitmapData;

	/**
	 * Create a new Game.
	 */
	public function new() {
		super();
		profiler = new Profiler();
	}

	/**
	 * Call to start the game.
	 */
	public function init(): Void {
		bitmap = new Bitmap();
		createLayers();
		addChild(bitmap);

		// profiling stuff
		profiler.addSection("update");
		profiler.addSection("physics");
		profiler.addSection("render");
		profiler.addSection("system");

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

	/**
	 * Called every frame.
	 * @param  e
	 */
	public function update(e: Event = null): Void {
		profiler.endSection("system");
		profiler.startSection("update");

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
		} catch (error: Dynamic) {
			Main.log("Render Error:" + error);
		}
		profiler.render(surface);
	}

	public function dispose(): Void {
		flash.Lib.current.removeEventListener(Event.ENTER_FRAME, update);
		flash.Lib.current.removeChild(this);
		IO.clearAllKeyDownCallbacks();
		profiler = null;
		bitmap = null;
		surface.dispose();
		surface = null;
	}
}