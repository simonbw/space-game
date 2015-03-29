Part = require 'ship/Part'

# Basic building block
class Hull extends Part
  @type = type = new Part.Type('Hull', 1, 1, 0xBBBBBB, 300)
  
  constructor: (x, y) ->
    super(x, y, type)

  clone: () =>
    return new Hull(@x, @y)

module.exports = Hull