package ship;

import nape.geom.Vec2;

/**
 * Does nothing but provide protection.
 */
class Hull extends RectangularPart {
	public function new() {
		super(1, 1, 300, 15.0);
	}

	override function makeShape():Void {
		super.makeShape();
		shape.material = Physics.M_HEAVY_METAL;
	}
}