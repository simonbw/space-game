import flash.geom.Point;
import util.MyMath;

import nape.geom.Vec2;

class Stars implements Renderable {
	var points:Array<Point>;
	public var renderDepth:Int;

	public function new() {
		renderDepth = 1000;
		
		points = new Array<Point>();
		var s = flash.Lib.current.stage;
		var max = Math.max(s.stageWidth, s.stageHeight);
		var buffer = 300;
		for (i in 0...300) {
			var x = Std.int(Math.random() * (max + 2 * buffer) - buffer);
			var y = Std.int(Math.random() * (max + 2 * buffer) - buffer);
			points.push(new Point(x,y));
		}
	}

	public function render(surface:flash.display.BitmapData, camera:Camera):Void {
		surface.lock();
		var m = new flash.geom.Matrix();
		m.translate(-camera.width() / 2, -camera.height() / 2);
		m.translate(-camera.position.x / 10, -camera.position.y / 10);
		m.rotate(camera.angle);
		m.translate(camera.width() / 2, camera.height() / 2);
		for (point in points) {
			var p = m.transformPoint(point);
			surface.setPixel(MyMath.modInt(Std.int(p.x), surface.width), MyMath.modInt(Std.int(p.y), surface.height), 0xFFFFFF);
		}
		surface.unlock();
	}
}