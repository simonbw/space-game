package ship;

import nape.geom.Vec2;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.phys.Material;

class Engine extends SmallPart {
	static inline var THROTTLE_INCREMENT = 0.3;

	public var throttle(get, set):Float;
	var _throttle:Float;
	var targetThrottle:Float;
	public var power:Float;
	public var maneuverable:Bool;

	public function new(maneuverable:Bool = true, power:Float = 4000.0) {
		super();
		this.power = power;
		this.maneuverable = maneuverable;
		targetThrottle = 0.0;
		_throttle = 0.0;
	}

	public inline function set_throttle(value:Float):Float {
		targetThrottle = Math.max(Math.min(value, 1.0), 0.0);
		return targetThrottle;
	}

	public inline function get_throttle():Float {
		return targetThrottle;
	}

	override public function update(timestep:Float):Void {
		var diff = Math.min(Math.max(targetThrottle - _throttle, -THROTTLE_INCREMENT), THROTTLE_INCREMENT);
		_throttle = Math.max(Math.min(_throttle + diff, 1.0), 0.0);
		
		if (_throttle > 0) {
			var d = Math.PI / 2 + ship.body.rotation + directionToRadian();
			var thrust = _throttle * timestep * power;
			var impulse = Vec2.get(Math.cos(d) * thrust, Math.sin(d) * thrust, true);
			var impulsePoint = shape.worldCOM;
			ship.body.applyImpulse(impulse, impulsePoint);
		}
	}

	override public function draw(g:flash.display.Graphics):Void {
		super.draw(g);
		g.lineStyle(1, 0xFF6600);
		g.moveTo(corners[0].x, corners[0].y);
		g.lineTo(corners[1].x, corners[1].y);

		if (_throttle > 0) {
			var tip = rotateVec(Vec2.get(0, -drawSize.y / 2 - (15 * _throttle * (0.85 + 0.3 * Math.random()) * power / 4000)));
			tip.addeq(center);
			g.beginFill(0xFF9900);
			g.moveTo(corners[0].x, corners[0].y);
			g.lineTo(tip.x, tip.y);
			g.lineTo(corners[1].x, corners[1].y);
			g.endFill();
			tip.dispose();
		}
	}
}