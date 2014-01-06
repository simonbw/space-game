

import flash.display.Sprite;
import util.Pool;

import nape.geom.Vec2;
import nape.callbacks.*;
import nape.phys.Body;
import nape.phys.BodyType;
import nape.dynamics.InteractionFilter;

class Laser extends Entity implements Renderable implements Updatable {
	static inline var SPEED = 3200;
	public static var CB_LASER = new CbType();
	public static var CB_LASER_HITTABLE = new CbType();
	static var MATERIAL = new nape.phys.Material(0.1, 0.0, 0.0, 0.001, 1.0);
	
	public var renderDepth:Int;

	var sprite:Sprite;
	public var body:Body;
	public var velocity:Vec2;
	var lifespan:Float;
	static private inline var SIZE:Int = 2;

	static public function initLaser(space:nape.space.Space):Void {
		var listener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, [CB_LASER], [CB_LASER_HITTABLE], function(cb:InteractionCallback) {
			var laser = cast(cb.int1.castShape.userData.entity, Laser);
			if (laser != null && !laser.disposed) {
				var other = cast(cb.int2.castShape.userData.entity, Hittable);
				try {
					if (other != null) {
						var p = laser.body.position;
						var v = laser.velocity;
						other.hit(p, v);
					}
				} catch (error:Dynamic) {
					Main.log("Collision Error: " + error);
				}
				laser.hit();
			}
		});
		listener.space = space;
	}
	
	public function new(position:Vec2, direction:Vec2, offset:Vec2 = null, lifespan:Float = 5.0) {
		super();
		renderDepth = 80;
		this.lifespan = lifespan;
		
		body = new Body(BodyType.DYNAMIC, position);
		body.isBullet = true;
		velocity = direction.unit();
		velocity.muleq(SPEED);
		if (offset != null) {
			velocity.addeq(offset);
		}
		body.velocity.set(velocity);
		
		body.space = Main.currentGame.space;
		
		var shape = new nape.shape.Circle(SIZE, Vec2.get(0,0), MATERIAL, new InteractionFilter(2, ~2));
		shape.body = body;
		shape.userData.entity = this;
		shape.cbTypes.add(CB_LASER);
		
		sprite = Pool.sprite();
		sprite.graphics.lineStyle(0, 0xFFFF00);
		sprite.graphics.lineTo(-velocity.x / Main.stage.frameRate * 0.8, -velocity.y / Main.stage.frameRate * 0.8);
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