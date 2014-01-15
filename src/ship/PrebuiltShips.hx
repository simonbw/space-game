package ship;

class PrebuiltShips {

	public static function makeXWing(ship:ship.Ship):Void {
		for (i in 2...8) {
			ship.addPart(new Hull(), i, 0);
			ship.addPart(new Hull(), -i, 0);
		}

		ship.addPart(new Reactor(), -1, -1);

		ship.addPart(new Engine(false), -1, 2, BACKWARD);
		ship.addPart(new Engine(false), 0, 2, BACKWARD);
		ship.addPart(new Engine(false), 1, 2, BACKWARD);
		ship.addPart(new Battery(), 2, 1);
		ship.addPart(new Battery(), -2, 1);
		ship.addPart(new ShieldGenerator(), 2, -1);
		ship.addPart(new ShieldGenerator(), -2, -1);

		for (i in -2...3) {
			ship.addPart(new Engine(false, 25), i, -2, FORWARD);
		}

		ship.addPart(new LaserCannon(), 2, 2, FORWARD);
		ship.addPart(new LaserCannon(), -2, 2, FORWARD);

		for (i in -1...2) {
			ship.addPart(new Engine(false), 8, i, RIGHT);
			ship.addPart(new Engine(false), -8, i, LEFT);
		}
		ship.addPart(new Engine(true, 15), 8, -2, FORWARD);
		ship.addPart(new Engine(true, 15), 8, 2, BACKWARD);
		ship.addPart(new Engine(true, 15), -8, -2, FORWARD);
		ship.addPart(new Engine(true, 15), -8, 2, BACKWARD);


		ship.body.rotation = Math.PI;
		ship.removeDisconnected();
		ship.realign();
	}
	
	public static function makeFreighter(ship:ship.Ship):Void {
		for (i in -3...12) {
			if (util.MyMath.modInt(i, 3) == 1) {
				ship.addPart(new ShieldCapacitor(), -1, i);
				ship.addPart(new ShieldGenerator(), 0, i);
				ship.addPart(new ShieldCapacitor(), 1, i);
			} else {
				ship.addPart(new Hull(), -1, i);
				ship.addPart(new Hull(), 0, i);
				ship.addPart(new Hull(), 1, i);
			}
		}
		for (i in -6...15) {
			ship.addPart(new Hull(), -2, i);
			ship.addPart(new Hull(), 2, i);
		}

		for (i in -6...15) {
			if (util.MyMath.modInt(i, 3) == 1) {
				ship.addPart(new Engine(true, 8), -3, i, LEFT);
				ship.addPart(new Engine(true, 8), 3, i, RIGHT);
			}
		}

		ship.addPart(new Engine(), -2, 15, BACKWARD);
		ship.addPart(new Engine(), 0, 15, BACKWARD);
		ship.addPart(new Engine(), 2, 15, BACKWARD);
		ship.addPart(new LaserCannon(), -1, 15, FORWARD);
		ship.addPart(new LaserCannon(), 1, 15, FORWARD);

		for (i in -2...3) {
			ship.addPart(new Engine(true, 12), i, -7, FORWARD);
		}

		ship.addPart(new Reactor(), -1, 12);
		ship.addPart(new Reactor(), -1, -6);

		ship.body.rotation = Math.PI;
		ship.removeDisconnected();
		ship.realign();
	}
	
	public static function makeRam(ship:ship.Ship):Void {
		for (i in 2...8) {
			ship.addPart(new Hull(), i, 0);
			ship.addPart(new Hull(), -i, 0);
		}

		ship.addPart(new Reactor(), -1, -1);

		ship.addPart(new Engine(false), -1, 2, BACKWARD);
		ship.addPart(new Engine(false), 0, 2, BACKWARD);
		ship.addPart(new Engine(false), 1, 2, BACKWARD);
		ship.addPart(new Battery(), 2, 1);
		ship.addPart(new Battery(), -2, 1);
		ship.addPart(new ShieldGenerator(), 2, -1);
		ship.addPart(new ShieldGenerator(), -2, -1);

		for (i in -2...3) {
			ship.addPart(new Engine(false, 25), i, -2, FORWARD);
		}

		ship.addPart(new LaserCannon(), 2, 2, FORWARD);
		ship.addPart(new LaserCannon(), -2, 2, FORWARD);

		for (i in -1...2) {
			ship.addPart(new Engine(false), 8, i, RIGHT);
			ship.addPart(new Engine(false), -8, i, LEFT);
		}
		ship.addPart(new Engine(true, 15), 8, -2, FORWARD);
		ship.addPart(new Engine(true, 15), 8, 2, BACKWARD);
		ship.addPart(new Engine(true, 15), -8, -2, FORWARD);
		ship.addPart(new Engine(true, 15), -8, 2, BACKWARD);

		//the ram part
		for (i in 3...32) {
			ship.addPart(new Hull(), -1, i);
			ship.addPart(new Hull(), 0, i);
			ship.addPart(new Hull(), 1, i);
		}

		ship.body.rotation = Math.PI;
		ship.removeDisconnected();
		ship.realign();
	}
}