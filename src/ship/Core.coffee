Part = require 'ship/Part'

# The core of every ship. This should never be destroyed.
class Core extends Part
  @type = type = new Part.Type('Core', 1, 1, 0x55AAFF, 1000)
  
  constructor: (x=0, y=0) ->
    super(x, y, type)

module.exports = Core