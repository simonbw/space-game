package ship;

import nape.geom.Vec2;
import de.polygonal.ds.HashSet;
import de.polygonal.ds.Hashable;

/**
 * Parent of all ship parts. Added to a ship.
 */
class ShipPart implements Hashable implements Hittable {

	/** Grid positions that can connect to this part */
	public var adjacent:Array<{x:Int, y:Int}>;
	/** Armor value */
	public var armor:Float;
	/** Center of this part in sprite coordinates */
	public var center:Vec2;
	/** Set of all parts connect to this part */
	public var connectedParts:HashSet<ShipPart>;
	/** Location of corners in sprite coordinates */
	public var corners:Array<Vec2>;
	/** Facing direction */
	public var direction:Direction;
	/** width,height in sprite coordinates */
	public var drawSize:Vec2;
	/** x,y in grid coordinates */
	public var gridPosition:Vec2;
	/** All the grid positions this part occupies */
	public var gridpositions:Array<{x:Int, y:Int}>;
	/** width,height in grid coordinates */
	public var gridSize:Vec2;
	/** Number of hit points */
	public var health:Float;
	/** For hashing */
	public var key:Int;
	/** The position in local ship coordinates */
	public var localPosition:Vec2;
	/** Health when fully repaired */
	public var maxHealth:Float;
	/** The ship that has this part */
	public var ship:Ship;
	/** Priority to update */
	public var updatePriority:Int;

	/**
	 * [new description]
	 * @param  size           [description]
	 * @param  health         [description]
	 * @param  armor          [description]
	 * @param  updatePriority [description]
	 * @return                [description]
	 */
	public function new(size:Vec2, health:Float = 100.0, armor:Float = 1.0, updatePriority = 0) {
		this.health = health;
		this.maxHealth = health;
		this.armor = armor;
		this.updatePriority = updatePriority;
		key = Std.int(Math.random() * (2<<16));
		connectedParts = new HashSet<ShipPart>(2<<4);
		adjacent = new Array<{x:Int, y:Int}>();
		gridpositions = new Array<{x:Int, y:Int}>();
		gridSize = size;
		drawSize = Vec2.get(gridSize.x * Ship.GRID_SIZE, gridSize.y * Ship.GRID_SIZE);
	}

	/**
	 * [addToShip description]
	 * @param ship      [description]
	 * @param position  [description]
	 * @param direction [description]
	 */
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

	/**
	 * [onDestroy description]
	 * @return [description]
	 */
	function onDestroy():Void {

	}

	/**
	 * [onRemove description]
	 * @return [description]
	 */
	public function onRemove():Void {
		ship = null;
	}
	
	/**
	 * [directionToRadian description]
	 * @return [description]
	 */
	inline function directionToRadian():Float {
		return switch (direction) {
			case FORWARD: 0.0;
			case BACKWARD: Math.PI;
			case LEFT: -Math.PI / 2;
			case RIGHT: Math.PI / 2;
		}
	}
	
	/**
	 * [directionVec description]
	 * @param  weak [description]
	 * @return      [description]
	 */
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

	/**
	 * [rotateVec description]
	 * @param  vector [description]
	 * @return        [description]
	 */
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

	/**
	 * [toShipCoords description]
	 * @param  vector [description]
	 * @return        [description]
	 */
	inline function toShipCoords(vector:Vec2):Vec2 {
		// rotateVec(vector);
		vector.addeq(center);
		return vector;
	}

	/**
	 * [getWorldPosition description]
	 * @param  weak [description]
	 * @return      [description]
	 */
	public inline function getWorldPosition(weak:Bool = false):Vec2 {
		return ship.body.localPointToWorld(center, weak);
	}

	/**
	 * [update description]
	 * @param  timestep [description]
	 * @return          [description]
	 */
	public function update(timestep:Float):Void {
		if (health <= 0) {
			ship.removePart(this);
		}
	}

	/**
	 * [draw description]
	 * @param  g.display.Graphics [description]
	 * @param  lod                [description]
	 * @return                    [description]
	 */
	public function draw(g:flash.display.Graphics, lod:Float):Void {

	}

	/**
	 * [getTorque description]
	 * @return [description]
	 */
	public function getTorque():Float {
		return 0.0;
	}
	
	/**
	 * Inflict a certain amount of damage to the ship.
	 * @param  amount damage to inflict
	 * @return        amount of damage shielded
	 */
	public inline function inflictDamage(amount:Float, damageType:DamageType):Float {
		var shielded = 0.0;
		if (damageType != DamageType.Collsion) {
			shielded = ship.requestShield(amount);
		}
		amount -= shielded;
		amount = Math.max(amount - armor, 0);
		health -= amount;
		if (health <= 0) {
			ship.partsToRemove.push(this);
			onDestroy();
		} else if (amount > 0) {
			if (connectedParts.size() > 0) {
				var chance = 2.0 * amount / (maxHealth + 1.5 * health) / connectedParts.size();
				if (util.Random.bool(chance)) {
					for (p in connectedParts) {
						p.connectedParts.remove(this);
					}
					connectedParts.clear();
					ship.needToRealign = true;
				}
			}
		}
		return shielded;
	}

	/**
	 * [hit description]
	 * @param  hitPos                [description]
	 * @param  projectile.Projectile [description]
	 * @return                       [description]
	 */
	public function hit(hitPos:Vec2, projectile:projectiles.Projectile):Bool {
		if (ship != null && ship.game != null) {
			var damage = projectile.info.damage;
			var shielded = inflictDamage(damage, projectile.info.damageType);
			
			// effects
			damage -= shielded;
			if (damage > 0.1) {
				ship.game.addEntity(new effects.MetalImpactEffect(hitPos, Math.sqrt(damage)));
			}
			if (shielded > 0.1) {
				ship.game.addEntity(new effects.ShieldImpactEffect(hitPos, Math.sqrt(shielded)));
			}
		}
		return (health > 0);
	}

	/**
	 * [dispose description]
	 * @return [description]
	 */
	public function dispose():Void {
		Main.log("DISPOSING " + this);
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

	/**
	 * [serialize description]
	 * @return [description]
	 */
	public function serialize():String {
		return Type.getClassName(Type.getClass(this)) + " " + gridPosition.x + " " + gridPosition.y + " " + direction;
	}
}