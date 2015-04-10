Entity = require 'Entity'

class PlayerPersonController extends Entity
  K_FORWARD = 87 # w
  K_BACKWARD = 83 # s
  K_LEFT = 65 # a
  K_RIGHT = 68 # d
  K_WALK = 16 # shift
  K_INTERACT = 69 # e
  
  constructor: (@person) ->

  beforeTick: () =>
    modifier = if @game.io.keys[K_WALK] then 0.4 else 1
    x = (@game.io.keys[K_RIGHT] - @game.io.keys[K_LEFT])
    y = -(@game.io.keys[K_FORWARD] - @game.io.keys[K_BACKWARD])

    length = Math.sqrt(x * x + y * y)
    if length > 1
      x /= length
      y /= length
        
    @person.move([x * modifier, y * modifier])

  onKeyDown: (key) =>
    switch key
      when K_INTERACT
        @person.interact()

module.exports = PlayerPersonController