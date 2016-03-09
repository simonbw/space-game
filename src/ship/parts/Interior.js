import Part from './Part';

/**
 * Basic interior block
 * @extends Part
 */
export default class Interior extends Part {
}

Interior.prototype.color = 0xFAFAFA;
Interior.prototype.interior = true;
Interior.prototype.maxHealth = 80;
Interior.prototype.name = 'Interior';
