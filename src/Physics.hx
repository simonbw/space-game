
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
import nape.phys.Material;

import projectiles.Projectile;

class Physics {

	// CallBack types
	public static var CB_HITTABLE = new CbType();
	public static var CB_PROJECTILE = new CbType();
	public static var CB_SHIP = new CbType();
	public static var CB_SHIP_PART = new CbType();
	public static var CB_ASTEROID = new CbType();

	// Collision Groups
	public static inline var G_SHIP_1 = 1<<0;
	public static inline var G_SHIP_2 = 1<<1;
	public static inline var G_SHIP_3 = 1<<1;
	public static inline var G_SHIP_4 = 1<<1;
	public static inline var G_SHIP = G_SHIP_1 | G_SHIP_2 | G_SHIP_3 | G_SHIP_4;
	public static inline var G_ASTEROID = 1<<5;
	public static inline var G_PROJECTILE_1 = 1<<9;
	public static inline var G_PROJECTILE_2 = 1<<10;
	public static inline var G_PROJECTILE_3 = 1<<11;
	public static inline var G_PROJECTILE_4 = 1<<12;
	public static inline var G_PROJECTILE = G_PROJECTILE_1 | G_PROJECTILE_2 | G_PROJECTILE_3 | G_PROJECTILE_4;
	public static inline var G_PARTICLE_1 = 1<<13;
	public static inline var G_PARTICLE_2 = 1<<14;
	public static inline var G_PARTICLE = G_PARTICLE_1 | G_PARTICLE_2;

	// Premade collision filters
	public static var F_ASTEROID = new InteractionFilter(G_ASTEROID);
	public static var F_SOLID_SHIP = new InteractionFilter(G_SHIP);
	public static var F_HOLLOW_SHIP = new InteractionFilter(G_SHIP, ~G_SHIP);
	public static var F_SOLID_PROJECTILE = new InteractionFilter(G_PROJECTILE);
	public static var F_HOLLOW_PROJECTILE = new InteractionFilter(G_PROJECTILE, ~G_PROJECTILE);
	public static var F_SOLID_PARTICLE = new InteractionFilter(G_PARTICLE, ~(G_PROJECTILE));

	// Materials
	public static var M_ENERGY = new Material(-1.0, 0.0, 0.0, 0.001, 1.0);
	public static var M_LIGHT_METAL = new Material(0.15, 0.8, 1.5, 1.0, 1.0);
	public static var M_MEDIUM_METAL = new Material(0.15, 0.8, 1.5, 2.0, 1.0);
	public static var M_HEAVY_METAL = new Material(0.15, 0.8, 1.5, 3.0, 1.0);
	public static var M_ROCK = new Material(0.5, 1.2, 1.8, 1.0);

	/**
	 * Initialize all the listeners on a space.
	 * @param  space [description]
	 * @return       [description]
	 */
	public static function init(space:Space) {
		initProjectiles(space);
		initShipCollisions(space);
	}

	static function initProjectiles(space:Space):Void {
		var listener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, [CB_PROJECTILE], [CB_HITTABLE], function(cb:InteractionCallback):Void {
			var projectile = cast(cb.int1.userData.entity, Projectile);
			if (projectile != null && !projectile.disposed) {
				var other = cast(cb.int2.userData.entity, Hittable);
				try {
					if (other != null) {
						var p = projectile.body.position;
						other.hit(p, projectile);
					}
				} catch (error:Dynamic) {
					Main.log("Collision Error: " + error);
				}
				projectile.hit();
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
			part1.inflictDamage(damage, DamageType.Collsion);
			part2.inflictDamage(damage, DamageType.Collsion);
			impulseMultiplier *= 2.0;

			var avgVelocity = velocity1.add(velocity2).mul(0.5);
			for (contact in arbiter.contacts) {
				ship1.game.addEntity(new effects.CollisionEffect(contact.position, avgVelocity, arbiter.normal, Math.sqrt(damage) / 2));
			}

			var result = PreFlag.ACCEPT_ONCE;
			if (!(part1.health > 0 && part2.health > 0)) {
				var impulse1 = arbiter.normal.unit();
				impulse1.muleq(Math.abs(velocityDiff.unit(true).dot(arbiter.normal.unit(true))) * impulseMultiplier);
				var impulse2 = impulse1.mul(-1);
				if (cb.swapped) {
					impulse1.muleq(-1);
					impulse2.muleq(-1);
				}
				ship1.body.applyImpulse(impulse2, arbiter.shape1.worldCOM);
				ship2.body.applyImpulse(impulse1, arbiter.shape2.worldCOM);
				result = PreFlag.IGNORE_ONCE;
				impulse1.dispose();
				impulse2.dispose();
			}

			velocityDiff.dispose();
			velocity1.dispose();
			velocity2.dispose();
			avgVelocity.dispose();
			a1.dispose();
			a2.dispose();

			return result;
		});
		listener.space = space;
	}
}
