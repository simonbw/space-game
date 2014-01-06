

class Entity {

	/** set to true when this object should be disposed of */
	public var game:Game;
	public var disposed:Bool;
	
	public function new() {
		disposed = false;
	}
	
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
		game.removeEntity(this);
		disposed = true;
	}

}