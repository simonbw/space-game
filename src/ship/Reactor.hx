package ship;

class Reactor extends BaseReactor {

	public function new() {
		super(28, 128, 3, 3, 500);
		color = 0x777777;
	}

	override public function draw(g:flash.display.Graphics, lod:Float):Void {
		super.draw(g, lod);

		g.lineStyle(5, 0x00FFFF);
		g.drawCircle(center.x, center.y, Ship.GRID_SIZE);
	}
}