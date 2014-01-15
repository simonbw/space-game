package ship;

class EnergyManager {
	public var multipliers:Map<EnergyType, Float>;

	/** The amount of energy being consumed per second **/
	public var energyConsumption:Float;
	/** The amount of energy being produced per second **/
	public var energyProduction:Float;
	/** energyConsumption / energyProduction if energy is running low **/
	public var energyLoad:Float;
	/** The ship this is attached to **/
	var ship:Ship;

	public function new(ship:Ship) {
		this.ship = ship;

		multipliers = new Map<EnergyType, Float>();
		
		multipliers.set(EnergyType.ENGINE, 1.0);
		multipliers.set(EnergyType.SHIELD, 1.0);
		multipliers.set(EnergyType.WEAPON, 1.0);

		energyConsumption = 0.0;
		energyProduction = 0.0;
		energyLoad = 0.0;
	}

	public function update(timestep:Float):Void {
		
		if (ship.energy < energyConsumption) {
			energyLoad = 0.8 * energyLoad + 0.2 * energyConsumption / energyProduction;
		} else {
			energyLoad = 0.8 * energyLoad;
		}

		energyConsumption = 0.0;
		energyProduction = 0.0;
	}

	public function giveEnergy(amount:Float):Void {
		energyProduction += amount;
	}

	public function requestEnergy(amount:Float, energyType:EnergyType):Float {
		amount *= multipliers.get(energyType);
		energyConsumption += amount;
		var result = Math.min(amount, ship.energy);
		if (energyLoad > 1.0) {
			result /= energyLoad;
		}
		return result;
	}

}