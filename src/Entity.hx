
import de.polygonal.ds.Hashable;

class Entity implements Hashable {
	static var keyCount = 0;

	/** set to true when this object should be disposed of */
	public var game:Game;
	/** Used for hashing */
	public var key:Int;
	/** True once this has been disposed */
	public var disposed:Bool;
	
	public function new() {
		disposed = false;
		game = null;
		key = keyCount;
		keyCount++;
	}
	
	/**
	 * Called when added to the game.
	 * @param  game game added to
	 */
	public function init(game:Game):Void {
		this.game = game;
	}
	
	/**
	 * Called when this is removed from the game.
	 */
	public function dispose():Void {
		if (disposed) {
			Main.log("already disposed");
		}
		if (game != null) {
			game.removeEntity(this);
		}
		disposed = true;
	}

}