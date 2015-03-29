Part = require 'ship/Part'

# Provides thrust
class Thruster extends Part
  @type = type = new Part.Type('Thruster', 1, 1, 0x666666)
  type.directional = true

  constructor: (x, y, @direction=0) ->
    super(x, y, type)
    @throttle = 1
    @maxThrust = 10

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