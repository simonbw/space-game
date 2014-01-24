package effects;

import nape.geom.Vec2;

import util.Random;

class PartDestroyedEffect extends ParticleSystem<PartDestroyedParticle> {
	
	var velocity:Vec2;
	public function new(position:Vec2, velocity:Vec2) {
		super(position);
		this.velocity = velocity;
		for (i in 0...5) {
			var p = Vec2.get(Random.normal(0, ship.Ship.GRID_SIZE / 2), Random.normal(0, ship.Ship.GRID_SIZE / 2));
			addParticle(new PartDestroyedParticle(p));
		}
	}

	override public function update(timestep:Float):Void {
		position.addeq(velocity.mul(timestep, true));
		super.update(timestep);
	}

	override function draw():Void {
		var g = sprite.graphics;
		g.clear();
		for (particle in particles) {
			g.beginFill(particle.color, particle.alpha);
			g.drawCircle(particle.position.x, particle.position.y, particle.size);
			g.endFill();
		}
	}

	override public function dispose():Void {
		super.dispose();
		velocity.dispose();
	}
}

class PartDestroyedParticle extends Particle {
	public var size:Float;
	public var color:Int;
	public var alpha:Float;

	public function new(position:Vec2) {
		super(position);
		size = Math.random() * Math.random() * 16 + 3;
		color = util.Color.interpolate(0xFFFF00, 0xFF5500, Math.random());
		alpha = util.MyMath.limit(Random.normal(0.6, 0.3));
		velocity.setxy(Random.normal(0, 60), Random.normal(0, 60));
	}

	override public function update(timestep):Void {
		super.update(timestep);
		size -= timestep * 20;
		if (size <= 0) {
			dispose();
		}
	}
}