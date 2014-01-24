package effects;

import nape.geom.Vec2;

class EngineEffect extends SimpleParticleSystem<EngineParticle> {
	
	public var readyToDispose:Bool;
	var velocity:Vec2;
	var toAdd:Array<EngineParticle>;
	var thrust:Float;

	public function new(position:Vec2, velocity:Vec2) {
		super(position);
		readyToDispose = false;
		this.velocity = velocity;
		toAdd = new Array<EngineParticle>();
		thrust = 0;
		renderDepth = 150;
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
	}

	public function applyThrust(impulse:Vec2):Void {
		thrust = impulse.length * 1.5;
		if (impulse.length > 0.1) {
			toAdd.push(new EngineParticle(thrust, velocity.add(impulse.mul(-100, true))));
		}
	}

	public function off():Void {
		thrust = 0;
	}

	public function move(pos:Vec2, vel:Vec2):Void {
		var diff = position.sub(pos);
		for (particle in particles) {
			particle.position.addeq(diff);
		}
		position.set(pos);
		diff.dispose();

		for (p in toAdd) {
			addParticle(p);
		}
		toAdd.splice(0, toAdd.length);
	}

	override function draw():Void {
		super.draw();
		if (!readyToDispose && thrust > 0.01) {
			var g = sprite.graphics;
			g.beginFill(util.Color.interpolate(0xFFFF00, 0xFF8800, Math.random()));
			g.drawCircle(0, 0, thrust);
			g.endFill();
		}
	}

	override function checkDone():Bool {
		return (readyToDispose && super.checkDone());
	}
}

class EngineParticle extends SimpleParticle {
	static inline var LIFESPAN = 0.8;
	var maxsize:Float;
	public function new(size:Float, velocity:Vec2) {
		super(Vec2.get(0, 0), velocity);
		lifespan = LIFESPAN;
		maxsize = size;
	}

	override public function update(timestep):Void {
		super.update(timestep);
		var percent = lifespan / LIFESPAN;
		color = util.Color.interpolate(0xFFFF00, 0xFF0000, percent);
		size = percent * maxsize;
		alpha = percent;
	}
}