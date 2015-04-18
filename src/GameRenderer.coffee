Pixi = require 'pixi.js'
Camera = require 'Camera'

# The base renderer. Handles layers and camera movement.
class GameRenderer
  
  # Create a new GameRenderer
  constructor: ->
    [w, h] = [window.innerWidth, window.innerHeight]
    @pixiRenderer = Pixi.autoDetectRenderer(w, h, {antialias: false})
    document.body.appendChild(@pixiRenderer.view)
    @stage = new Pixi.Container()
    @camera = new Camera(this)

    @layerInfos = {}
    @layerInfos['menu'] = { scroll: 0 }
    @layerInfos['hud'] = { scroll: 0 }
    @layerInfos['world_overlay'] = { scroll: 1 }
    @layerInfos['world_front'] = { scroll: 1 }
    @layerInfos['world'] = { scroll: 1 }
    @layerInfos['world_back'] = { scroll: 1 }

    order = ['menu', 'hud', 'world_overlay', 'world_front', 'world', 'world_back']
    for name, i in order
      layerInfo = @layerInfos[name]
      layerInfo.name = name
      layer = new Pixi.Container()
      layerInfo.index = i
      layerInfo.layer = layer
      @stage.addChildAt(layer, i)

  # Render the current frame.
  render: (engine) =>
    for name, info of @layerInfos
      @camera.updateLayer(info)
    
    @pixiRenderer.render(@stage)

  # Add a child to a specific layer.
  add: (sprite, layer='world') =>
    @layerInfos[layer.toLowerCase()].layer.addChild(sprite)

  # Remove a child from a specific layer.
  remove: (sprite, layer='world') =>
    @layerInfos[layer.toLowerCase()].layer.removeChild(sprite)

module.exports = GameRenderer
