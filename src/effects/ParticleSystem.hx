package effects;

import flash.display.BitmapData;
import flash.display.Sprite;
import nape.geom.Vec2;

class ParticleSystem<T:Particle> extends Entity implements Renderable implements Updatable {

	public var renderDepth:Int;
	public var particles:Array<T>;
	public var toRemove:Array<T>;
	public var position:Vec2;
	var sprite:Sprite;

	public function new(position:Vec2 = null) {
		super();
		renderDepth = 100;
		this.position = position.copy();
		sprite = util.Pool.sprite();
		particles = new Array<T>();
		toRemove = new Array<T>();
	}

	public function addParticle(particle:T):Void {
		particles.push(particle);
	}

	public function removeParticle(particle:T):Void {
		toRemove.push(particle);
	}

	public function update(timestep:Float):Void {
		for (particle in particles) {
			particle.update(timestep);
			if (particle.disposed) {
				removeParticle(particle);
			}
		}
		for (particle in toRemove) {
			particles.remove(particle);
		}
		toRemove.splice(0, toRemove.length);
		if (checkDone()) {
			dispose();
		}
	}

	function checkDone():Bool {
		return (particles.length == 0);
	}

	function draw():Void {
	}

	public function render(surface:BitmapData, camera:Camera):Void {
		draw();

		var m = new flash.geom.Matrix();
		m.translate(position.x, position.y);
		camera.getMatrix(m);
		surface.draw(sprite, m);
	}

	override public function dispose():Void {
		super.dispose();
		util.Pool.disposeSprite(sprite);
		for (particle in particles) {
			particle.dispose();
		}
		for (particle in toRemove) {
			particles.remove(particle);
		}
		toRemove.splice(0, toRemove.length);
		position.dispose();
		position = null;
		particles = null;
	}
}