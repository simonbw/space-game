CollisionGroups = require 'CollisionGroups'
p2 = require 'p2'
Pixi = require 'pixi.js'

# A count of all parts created ever
partCount = 0

# Base class for all ship parts
class Part

  # Default Properties
  color: 0xFFFFFF
  directional: false
  height: 1
  interior: false
  mass: 1
  maxHealth: 100
  name: 'Ship Part'
  width: 1

  constructor: (@position) ->
    @partId = partCount++
    if @makeShape?
      @shape = @makeShape()
      @shape.owner = this
    if @makeSprite?
      @sprite = @makeSprite()
      [@sprite.x, @sprite.y] = @position
    @health = @maxHealth

  # Grid position of this part
  @property 'x',
    get: ->
      return @position[0]
    set: (val) ->
      @position[0] = val

  # Grid position of this part
  @property 'y',
    get: ->
      return @position[1]
    set: (val) ->
      @position[1] = val
  
  # Create the physics shape
  makeShape: () =>
    shape = new p2.Rectangle(@width, @height)
    if @interior
      shape.collisionGroup = CollisionGroups.SHIP_INTERIOR
    else
      shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR
    shape.collisionMask = CollisionGroups.ALL
    return shape

  # Create the sprite
  makeSprite: () =>
    sprite = new Pixi.Graphics()
    sprite.beginFill(@color)
    sprite.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.endFill()
    if @directional
      sprite.rotation = (@direction + 2) * Math.PI / 2
    return sprite

  # Return a list of grid points that are adjacent to this part.
  getAdjacentPoints: () =>
    return [[@x + 1, @y], [@x, @y + 1], [@x - 1, @y], [@x, @y - 1]]

  # Return an array of adjacent parts
  # @param withNull [Boolean]
  getAdjacentParts: (withNull=false) =>
    parts = []
    for point in @getAdjacentPoints()
      part = @ship.partAtGrid(point)
      if withNull or part?
        parts.push(part)
    return parts

  # Return the air pressure of the current part
  # For parts without an interior, this is 0.
  getPressure: () =>
    if @room?
      return @room.pressure
    return 0
  
  # Return the position of the part in local physics coordinates of the ship
  getLocalPosition: () =>
    if @ship?
      return @ship.gridToLocal(@position)
    return null

  # Return the position of the part in world physics coordinates
  getWorldPosition: () =>
    if @ship
      return @ship.gridToWorld(@position)
    return null

  getVelocity: () =>
    if @ship
      return @ship.velocityAtGridPoint(@position)
    return null

  # Return a copy of this part
  clone: () =>
    return new @constructor(@position)

  # A nice string of this part
  toString: () =>
    return "<#{@name} at (#{@position})>"


module.exports = Part