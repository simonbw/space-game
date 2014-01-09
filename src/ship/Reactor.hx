package ship;

class Reactor extends RectangularPart {
	static inline var ENERGY_CAPACITY = 100;
	static inline var ENERGY_PRODUCTION = 15;

	public function new() {
		super(3, 3, 500);

		color = 0x777777;
	}

	override public function update(timestep:Float):Void {
		ship.giveEnergy(timestep * ENERGY_PRODUCTION);
	}

	override public function addToShip(ship:Ship, position:nape.geom.Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		ship.maxEnergy += ENERGY_CAPACITY;
	}

	override public function onRemove():Void {
		ship.maxEnergy -= ENERGY_CAPACITY;
		super.onRemove();
	}

	override public function draw(g:flash.display.Graphics, lod:Float):Void {
		super.draw(g, lod);

		g.lineStyle(5, 0x00FFFF);
		g.drawCircle(center.x, center.y, Ship.GRID_SIZE);
	}
}