Entity = require 'core/Entity'
Pixi = require 'pixi.js'
Point = Pixi.Point

Matrix = Pixi.Matrix

# Controls the viewport
class Camera extends Entity
  constructor: (@renderer, @position = null, @z = 30.0, @angle = 0) ->
    @position ?= [0, 0]
    @velocity = [0, 0]
  
  # Easy access to position[0]
  @property 'x',
    get: () ->
      return @position[0]
    set: (value) ->
      @position[0] = value

  # Easy access to position[1]
  @property 'y',
    get: ->
      return @position[1]
    set: (value) ->
      @position[1] = value

  # Easy access to velocity[0]
  @property 'vx',
    get: ->
      return @velocity[0]
    set: (value) ->
      @velocity[0] = value

  # Easy access to velocity[1]
  @property 'vy',
    get: ->
      return @velocity[1]
    set: (value) ->
      @velocity[1] = value

  render: () =>
    @x += @vx * @game.timestep
    @y += @vy * @game.timestep

  # Center the camera on a position
  center: ([x, y]) =>
    @x = x
    @y = y

  # Move the camera toward being centered on a position, with a target velocity
  smoothCenter: ([x, y], [vx, vy], smooth = 0.9) =>
    # TODO: make velocity transition smooth
    dx = (x - @x) * @game.framerate
    dy = (y - @y) * @game.framerate
    @vx = vx + (1 - smooth) * dx
    @vy = vy + (1 - smooth) * dy

  # Set the camera 
  smoothZoom: (z, smooth = 0.9) =>
    @z = smooth * @z + (1 - smooth) * z

  # Returns [width, height] of the viewport
  getViewportSize: =>
    return [@renderer.pixiRenderer.width, @renderer.pixiRenderer.height]

  # Convert screen coordinates to world coordinates
  toWorld: ([x, y], depth = 1.0) =>
    [w, h] = @getViewportSize()
    p = new Point(x, y)
    p = @getMatrix(depth).applyInverse(p, p)
    return [p.x, p.y]

  # Convert world coordinates to screen coordinates
  toScreen: ([x, y], depth = 1.0) =>
    [w, h] = @getViewportSize()
    p = new Point(x, y)
    p = @getMatrix(depth).apply(p, p)
    return [p.x, p.y]

  # Creates a transformation matrix to go from screen world space to screen space.
  getMatrix: (depth = 1.0) =>
    [w, h] = @getViewportSize()
    m = new Matrix()
    m.translate(-@x * depth, -@y * depth)
    m.scale(@z * depth, @z * depth)
    m.rotate(@angle)
    m.translate(w / 2, h / 2)
    return m

  # Update the properties of a renderer layer to match this camera
  updateLayer: (layerInfo) =>
    scroll = layerInfo.scroll
    if scroll != 0
      layer = layerInfo.layer
      [layer.x, layer.y] = @toScreen([0, 0])
      layer.rotation = @angle
      layer.scale.set(@z, @z)

module.exports = Camera
