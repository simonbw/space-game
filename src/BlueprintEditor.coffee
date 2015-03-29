Core = require 'ship/Core'
Entity = require 'Entity'
Hull = require 'ship/Hull'
Interior = require 'ship/Interior'
IO = require 'IO'
Pixi = require 'pixi.js'
Thruster = require 'ship/Thruster'
Util = require 'util/Util'

# A screen to edit blueprints
class BlueprintEditor extends Entity
  K_NEXT_PART = 81 # q
  K_PREVIOUS_PART = 69 # e
  K_CLOSE = 32 # space

  constructor: (@blueprint, @onclose = null) ->
    @sprite = new Pixi.Container()
    @layer = 'menu'
    @background = new Pixi.Graphics()
    @background.beginFill(0x111711)
    @background.drawRect(-100, -100, 200, 200)
    @background.endFill()

    @sprite.addChild(@background)
    @sprite.addChild(@blueprint.sprite)

    @selector = new Pixi.Graphics()
    @sprite.addChild(@selector)

    @direction = 0

    @partClasses = [Hull, Thruster, Interior]
    @partIndex = 0
    @nextPart(0)

  getHoverSquare: () =>
    return @game.camera.toWorld(@game.io.mousePosition).map(Math.round)

  render: () =>
    @selector.clear()
    [x, y] = @getHoverSquare()

    hoverPart = @blueprint.partGrid.get(x, y)
    if not hoverPart?
      @selector.beginFill(@Part.type.color)
      @selector.drawRect(-0.5, -0.5, 1, 1)
      @selector.endFill()
    
    canAdd = !hoverPart
    if hoverPart?
      color = 0xFFFFFF
    else if canAdd
      color = 0x33FF33
    else
      color = 0xFF3333
    
    @selector.lineStyle(0.05, color)
    @selector.drawRect(-1, -1, 1, 1)

    if @Part.type.directional
      @selector.lineStyle(0.05, 0xFFFFFF, 0.5)
      @selector.moveTo(-0.5, -0.5) # for some reason this has to have this offset
      angle = (@direction + 3) * Math.PI / 2
      @selector.lineTo(Math.cos(angle) * 0.5 - 0.5, Math.sin(angle) * 0.5 - 0.5)

    [@selector.x, @selector.y] = [x, y]

  onClick: (mousePosition) =>
    [x, y] = @getHoverSquare()
    if not @blueprint.partGrid.get(x, y)?
      args = [x, y]
      if @Part.type.directional
        args.push(@direction)
      part = new @Part(args...)
      @blueprint.addPart(part)

  onRightClick: (mousePosition) =>
    [x, y] = @getHoverSquare()
    part = @blueprint.partGrid.get(x, y)
    if part? and part.type isnt Core.type
      @blueprint.removePart(part)

  nextPart: (i=1) =>
    @partIndex = Util.mod(@partIndex + i, @partClasses.length)
    @Part = @partClasses[@partIndex]
    console.log "Selected #{@Part.name}"

  onKeyDown: (key) =>
    switch key
      when K_CLOSE then @destroy()
      when K_NEXT_PART then @nextPart(1)
      when K_PREVIOUS_PART then @nextPart(-1)

  destroyed: () =>
    console.log "closed"
    if @onclose?
      console.log "callbacking"
      @onclose(@blueprint)
  


module.exports = BlueprintEditor