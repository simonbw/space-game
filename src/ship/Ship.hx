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
    static public var SHIELD_MATERIAL = new nape.phys.Material(0.5, 0.1, 0.15, 0.0, 0.0);

    public var renderDepth:Int;

    var parts:Array<ShipPart>;
    var partMap:util.CoordinateMap<ShipPart>;
	var dirty:Bool;

    var engines:Array<Engine>;
    var shieldGenerators:Array<ShieldGenerator>;

    var shield:Float;
    var shieldEnabled:Bool;
    var energy:Float;

    var sprite:Sprite;
    var drawOffset:Vec2;
    public var body:Body;

    public function new(position:Vec2) {
        super();
        renderDepth = 100;
		
		dirty = false;
        parts = new Array<ShipPart>();
        partMap = new util.CoordinateMap<ShipPart>();
        engines = new Array<Engine>();
        shieldGenerators = new Array<ShieldGenerator>();
        body = new Body();
		body.position.set(position);
		body.isBullet = true;
		shieldEnabled = false;
        shield = 0.0;
        energy = 0.0;
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
	
	public inline function buildShip1():Void {
		
		for (i in 2...8) {
			addPart(new Hull(), i, 0);
			addPart(new Hull(), -i, 0);
		}
		for (i in 0...8) {
			addPart(new Hull(), -1, i);
			addPart(new Hull(), 0, i);
			addPart(new Hull(), 1, i);
		}
		for (i in -2...3) {
			addPart(new Engine(false, 10000), i, -1, FORWARD);
		}
		for (i in 1...4) {
			addPart(new Hull(), 2, i);
			addPart(new Hull(), -2, i);
		}
		
		addPart(new LaserCannon(), 2, 4, FORWARD);
		addPart(new LaserCannon(), -2, 4, FORWARD);
		
		addPart(new Engine(), 8, -1, FORWARD);
		addPart(new Engine(false), 8, 0, RIGHT);
		addPart(new Engine(), 8, 1, BACKWARD);
		addPart(new Engine(), -8, -1, FORWARD);
		addPart(new Engine(false), -8, 0, LEFT);
		addPart(new Engine(), -8, 1, BACKWARD);
		
		body.rotation = Math.PI;
		removeDisconnected();
		realign();
	}
	
	public inline function buildShip2():Void {
		for (i in -3...16) {
			addPart(new Hull(), -1, i);
			addPart(new Hull(), 0, i);
			addPart(new Hull(), 1, i);
		}
		addPart(new Engine(), -1, 16, BACKWARD);
		addPart(new Engine(), 0, 16, BACKWARD);
		addPart(new Engine(), 1, 16, BACKWARD);
		addPart(new Engine(), -2, 15, LEFT);
		addPart(new Engine(), 2, 15, RIGHT);
		addPart(new Engine(), -2, -2, LEFT);
		addPart(new Engine(), 2, -2, RIGHT);
		addPart(new Engine(), -2, -3, FORWARD);
		addPart(new Engine(), 2, -3, FORWARD);
		addPart(new Engine(), -2, -1, BACKWARD);
		addPart(new Engine(), 2, -1, BACKWARD);
		
		body.rotation = Math.PI;
		removeDisconnected();
		realign();
	}

    function realign():Void {
        drawOffset.subeq(body.localCOM);
        body.align();
    }

    public function addPart(part:ShipPart, x:Int, y:Int, direction:Direction = null):Void {
		dirty = true;
        parts.push(part);
        partMap.set(x, y, part);
        part.addToShip(this, Vec2.get(x, y), direction);

        for (a in part.adjacent) {
            if (partMap.exists(a.x, a.y)) {
                var other = partMap.get(a.x, a.y);
                part.connectedParts.set(other);
                other.connectedParts.set(part);
            }
        }

        if (Std.is(part, ship.Engine)) {
            engines.push(cast(part, ship.Engine));
        }
        if (Std.is(part, ship.ShieldGenerator)) {
            shieldGenerators.push(cast(part, ship.ShieldGenerator));
        }
    }

    /**
     * Remove a part from the ship. Does not handle what the part should do.
     * @param	part 
     * @return
     */
    public function removePart(part:ShipPart):Void {
		dirty = true;
		part.onRemove();
		parts.remove(part);
		partMap.remove(Std.int(part.gridPosition.x), Std.int(part.gridPosition.y));
		if (Std.is(part, ship.Engine)) {
            engines.remove(cast(part, ship.Engine));
        }
        if (Std.is(part, ship.ShieldGenerator)) {
            shieldGenerators.remove(cast(part, ship.ShieldGenerator));
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
	 * Toggles the shield.
	 */
    public function toggleShield():Void {
        shieldEnabled = !shieldEnabled;
    }

	/**
	 * Call every frame
	 * @param	timestep
	 */
    public function update(timestep:Float):Void {
		
		if (dirty) {
			removeDisconnected();
			realign();
			dirty = false;
		}
        
		for (part in parts) {
            part.update(timestep);
        }

        var maxShield = 0.0;
        for (shieldGenerator in shieldGenerators) {
            maxShield += shieldGenerator.capacity;
        }
        for (shieldGenerator in shieldGenerators) {
            shield += shieldGenerator.rechargeRate * timestep;
        }
        shield = Math.min(shield, maxShield);
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
            part.draw(g);
        }

        if (shield > 0 || shieldEnabled) {
            var shieldX = -drawOffset.x;
            var shieldY = -drawOffset.y;
            var shieldR = 50;
            var gm = new Matrix();
            gm.createGradientBox(shieldR * 2, shieldR * 2, 0, shieldX - shieldR, shieldY - shieldR);
            g.lineStyle();
            g.beginGradientFill(GradientType.RADIAL, [0x000000, 0x00FFFF, 0x00FFFF], [0, 0.2, 0.6], [180, 240, 255], gm);
            g.drawCircle(shieldX, shieldY, shieldR);
            g.endFill();
        }

        // g.lineStyle(3, 0x00FF00);
        // g.drawCircle(-drawOffset.x, -drawOffset.y, 5);

        // g.lineStyle(3, 0xFF6666);
        // g.drawCircle(body.localCOM.x - drawOffset.x, body.localCOM.y - drawOffset.y, 2);

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
	}
}