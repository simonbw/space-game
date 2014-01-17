package ship;

class Interior extends RectangularPart {
	public function new() {
		super(1, 1, 100, 5.0);
		color = 0xDDDDDD;
	}
	
	override function makeShape():Void {
		super.makeShape();
		shape.filter = Physics.F_HOLLOW_SHIP;
	}
}