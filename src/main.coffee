# Allows defining of properties on classes.
# It is a little sketchy and may disappear soon.
Function::property = (prop, desc) ->
  Object.defineProperty this.prototype, prop, desc

Blueprint = require 'ship/Blueprint'
BlueprintEditor = require 'BlueprintEditor'
FPSCounter = require 'util/FPSCounter'
Game = require 'Game'
Hull = require 'ship/parts/Hull'
Person = require 'Person'
PlayerShipController = require 'PlayerShipController'
PlayerPersonController = require 'PlayerPersonController'
Ship = require 'ship/Ship'
ShipHud = require 'ShipHud'

window.onload = ->
  console.log "loaded"
  window.game = game = new Game()
  game.start()

  # game.addEntity(new FPSCounter())

  # TODO: Refactor this to go somewhere else.
  # ship = new Ship()
  # game.addEntity(ship)

  callback = (bp) ->
    game.camera.z = 20
    window.ship = new Ship(bp)
    person = new Person()
    person.board(ship)
    controller = new PlayerPersonController(person)
    # controller = new PlayerShipController(ship)
    hud = new ShipHud(ship)
    game.addEntity(ship)
    game.addEntity(person)
    game.addEntity(controller)
    game.addEntity(hud)
    game.camera.follow(ship)

  game.addEntity(new BlueprintEditor(new Blueprint, callback))
