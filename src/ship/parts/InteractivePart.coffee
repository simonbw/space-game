p2 = require 'p2'
Part = require "ship/parts/Part"
CollisionGroups = require 'CollisionGroups'

class InteractivePart extends Part
  interactive: true
  name: "Interactive Part"

  constructor: (pos) ->
    super(pos)
    @sensor = @makeSensor()
    @sensor.owner = this

  makeSensor: () =>
    shape = new p2.Rectangle(@width + 0.5, @height + 0.5)
    shape.sensor = true
    shape.collisionGroup = CollisionGroups.SHIP_SENSOR
    shape.collisionMask = CollisionGroups.PERSON
    return shape

  interact: (person) =>
    console.log "interacted"


module.exports = InteractivePart