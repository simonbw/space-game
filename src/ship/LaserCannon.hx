package ship;


import nape.geom.Vec2;
import nape.phys.Material;

class LaserCannon extends SmallPart {
	
	static inline var INTERVAL = 0.15;
	
	var cooldown:Float;

	public function new() {
		super();
		cooldown = 0;
	}

	override public function update(timestep:Float):Void {
		if (cooldown > 0) {
			cooldown -= timestep;
		}
	}

	public function fire():Bool {
		if (cooldown <= 0) {
			cooldown += INTERVAL;
			var pos = ship.body.localPointToWorld(toShipCoords(Vec2.get(0, 0, true)));
			var dir = ship.body.localVectorToWorld(rotateVec(Vec2.get(0, 1, true)));
			var l = new Laser(pos, dir, ship.body.velocity);
			// pos.dispose();
			// dir.dispose();
			Main.currentGame.addEntity(l);
			return true;
		} else {
			return false;
		}
	}

	override public function draw(g:flash.display.Graphics):Void {
		g.lineStyle();
		// g.lineStyle(1, 0x666666);
		g.beginFill(0x888888);
		g.drawRect(center.x - drawSize.x / 2, center.y - drawSize.y / 2, drawSize.x, drawSize.y);
		g.endFill();

		// g.lineStyle(1, 0x00FFFF);
		// g.moveTo(localPosition.x, localPosition.y);
		// var point = Vec2.get(0, size.y / 2);
		// toShipCoords(point);
		// g.lineTo(point.x, point.y);
		// point.dispose();
		// g.lineStyle(1, 0x00FF00);
	}
}