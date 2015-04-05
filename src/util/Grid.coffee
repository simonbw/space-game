
# A 2 dimensional map
class Grid
  constructor: ->
    @data = {}

  # Set a value at a location
  set: ([x, y], value) =>
    @data[x] ?= {}
    @data[x][y] = value

  # Get a value at a location or undefined.
  get: ([x, y]) =>
    if not @data.hasOwnProperty(x)
      return undefined
    return @data[x][y]

  # Delete the value at a location
  remove: ([x, y]) =>
    @data[x] ?= {}
    delete @data[x][y]
    

module.exports = Grid