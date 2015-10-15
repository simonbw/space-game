Part = require 'ship/parts/Part'
Pixi = require 'pixi.js'

Util = require 'util/Util'


# Provides thrust
class Thruster extends Part
  color: 0x555555
  directional: true
  maxHealth: 120
  name: 'Thruster'
  thruster: true
  maxEnergyDeficit: 0.5

  constructor: (pos, @direction=0) ->
    super(pos)
    @throttle = 0
    @maxThrust = 200
    @energyDeficit = @maxEnergyDeficit

  makeSprite: () =>
    sprite = super()
    sprite.flame = new Pixi.Graphics
    sprite.addChild(sprite.flame)
    return sprite

  renderThrust: (thrust) =>
    @sprite.flame.clear()
    @sprite.flame.lineStyle(0.4 * thrust / @maxThrust, 0xFFAA00)
    @sprite.flame.moveTo(-1, -1)
    @sprite.flame.lineTo(0, -1)

  setThrottle: (value) =>
    @throttle = Util.clamp(value, 0)

# Return the amount of thrust to apply based on current state of the thruster
  getThrust: () =>
    target = @throttle * @maxThrust
    energyLimited = (1 - @energyDeficit / @maxEnergyDeficit) * @maxThrust
    return Math.min(target, energyLimited)

  tick: (ship) =>
    world = ship.gridToWorld(@position)
    angle = ship.body.angle + (@direction + 3) * Math.PI / 2
    thrust = @getThrust()
    force = [Math.cos(angle) * thrust, Math.sin(angle) * thrust]
    ship.body.applyForce(force, world)
    @energyDeficit += thrust / @maxThrust * @maxEnergyDeficit
    @renderThrust(thrust)

  clone: () =>
    return new Thruster(@position, @direction)

module.exports = Thruster