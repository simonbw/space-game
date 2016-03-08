Entity = require 'core/Entity'
IO = require 'core/IO'
Util = require 'util/Util'

# Controls the player's character
class PlayerPersonController extends Entity
  K_FORWARD = 87 # w
  K_BACKWARD = 83 # s
  K_LEFT = 65 # a
  K_RIGHT = 68 # d
  K_TURN_LEFT = 81 # q
  K_TURN_RIGHT = 69 # e
  K_STABILIZE = 16 # shift
  K_WALK = 16 # shift
  K_INTERACT = 32 # space
  K_NEXT_INTERACT = 9 # tab

  A_MOVE_X = 0
  A_MOVE_Y = 1
  A_TURN = 2
  A_AIM_X = 2
  A_AIM_Y = 3

  B_INTERACT = 0
  B_NEXT_INTERACT = 1

  constructor: (@person) ->
    @shipController = null

  beforeTick: () =>
    if @person.chair?
      @controlShip()
    else
      @controlPerson()

# Send inputs for the ship the player is in
  controlShip: () =>
    ship = @person.chair.ship

    forward = -@getForward()
    side = @getSide()
    turn = @getTurn()

    if @game.io.keys[K_STABILIZE]
      turn = Util.clamp(turn - ship.body.angularVelocity * 2)
      # TODO: Linear Stabilization

    # aim toward mouse
#    k = 2.0 # spring constant
#    m = 1
#    d = 0.9 # damping coefficient
#    c = 2 * Math.sqrt(m * k) * d
#    v = ship.body.angularVelocity
#    x = Util.angleDelta(ship.body.angle, @getAimAngle() + Math.PI / 2)
#    x = 0.9 * x + 0.1 * x ** 3
#    turn = Util.clamp(k * x - c * v)

    ship.thrustBalancer.balance(forward, side, turn)

# Send inputs to control a person not a ship
  controlPerson: () =>
    modifier = if @game.io.keys[K_WALK] then 0.4 else 1
    x = @getSide() * modifier
    y = -@getForward() * modifier
    length = Math.sqrt(x * x + y * y)
    if length > 1
      x /= length
      y /= length

    @person.move([x * modifier, y * modifier])
    @person.rotateTowards(@getAimAngle())

  getAimAngle: () =>
    if @game.io.usingGamepad
      [dx, dy] = [@game.io.getAxis(A_AIM_X), @game.io.getAxis(A_AIM_Y)]
    else
      mouseWorldPosition = @game.camera.toWorld(@game.io.mousePosition)
      [dx, dy] = [mouseWorldPosition[0] - @person.position[0], mouseWorldPosition[1] - @person.position[1]]
    return Math.atan2(dy, dx)

  getSide: =>
    return @game.io.keys[K_RIGHT] - @game.io.keys[K_LEFT] + @game.io.getAxis(A_MOVE_X)

  getForward: =>
    return @game.io.keys[K_FORWARD] - @game.io.keys[K_BACKWARD] - @game.io.getAxis(A_MOVE_Y)

  getTurn: =>
    return @game.io.keys[K_TURN_RIGHT] - @game.io.keys[K_TURN_LEFT] + @game.io.getAxis(A_TURN)

  onButtonDown: (button) =>
    switch button
      when B_INTERACT
        @person.interact()
      when B_NEXT_INTERACT
        if @game.io.keys[16]
          @person.previousInteraction()
        else
          @person.nextInteraction()

  onKeyDown: (key) =>
    switch key
      when K_INTERACT
        @person.interact()
      when K_NEXT_INTERACT
        if @game.io.keys[16]
          @person.previousInteraction()
        else
          @person.nextInteraction()

module.exports = PlayerPersonController