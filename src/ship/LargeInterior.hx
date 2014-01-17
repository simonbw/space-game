package ship;

class LargeInterior extends RectangularPart {
	public function new() {
		super(3, 3, 100, 5.0);
		color = 0xDDDDDD;
	}

	override function makeShape():Void {
		super.makeShape();
		shape.filter = Physics.F_HOLLOW_SHIP;
	}
}