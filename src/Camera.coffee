Pixi = require "pixi.js"
Matrix = Pixi.Matrix
Point = Pixi.Point

# Controls the viewport
class Camera
  constructor: (@renderer, @x = 0, @y = 0, @z = 10.0, @angle = 0) ->
    @following = null

  # Make the camera center on this thing every frame
  follow: (thing) =>
    @following = thing

  tick: =>
    if @following?
      @x = @following.x
      @y = @following.y

  # Returns [width, height] of the viewport
  getViewportSize: =>
    return [@renderer.pixiRenderer.width, @renderer.pixiRenderer.height]

  # Convert screen coordinates to world coordinates
  toWorld: (x, y) =>
    [w, h] = @getViewportSize()
    if not x?
      y = x.y
      x = x.x
    p = new Point(x, y)
    return @getMatrix().apply(p, p)

  # Convert world coordinates to screen coordinates
  toScreen: (x, y) =>
    [w, h] = @getViewportSize()
    if not x?
      y = x.y
      x = x.x
    p = new Point(x, y)
    return @getMatrix().applyInverse(p, p)

  # Creates a transformation matrix to go from screen space to world space.
  getMatrix: (scale = 1.0) =>
    [w, h] = @getViewportSize()
    m = new Matrix()
    m.translate(-@x, -@y)
    m.scale(@z * scale, @z * scale)
    m.rotate(@angle)
    m.translate(w / 2, h / 2)
    return m

  # Update the properties of a renderer layer to match this camera
  updateLayer: (layerInfo) =>
    layer = layerInfo.layer
    [w, h] = @getViewportSize()

    p = @toWorld(0, 0)

    layer.x = p.x
    layer.y = p.y

    layer.rotation = @angle
    layer.scale.x = @z
    layer.scale.y = -@z

module.exports = Camera
