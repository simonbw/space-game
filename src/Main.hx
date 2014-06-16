/**
 * Initializes the game.
 */
class Main {
	static public var currentGame:Game;
	static public var stage:flash.display.Stage;

	/**
	 * Gets called when the SWF loads.
	 */
	static function main() {
		stage = flash.Lib.current.stage;
		IO.init();
		try {
			SoundManager.init();
		} catch (error:Dynamic) {
			trace(error.name + " " + error.message + " " + error.errorID);
		}
		ui.Cursor.init();
		IO.addKeyDownCallback(IO.K_RESET, reset);
		reset();
	}

	static public function reset():Void {
		if (currentGame != null) {
			try {
				currentGame.dispose();
			} catch(error:Dynamic) {
				trace(error);
			}
		}
		currentGame = new Game();
		try {
			currentGame.init();
		} catch (error:Dynamic) {
			trace("error: " + error);
		}
	}

	/**
	 * Log something. Attempts to use the game's profiler, and reverts to haxe's trace if that fails.
	 * @param  s string to log
	 */
	public static function log(s:Dynamic, forceTrace:Bool = false):Void {
		try {
			if (forceTrace) {
				trace(s);
			}
			currentGame.profiler.log("" + s);
		} catch(error:Dynamic) {
			trace(s);
		}
	}

	/**
	 * @param  s string to log
	 */
	public static function log2(s:String, position:Int):Void {
		try {
			currentGame.profiler.setCustomData(s, position);
		} catch(error:Dynamic) {
			trace(error);
		}
	}
}