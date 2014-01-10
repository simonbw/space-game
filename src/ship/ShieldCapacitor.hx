package ship;

import nape.geom.Vec2;

class ShieldCapacitor extends RectangularPart {
	public var capacity:Float;

	public function new() {
		super(1, 1, 50);
		color = 0xFFDDAA;
		capacity = 200.0;
	}

	override public function addToShip(ship:Ship, position:nape.geom.Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		ship.maxShield += capacity;
	}

	override public function onRemove():Void {
		ship.maxShield -= capacity;
		super.onRemove();
	}
}