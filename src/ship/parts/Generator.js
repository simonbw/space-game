import Part from './Part';

/**
 * Creates power
 * @extends Part
 */
export default class Generator extends Part {
}

Generator.prototype.color = 0x9999FF;
Generator.prototype.energyCapacity = 200;
Generator.prototype.maxHealth = 200;
Generator.prototype.name = 'Generator';
Generator.prototype.power = 5;
