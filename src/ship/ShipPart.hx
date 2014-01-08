package ship;

import nape.geom.Vec2;
import de.polygonal.ds.HashSet;
import de.polygonal.ds.Hashable;

class ShipPart implements Hashable implements Hittable {

	public var updatable:Bool;
	public var key:Int;
	public var gridPosition:Vec2;
	public var gridSize:Vec2;
	public var drawSize:Vec2;
	public var connectedParts:HashSet<ShipPart>;
	public var localPosition:Vec2;
	public var center:Vec2;
	public var corners:Array<Vec2>;
	public var direction:Direction;
	public var ship:Ship;
	public var adjacent:Array<{x:Int, y:Int}>;
	public var gridpositions:Array<{x:Int, y:Int}>;

	public function new(size:Vec2) {
		key = Std.int(Math.random() * (2<<16));
		connectedParts = new HashSet<ShipPart>(2<<4);
		adjacent = new Array<{x:Int, y:Int}>();
		gridpositions = new Array<{x:Int, y:Int}>();
		gridSize = size;
		drawSize = Vec2.get(gridSize.x * Ship.GRID_SIZE, gridSize.y * Ship.GRID_SIZE);
		updatable = false;
	}

	public function addToShip(ship:Ship, position:Vec2, direction:Direction = null):Void {
		gridPosition = position;
		localPosition = gridPosition.mul(Ship.GRID_SIZE);
		center = localPosition.addMul(drawSize, 0.5); 
		this.ship = ship;
		if (direction == null) {
			direction = Direction.FORWARD;
		}
		this.direction = direction;
	}

	public function onRemove():Void {
		ship = null;
	}
	
	inline function directionToRadian():Float {
		return switch (direction) {
			case FORWARD: 0.0;
			case BACKWARD: Math.PI;
			case LEFT: -Math.PI / 2;
			case RIGHT: Math.PI / 2;
		}
	}
	
	inline function directionVec(weak:Bool = false):Vec2 {
		return switch (direction) {
			case FORWARD:
				Vec2.get(0, 1, weak);
			case BACKWARD:
				Vec2.get(0, -1, weak);
			case LEFT:
				Vec2.get(1, 0, weak);
			case RIGHT:
				Vec2.get( -1, 0, weak);
		}
	}

	inline function rotateVec(vector:Vec2):Vec2 {
		switch (direction) {
			case FORWARD:
				// do nothing
			case BACKWARD:
				vector.setxy(-vector.x, -vector.y);
			case LEFT:
				vector.setxy(vector.y, -vector.x);
			case RIGHT:
				vector.setxy(-vector.y, vector.x);
		}
		return vector;
	}

	inline function toShipCoords(vector:Vec2):Vec2 {
		rotateVec(vector);
		vector.addeq(gridPosition.mul(Ship.GRID_SIZE, true));
		return vector;
	}

	public function update(timestep:Float):Void {

	}

	public function draw(g:flash.display.Graphics, lod:Float):Void {

	}

	public function getTorque():Float {
		return 0.0;
	}
	
	public function hit(hitPos:Vec2, hitVelocity:Vec2):Void {
		ship.game.addEntity(new effects.ImapctEffect(hitPos));
	}

	public function dispose():Void {
		gridPosition.dispose();
		gridSize.dispose();
		drawSize.dispose();
		connectedParts.free();
		localPosition.dispose();
		center.dispose();
		for (corner in corners) {
			corner.dispose();
		}
		corners = null;
		direction = null;
		ship = null;
		// for (point in adjacent) {
		// 	point.dispose();
		// }
		adjacent = null;
	}
}