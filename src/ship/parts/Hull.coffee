Part = require 'ship/parts/Part'

# Basic building block
class Hull extends Part
  color: 0xBBBBBB
  maxHealth: 300
  name: 'Hull'
  
module.exports = Hull