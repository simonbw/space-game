package projectiles;

import flash.display.Sprite;
import util.Pool;
import util.Random;

import nape.geom.Vec2;
import nape.callbacks.*;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.dynamics.InteractionFilter;

class Laser extends projectiles.Projectile {
	static inline var SPEED = 10000;
	static inline var ACCURACY = 0.05;
	static inline var LIFESPAN = 5.0;
	
	var direction:Vec2;
	
	public function new(position:Vec2, direction:Vec2, offset:Vec2 = null) {
		super(position, ProjectileInfo.LASER, LIFESPAN);
		
		for (shape in body.shapes) {
			shape.material = Physics.M_ENERGY;
			shape.filter = Physics.F_HOLLOW_PROJECTILE;
		}

		this.direction = direction.unit();
		velocity = direction.copy();
		velocity.x *= util.Random.normal(1.0, ACCURACY);
		velocity.y *= util.Random.normal(1.0, ACCURACY);
		velocity.muleq(Random.normal(SPEED, SPEED / 16));
		if (offset != null) {
			velocity.addeq(offset);
		}
		body.velocity.set(velocity);
	}

	override function draw():Void {
		sprite.graphics.lineStyle(0, 0xFFFF00, 0.5);
		var l = SPEED * 0.8 / Main.stage.frameRate;
		sprite.graphics.lineTo(-direction.x  * l, -direction.y * l);
	}

	override public function dispose():Void {
		super.dispose();
		direction.dispose();
		direction = null;
	}
}