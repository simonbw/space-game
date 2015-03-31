p2 = require 'p2'
Pixi = require 'pixi.js'
CollisionGroups = require 'CollisionGroups'

# Base class for all ship parts
class Part
  constructor: (@x, @y, @type) ->
    @shape = @makeShape()
    @shape.owner = this
    @sprite = @makeSprite()
    @sprite.x = @x
    @sprite.y = @y
    @health = @maxHealth

  # Expose fields from the type
  ['mass', 'width', 'height', 'maxHealth'].forEach (field) ->
    Part.property field,
      get: ->
        return @type[field]
  
  makeShape: () =>
    shape = new p2.Rectangle(@width, @height)
    if @type.interior
      console.log "interior part"
      shape.collisionGroup = CollisionGroups.SHIP_INTERIOR
    else
      console.log "exterior part"
      shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR
    shape.collisionMask = CollisionGroups.ALL
    return shape

  makeSprite: () =>
    sprite = new Pixi.Graphics()
    sprite.beginFill(@type.color)
    sprite.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.endFill()
    return sprite

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