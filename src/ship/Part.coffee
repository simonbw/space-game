p2 = require 'p2'
Pixi = require 'pixi.js'

# Base class for all ship parts
class Part
  constructor: (@x, @y, @type) ->
    @shape = @type.makeShape()
    @shape.owner = this
    @sprite = @type.makeSprite()
    @sprite.x = @x - @width / 2
    @sprite.y = @y - @height / 2
    @health = @type.maxHealth
 
  @property 'mass',
    get: ->
      return @type.mass

  @property 'width',
    get: ->
      return @type.width

  @property 'height',
    get: ->
      return @type.height
  
  toString: () =>
    return "<#{@type} at (#{@x},#{@y})>"


# Contains data about all parts of the same type
class Part.Type
  constructor: (@name, @width=1, @height=1, @color=0xBBBBBB, @maxHealth=100) ->
    @mass = @width * @height

  makeShape: () =>
    return new p2.Rectangle(@width, @height)

  makeSprite: () =>
    sprite = new Pixi.Graphics()
    sprite.beginFill(@color)
    sprite.drawRect(0.05, 0.05, @width - 0.1, @height - 0.1)
    sprite.endFill()
    return sprite

  toString: () =>
    return @name


# Base class for ship parts with direction
class Part.Directional
  constructor: (x, y, type, @direction=0) ->
    super(x, y, type)

module.exports = Part