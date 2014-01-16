package ai;
import ship.Ship;
import ship.EnergyType;
import util.MyMath;

import nape.geom.Vec2;

class PlayerShipController extends Entity implements Updatable {
	var ship:Ship;
	var stabilize:Bool;

	public function new(ship:Ship) {
		super();
		this.ship = ship;
		stabilize = false;

		IO.addKeyDownCallback(IO.K_STABILIZE, function():Void {
			stabilize = !stabilize;
		});

		IO.addKeyDownCallback(IO.K_SHIELD, function():Void {
			Main.log("toggling shields");
			var multiplier = ship.energyManager.multipliers.get(EnergyType.SHIELD);
			if (multiplier > 0) {
				multiplier = 0;
			} else {
				multiplier = 1.0;
			}
			ship.energyManager.multipliers.set(EnergyType.SHIELD, multiplier);
		});
	}

	public function update(timestep:Float):Void {
		if (ship.disposed) {
			dispose();
			return;
		}
		var thrusting = false;
		var turning = false;
		ship.clearEngines();
		if (IO.keys[IO.K_TURN_LEFT]) {
			ship.turn( -1.0);
			turning = true;
		}
		if (IO.keys[IO.K_TURN_RIGHT]) {
			ship.turn(1.0);
			turning = true;
		}

		if (IO.keys[IO.K_UP]) {
			ship.thrust(1.0, FORWARD);
			thrusting = true;
		}

		if (IO.keys[IO.K_DOWN]) {
			ship.thrust(1.0, BACKWARD);
			thrusting = true;
		}

		if (IO.keys[IO.K_STRAFE_RIGHT]) {
			ship.thrust(1.0, RIGHT);
			thrusting = true;
		}

		if (IO.keys[IO.K_STRAFE_LEFT]) {
			ship.thrust(1.0, LEFT);
			thrusting = true;
		}

		if (stabilize && !IO.keys[IO.K_KILL_ROTATION]) {
			var direction = Vec2.fromPolar(1, ship.body.rotation + Math.PI / 2);
			direction.muleq(MyMath.max(direction.dot(ship.body.velocity), 0)); // don't go backwards
			ship.stabilizeLinear(direction);
			direction.dispose();
		}
		
		if (stabilize && !turning) {
			ship.stabilizeRotation();
		}
		
		if ((IO.keys[IO.K_KILL_ROTATION])) {
			if (!turning) {
				ship.stabilizeRotation();
			}
			if (!thrusting) {
				ship.stabilizeLinear();
			}
		}

		if (IO.keys[IO.K_LASER]) {
			ship.fireLasers();
		}

	}
}