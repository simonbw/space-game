package projectiles;

import flash.display.Sprite;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.dynamics.InteractionFilter;

import util.Pool;
import util.Random;
import effects.EngineEffect;

class Missile extends projectiles.Projectile {
	static inline var SPEED = 150;
	static inline var LIFESPAN = 10.0;
	static inline var BURN_TIME = 2.0;
	static inline var THRUST = 96.0;

	var engineEffect:EngineEffect;
	
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
		engineEffect = new EngineEffect(body.position, velocity);
	}

	override public function init(game:Game):Void {
		super.init(game);
		game.addEntity(engineEffect);
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
		if (!disposed) {
			if (lifespan > LIFESPAN - BURN_TIME) { // burning
				var impulse = Vec2.fromPolar(timestep * THRUST, body.rotation);
				body.applyImpulse(impulse);
				engineEffect.applyThrust(impulse);
				impulse.dispose();
			} else { // coasting
				engineEffect.off();
			}
		}
	}

	override public function update2(timestep:Float):Void {
		super.update2(timestep);
		if (!disposed) {
			engineEffect.move(body.position, velocity);
		}
	}

	override function draw(load:Float):Void {
		sprite.graphics.lineStyle(4.0, 0x666666, 1.0);
		var endpoint = Vec2.fromPolar(16, body.rotation);
		sprite.graphics.lineTo(endpoint.x, endpoint.y);
		endpoint.dispose();
	}

	override public function dispose():Void {
		super.dispose();
		velocity.dispose();
		velocity = null;
		engineEffect.readyToDispose = true;
	}
}