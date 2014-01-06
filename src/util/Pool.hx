package util;
import flash.display.Sprite;

/**
 */
class Pool
{
	static var spritePool = new Array<Sprite>();
	
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
}