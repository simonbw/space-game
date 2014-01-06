package ship;

class PlayerShipController 
{
	var ship:Ship;

	public function new(ship:Ship) {
		this.ship = ship;

		IO.addKeyDownCallback(IO.K_SHIELD, ship.toggleShield);
	}	

	public function update(timestep:Float):Void {
		ship.clearEngines();

		if (IO.keys[IO.K_TURN_LEFT]) {
			ship.turn(-1.0);
		}
		if (IO.keys[IO.K_TURN_RIGHT]) {
			ship.turn(1.0);
		}

		if (IO.keys[IO.K_UP]) {
			ship.thrust(1.0, FORWARD);
		}

		if (IO.keys[IO.K_DOWN]) {
			ship.thrust(1.0, BACKWARD);
		}

		if (IO.keys[IO.K_STRAFE_RIGHT]) {
			ship.thrust(1.0, RIGHT);
		}

		if (IO.keys[IO.K_STRAFE_LEFT]) {
			ship.thrust(1.0, LEFT);
		}

		if (IO.keys[IO.K_STABILIZE]) {
			ship.stabilize();
		}

		if (IO.keys[IO.K_KILL_ROTATION]) {
			ship.stabilizeRotation();
		}

		if (IO.keys[IO.K_LASER]) {
			ship.fireLasers();
		}

	}
}