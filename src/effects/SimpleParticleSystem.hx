package effects;

import nape.geom.Vec2;

class SimpleParticleSystem<T:SimpleParticle> extends ParticleSystem<SimpleParticle> implements Renderable implements Updatable {
	public function new(position:Vec2) {
		super(position);
	}

	override public function draw():Void {
		var g = sprite.graphics;
		g.clear();
		for (particle in particles) {
			g.beginFill(particle.color, particle.alpha);
			g.drawCircle(particle.position.x, particle.position.y, particle.size);
			g.endFill();
		}
	}
}