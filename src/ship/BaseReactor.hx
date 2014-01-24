package ship;

class BaseReactor extends RectangularPart {

	var capacity:Float;
	var production:Float;
	public function new(production:Float, capacity:Float, width:Int = 1, height:Int = 1, health:Float = 200.0) {
		super(width, height, health);
		this.production = production;
		this.capacity = capacity;
		updatePriority = 1000;
	}

	override public function update(timestep:Float):Void {
		super.update(timestep);
		ship.giveEnergy(timestep * production * (0.7 * health / maxHealth + 0.3));
	}

	override public function addToShip(ship:Ship, position:nape.geom.Vec2, direction:Direction = null):Void {
		super.addToShip(ship, position, direction);
		ship.maxEnergy += capacity;
		ship.addUpdatePart(this);
	}

	override public function onRemove():Void {
		ship.maxEnergy -= capacity;
		super.onRemove();
	}
}