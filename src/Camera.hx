
import flash.display.StageDisplayState;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.Lib;

import nape.geom.Vec2;

class Camera {

	public var position:Vec2;
	public var zoom:Float;
	public var angle:Float;

	public function new() {
		position = Vec2.get(0,0);

		zoom = 0.6;
		angle = 0.0;
	}

	public function center(point:Vec2):Void {
		position.set(point);
	}
	
	public function smoothCenter(point:Vec2, speed:Float = 0.5):Void {
		position.set(position.mul(1 - speed, true).addMul(point, speed, true));
	}
	
	public inline function width():Float {
		if (Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN || Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
			return Lib.current.stage.fullScreenWidth;
		} else {
			return Lib.current.stage.stageWidth;
		}
	}

	public inline function height():Float {
		if (Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN || Lib.current.stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
			return Lib.current.stage.fullScreenHeight;
		} else {
			return Lib.current.stage.stageHeight;
		}
	}

	public function screenToWorld(point:Point):Vec2 {
		var m = getMatrix();
		m.invert();
		return Vec2.fromPoint(m.transformPoint(point));
	}

	public function worldToScreen(point:Vec2):Point {
		var m = getMatrix();
		var p = new flash.geom.Point(point.x, point.y);
		return m.transformPoint(p);
	}

	public function getMatrix(m:Matrix = null):Matrix {
		if (m == null) {
			m = new Matrix();
		}

		m.translate(-position.x, -position.y);
		m.scale(zoom, zoom);
		m.rotate(angle);
		m.translate(width() / 2, height() / 2);

		return m;
	}

}