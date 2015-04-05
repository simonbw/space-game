Pixi = require 'pixi.js'
Matrix = Pixi.Matrix
Point = Pixi.Point

# Controls the viewport
class Camera
  constructor: (@renderer, @x = 0, @y = 0, @z = 30.0, @angle = 0) ->
    @following = null

  # Make the camera center on this thing every frame
  follow: (thing) =>
    @following = thing

  tick: =>
    if @following?
      [@x, @y] = @following.position
      # console.log [@x, @y]

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
      [w, h] = @getViewportSize()
      [layer.x, layer.y] = @toScreen([0, 0])
      layer.rotation = @angle
      layer.scale.set(@z, @z)

module.exports = Camera
