Part = require "ship/parts/Part"

# Basic interior block
class Interior extends Part
  color: 0xFAFAFA
  maxHealth: 80
  name: 'Interior'
  interior: true

module.exports = Interior
