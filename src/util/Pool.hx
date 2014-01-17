package util;
import flash.display.Sprite;
import flash.display.Shape;

/**
 */
class Pool
{
	static var spritePool = new Array<Sprite>();
	static var shapePool = new Array<Shape>();
	
	inline static public function sprite():Sprite {
		if (spritePool.length == 0) {
			return new Sprite();
		} else {
			var s = spritePool.pop();
			s.x = 0;
			s.y = 0;
			return s;
		}
	}
	
	inline static public function disposeSprite(s:Sprite):Void {
		s.removeChildren();
		s.graphics.clear();
		spritePool.push(s);
	}

	inline static public function shape():Shape {
		if (shapePool.length == 0) {
			return new Shape();
		} else {
			var s = shapePool.pop();
			s.x = 0;
			s.y = 0;
			return s;
		}
	}
	
	inline static public function disposeShape(s:Shape):Void {
		s.graphics.clear();
		shapePool.push(s);
	}
}