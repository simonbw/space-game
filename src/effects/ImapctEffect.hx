package effects;

import nape.geom.Vec2;


class ImapctEffect extends Entity implements Renderable implements Updatable {
	static inline var LIFESPAN = 0.1;

	public var renderDepth:Int;
	var position:Vec2;
	var lifespan:Float;
	var sprite:flash.display.Sprite;

	public function new(position:Vec2) {
		super();
		renderDepth = 50;
		lifespan = LIFESPAN;
		sprite = util.Pool.sprite();
		this.position = position.copy();

		sprite.graphics.beginFill(0xFFFF00);
		sprite.graphics.drawCircle(0, 0, 3);
		sprite.graphics.endFill();
	}

	public function update(timestep:Float):Void {
		lifespan -= timestep;
		if (lifespan <= 0) {
			dispose();
		}
	}

	public function render(surface:flash.display.BitmapData, camera:Camera):Void {
		var g = sprite.graphics;
		g.clear();
		g.beginFill(0xFFFF00);
		g.drawCircle(0, 0, 3 * lifespan / LIFESPAN);
		g.endFill();

		var m = new flash.geom.Matrix();
		m.translate(position.x, position.y);
		camera.getMatrix(m);
		surface.draw(sprite, m);
	}

	override public function dispose():Void {
		super.dispose();
		position.dispose();
		util.Pool.disposeSprite(sprite);
	}

}