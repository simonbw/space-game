CollisionGroups = require 'CollisionGroups'
Part = require 'ship/parts/Part'

class Door extends Part
  color: 0x999999
  maxHealth: 250
  name: 'Door'

  constructor: (pos) ->
    super(pos)
    @isOpen = false

  open: () =>
    console.log "opening"
    @sprite.alpha = 0.1
    @isOpen = true
    @shape.collisionGroup = CollisionGroups.SHIP_INTERIOR

  close: () =>
    console.log "closing"
    @sprite.alpha = 1.0
    @isOpen = false
    @shape.collisionGroup = CollisionGroups.SHIP_EXTERIOR

  tick: () =>
    if Math.random() < 0.01
      if @isOpen then @close() else @open()

module.exports = Door