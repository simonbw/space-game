package ship;

class Battery extends RectangularPart {
	static inline var ENERGY_CAPACITY = 100;

	public function new() {
		super(1, 1);
		color = 0x55AADD;
	}

	override public function addToShip(ship:Ship, position:nape.geom.Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		ship.maxEnergy += ENERGY_CAPACITY;
	}

	override public function onRemove():Void {
		ship.maxEnergy -= ENERGY_CAPACITY;
		super.onRemove();
	}

}