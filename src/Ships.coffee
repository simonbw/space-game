Blueprint = require "ship/Blueprint"
parts = require "ship/Parts"

Ships = {}

# Basic starting ship
Ships.starterShip = ->
  blueprint = new Blueprint()
  blueprint.addPart(new parts.Chair([0, 1]))
  blueprint.addPart(new parts.Generator([0, 2]))

  blueprint.addPart(new parts.Thruster([1, 2], 0))
  blueprint.addPart(new parts.Thruster([-1, 2], 0))

  blueprint.addPart(new parts.Thruster([1, -1], 2))
  blueprint.addPart(new parts.Thruster([-1, -1], 2))

  blueprint.addPart(new parts.Thruster([-2, 0], 1))
  blueprint.addPart(new parts.Thruster([-2, 1], 1))
  blueprint.addPart(new parts.Thruster([2, 0], 3))
  blueprint.addPart(new parts.Thruster([2, 1], 3))

  for pos in [[-1, 1], [1, 1]]
    blueprint.addPart(new parts.Interior(pos))
  for pos in [[-1, 0], [1, 0]]
    blueprint.addPart(new parts.AirVent(pos))

  return blueprint

# Basic starting ship
Ships.simpleStation = ->
  blueprint = new Blueprint()
  for x in [-5..5]
    for y in [-5..5]
      [ax, ay] = [Math.abs(x), Math.abs(y)]
      if x != 0 or y != 0
        if ax == 5 or ay == 5 # Outside
          if x == 0 or y == 0
            blueprint.addPart(new parts.Door([x, y]))
          else
            blueprint.addPart(new parts.Hull([x, y]))
        else
          if ax == 2 and ay == 2
            blueprint.addPart(new parts.AirVent([x, y]))
          else if ax == 4 and ay == 4
            blueprint.addPart(new parts.Generator([x, y]))
          else
            blueprint.addPart(new parts.Interior([x, y]))
  return blueprint

module.exports = Ships