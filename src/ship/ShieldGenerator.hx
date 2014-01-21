package ship;

import nape.geom.Vec2;

class ShieldGenerator extends RectangularPart {
	static inline var EFFICIENCY = 8.0;

	public var rechargeRate:Float;
	public var capacity:Float;

	public function new() {
		super(1, 1, 50);
		color = 0xFFEEBB;
		rechargeRate = 64.0;
		capacity = 64.0;
		updatePriority = 60;
	}

	override public function addToShip(ship:Ship, position:nape.geom.Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		ship.maxShield += capacity;
		ship.addUpdatePart(this);
	}

	override public function onRemove():Void {
		ship.maxShield -= capacity;
		super.onRemove();
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);

		var diff = ship.maxShield - ship.shield;
		var e = util.MyMath.min(diff, rechargeRate * timestep) / EFFICIENCY;
		ship.shield += ship.requestEnergy(e, EnergyType.SHIELD) * EFFICIENCY;
	}
}