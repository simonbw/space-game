import Part from './Part';

/**
 * The core of every ship. This should never be destroyed.
 * @extends Part
 */
export default class Core extends Part {
  constructor(pos = [0, 0]) {
    super(pos);
  }
}

Core.prototype.color = 0x55AAFF;
Core.prototype.maxHealth = 1000;
Core.prototype.name = 'Core';
