package projectiles;

import flash.display.Sprite;
import util.Pool;
import util.Random;

import nape.geom.Vec2;
import nape.phys.Body;
import nape.shape.Shape;
import nape.phys.BodyType;
import nape.dynamics.InteractionFilter;

class Projectile extends Entity implements Renderable implements Updatable implements Updatable2 {
	static inline var SIZE:Int = 2;
	
	public var renderDepth:Int;
	public var body:Body;
	public var velocity:Vec2;
	public var info:ProjectileInfo;
	var needToDraw:Bool;
	var sprite:Sprite;
	var lifespan:Float;
	
	public function new(position:Vec2, info:ProjectileInfo, lifespan:Float = 5.0) {
		super();
		renderDepth = 80;
		this.info = info;
		this.lifespan = lifespan;
		velocity = Vec2.get();
		makeBody(position);
		sprite = Pool.sprite();
		needToDraw = true;
	}

	function makeBody(position:Vec2):Void{
		body = new Body(BodyType.DYNAMIC, position);
		body.isBullet = true;
		
		var shape = new nape.shape.Circle(SIZE, Vec2.get(0,0));
		shape.body = body;
		shape.userData.entity = this;
		shape.cbTypes.add(Physics.CB_PROJECTILE);
	}

	override public function init(game:Game):Void {
		super.init(game);
		body.space = game.space;
	}

	public function update(timestep:Float):Void {
		velocity.set(body.velocity);
		if (lifespan != 0) {
			lifespan -= timestep;
			if (lifespan <= 0) {
				dispose();
			}
		}
	}


	public function update2(timestep:Float):Void {
		if (!disposed && lifespan < 0) {
			dispose();
		}
	}
	
	public function hit():Bool {
		lifespan = -1;
		return true;
	}

	function draw():Void {
		var g = sprite.graphics;
		g.beginFill(0xFF0000);
		g.drawCircle(0, 0, 2);
		g.endFill();
		needToDraw = false;
	}

	public function render(surface:flash.display.BitmapData, camera:Camera):Void {
		if (!disposed) {
			if (needToDraw) {
				draw();
			}
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
		body = null;
	}
}