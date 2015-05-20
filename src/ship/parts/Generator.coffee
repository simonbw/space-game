Part = require 'ship/parts/Part'

# Creates power
class Generator extends Part
  energyCapacity: 200
  color: 0x9999FF
  maxHealth: 200
  name: 'Generator'
  power: 100

module.exports = Generator