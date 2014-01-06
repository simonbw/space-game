package ship;

import nape.geom.Vec2;

class ShieldGenerator extends SmallPart {

	public var rechargeRate:Float;
	public var capacity:Float;

	public function new() {
		super();

		rechargeRate = 3.0;
		capacity = 10.0;
	}

	override public function draw(g:flash.display.Graphics):Void {
		g.lineStyle();
		g.beginFill(0x888888);
		g.drawRect(center.x - drawSize.x / 2, center.y - drawSize.y / 2, drawSize.x, drawSize.y);
		g.endFill();
		g.lineStyle(2, 0x00FFFF);
		g.drawCircle(center.x, center.y, 2);
	}
}