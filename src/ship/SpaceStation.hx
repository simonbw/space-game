package ship;

import nape.geom.Vec2;

class SpaceStation extends Ship {
	
	public function new(position:Vec2) {
		super(position);
		body.type = nape.phys.BodyType.STATIC;

		renderDepth -= 1;
	}

	override public function removeDisconnected():Void {
		// do nothing
	}
	override public function realign():Void {
		// do nothing
	}
}