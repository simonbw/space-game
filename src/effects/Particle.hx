package effects;

import flash.display.Graphics;
import nape.geom.Vec2;

class Particle extends Entity implements Updatable {
	
	var particleSystem:ParticleSystem;
	var position:Vec2;
	var velocity:Vec2;

	public function new(position:Vec2, velocity = null) {
		this.position = position;
		if (velocity == null) {
			velocity = Vec2.get(0, 0);
		}
		this.velocity = velocity;
		sprite = util.Pool.shape();	
	}

	public function update(timestep:Float):Void {
		position.addeq(velocity.mul(timestep, true));
	}

	public function draw(g:Graphics):Void {

	}

	override public function dispose():Void {
		super.dispose();
	}
}