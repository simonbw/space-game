Entity = require 'Entity'
Util = require 'util/Util'

normalize = (value) ->
  epsilon = 0.05
  if value > epsilon
    return value - epsilon
  if value < -1 * epsilon
    return value + epsilon
  return 0

# Controls a ship
class PlayerShipController extends Entity
  K_FORWARD = 87 # w
  K_BACKWARD = 83 # s
  K_LEFT = 65 # a
  K_RIGHT = 68 # d
  K_TURN_LEFT = 81 # q
  K_TURN_RIGHT = 69 # e
  K_STABILIZE = 16 # shift

  constructor: (@ship) ->


  beforeTick: () =>
    forward = @game.io.keys[K_FORWARD] - @game.io.keys[K_BACKWARD]
    side = @game.io.keys[K_RIGHT] - @game.io.keys[K_LEFT]
    turn = @game.io.keys[K_TURN_RIGHT] - @game.io.keys[K_TURN_LEFT]
    
    if @game.io.keys[K_STABILIZE]
      turn += Util.clamp(-@ship.body.angularVelocity * 2)
      # TODO: Linear Stabilization

    # gamepad = navigator.getGamepads()[0]
    # if gamepad?
    #   console.log gamepad
    #   side += normalize(gamepad.axes[0]) #left x
    #   forward += -normalize(gamepad.axes[1]) #left y
    #   turn += normalize(gamepad.axes[2]) #right x
    #   # gamepad.axes[3] #right y

    forward = Util.clamp(forward)
    side = Util.clamp(side)
    turn = Util.clamp(turn)

    @ship.thrustBalancer.balance(forward, side, turn)

  onKeyDown: (key) =>
    # do nothing

module.exports = PlayerShipController