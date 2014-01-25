package effects;

import util.Random;
import util.MyMath;
import util.Color;

import nape.geom.Vec2;

class LaserBurstEffect extends SimpleParticleSystem<LaserBurstParticle> {

	var velocity:Vec2;
	public function new(position:Vec2, direction:Vec2, velocity:Vec2) {
		super(position);
		this.velocity = velocity;

		for (i in 0...10) {
			var vel = Vec2.fromPolar(Random.normal(100, 100), direction.angle + Random.normal(0.0, 0.6));
			addParticle(new LaserBurstParticle(vel));
		}
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
		if (!disposed) {
			position.addeq(velocity.mul(timestep, false));
		}
	}

	override public function dispose():Void {
		super.dispose();
		velocity.dispose();
		velocity = null;
	}
}

class LaserBurstParticle extends SimpleParticle {
	var maxLife:Float;
	public function new(velocity:Vec2) {
		maxLife = MyMath.limit(Random.normal(0.2, 0.1));
		super(Vec2.get(0, 0), velocity, 0xFFFF00, 1.0, MyMath.limit(Random.normal(1.2, 1.5), 0.1, 3.0), maxLife);
		color = Color.interpolate(color, 0xFFFFDD, Math.random());
		color = Color.interpolate(color, 0xFF5500, Math.random());
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
		if (!disposed) {
			alpha = lifespan / maxLife;
		}
	}
}