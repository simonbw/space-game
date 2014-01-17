package effects;

import nape.geom.Vec2;


class CollisionEffect extends Entity implements Renderable implements Updatable {
	static inline var LIFESPAN = 0.2;

	public var renderDepth:Int;
	var position:Vec2;
	var lifespan:Float;
	var size:Float;
	var color:Int;
	var sprite:flash.display.Sprite;

	public function new(position:Vec2, normal:Vec2, size:Float, color:Int = 0xFFBB00) {
		super();
		renderDepth = 50;
		lifespan = LIFESPAN;
		this.position = position.copy();
		this.size = size;
		this.color = color;
		sprite = util.Pool.sprite();
		sprite.graphics.beginFill(color);
		sprite.graphics.drawCircle(0, 0, size);
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
		g.beginFill(color);
		g.drawCircle(0, 0, size * lifespan / LIFESPAN);
		g.endFill();

		var m = new flash.geom.Matrix();
		m.translate(position.x, position.y);
		camera.getMatrix(m);
		surface.draw(sprite, m);
	}

	override public function dispose():Void {
		super.dispose();
		position.dispose();
		position = null;
		util.Pool.disposeSprite(sprite);
		sprite = null;
	}
}