Part = require 'ship/parts/Part'

# The core of every ship. This should never be destroyed.
class Core extends Part
  color: 0x55AAFF
  maxHealth: 1000
  name: 'Core'

  constructor: (pos=null) ->
    pos ?= [0, 0]
    super(pos)

module.exports = Core