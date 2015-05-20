# Base class for lots of stuff in the game
#
# @method #added()
#   Called right before being added to the game
#
# @method #render()
#   Called before rendering
#
# @method #tick()
#   Called right before physics
#
# @method #beforeTick()
#   Called before normal tick
#
# @method #afterTick()
#   Called after updating
#
# @method #afterAdded
#   Called after being added
#
# @method #destroed()
#   Called after being removed from the game
#   
class Entity
  destroy: () =>
    @game.removeEntity(this)

  ### OPTIONAL PARAMETERS ###
  # sprite [Pixi.DisplayObject]
  #   added to renderer when added to game.
  #   Do NOT change once added to game

  # layer [Pixi.DisplayObject]
  #   renderer layer to add sprite to
  #   Do NOT change once added to game

module.exports = Entity
