Entity = require 'Entity'

# Utility class that logs the framerate every 30 frames
class FPSCounter extends Entity
  constructor: ->
    @frame = 0
    @lastTick = Date.now()
    @fps = 60

  tick: () =>
    @frame++
    now = Date.now()
    @fps = 0.9 * @fps + 0.1 * (1000 / (now - @lastTick))
    @lastTick = now

    if @frame % 60 == 0
      console.log Math.round(@fps)

module.exports = FPSCounter
