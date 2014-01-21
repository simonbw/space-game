package effects;

import nape.geom.Vec2;

import util.Random;

class CollisionEffect extends ParticleSystem<CollisionParticle> implements Renderable implements Updatable {
	public function new(position:Vec2, velocity:Vec2, normal:Vec2, size:Float) {
		super(position);
		renderDepth = 2000;

		normal = normal.unit().perp();
		size = Math.sqrt(size);
		var i =  size / 10;
		while (i > 1 || (i > 0 && Random.bool(i))) {
			i--;
			var speed = Random.normal(300, 160) * Random.sign() * size;
			var v = Vec2.fromPolar(speed, Random.uniform(0, Math.PI * 2));
			v.addeq(velocity);
			addParticle(new CollisionParticle(Vec2.get(0,0), v, Random.normal(1.0, 0.2)));
		}
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
}

class CollisionParticle extends SimpleParticle {
	static inline var LIFESPAN = 0.4;
	public function new(position:Vec2, velocity:Vec2, size:Float = 1.0) {
		super(position, velocity, 0xFFFF00, 1.0, 2.0 * size, LIFESPAN);
		color = 0xFFFF00;
	}

	override public function update(timestep:Float):Void {
		alpha = lifespan / LIFESPAN;
		super.update(timestep);
	}
}