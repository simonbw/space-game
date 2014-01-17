package effects;

import flash.display.Graphics;
import nape.geom.Vec2;

class SimpleParticle extends Particle {

	var color:Int;
	var alpha:Float;
	var size:Float;


	public function new(position:Vec2, velocity = null, color:Int = 0xFFFFFF, alpha:Float = 1.0, size:Float = 2.0) {
		this.color = color;
		this.alpha = alpha;
		this.size = size;
	}

	override public function draw(g:Graphics):Void {
		g.beginFill(color, alpha);
		g.drawCircle(position.x, position.y, size);
		g.endFill();
	}
}