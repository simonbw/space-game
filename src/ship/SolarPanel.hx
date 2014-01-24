package ship;

class SolarPanel extends BaseReactor {

	public function new() {
		super(5, 2.5, 1, 1, 60);
		color = 0x050577;
	}

	override public function draw(g:flash.display.Graphics, lod:Float):Void {
		super.draw(g, lod);

		if (lod > 0.7) {
			g.lineStyle(0, 0x000000, util.MyMath.limit(0.35 * (lod - 0.7), 0, 1.0));
			for (i in 0...5) {
				g.moveTo(localPosition.x + i * 4, localPosition.y);
				g.lineTo(localPosition.x + i * 4, localPosition.y + Ship.GRID_SIZE);
				g.moveTo(localPosition.x, localPosition.y + i * 4);
				g.lineTo(localPosition.x + Ship.GRID_SIZE, localPosition.y + i * 4);
			}
		}

		if (lod > 2.2) {
			g.lineStyle(0, 0x000000, util.MyMath.limit(0.5 * (lod - 2.2), 0, 0.6));
			for (i in 1...16) {
				g.moveTo(localPosition.x + i, localPosition.y);
				g.lineTo(localPosition.x + i, localPosition.y + Ship.GRID_SIZE);
				g.moveTo(localPosition.x, localPosition.y + i);
				g.lineTo(localPosition.x + Ship.GRID_SIZE, localPosition.y + i);
			}
		}
	}
}