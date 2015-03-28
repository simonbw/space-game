Part = require "ship/Part"

class Hull extends Part
  @type = type = new Part.Type(1, 1, 0xBBBBBB, 300)
  
  constructor: (x, y) ->
    super(x, y, type)

module.exports = Hull