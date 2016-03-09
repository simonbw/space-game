import Generator from './parts/Generator';

// There are 3 types of parts in the energy system
// storage - Store excess energy.
// producers - Create energy every turn.
// consumers - Use energy every turn.
//             Creates an energy deficit when using energy.
//             Has a maximum deficit which is generally the most amount of
//                 energy it could use in one turn.
//
// Every turn the PowerManager balances the energy.
//
//     First, the total amount of energy available is calculated by summing the
// energy produced by each generator and the energy currently in storage.
//     The total energy deficit is calculated by summing the energy deficits of
// all the consumers.
//     If the total deficit is less than or equal to the available energy, all
// consumers have their deficit filled and the total deficit is subtracted from
// the available energy.
//     If the total deficit is greater than the available energy, energy is
// distributed to each consumer proportional to its maximum deficit.
//     Any remaining available energy is put into storage.


/**
 * Balances energy production, consumption and storage.
 */
export default class PowerManager {
  constructor(ship) {
    this.ship = ship;
    this.generators = [];
    this.consumers = [];
    this.energyUsers = [];
    this.energy = 0;
    this.capacity = 0;
  }

  /**
   * Called during the tick.
   */
  tick() {
    this.energy += this.generators.length * 5;
  }

  /**
   * Called after the tick.
   */
  afterTick() {
    // TODO: Cleanup energy distribution
    const totalDeficit = this.consumers.reduce((deficit, consumer) => (deficit + consumer.energyDeficit), 0);

    const ratio = Math.min(this.energy / totalDeficit, 1);

    // give consumer energy
    this.consumers.forEach((consumer) => {
      const deficit = consumer.energyDeficit;
      const toGive = Math.min(deficit * ratio, this.energy);
      consumer.energyDeficit -= toGive;
      this.energy -= toGive;
    });

    this.energy = Math.min(this.energy, this.capacity);
  }

  /**
   * Called when a part is added.
   * @param part {Part}
   * @returns {number}
   */
  partAdded(part) {
    if (part instanceof Generator) {
      this.generators.push(part);
    }

    if (part.maxEnergyDeficit) {
      this.consumers.push(part);
      console.log("Added consumer");
    }

    if ((part.energyCapacity != null)) {
      this.capacity += part.energyCapacity;
    }
  }

  /**
   * Called when a part is removed.
   * @param part {Part}
   * @returns {number}
   */
  partRemoved(part) {
    if (part instanceof Generator) {
      this.generators.splice(this.generators.indexOf(part), 1);
    }

    if (part.maxEnergyDeficit) {
      this.consumers.splice(this.consumers.indexOf(part), 1);
    }

    if (part.energyCapacity) {
      this.capacity += -part.energyCapacity;
    }
  }
}
