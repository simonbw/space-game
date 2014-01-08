package ship;


import nape.geom.Vec2;
import nape.phys.Material;

class LaserCannon extends RectangularPart {
	
	static inline var INTERVAL = 0.15;
	static inline var ENERGY_USE = 10.0;
	
	var cooldown:Float;

	public function new() {
		super(1, 1);
		cooldown = 0;
		updatable = true;

		color = 0xFFFFFF;
	}

	override public function update(timestep:Float):Void {
		if (cooldown > 0) {
			cooldown -= ship.requestEnergy(timestep * ENERGY_USE) / ENERGY_USE;
		}
	}

	public function fire():Bool {
		if (cooldown <= 0) {
			cooldown += INTERVAL;
			var pos = ship.body.localPointToWorld(toShipCoords(Vec2.get(0, drawSize.y / 2 + 3, true)));
			var dir = ship.body.localVectorToWorld(rotateVec(Vec2.get(0, 1, true)));
			var l = new Laser(pos, dir, ship.body.velocity);
			// pos.dispose();
			// dir.dispose();
			Main.currentGame.addEntity(l);
			return true;
		} else {
			return false;
		}
	}
}