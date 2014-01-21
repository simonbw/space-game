package projectiles;

import flash.display.Sprite;
import util.Pool;
import util.Random;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.dynamics.InteractionFilter;

class Missile extends projectiles.Projectile {
	static inline var SPEED = 200;
	static inline var LIFESPAN = 15.0;
	static inline var BURN_TIME = 0.5;
	static inline var THRUST = 64.0;
	
	public function new(position:Vec2, direction:Vec2, offset:Vec2 = null) {
		super(position, ProjectileInfo.MISSILE, LIFESPAN);
		
		for (shape in body.shapes) {
			shape.material = Physics.M_MEDIUM_METAL;
			shape.filter = Physics.F_SOLID_PROJECTILE;
		}

		velocity = direction.copy();
		velocity.muleq(Random.normal(SPEED, SPEED / 10));
		if (offset != null) {
			velocity.addeq(offset);
		}
		body.velocity.set(velocity);
		body.rotation = direction.angle;
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);

		if (lifespan > BURN_TIME) {
			var impulse = Vec2.fromPolar(timestep * THRUST, body.rotation);
			body.applyImpulse(impulse);
			impulse.dispose();
		}
	}

	override function draw():Void {
		sprite.graphics.lineStyle(4.0, 0x666666, 1.0);
		var endpoint = Vec2.fromPolar(16, body.rotation);
		sprite.graphics.lineTo(endpoint.x, endpoint.y);
		endpoint.dispose();
	}

	override public function dispose():Void {
		super.dispose();
		velocity.dispose();
		velocity = null;
	}
}