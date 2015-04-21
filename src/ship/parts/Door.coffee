CollisionGroups = require 'CollisionGroups'
p2 = require 'p2'
Pixi = require 'pixi.js'
InteractivePart = require 'ship/parts/InteractivePart'
Interior = require 'ship/parts/Interior'

TIME = -1 #60 * 10

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

  makeSprite: () =>
    sprite = new Pixi.Container()
    sprite.floor = new Pixi.Graphics()
    sprite.addChild(sprite.floor)
    sprite.door = new Pixi.Graphics()
    sprite.addChild(sprite.door)
    sprite.floor.beginFill(Interior.prototype.color)
    sprite.floor.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.floor.endFill()
    sprite.door.beginFill(@color)
    sprite.door.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.door.endFill()
    return sprite

  # Open the door
  open: (time=-1) =>
    @sprite.door.visible = false
    @isOpen = true
    @shape.collisionGroup = CollisionGroups.SHIP_INTERIOR
    @timer = time

  # Close the door
  close: () =>
    @sprite.door.visible = true
    @isOpen = false
    @shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR

  getPressure: () =>
    totalPressure = 0
    totalRooms = 0
    for room in @getAdjacentRooms()
      totalRooms++
      if room?
        totalPressure += room.pressure
    return (totalPressure / totalRooms) || 0

  # Returns a set of rooms this door is attached to.
  # Null means its attached to outer space
  getAdjacentRooms: () =>
    result = []
    for part in @getAdjacentParts(true)
      if not part?
        result.push(null)
      else if part.room?
        result.push(part.room)
    return result

  tick: () =>
    if @timer > 0
      @timer--
      if @timer == 0
        @close()

module.exports = Door