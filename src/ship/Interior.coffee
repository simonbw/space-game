Part = require "ship/Part"

# Basic interior block
class Interior extends Part
  @type = type = new Part.Type('Interior', 1, 1, 0xDDDDDD, 80)
  type.interior = true

  constructor: (x, y) ->
    super(x, y, type)

  clone: () =>
    return new Interior(@x, @y)

module.exports = Interior
