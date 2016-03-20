import Part from './Part';

/**
 * Basic building block
 * @extends Part
 */
export default class Hull extends Part {
}

Hull.prototype.color = 0xBBBBBB;
Hull.prototype.maxHealth = 300;
Hull.prototype.name = 'Hull';
