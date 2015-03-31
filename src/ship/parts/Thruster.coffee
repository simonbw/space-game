Part = require 'ship/parts/Part'

type = new Part.Type('Thruster', 1, 1, 0x666666)
type.directional = true
type.thruster = true

# Provides thrust
class Thruster extends Part
  @type = type

  constructor: (x, y, @direction=0) ->
    super(x, y, type)
    @throttle = 0
    @maxThrust = 200

  makeSprite: () =>
    sprite = super()
    sprite.lineStyle(0.08, 0xFFAA00)
    sprite.moveTo(-1, -1)
    sprite.lineTo(0, -1)
    sprite.rotation = (@direction + 2) * Math.PI / 2
    return sprite

  setThrottle: (value) =>
    @throttle = value

  tick: (ship) =>
    world = ship.gridToWorld([@x, @y])
    angle = ship.body.angle + (@direction + 3) * Math.PI / 2
    power = @throttle * @maxThrust
    force = [Math.cos(angle) * power, Math.sin(angle) * power]
    ship.body.applyForce(force, world)

  clone: () =>
    return new Thruster(@x, @y, @direction)

module.exports = Thruster