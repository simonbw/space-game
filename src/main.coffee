# Allows defining of properties on classes.
# It is a little sketchy and may disappear soon.
Function::property = (prop, desc) ->
  Object.defineProperty this.prototype, prop, desc

Game = require 'Game'
Ship = require 'ship/Ship'
Blueprint = require 'ship/Blueprint'
BlueprintEditor = require 'BlueprintEditor'
Hull = require 'ship/Hull'
FPSCounter = require 'util/FPSCounter'

window.onload = ->
  console.log "loaded"
  window.game = game = new Game()
  game.start()

  # game.addEntity(new FPSCounter())

  # TODO: Refactor this to go somewhere else.
  # ship = new Ship()
  # game.addEntity(ship)

  callback = (bp) ->
    ship = new Ship(bp)
    game.addEntity(ship)

  game.addEntity(new BlueprintEditor(new Blueprint, callback))
