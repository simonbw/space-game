Part = require 'ship/parts/Part'

# Creates power
class Generator extends Part
  energyCapacity: 200
  color: 0x9999FF
  maxHealth: 200
  name: 'Generator'
  power: 5

module.exports = Generator