package ship;

import flash.display.Sprite;
import flash.display.BitmapData;
import flash.geom.Matrix;
import flash.display.GradientType;
import util.MyMath;
import util.Pool;

import nape.phys.Body;
import nape.shape.Shape;
import nape.geom.Vec2;

class Ship extends Entity implements Renderable implements Updatable implements Updatable2 {
	static public inline var GRID_SIZE = 16;

	public var renderDepth:Int;

	var parts:Array<ShipPart>;
	var partMap:util.CoordinateMap<ShipPart>;
	var needToRealign:Bool;

	var engines:Array<Engine>;
	var reactors:Array<Reactor>;
	var shieldGenerators:Array<ShieldGenerator>;

	public var energy:Float;
	public var energyConsumption:Float;
	public var energyProduction:Float;
	public var energyLoad:Float;
	public var maxEnergy:Float;

	public var shield:Float;
	public var maxShield:Float;


	var sprite:Sprite;
	var drawOffset:Vec2;
	public var body:Body;

	public function new(position:Vec2) {
		super();
		renderDepth = 100;

		needToRealign = false;
		parts = new Array<ShipPart>();
		partMap = new util.CoordinateMap<ShipPart>();
		engines = new Array<Engine>();
		reactors = new Array<Reactor>();
		shieldGenerators = new Array<ShieldGenerator>();
		body = new Body();
		body.position.set(position);
		// body.isBullet = true;
		energyLoad = 0.0;
		maxEnergy = 10.0;
		energy = maxEnergy;
		shield = 0.0;
		maxShield = 0.0;

		this.drawOffset = Vec2.get(0, 0);
		if (drawOffset != null) {
			this.drawOffset.set(drawOffset);
		}
		sprite = Pool.sprite();
	}

	override public function init(game:Game):Void {
		super.init(game);
		body.space = game.space;
	}

	public function realign():Void {
		drawOffset.subeq(body.localCOM);
		body.align();
	}

	public function addPart(part:ShipPart, x:Int, y:Int, direction:Direction = null):Void {
		needToRealign = true;
		parts.push(part);
		part.addToShip(this, Vec2.get(x, y), direction);
		for (p in part.gridpositions) {
			partMap.set(p.x, p.y, part);
		}
		for (a in part.adjacent) {
			if (partMap.exists(a.x, a.y)) {
				var other = partMap.get(a.x, a.y);
				part.connectedParts.set(other);
				other.connectedParts.set(part);
			}
		}
		if (Std.is(part, Engine)) {
			engines.push(cast(part, Engine));
		}
		if (Std.is(part, Reactor)) {
			reactors.push(cast(part, Reactor));
		}
		if (Std.is(part, ShieldGenerator)) {
			shieldGenerators.push(cast(part, ShieldGenerator));
		}
	}

	/**
	 * Remove a part from the ship. Does not handle what the part should do.
	 * @param	part
	 * @return
	 */
	public function removePart(part:ShipPart):Void {
		needToRealign = true;
		part.onRemove();
		parts.remove(part);
		for (p in part.gridpositions) {
			partMap.remove(p.x, p.y);
		}
		if (Std.is(part, ship.Engine)) {
			engines.remove(cast(part, ship.Engine));
		}
		if (Std.is(part, Reactor)) {
			reactors.remove(cast(part, Reactor));
		}
		if (Std.is(part, ShieldGenerator)) {
			shieldGenerators.remove(cast(part, ShieldGenerator));
		}

		// remove from connections
		for (connectedPart in part.connectedParts) {
			connectedPart.connectedParts.remove(part);
		}

		if (parts.length == 0) {
			dispose();
		}
	}

	/**
	 * Remove part at a location
	 * @param  x
	 * @param  y
	 * @return   the part that was removed or null
	 */
	public function removePartAt(x:Int, y:Int):ShipPart {
		var part = partMap.get(x, y);
		removePart(part);
		return part;
	}

	/**
	 * Removes all parts that are not connected to (0,0) from the ship.
	 */
	public function removeDisconnected():Void {
		var queue = new Array<ShipPart>();
		var connected = new de.polygonal.ds.HashSet<ShipPart>(256);
		queue.push(parts[0]);
		while (queue.length > 0) {
			var part = queue.pop();
			connected.set(part);
			for (connectedPart in part.connectedParts) {
				if (!connected.contains(connectedPart)) {
					queue.push(connectedPart);
				}
			}
		}

		var toRemove = new Array<ShipPart>();
		for (part in parts) {
			if (!connected.contains(part)) {
				toRemove.push(part);
			}
		}

		if (toRemove.length > 0) {
			var other = new Ship(body.position.add(body.localVectorToWorld(drawOffset)));
			other.body.rotation = body.rotation;
			other.body.velocity.set(body.velocity);
			for (part in toRemove) {
				var x = Std.int(part.gridPosition.x);
				var y = Std.int(part.gridPosition.y);
				var d = part.direction;
				removePart(part);
				other.addPart(part, x, y, d);
			}

			other.realign();
			game.addEntity(other);
		}
	}

	/**
	 * Call every frame
	 * @param	timestep
	 */
	public function update(timestep:Float):Void {
		if (needToRealign) {
			removeDisconnected();
			realign();
			needToRealign = false;
		}

		energyConsumption = 0.0;
		energyProduction = 0.0;
		giveEnergy(timestep);
		for (part in reactors) {
			part.update(timestep);
		}
		for (part in shieldGenerators) {
			part.update(timestep);
		}
		for (part in parts) {
			if (part.updatable) {
				part.update(timestep);
			}
		}

		if (energy < energyConsumption) {
			energyLoad = 0.8 * energyLoad + 0.2 * energyConsumption / energyProduction;
		} else {
			energyLoad = 0.8 * energyLoad;

		}

		if (energy > maxEnergy) {
			energy = maxEnergy;
		}
		if (shield > maxShield) {
			shield = maxShield;
		}
	}

	/**
	 * Called after physics.
	 * @param	timestep
	 */
 	public function update2(timestep:Float):Void {

	}

	/**
	 * Turn the ship.
	 * @param	amount	> 0 means right, < 0 means left
	 */
	public function turn(amount:Float):Void {
		if (amount > 0) {
			turnRight(amount);
		}
		if (amount < 0) {
			turnLeft(-amount);
		}
	}

	/**
	 * Event handler for when hit by a projectile.
	 * @param	position
	 * @param	velocity
	 */
	public function hit(position:Vec2, velocity:Vec2):Void {

	}

	public function requestEnergy(amount:Float):Float {
		energyConsumption += amount;
		var result = MyMath.min(amount, energy);
		if (energyLoad > 1.0) {
			result /= energyLoad;
		}
		energy -= result;
		energy = MyMath.max(energy, 0);
		return result;
	}

	public function giveEnergy(amount:Float):Void {
		energyProduction += amount;
		energy += amount;
	}

	public function requestShield(amount:Float):Float {
		var result = MyMath.min(amount, shield);
		shield -= result;
		return result;
	}

	/**
	 * Turn the ship left.
	 * @param	amount
	 */
	function turnLeft(amount:Float):Void {
		amount = Math.min(Math.max(0, amount), 1.0);
		var center = body.localCOM;
		for (engine in engines) {
			if (!engine.maneuverable) {
				continue;
			}
			if (engine.direction == RIGHT && engine.center.y < center.y - drawOffset.y - 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			} else if (engine.direction == LEFT && engine.center.y > center.y - drawOffset.y + 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			} else if (engine.direction == FORWARD && engine.center.x < center.x - drawOffset.x - 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			} else if (engine.direction == BACKWARD && engine.center.x > center.x - drawOffset.x + 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			}
		}
	}

	/**
	 * Turn the ship right.
	 * @param	amount
	 */
	function turnRight(amount:Float):Void {
		amount = Math.min(Math.max(0, amount), 1.0);
		var center = body.localCOM;
		for (engine in engines) {
			if (!engine.maneuverable) {
				continue;
			}
			if (engine.direction == RIGHT && engine.center.y > center.y - drawOffset.y + 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			} else if (engine.direction == LEFT && engine.center.y < center.y - drawOffset.y - 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			} else if (engine.direction == FORWARD && engine.center.x > center.x - drawOffset.x + 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			} else if (engine.direction == BACKWARD && engine.center.x < center.x - drawOffset.x - 1) {
				engine.throttle = (Math.max(engine.throttle, amount));
			}
		}
	}

	/**
	 * Thrust in a given direction.
	 * @param	amount
	 * @param	direction
	 */
	public function thrust(amount:Float, direction:Direction):Void {
		amount = Math.min(Math.max(0, amount), 1.0);
		for (engine in engines) {
			if (engine.direction == direction) {
				engine.throttle = (Math.max(engine.throttle, amount));
			}
		}
	}

	/**
	 * Attempt to stop the rotation of the ship.
	 */
	public function stabilizeRotation():Void {
		if (body.angularVel > 0.0001) {
			turnLeft(Math.min(0.9, 1.5 * body.angularVel));
		}
		if (body.angularVel < -0.0001) {
			turnRight(-Math.max(-0.9, 1.5 * body.angularVel));
		}
	}

	/**
	 * Attempt to match a given linear velocity.
	 * @param	targetVelocity
	 */
	public function stabilizeLinear(targetVelocity:Vec2 = null):Void {
		if (targetVelocity == null) {
			targetVelocity = Vec2.get(0, 0, true);
		}

		var v = body.velocity.sub(targetVelocity);
		if (v.length > 0.01) {
			var a = body.localVectorToWorld(Vec2.get(1, 0, true));
			var b = body.localVectorToWorld(Vec2.get(0, 1, true));

			var adotv = a.dot(v);
			var bdotv = b.dot(v);
			if (adotv > 0.01) {
				thrust(Math.min(0.9, adotv / 10), RIGHT);
			} else if (a.dot(v) < -0.01) {
				thrust(Math.min(0.9, -adotv / 10), LEFT);
			}

			if (bdotv > 0.01) {
				thrust(Math.min(0.9, bdotv / 10), BACKWARD);
			} else if (b.dot(v) < -0.01) {
				thrust(Math.min(0.9, -bdotv / 10), FORWARD);
			}

			a.dispose();
			b.dispose();
			v.dispose();
		}
	}

	public function clearEngines():Void {
		for (engine in engines) {
			engine.throttle = (0.0);
		}
	}

	public function fireLasers() {
		for (part in parts) {
			if (Std.is(part, ship.LaserCannon)) {
				cast(part, ship.LaserCannon).fire();
			}
		}
	}

	public function render(surface:BitmapData, camera:Camera):Void {
		var g = sprite.graphics;
		g.clear();
		for (part in parts) {
			part.draw(g, camera.zoom);
		}

		var m = new flash.geom.Matrix();
		m.translate(drawOffset.x, drawOffset.y);
		m.rotate(body.rotation);
		m.translate(body.position.x, body.position.y);
		camera.getMatrix(m);
		surface.draw(sprite, m, null, null, null, true);
	}

	override public function dispose():Void {
		super.dispose();
		body.space = null;
		Pool.disposeSprite(sprite);
		sprite = null;
		partMap = null;
		shieldGenerators = null;
		engines = null;
		reactors = null;
	}
}