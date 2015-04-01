CollisionGroups = require 'CollisionGroups'
p2 = require 'p2'
Pixi = require 'pixi.js'

partCount = 0
# Base class for all ship parts
class Part
  constructor: (@x, @y, @type) ->
    @partId = partCount++
    @shape = @makeShape()
    @shape.owner = this
    @sprite = @makeSprite()
    @sprite.x = @x
    @sprite.y = @y
    @health = @maxHealth

  # Expose fields from the type
  ['mass', 'width', 'height', 'maxHealth', 'interior'].forEach (field) ->
    Part.property field,
      get: ->
        return @type[field]

  @property 'position',
    get: ->
      return [@x, @y]
      
  makeShape: () =>
    shape = new p2.Rectangle(@width, @height)
    if @type.interior
      shape.collisionGroup = CollisionGroups.SHIP_INTERIOR
    else
      shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR
    shape.collisionMask = CollisionGroups.ALL
    return shape

  makeSprite: () =>
    sprite = new Pixi.Graphics()
    sprite.beginFill(@type.color)
    sprite.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.endFill()
    return sprite

  getAdjacentPoints: () =>
    return [[@x + 1, @y], [@x, @y + 1], [@x - 1, @y], [@x, @y - 1]]

  # 
  getAdjacentParts: (ship, withNull=false) =>
    parts = []
    for point in @getAdjacentPoints()
      part = ship.partAtGrid(point)
      if withNull or part?
        parts.push(part)
    return parts

  clone: () =>
    return new Part(@x, @y, @type)

  toString: () =>
    return "<#{@type} at (#{@x},#{@y})>"


# Contains data about all parts of the same type
# TODO: Refactor this so that a separate Type class is not needed.
class Part.Type
  constructor: (@name, @width=1, @height=1, @color=0xBBBBBB, @maxHealth=100) ->
    @mass = @width * @height

  toString: () =>
    return @name


module.exports = Part