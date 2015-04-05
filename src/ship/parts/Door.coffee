CollisionGroups = require 'CollisionGroups'
p2 = require 'p2'
InteractivePart = require 'ship/parts/InteractivePart'

TIME = 60 * 2

class Door extends InteractivePart
  color: 0x999999
  maxHealth: 250
  name: 'Door'

  constructor: (pos) ->
    super(pos)
    @isOpen = false
    @timer = 0

  # Called when a person interacts with this
  interact: (person) =>
    if @isOpen
      @close()
    else
      @open(TIME)

  # Open the door
  open: (time=-1) =>
    @sprite.alpha = 0.1
    @isOpen = true
    @shape.collisionGroup = CollisionGroups.SHIP_INTERIOR
    @timer = time

  # Close the door
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
    if @timer > 0
      @timer--
      if @timer == 0
        @close()

module.exports = Door