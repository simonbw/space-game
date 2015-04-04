CollisionGroups = require 'CollisionGroups'
Part = require 'ship/parts/Part'

class Door extends Part
  color: 0x999999
  maxHealth: 250
  name: 'Door'

  constructor: (pos) ->
    super(pos)
    @isOpen = false

  open: () =>
    @sprite.alpha = 0.1
    @isOpen = true
    @shape.collisionGroup = CollisionGroups.SHIP_INTERIOR

  close: () =>
    @sprite.alpha = 1.0
    @isOpen = false
    @shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR

  # Returns a set of rooms this door is attached to.
  # Null means its attached to outer space
  getAdjacentRooms: (ship) =>
    result = new Set()
    for part in @getAdjacentParts(ship, true)
      if not part?
        result.add(null)
      else if part.room?
        result.add(part.room)
    return result

  tick: () =>
    if Math.random() < 0.01
      if @isOpen then @close() else @open()

module.exports = Door