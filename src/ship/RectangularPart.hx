package ship;

import nape.geom.Vec2;
import nape.shape.Shape;
import nape.shape.Polygon;
import nape.phys.Material;

class RectangularPart extends ShipPart {
	static var MATERIAL = Material.steel();

	var shape:Shape;
	var health:Float;
	var maxHealth:Float;
	var color:Int;
	
	public function new(width:Int, height:Int, health:Float = 100.0) {
		super(Vec2.get(width, height));
		this.health = health;
		maxHealth = health;

		color = 0xAAAAAA;
	}

	override public function addToShip(ship:Ship, position:Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		
		shape = new Polygon(Polygon.box(drawSize.x, drawSize.y, true), MATERIAL);
		shape.cbTypes.add(Laser.CB_LASER_HITTABLE);
		ship.body.shapes.add(shape);
		shape.translate(center);
		shape.userData.entity = this;

		for (i in 0...(Std.int(gridSize.x))) {
			for (j in 0...(Std.int(gridSize.y))) {
				var x:Int = i;
				var y:Int = j;
				switch (this.direction) {
					case FORWARD:
						x = i;
						y = j;
					case BACKWARD:
						x = -i;
						y = -j;
					case LEFT:
						x = j;
						y = -i;
					case RIGHT:
						x = -j;
						y = i;
				}
				gridpositions.push({
					x: Std.int(position.x) + x,
					y: Std.int(position.y) + y
				});
			}
		}

		for (i in 0...(Std.int(gridSize.x))) {
			adjacent.push({x: Math.round(position.x + i), y: Math.round(position.y) - 1});
			adjacent.push({x: Math.round(position.x + i), y: Math.round(position.y + gridSize.y)});
		}

		for (i in 0...(Std.int(gridSize.y))) {
			adjacent.push({x: Math.round(position.x) - 1, y: Math.round(position.y) + i});
			adjacent.push({x: Math.round(position.x + gridSize.x), y: Math.round(position.y) + i});
		}

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
		if (ship != null && ship.game != null) {
			var damage = 30.0;
			var shielded = ship.requestShield(damage);
			damage -= shielded;
			health -= damage;
			if (damage > 0.1) {
				ship.game.addEntity(new effects.MetalImpactEffect(hitPos, Math.sqrt(damage)));
			}
			if (shielded > 0.1) {
				ship.game.addEntity(new effects.ShieldImpactEffect(hitPos, Math.sqrt(shielded)));
			}
			if (health <= 0) {
				ship.removePart(this);
			}
		}
	}

	override public function draw(g:flash.display.Graphics, lod:Float):Void {
		g.lineStyle();
		if (health >= maxHealth) {
			g.beginFill(color);
		} else {
			g.beginFill(0xAA0000);
		}
			
		g.drawRect(localPosition.x, localPosition.y, drawSize.x, drawSize.y);
		g.endFill();

		if (lod > 1.0) {
			g.lineStyle(1, 0x00FFFF, 0.2);
			for (part in connectedParts) {
				g.moveTo(center.x, center.y);
				g.lineTo(part.center.x, part.center.y);
			}
		}

		//for (corner in corners) {
			//g.lineStyle(0, 0x666666);
			//g.drawCircle(corner.x, corner.y, 1);
		//}
		// g.lineStyle(1, 0x000000);
		// g.drawCircle(center.x, center.y, 2);
	}
}