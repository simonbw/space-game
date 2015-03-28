Part = require 'ship/Part'

# Provides thrust
class Thruster extends Part
  @type = type = new Part.Type('Thruster', 1, 1, 0x666666)

  constructor: (x, y, @direction=0) ->
    super(x, y, type)
    @throttle = 0

  setThrottle: (value) =>
    @throttle = value

  tick: (ship) =>
    world = ship.gridToWorld([@x, @y])
    angle = ship.body.angle + (@direction + 1) * Math.PI / 2
    power = @throttle * 5
    force = [Math.cos(angle) * power, Math.sin(angle) * power]
    ship.body.applyForce(force, world)

module.exports = Thruster