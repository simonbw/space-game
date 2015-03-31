Core = require 'ship/parts/Core'
Entity = require 'Entity'
Grid = require 'util/Grid'
Pixi = require 'pixi.js'

# A blueprint for the layout of parts on a ship
class Blueprint extends Entity
  BASE_MASS = 0.1

  constructor: (x = 0, y = 0) ->
    @sprite = new Pixi.Graphics()
    @layer = 'world'
    @parts = []
    @partGrid = new Grid()
    @core = @addPart(new Core())

  # Add a Part to this blueprint
  addPart: (part) =>
    @parts.push(part)
    angle = if part.direction? then Math.PI / 2 * part.direction else 0
    if part.sprite?
      @sprite.addChild(part.sprite)

    @partGrid.set([part.x, part.y], part)
    return part
  
  # Take a part off this blueprint
  removePart: (part) =>
    @parts.splice(@parts.indexOf(part), 1)
    if part.sprite?
      @sprite.removeChild(part.sprite)
    
    @partGrid.remove([part.x, part.y])

    return part

module.exports = Blueprint