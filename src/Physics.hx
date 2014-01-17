
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.dynamics.InteractionFilter;
import nape.space.Space;

import projectiles.Laser;

class Physics {

	public static var CB_HITTABLE = new CbType();
	public static var CB_PROJECTILE = new CbType();
	public static var CB_SHIP_PART = new CbType();
	public static var CB_ASTEROID = new CbType();

	public static inline var G_SHIP_1 = 1<<0;
	public static inline var G_SHIP_2 = 1<<1;
	public static inline var G_SHIP_3 = 1<<1;
	public static inline var G_SHIP_4 = 1<<1;
	public static inline var G_ASTEROID = 1<<5;
	public static inline var G_PROJECTILE_1 = 1<<9;
	public static inline var G_PROJECTILE_2 = 1<<10;
	public static inline var G_PROJECTILE_3 = 1<<11;
	public static inline var G_PROJECTILE_4 = 1<<12;

	public static var F_ASTEROID = new InteractionFilter(G_ASTEROID);
	public static var F_SOLID_SHIP = new InteractionFilter(G_SHIP_1);
	public static var F_HOLLOW_SHIP = new InteractionFilter(G_SHIP_1, ~G_SHIP_1);
	public static var F_SOLID_PROJECTILE = new InteractionFilter(G_PROJECTILE_1);
	public static var F_HOLLOW_PROJECTILE = new InteractionFilter(G_PROJECTILE_1, ~G_PROJECTILE_1);

	public static function init(space:Space) {
		initProjectiles(space);
		initShipCollisions(space);
	}

	static function initProjectiles(space:Space):Void {
		var listener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, [CB_PROJECTILE], [CB_HITTABLE], function(cb:InteractionCallback):Void {
			var laser = cast(cb.int1.userData.entity, Laser);
			if (laser != null && !laser.disposed) {
				var other = cast(cb.int2.userData.entity, Hittable);
				try {
					if (other != null) {
						var p = laser.body.position; //arbiter.contacts.at(0).position;
						var v = laser.velocity;
						other.hit(p, v);
					}
				} catch (error:Dynamic) {
					Main.log("Collision Error: " + error);
				}
				laser.hit();
			}
		});
		listener.space = space;
	}

	/**
	 * Handle ship-to-ship collisions.
	 * @param  space [description]
	 * @return       [description]
	 */
	static function initShipCollisions(space:Space):Void {
		var listener = new PreListener(InteractionType.COLLISION, [CB_SHIP_PART], [CB_SHIP_PART], function(cb:PreCallback):PreFlag {
			var arbiter = cb.arbiter.collisionArbiter;
			var part1 = cast(cb.int1.userData.entity, ship.ShipPart);
			var part2 = cast(cb.int2.userData.entity, ship.ShipPart);
			var ship1 = part1.ship;
			var ship2 = part2.ship;
			var impulseMultiplier = 0.0;

			var a1 = ship1.body.localVectorToWorld(part1.center.mul(ship1.body.angularVel, true));
			var a2 = ship2.body.localVectorToWorld(part2.center.mul(ship2.body.angularVel, true));

			var velocity1 = ship1.body.velocity.copy(); // account for rotational stuff later
			velocity1.addeq(a1);
			var velocity2 = ship2.body.velocity.copy();
			velocity2.addeq(a2);
			var velocityDiff = velocity1.sub(velocity2);
			var damage = Math.pow(Math.abs(velocityDiff.dot(arbiter.normal.unit(true))) / 1000, 2.2) * Math.sqrt(ship1.body.inertia + ship2.body.inertia) * 0.9;
			impulseMultiplier += Math.max(Math.min(damage, part1.health), 0);
			impulseMultiplier += Math.max(Math.min(damage, part2.health), 0);
			part1.inflictDamage(damage);
			part2.inflictDamage(damage);
			impulseMultiplier *= 1.4;

			for (contact in arbiter.contacts) {
				ship1.game.addEntity(new effects.CollisionEffect(contact.position, arbiter.normal, Math.sqrt(damage) / 2));
			}

			if ((part1.health > 0 && part2.health > 0)) {
				return PreFlag.ACCEPT_ONCE;
			} else {
				var impulse1 = arbiter.normal.unit();
				impulse1.muleq(Math.abs(velocityDiff.unit(true).dot(arbiter.normal.unit(true))) * impulseMultiplier);
				var impulse2 = impulse1.mul(-1);
				if (cb.swapped) {
					impulse1.muleq(-1);
					impulse2.muleq(-1);
				}
				ship1.body.applyImpulse(impulse2, arbiter.shape1.worldCOM);
				ship2.body.applyImpulse(impulse1, arbiter.shape2.worldCOM);

				velocityDiff.dispose();
				velocity1.dispose();
				velocity2.dispose();
				a1.dispose();
				a2.dispose();
				impulse1.dispose();
				impulse2.dispose();
				return PreFlag.IGNORE_ONCE;
			}
		});
		listener.space = space;
	}
}
