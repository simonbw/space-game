package ai;
import ship.Ship;
import ship.EnergyType;
import util.MyMath;

import nape.geom.Vec2;

/**
 * Controls firing ship engines.
 */
class PlayerShipController extends Entity implements Updatable {
	static inline var SHIELD_MODES = 10;
	var ship:Ship;
	var stabilize:Bool;
	var shieldMode:Int;


	public function new(ship:Ship) {
		super();
		this.ship = ship;
		stabilize = false;
		shieldMode = SHIELD_MODES;
	}

	override public function init(game:Game):Void {
		super.init(game);

		// toggle stabilize on keypress
		IO.addKeyDownCallback(IO.K_STABILIZE, function():Void {
			stabilize = !stabilize;
		});

		// increase shield on keypress
		IO.addKeyDownCallback(IO.K_SHIELD_UP, function():Void {
			shieldMode = util.MyMath.minInt(shieldMode + 1, SHIELD_MODES);
			ship.energyManager.multipliers.set(EnergyType.SHIELD, shieldMode / SHIELD_MODES);
		});

		// decrease shield on keypress
		IO.addKeyDownCallback(IO.K_SHIELD_DOWN, function():Void {
			shieldMode = util.MyMath.maxInt(shieldMode - 1, 0);
			ship.energyManager.multipliers.set(EnergyType.SHIELD, shieldMode / SHIELD_MODES);
		});

		// self destruct button
		IO.addKeyDownCallback(IO.K_MISSILE, function():Void {
			ship.explode();
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

		
		if (game.input.xAxis > 0) {
			ship.balancedThrust(game.input.xAxis, RIGHT);
		}
		if (game.input.xAxis < 0) {
			ship.balancedThrust(-game.input.xAxis, LEFT);
		}
		if (game.input.yAxis > 0) {
			ship.balancedThrust(game.input.yAxis, FORWARD);
		}
		if (game.input.yAxis < 0) {
			ship.balancedThrust(-game.input.yAxis, BACKWARD);
		}

		if (Math.abs(game.input.turn) > 0) {
			ship.turn(game.input.turn);
		}

		// if (IO.keys[IO.K_TURN_LEFT]) {
		// 	ship.turn( -1.0);
		// 	turning = true;
		// }
		// if (IO.keys[IO.K_TURN_RIGHT]) {
		// 	ship.turn(1.0);
		// 	turning = true;
		// }

		// if (IO.keys[IO.K_UP]) {
		// 	ship.balancedThrust(1.0, FORWARD);
		// 	thrusting = true;
		// }

		// if (IO.keys[IO.K_DOWN]) {
		// 	ship.balancedThrust(1.0, BACKWARD);
		// 	thrusting = true;
		// }

		// if (IO.keys[IO.K_STRAFE_RIGHT]) {
		// 	ship.balancedThrust(1.0, RIGHT);
		// 	thrusting = true;
		// }

		// if (IO.keys[IO.K_STRAFE_LEFT]) {
		// 	ship.balancedThrust(1.0, LEFT);
		// 	thrusting = true;
		// }

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