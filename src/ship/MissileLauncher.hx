package ship;

import nape.geom.Vec2;
import nape.phys.Material;

import projectiles.Missile;

class MissileLauncher extends RectangularPart implements Weapon{
	
	static inline var INTERVAL = 2.0;
	static inline var ENERGY_USE = 2.0;
	
	var cooldown:Float;

	public function new() {
		super(1, 2);
		cooldown = 0;
		color = 0x666666;
	}

	override public function addToShip(ship:Ship, position:Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		ship.addUpdatePart(this);
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
		if (cooldown > 0) {
			cooldown -= ship.requestEnergy(timestep * ENERGY_USE, EnergyType.WEAPON) / ENERGY_USE;
		}
	}

	public function fire():Bool {
		if (cooldown <= 0) {
			cooldown += INTERVAL;
			var pos = ship.body.localPointToWorld(toShipCoords(Vec2.get(0, 40, true).addeq(ship.drawOffset)));
			var dir = ship.body.localVectorToWorld(rotateVec(Vec2.get(0, 1, true)));
			var missile = new Missile(pos, dir, ship.body.velocity);

			SoundManager.playSoundAt("missile_launch", pos.copy());
			
			// pos.dispose();
			dir.dispose();
			Main.currentGame.addEntity(missile);
			return true;
		} else {
			return false;
		}
	}
}