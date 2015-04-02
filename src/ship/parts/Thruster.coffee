Part = require 'ship/parts/Part'

# Provides thrust
class Thruster extends Part
  color: 0x555555
  directional: true
  maxHealth: 120
  name: 'Thruster'
  thruster: true

  constructor: (pos, @direction=0) ->
    super(pos)
    @throttle = 0
    @maxThrust = 200

  makeSprite: () =>
    sprite = super()
    sprite.lineStyle(0.08, 0xFFAA00)
    sprite.moveTo(-1, -1)
    sprite.lineTo(0, -1)
    return sprite

  setThrottle: (value) =>
    @throttle = value

  tick: (ship) =>
    world = ship.gridToWorld(@position)
    angle = ship.body.angle + (@direction + 3) * Math.PI / 2
    power = @throttle * @maxThrust
    force = [Math.cos(angle) * power, Math.sin(angle) * power]
    ship.body.applyForce(force, world)

  clone: () =>
    return new Thruster(@position, @direction)

module.exports = Thruster