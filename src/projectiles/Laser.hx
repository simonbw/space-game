package projectiles;

import flash.display.Sprite;
import util.Pool;
import util.Random;

import nape.geom.Vec2;
import nape.callbacks.*;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.dynamics.InteractionFilter;

class Laser extends Entity implements Renderable implements Updatable {
	static inline var SPEED = 10000;
	static var MATERIAL = new nape.phys.Material(0.1, 0.0, 0.0, 0.001, 1.0);
	
	public var renderDepth:Int;

	var sprite:Sprite;
	public var body:Body;
	public var velocity:Vec2;
	var lifespan:Float;
	static private inline var SIZE:Int = 2;
	
	public function new(position:Vec2, direction:Vec2, offset:Vec2 = null, lifespan:Float = 5.0) {
		super();
		renderDepth = 80;
		this.lifespan = lifespan;
		
		body = new Body(BodyType.DYNAMIC, position);
		body.isBullet = true;
		direction = direction.unit();
		velocity = direction.copy();
		velocity.muleq(Random.normal(SPEED, SPEED / 10));
		if (offset != null) {
			velocity.addeq(offset);
		}
		body.velocity.set(velocity);
		
		body.space = Main.currentGame.space;
		
		var shape = new nape.shape.Circle(SIZE, Vec2.get(0,0), MATERIAL, new InteractionFilter(2, ~2));
		shape.body = body;
		shape.userData.entity = this;
		shape.cbTypes.add(Physics.CB_PROJECTILE);
		
		sprite = Pool.sprite();
		sprite.graphics.lineStyle(0, 0xFFFF00, 0.5);
		var l = SPEED * 0.8 / Main.stage.frameRate;
		sprite.graphics.lineTo(-direction.x  * l, -direction.y * l);
	}

	public function update(timestep:Float):Void {
		lifespan -= timestep;
		if (lifespan < 0) {
			dispose();
		}
	}
	
	public function hit():Void {
		if (!disposed) {
			dispose();
		}
	}

	public function render(surface:flash.display.BitmapData, camera:Camera):Void {
		if (!disposed) {
			var m = new flash.geom.Matrix();
			m.translate(body.position.x, body.position.y);
			camera.getMatrix(m);
			surface.draw(sprite, m);
		}
	}

	override public function dispose():Void {
		super.dispose();
		Pool.disposeSprite(sprite);
		sprite = null;
		body.space = null;
		velocity.dispose();
		velocity = null;
		body = null;
	}
}