Entity = require 'Entity'
Pixi = require 'pixi.js'
Hull = require 'ship/Hull'
Core = require 'ship/Core'

# A screen to edit blueprints
class BlueprintEditor extends Entity
  constructor: (@blueprint) ->
    @sprite = new Pixi.Container()
    @layer = 'menu'
    @background = new Pixi.Graphics()
    @sprite.addChild(@background)
    @sprite.addChild(@blueprint.sprite)

    @selector = new Pixi.Graphics()
    @sprite.addChild(@selector)

  getHoverSquare: () =>
    return @game.camera.toWorld(@game.io.mousePosition).map(Math.round)

  render: () =>

    @selector.clear()
    @selector.lineStyle(0.05, 0xFFFFFF)
    @selector.drawRect(-1, -1, 1, 1)

    [@selector.x, @selector.y] = @getHoverSquare()

  onClick: (mousePosition) =>
    [x, y] = @getHoverSquare()
    if not @blueprint.partGrid.get(x, y)?
      part = new Hull(x, y)
      @blueprint.addPart(part)

  onRightClick: (mousePosition) =>
    [x, y] = @getHoverSquare()
    part = @blueprint.partGrid.get(x, y)
    if part? and part.type isnt Core.type
      @blueprint.removePart(part)
  


module.exports = BlueprintEditor