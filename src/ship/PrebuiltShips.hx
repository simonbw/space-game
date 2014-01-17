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
		ship.addPart(new ShieldCapacitor(), 2, 1);
		ship.addPart(new ShieldCapacitor(), -2, 1);
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

		ship.addPart(new Engine(false), -2, 15, BACKWARD);
		ship.addPart(new Engine(false), 0, 15, BACKWARD);
		ship.addPart(new Engine(false), 2, 15, BACKWARD);
		ship.addPart(new LaserCannon(), -1, 15, FORWARD);
		ship.addPart(new LaserCannon(), 1, 15, FORWARD);

		for (i in -2...3) {
			ship.addPart(new Engine(false, 24), i, -7, FORWARD);
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
	
	public static function makeCruiser(ship:ship.Ship):Void {
		for (i in 0...11) {
			for (j in 0...3) {
				ship.addPart(new Hull(), -5, i * 3 + j);
				ship.addPart(new Hull(), 5, i * 3 + j);
			}
			ship.addPart(new LargeInterior(), -4, i * 3);
			if (util.MyMath.modInt(i, 2) == 1) {
				ship.addPart(new Reactor(), -1, i * 3);
			} else {
				ship.addPart(new LargeInterior(), -1, i * 3);
			}
			ship.addPart(new LargeInterior(), 2, i * 3);
		}
		for (i in -4...5) {
			ship.addPart(new ship.Engine(false, 50), i, -1, FORWARD);
			ship.addPart(new ship.Engine(false, 30), i, 33, BACKWARD);
		}
		for (i in 0...31) {
			if (util.MyMath.modInt(i, 3) == 2) {
				ship.addPart(new Engine(true, 10), -6, i, LEFT);
				ship.addPart(new Engine(true, 10), 6, i, RIGHT);
			} else {
				ship.addPart(new Hull(), -5, i);
				ship.addPart(new Hull(), 5, i);
			}
		}
		
		ship.body.rotation = Math.PI;
		ship.removeDisconnected();
		ship.realign();
	}


}