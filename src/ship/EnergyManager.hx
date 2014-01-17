package ship;


/**
 * Manages energy distribution on a ship.
 */
class EnergyManager {
	/** Percent of full power the system is at **/
	public var multipliers:Map<EnergyType, Float>;
	/** Amount consumed by each system **/
	public var consumptions:Map<EnergyType, Float>;
	/** The amount of energy being consumed per second **/
	public var totalConsumption:Float;
	/** The amount of energy being produced per second **/
	public var energyProduction:Float;
	/** totalConsumption / energyProduction if energy is running low **/
	public var energyLoad:Float;
	/** The ship this is attached to **/
	var ship:Ship;

	public function new(ship:Ship) {
		this.ship = ship;

		multipliers = new Map<EnergyType, Float>();
		consumptions = new Map<EnergyType, Float>();
		
		multipliers.set(EnergyType.ENGINE, 1.0);
		multipliers.set(EnergyType.SHIELD, 1.0);
		multipliers.set(EnergyType.WEAPON, 1.0);

		consumptions.set(EnergyType.ENGINE, 0.0);
		consumptions.set(EnergyType.SHIELD, 0.0);
		consumptions.set(EnergyType.WEAPON, 0.0);

		totalConsumption = 0.0;
		energyProduction = 0.0;
		energyLoad = 0.0;
	}

	public function update(timestep:Float):Void {
		
		if (ship.energy < totalConsumption) {
			energyLoad = 0.8 * energyLoad + 0.2 * totalConsumption / energyProduction;
		} else {
			energyLoad = 0.8 * energyLoad;
		}

		totalConsumption = 0.0;
		energyProduction = 0.0;
		consumptions.set(EnergyType.ENGINE, 0.0);
		consumptions.set(EnergyType.SHIELD, 0.0);
		consumptions.set(EnergyType.WEAPON, 0.0);
	}

	public function giveEnergy(amount:Float):Void {
		energyProduction += amount;
	}

	public function requestEnergy(amount:Float, energyType:EnergyType):Float {
		amount *= multipliers.get(energyType);
		consumptions.set(energyType, consumptions.get(energyType) + amount);
		totalConsumption += amount;
		amount = Math.min(amount, ship.energy);
		if (energyLoad > 1.0) {
			amount /= energyLoad;
		}
		return amount;
	}

}