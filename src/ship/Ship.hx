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

class Ship extends Entity implements Renderable implements Updatable implements Updatable2 implements Hittable {
	static public inline var GRID_SIZE = 16;

	public var renderDepth:Int;

	/** All the parts on the ship **/
	public var parts:Array<ShipPart>;
	/** Parts that need to be updated **/
	var updateParts:Array<ShipPart>;
	/** Parts that need to be updated **/
	public var partsToRemove:Array<ShipPart>;
	/** parts that need to be redrawn **/
	var dirtyParts:Array<ShipPart>;
	/** A map from grid position to part **/
	var partMap:util.CoordinateMap<ShipPart>;
	/** True if the ship needs to be realigned because its local COM has changed **/
	public var needToRealign:Bool;
	/** All the engines on the ship **/
	var engines:Array<Engine>;
	/** All the reactors on the ship **/
	var reactors:Array<Reactor>;
	/** All the shield generators on the ship **/
	var shieldGenerators:Array<ShieldGenerator>;
	/** An image used for caching **/
	var image:BitmapData;
	/** The amount of energy available **/
	public var energy:Float;
	/** Manages the energy flow **/
	public var energyManager:EnergyManager;
	/** The maximum amount of energy the ship can hold **/
	public var maxEnergy:Float;
	/** The amount of shielding currently available **/
	public var shield:Float;
	/** The maximum value the shields can reach **/
	public var maxShield:Float;
	/** The sprite used for drawing **/
	var sprite:Sprite;
	/** The offset of the sprite from the local COM **/
	public var drawOffset:Vec2;
	/** The offset of the image from the sprite location **/
	var imageOffset:Vec2;
	/** The physics body of the ship **/
	public var body:Body;

	/**
	 * Create a new ship.
	 * @param  position The world coordinates of the ship.
	 * @return
	 */
	public function new(position:Vec2) {
		super();
		renderDepth = 100;

		needToRealign = false;
		parts = new Array<ShipPart>();
		updateParts = new Array<ShipPart>();
		partsToRemove = new Array<ShipPart>();
		dirtyParts = new Array<ShipPart>();
		partMap = new util.CoordinateMap<ShipPart>();
		engines = new Array<Engine>();
		reactors = new Array<Reactor>();
		shieldGenerators = new Array<ShieldGenerator>();
		body = new Body();
		body.position.set(position);
		// body.isBullet = true;
		maxEnergy = 10.0;
		energy = maxEnergy;
		energyManager = new EnergyManager(this);
		shield = 0.0;
		maxShield = 0.0;

		drawOffset = Vec2.get(0, 0);
		imageOffset = Vec2.get(0, 0);
		image = null;
		sprite = Pool.sprite();
	}

	/**
	 * Called when added to a game.
	 * @param  game
	 */
	override public function init(game:Game):Void {
		super.init(game);
		body.space = game.space;
	}

	/**
	 * Realigns the sprite with the center of mass.
	 * @return [description]
	 */
	public function realign():Void {
		drawOffset.subeq(body.localCOM);
		body.align();
	}

	/**
	 * Add a part to the ship.
	 * @param part      [description]
	 * @param x         [description]
	 * @param y         [description]
	 * @param direction [description]
	 */
	public function addPart(part:ShipPart, x:Int, y:Int, direction:Direction = null):Void {
		if (part == null) {
			throw "Cannot add null part";
		}
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
		dirtyParts.push(part);
	}

	public function addUpdatePart(part:ShipPart):Void {
		// check if already here
		for (p in updateParts) {
			if (part == p) {
				return;
			}
		}
		// else
		updateParts.push(part);
	}

	public function removeUpdatePart(part:ShipPart):Void {
		updateParts.remove(part);
	}

	/**
	 * Remove a part from the ship. Does not handle what the part should do.
	 * @param	part
	 * @return
	 */
	public function removePart(part:ShipPart):Void {
		needToRealign = true;
		try {
			if (part.ship == this) {
				part.onRemove();
			}
		} catch(error:Dynamic) {
			throw new flash.errors.Error("part.remove() " + part + ": " + error);
		}
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

		removeUpdatePart(part);

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
		try {
			var queue = new Array<ShipPart>();
			var connected = new de.polygonal.ds.HashSet<ShipPart>(256);
			if (parts.length > 0) {
				queue.push(parts[0]);
			}
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

				var out1 = Vec2.get();
				var out2 = Vec2.get();
				nape.geom.Geom.distanceBody(body, other.body, out1, out2);
				var impulse = out1.sub(out2);
				if (impulse.length != 0) {
					impulse.normalise().muleq(200);
}				impulse.add(Vec2.get(util.Random.normal(0, 100), util.Random.normal(0, 100), true));
				body.applyImpulse(impulse);
				other.body.applyImpulse(impulse.mul(-1, true));				
				impulse.dispose();
				out1.dispose();
				out2.dispose();
			}
		} catch(error:Dynamic) {
			throw new flash.errors.Error("removeDisconnected failed: " + error);
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

		energyManager.update(timestep);
		giveEnergy(timestep);
		if (shield > 0) {
			shield -= maxShield * timestep * 0.002;
		}
		updateParts.sort(function(a: ship.ShipPart, b: ship.ShipPart): Int {
			return b.updatePriority - a.updatePriority;
		});

		for (part in updateParts) {
			try {
				part.update(timestep);
			} catch (error:Dynamic) {
				throw new flash.errors.Error("" + part + ": " + error);
			}
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
 		if (disposed) {
 			return;
 		}
 		for (part in partsToRemove) {
 			removePart(part);
 		}
 		partsToRemove.splice(0, partsToRemove.length);
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
	public function hit(position:Vec2, projectile:projectiles.Projectile):Bool {
		return true;
	}

	public function requestEnergy(amount:Float, energyType:EnergyType):Float {
		var result = energyManager.requestEnergy(amount, energyType);
		energy -= result;
		energy = Math.max(energy, 0);
		return result;
	}

	public function giveEnergy(amount:Float):Void {
		energyManager.giveEnergy(amount);
		energy += amount;
	}

	public function requestShield(amount:Float):Float {
		var result = Math.min(amount, shield);
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
		var multiplier = body.inertia * 0.000008;
		if (body.angularVel > 10.0 / body.inertia) {
			turnLeft(Math.min(0.9, body.angularVel * multiplier));
		}
		if (body.angularVel < -10.0 / body.inertia) {
			turnRight(-Math.max(-0.9, body.angularVel * multiplier));
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
		var multiplier = body.mass * 0.0008;
		if (v.length > 1.0 / body.mass) {
			var a = body.localVectorToWorld(Vec2.get(1, 0, true));
			var b = body.localVectorToWorld(Vec2.get(0, 1, true));

			var adotv = a.dot(v);
			var bdotv = b.dot(v);
			if (adotv > 0.01) {
				thrust(Math.min(0.9, adotv * multiplier), RIGHT);
			} else if (a.dot(v) < -0.01) {
				thrust(Math.min(0.9, -adotv * multiplier), LEFT);
			}

			if (bdotv > 0.01) {
				thrust(Math.min(0.9, bdotv * multiplier), BACKWARD);
			} else if (b.dot(v) < -0.01) {
				thrust(Math.min(0.9, -bdotv * multiplier), FORWARD);
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
			if (Std.is(part, Weapon)) {
				cast(part, Weapon).fire();
			}
		}
	}

	public function makeImage():Void {
		if (image != null) {
			image.dispose();
		}

		var minX = 999999999;
		var maxX = -999999999;
		var minY = 999999999;
		var maxY = -999999999;

		for (part in parts) {
			if (part.gridPosition.x < minX) {
				minX = Std.int(part.gridPosition.x);
			}
			if (part.gridPosition.y < minY) {
				minY = Std.int(part.gridPosition.y);
			}
			if (part.gridPosition.x + part.gridSize.x > maxX) {
				maxX = Std.int(part.gridPosition.x + part.gridSize.x);
			}
			if (part.gridPosition.x + part.gridSize.y > maxY) {
				maxY = Std.int(part.gridPosition.y + part.gridSize.y);
			}
		}

		var buffer = 2;
		var w = (maxX - minX + 2 * buffer) * GRID_SIZE; 
		var h = (maxY - minY + 2 * buffer) * GRID_SIZE;

		image = new BitmapData(w, h, true, 0x0);
		imageOffset.setxy(-(minX - buffer) * GRID_SIZE - buffer, -(minY - buffer) * GRID_SIZE);
	}

	public function render(surface:BitmapData, camera:Camera):Void {
		// if (image == null) {
		// 	makeImage();
		// }

		// if (dirtyParts.length > 0) {
		// 	var g = sprite.graphics;
		// 	g.clear();
		// 	for (part in dirtyParts) {
		// 		part.draw(g, camera.zoom);
		// 	}
		// 	var m = new flash.geom.Matrix();
		// 	m.translate(imageOffset.x, imageOffset.y);
		// 	image.draw(sprite, m);
		// 	dirtyParts.splice(0, dirtyParts.length);
		// }

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