Core = require 'ship/parts/Core'
Entity = require 'Entity'
Hull = require 'ship/parts/Hull'
Interior = require 'ship/parts/Interior'
IO = require 'IO'
Pixi = require 'pixi.js'
Thruster = require 'ship/parts/Thruster'
Util = require 'util/Util'

class PartLabel extends Entity
  constructor: () ->
    @layer = 'hud'
    @sprite = new Pixi.Text('part', {
      font: '20px Arial'
      fill: '#FFFFFF'
    })

# A screen to edit blueprints
class BlueprintEditor extends Entity
  # KEYS
  K_NEXT_PART = 81 # q
  K_PREVIOUS_PART = 69 # e
  K_ROTATE_LEFT = 65 # a
  K_ROTATE_RIGHT = 68 # d
  K_CLOSE = 32 # space
  # K_CLOSE = 13 # enter

  constructor: (@blueprint, @onclose = null) ->
    @sprite = new Pixi.Container()
    @layer = 'world'
    @background = new Pixi.Graphics()
    @background.beginFill(0x111711)
    @background.endFill()

    @sprite.addChild(@background)
    @sprite.addChild(@blueprint.sprite)

    @selector = new Pixi.Graphics()
    @sprite.addChild(@selector)

    @partLabel = new PartLabel()

    @direction = 0
    @partClasses = [Hull, Thruster, Interior]
    @partIndex = 0
    @nextPart(0)

  added: () =>
    @game.addEntity(@partLabel)

  # Return the grid coordinates of the square the mouse is over
  getHoverSquare: () =>
    return @game.camera.toWorld(@game.io.mousePosition).map(Math.round)
  
  render: () =>
    @selector.clear()
    squrePos = @getHoverSquare()
    hoverPart = @blueprint.partGrid.get(squrePos)
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

    if game.io.buttons[0]
      @onClick()

    if game.io.buttons[2]
      @onRightClick()

    [@selector.x, @selector.y] = squrePos

  # Add parts on click
  onClick: (mousePosition) =>
    [x, y] = @getHoverSquare()
    if not @blueprint.partGrid.get([x, y])?
      args = [x, y]
      if @Part.type.directional
        args.push(@direction)
      part = new @Part(args...)
      @blueprint.addPart(part)

  # Remove parts on right click
  onRightClick: (mousePosition) =>
    part = @blueprint.partGrid.get(@getHoverSquare())
    if part? and part.type isnt Core.type
      @blueprint.removePart(part)

  # Select the next part.
  nextPart: (i=1) =>
    @partIndex = Util.mod(@partIndex + i, @partClasses.length)
    @Part = @partClasses[@partIndex]
    @partLabel.sprite.text = @Part.type.name

  # Rotate the current direction
  rotate: (i=1) =>
    @direction = Util.mod(@direction + i, 4)
  
  # Handle key presses
  onKeyDown: (key) =>
    switch key
      when K_CLOSE then @destroy()
      when K_NEXT_PART then @nextPart(1)
      when K_PREVIOUS_PART then @nextPart(-1)
      when K_ROTATE_LEFT then @rotate(-1)
      when K_ROTATE_RIGHT then @rotate(1)

  destroyed: () =>
    @partLabel.destroy()
    if @onclose?
      @onclose(@blueprint)
  


module.exports = BlueprintEditor