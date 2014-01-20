package effects;

import flash.display.Graphics;
import nape.geom.Vec2;

class SimpleParticle extends Particle {

	public var color:Int;
	public var alpha:Float;
	public var size:Float;
	public var lifespan:Float;

	public function new(position:Vec2, velocity = null, color:Int = 0xFFFFFF, alpha:Float = 1.0, size:Float = 2.0, lifespan:Float = 1.0) {
		super(position, velocity);
		this.color = color;
		this.alpha = alpha;
		this.size = size;
		this.lifespan = lifespan;
	}

	override public	function update(timestep:Float):Void {
		super.update(timestep);
		if (lifespan > 0) {
			lifespan -= timestep;
			if (lifespan <= 0) {
				dispose();
			}
		}
	}
}