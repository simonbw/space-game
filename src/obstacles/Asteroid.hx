package obstacles;

import flash.display.Sprite;
import flash.display.BitmapData;
import util.Geom;
import util.MyMath;
import util.Random;

import nape.geom.Vec2;
import nape.geom.GeomPoly;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.phys.Body;
import nape.phys.Material;
import nape.callbacks.CbType;

class Asteroid extends Entity implements Renderable implements Hittable {
	static inline var MIN_AREA:Float = 500;
	
	public static var CB_ASTEROID = new CbType();
	
	static var MATERIAL = new Material(0.3, 0.8, 1.8, 12.0);

	public var renderDepth:Int;
	public var body:Body;
	public var gpoly:GeomPoly;
	var offset:Vec2;
	var sprite:Sprite;

	function new(position:Vec2, space:nape.space.Space, gpoly:GeomPoly, angle:Float = 0.0) {
		super();
		renderDepth = 120;
		this.gpoly = gpoly;
		body = new nape.phys.Body();
		body.space = space;
		body.position.set(position);
		
		for (poly in gpoly.convexDecomposition()) {
			var shape = new Polygon(poly, MATERIAL);
			shape.cbTypes.add(CB_ASTEROID);
			shape.cbTypes.add(Laser.CB_LASER_HITTABLE);
			shape.userData.entity = this;
			body.shapes.add(shape);
		}
		offset = body.localCOM.copy();
		body.rotation = angle;
		
		sprite = new Sprite();
		var g = sprite.graphics;
		// g.lineStyle(3, 0x666666);
		g.beginFill(0x666666);
		var i = gpoly.iterator();
		var corner:Vec2;
		corner = i.next();
		g.moveTo(corner.x - offset.x, corner.y - offset.y);
		while (i.hasNext()) {
			corner = i.next();
			g.lineTo(corner.x - offset.x, corner.y - offset.y);
		}
		
		body.align();

		g.endFill();
	}
	
	static public function newRandom(position:Vec2, space:nape.space.Space):Asteroid {
		var corners = new Array<Vec2>();
		var theta = 0.0;
		var size = Random.normal(100, 50);
		while (theta < Math.PI * 2) {
			var r = size + size * Math.random() * 0.7;
			corners.push(Vec2.fromPolar(r, theta));
			theta += 0.5;
		}
		var gpoly = GeomPoly.get(corners);
		return new Asteroid(position, space, gpoly);
	}

	public function render(surface:BitmapData, camera:Camera):Void {
		var m = new flash.geom.Matrix();
		m.rotate(body.rotation);
		m.translate(body.position.x, body.position.y);
		camera.getMatrix(m);
		surface.draw(sprite, m);
	}
	
	public function hit(hitPos:Vec2, hitVelocity:Vec2):Void {
		game.addEntity(new effects.AsteroidImpactEffect(hitPos, Random.normal(3, 0.3)));
		if (!disposed && Random.bool(0.1)) {
			// store stuff about the body
			var pos2 = body.position.copy();
			var pos = body.position.copy().sub(body.localVectorToWorld(offset));
			var vel = body.velocity.copy();
			var rotation = body.rotation;
			var angularVel = body.angularVel;
			
			// calculate cut points
			hitVelocity = hitVelocity.unit();
			var cutStartPoint = body.worldPointToLocal(hitPos.sub(hitVelocity)).add(offset);
			var cutDirection = body.worldVectorToLocal(hitVelocity);
			
			body.space = null; // get this out of the way
			
			for (g in Geom.crackPoly(gpoly, cutStartPoint, cutDirection, 1)) {
				if (g.isSimple() && (g.area() > MIN_AREA)) {
					var a = new Asteroid(pos, game.space, g, rotation);
					a.body.velocity = vel;
					a.body.angularVel = angularVel;
					
					a.body.applyImpulse(a.body.position.sub(pos2, true).mul(50, true), pos2);
					Main.currentGame.addEntity(a);
				} else {
					if (!g.isSimple()) {
						Main.log("Non-simple polygon");
					}
				}
			}
			
			hitVelocity.dispose();
			cutStartPoint.dispose();
			cutDirection.dispose();
			
			dispose();
		}
	}

	override public function dispose():Void {
		super.dispose();
		gpoly.dispose();
		body.space = null;
		sprite = null;
	}
}