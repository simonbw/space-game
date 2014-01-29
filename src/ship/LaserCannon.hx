package ship;

import nape.geom.Vec2;
import nape.phys.Material;

import effects.LaserBurstEffect;
import projectiles.Laser;

class LaserCannon extends RectangularPart implements Weapon {
	
	static inline var INTERVAL = 0.25;
	static inline var ENERGY_USE = 8.0;
	
	var cooldown:Float;

	public function new() {
		super(1, 1);
		cooldown = 0;
		color = 0xFFFFFF;
	}

	override public function addToShip(ship:Ship, position:Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		ship.addUpdatePart(this);
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
		if (cooldown > 0) {
			cooldown -= ship.requestEnergy((0.7 * health / maxHealth + 0.3) * timestep * ENERGY_USE, EnergyType.WEAPON) / ENERGY_USE;
		}
	}

	public function fire():Bool {
		if (cooldown <= 0) {
			cooldown += INTERVAL;
			var pos = ship.body.localPointToWorld(toShipCoords(Vec2.get(0, 18, true).addeq(ship.drawOffset)));
			var dir = ship.body.localVectorToWorld(rotateVec(Vec2.get(0, 1, true)));
			var l = new Laser(pos, dir, ship.body.velocity);
			ship.game.addEntity(new LaserBurstEffect(pos.addMul(dir, -3), dir, ship.body.velocity.copy()));
			// l.addDoNotHit(ship);
			dir.dispose();

			SoundManager.playSound("laser");

			Main.currentGame.addEntity(l);
			return true;
		} else {
			return false;
		}
	}
}