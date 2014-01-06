package ship;

import nape.geom.Vec2;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.phys.Material;

class SmallPart extends ShipPart {
	static inline var SIZE = 1;
	static var MATERIAL = Material.steel();

	var shape:Shape;
	var health:Float;
	
	public function new(health:Float = 100.0) {
		super(Vec2.get(SIZE, SIZE));
		this.health = health;
	}

	override public function addToShip(ship:Ship, position:Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		
		shape = new Polygon(Polygon.box(drawSize.x, drawSize.y, true), MATERIAL);
		shape.cbTypes.add(Laser.CB_LASER_HITTABLE);
		ship.body.shapes.add(shape);
		shape.translate(center);
		shape.userData.entity = this;

		adjacent.push({x: Std.int(position.x), y: Std.int(position.y) + 1});
		adjacent.push({x: Std.int(position.x), y: Std.int(position.y) - 1});
		adjacent.push({x: Std.int(position.x) + 1, y: Std.int(position.y)});
		adjacent.push({x: Std.int(position.x) - 1, y: Std.int(position.y)});

		corners = new Array<Vec2>();
		corners.push(Vec2.get(0, 0));
		corners.push(Vec2.get(drawSize.x, 0));
		corners.push(Vec2.get(drawSize.x, drawSize.y));
		corners.push(Vec2.get(0, drawSize.y));

		for (corner in corners) {
			corner.addeq(localPosition);
		}
			
		var n = switch (this.direction) {
			case FORWARD: 0;
			case LEFT: 1;
			case BACKWARD: 2;
			case RIGHT: 3;
		}

		while (n > 0) {
			n--;
			corners.unshift(corners.pop());
		}
	}
	
	override public function onRemove():Void {
		super.onRemove();
		shape.body = null;
	}
	
	override public function hit(hitPos:Vec2, hitVelocity:Vec2):Void {
		super.hit(hitPos, hitVelocity);
		if (ship != null) {
			health -= 34.0;
			if (health <= 0) {
				ship.removePart(this);
			}
		}
	}

	override public function draw(g:flash.display.Graphics):Void {
		g.lineStyle();
		if (health > 99) {
			g.beginFill(0xAAAAAA);
		} else {
			g.beginFill(0xAA0000);
		}
			
		g.drawRect(localPosition.x, localPosition.y, drawSize.x, drawSize.y);
		g.endFill();

		//for (corner in corners) {
			//g.lineStyle(0, 0x666666);
			//g.drawCircle(corner.x, corner.y, 1);
		//}
		// g.lineStyle(1, 0x000000);
		// g.drawCircle(center.x, center.y, 2);
	}
}