GameRenderer = require 'GameRenderer'
IO = require 'IO'
p2 = require 'p2'

# Top Level control structure
class Game
  constructor: ->
    @entities = {
      all: []
      render: []
      tick: []
      beforeTick: []
      afterTick: []
      toRemove: []
    }
    @renderer = new GameRenderer()
    @camera = @renderer.camera
    @world = new p2.World({
      gravity: [0, 0]
    })
    @io = new IO(@renderer.pixiRenderer.view)

  # Begin everything
  start: =>
    console.log "Game Started"
    window.requestAnimationFrame(@loop)
  
  loop: () =>
    window.requestAnimationFrame(@loop)
    @tick()
    @world.step(1 / 60)
    @render()
    @renderer.render()
    @afterTick()

  # Add an entity to the game
  addEntity: (entity) =>
    entity.game = this
    if entity.added? then entity.added(this)
    @entities.all.push(entity)
    if entity.render? then @entities.render.push(entity)
    if entity.beforeTick? then @entities.beforeTick.push(entity)
    if entity.tick? then @entities.tick.push(entity)
    if entity.afterTick? then @entities.afterTick.push(entity)
    if entity.sprite? then @renderer.add(entity.sprite, entity.layer)
    if entity.body? then @world.addBody(entity.body)
    if entity.onClick? then @io.on('click', entity.onClick)
    if entity.onMouseDown? then @io.on('mousedown', entity.onMouseDown)
    if entity.onMouseUp? then @io.on('mousedown', entity.onMouseUp)
    if entity.onRightClick? then @io.on('rightclick', entity.onRightClick)
    if entity.onRightDown? then @io.on('rightdown', entity.onRightDown)
    if entity.onRightUp? then @io.on('rightdown', entity.onRightUp)

    if entity.afterAdded? then entity.afterAdded(this)

  # Slates an entity for removal
  removeEntity: (entity) =>
    @entities.toRemove.push(entity)
  
  # Actually removes references to the entities slated for removal
  cleanupEntities: =>
    # TODO: Do we really need a separate removal pass?
    while @entities.toRemove.length
      entity = @entities.toRemove.pop()
      @entities.all.splice(@entities.all.indexOf(entity), 1)
      if entity.render?
        @entities.render.splice(@entities.render.indexOf(entity), 1)
      if entity.tick?
        @entities.tick.splice(@entities.tick.indexOf(entity), 1)
      if entity.afterTick?
        @entities.afterTick.splice(@entities.afterTick.indexOf(entity), 1)
      
      if entity.sprite?
        @renderer.remove(entity.sprite, entity.layer)
      if entity.body?
        @world.removeBody(entity.body)

      if entity.onClick? then @io.off('click', entity.onClick)
      if entity.onMouseDown? then @io.off('mousedown', entity.onMouseDown)
      if entity.onMouseUp? then @io.off('mousedown', entity.onMouseUp)
      if entity.onRightClick? then @io.off('rightclick', entity.onRightClick)
      if entity.onRightDown? then @io.off('rightdown', entity.onRightDown)
      if entity.onRightUp? then @io.off('rightdown', entity.onRightUp)
      
      if entity.destroyed?
        entity.destroyed(this)
      entity.game = null

  # Called before physics
  tick: =>
    @cleanupEntities()
    for entity in @entities.beforeTick
      entity.beforeTick()
    @cleanupEntities()
    for entity in @entities.tick
      entity.tick()

  # Called after everything
  afterTick: =>
    @cleanupEntities()
    for entity in @entities.afterTick
      entity.afterTick()
  
  # Called before rendering
  render: =>
    @cleanupEntities()
    for entity in @entities.render
      entity.render()

module.exports = Game