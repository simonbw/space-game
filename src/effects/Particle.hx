package effects;

import flash.display.Graphics;
import nape.geom.Vec2;

class Particle extends Entity implements Updatable {
	
	public var position:Vec2;
	public var velocity:Vec2;

	public function new(position:Vec2, velocity = null) {
		super();
		this.position = position;
		if (velocity == null) {
			velocity = Vec2.get(0, 0);
		}
		this.velocity = velocity;
	}

	public function update(timestep:Float):Void {
		position.addeq(velocity.mul(timestep, true));
	}

	override public function dispose():Void {
		super.dispose();
	}
}