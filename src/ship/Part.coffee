p2 = require 'p2'
Pixi = require 'pixi.js'

# Base class for all ship parts
class Part
  constructor: (@x, @y, @type) ->
    @shape = @type.makeShape()
    @shape.owner = this
    @sprite = @type.makeSprite()
    @sprite.x = @x
    @sprite.y = @y
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

  @property 'maxHealth',
    get: ->
      return @type.maxHealth
  
  clone: () =>
    return new Part(@x, @y, @type)

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
    sprite.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.endFill()
    return sprite

  toString: () =>
    return @name


module.exports = Part