package effects;

import nape.geom.Vec2;

class EngineEffect extends SimpleParticleSystem<EngineParticle> {
	
	public var readyToDispose:Bool;
	var velocity:Vec2;
	public function new(position:Vec2, velocity:Vec2) {
		super(position);
		readyToDispose = false;
		this.velocity = velocity;
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
	}

	public function thrust(impulse:Vec2):Void {
		if (impulse.length > 0.1) {
			addParticle(new EngineParticle(impulse.length * 10, velocity.add(impulse)));
		}
	}

	public function move(pos:Vec2, vel:Vec2):Void {
		var diff = position.sub(pos);
		for (particle in particles) {
			particle.position.addeq(diff);
		}
		position.set(pos);
		diff.dispose();
	}

	override function checkDone():Bool {
		return (readyToDispose && super.checkDone());
	}
}

class EngineParticle extends SimpleParticle {
	static inline var LIFESPAN = 0.8;
	var maxsize:Float;
	public function new(size:Float, velocity:Vec2) {
		super(Vec2.get(0, 0), velocity, 0xFF5500);
		lifespan = LIFESPAN;
		maxsize = size;
	}

	override public function update(timestep):Void {
		super.update(timestep);
		size = lifespan / LIFESPAN * maxsize;
		alpha = lifespan / LIFESPAN;
	}
}