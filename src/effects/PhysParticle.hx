package effects;

import nape.geom.Vec2;
import nape.phys.Body;

class PhysParticle extends Particle {
	static var MATERIAL = new nape.phys.Material();
	var body:Body;
	public var color:Int;
	public var alpha:Float;
	public var size:Float;
	public var lifespan:Float;

	var added:Bool = false;

	public function new(position:Vec2, velocity = null, color:Int = 0xFFFFFF, alpha:Float = 1.0, size:Float = 2.0, lifespan:Float = 1.0) {
		super(position, velocity);
		this.color = color;
		this.alpha = alpha;
		this.size = size;
		this.lifespan = lifespan;

		try {
			body = new Body();
			body.isBullet = true;
			body.velocity.set(velocity);

			var shape = new nape.shape.Circle(size, Vec2.get(0,0), MATERIAL, Physics.F_SOLID_PARTICLE);
			shape.body = body;
			shape.userData.entity = this;
		} catch(error:Dynamic) {
			Main.log("PhysParticle" + error);
		}
	}

	override public function update(timestep:Float):Void {
		if (!added) {
			added = true;
			body.space = Main.currentGame.space;
		}
		position.set(body.position);
		if (lifespan > 0) {
			lifespan -= timestep;
			if (lifespan <= 0) {
				dispose();
			}
		}
	}

	override public function dispose():Void {
		super.dispose();
		body.space = null;
	}
}