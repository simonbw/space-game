Entity = require 'Entity'
PlayerShipController = require 'controllers/PlayerShipController'
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
  
  constructor: (@person) ->
    @shipController = null

  beforeTick: () =>
    if @person.chair?
      forward = @getForward()
      side = @getSide()
      turn = @getTurn()
      
      if @game.io.keys[K_STABILIZE]
        turn = Util.clamp(turn - @person.chair.ship.body.angularVelocity * 2)
        # TODO: Linear Stabilization

      @person.chair.ship.thrustBalancer.balance(forward, side, turn)
    else
      modifier = if @game.io.keys[K_WALK] then 0.4 else 1
      x = @getSide() * modifier
      y = -@getForward() * modifier

      length = Math.sqrt(x * x + y * y)
      if length > 1
        x /= length
        y /= length
          
      @person.move([x * modifier, y * modifier])

  getSide: =>
    return @game.io.keys[K_RIGHT] - @game.io.keys[K_LEFT]

  getForward: =>
    return @game.io.keys[K_FORWARD] - @game.io.keys[K_BACKWARD]

  getTurn: =>
    return @game.io.keys[K_TURN_RIGHT] - @game.io.keys[K_TURN_LEFT]


  onKeyDown: (key) =>
    switch key
      when K_INTERACT
        @person.interact()

module.exports = PlayerPersonController