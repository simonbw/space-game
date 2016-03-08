# Allows defining of properties on classes.
# It is a little sketchy and may disappear soon.
Function::property = (prop, desc) ->
  Object.defineProperty this.prototype, prop, desc

require 'numeric'

BlueprintEditor = require 'BlueprintEditor'
CameraController = require 'controllers/CameraController'
FPSCounter = require 'util/FPSCounter'
Game = require 'core/Game'
Person = require 'Person'
PlayerPersonController = require 'controllers/PlayerPersonController'
Ship = require 'ship/Ship'
Ships = require 'Ships'
ShipHud = require 'hud/ShipHud'
PersonHud = require 'hud/PersonHud'

window.onload = ->
  console.log "loaded"
  window.game = game = new Game()
  game.start()

  # game.addEntity(new FPSCounter())

  # TODO: Refactor this to go somewhere else.
  # ship = new Ship()
  # game.addEntity(ship)

  callback = (bp) ->
    window.ship = new Ship(bp)
    window.station = new Ship(Ships.simpleStation(), [0, -20])
    game.addEntity(station)
    person = new Person([0, 1])
    person.board(ship)
    game.addEntity(new ShipHud(ship))
    game.addEntity(new PersonHud(person))
    game.addEntity(ship)
    game.addEntity(person)
    game.addEntity(new PlayerPersonController(person))
    game.addEntity(new CameraController(game.camera, person))

  game.addEntity(new BlueprintEditor(Ships.starterShip(), callback))
#  game.addEntity(new FPSCounter)


  # maximize c * x
  #
  c = [1, 1]
  A = [[-1,0],[0,-1],[-1,-2]]
  b = [0, 0, 3]
#  console.log 'c:', c
#  console.log 'A', A
#  console.log 'b', b
#  console.log 'x', numeric.solveLP(c, A, b)
