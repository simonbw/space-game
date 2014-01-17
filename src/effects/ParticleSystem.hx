package effects;

import flash.display.BitmapData;
import flash.display.Sprite;
import nape.geom.Vec2;

class ParticleSystem extends Entity implements Renderable implements Updatable {

	public var renderDepth:Int;
	public var particles:Array<Particle>;
	public var toRemove:Array<Particle>;
	public var position:Vec2;
	var sprite:Sprite;

	public function new(position:Vec2 = null) {
		renderDepth = 100;
		this.position = new Vec2();
		sprite = util.Pool.sprite();
		particles = new Array<Particle>();
		toRemove = new Array<Particle>();
	}

	public function removeParticle(particle:Particle):Void {
		toRemove.push(particle);
	}

	public function update(timestep:Float):Void {
		for (particle in particles) {
			particle.update(timestep);
		}
		for (particle in toRemove) {
			particles.remove(particle);
		}
		toRemove.splice(0, toRemove.length);
	}

	public function render(surface:BitmapData, camera:Camera):Void {
		var g = sprite.graphics;
		g.clear();
		for (particle in particles) {
			paricle.draw(g);
		}
		var m = new flash.geom.Matrix();
		camera.getMatrix(m);
		surface.draw(sprite, m);
	}

	override public function dispose():Void {
		super.dispose();
		util.Pool.disposeSprite(sprite);
	}
}