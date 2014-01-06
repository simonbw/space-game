package ai;
import ship.Ship;

class StabilizeShipController extends Entity implements Updatable {
	var ship:Ship;

	public function new(ship:Ship) {
		super();
		this.ship = ship;
	}

	public function update(timestep:Float):Void {
		ship.clearEngines();
		ship.stabilizeRotation();
		ship.stabilizeLinear();
	}
}