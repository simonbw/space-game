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
    @world.on('beginContact', @beginContact)
    @world.on('endContact', @endContact)
    @world.on('impact', @endContact)
    @io = new IO(@renderer.pixiRenderer.view)

    @framerate = 60

  @property 'timestep',
    get: ->
      return 1 / @framerate

  # Begin everything
  start: =>
    @addEntity(@camera)
    console.log "Game Started"
    window.requestAnimationFrame(@loop)
  
  loop: () =>
    window.requestAnimationFrame(@loop)
    @tick()
    @world.step(@timestep)
    @afterTick()
    @render()
    @renderer.render()

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
    
    if entity.onClick? then @io.on(IO.CLICK, entity.onClick)
    if entity.onMouseDown? then @io.on(IO.MOUSE_DOWN, entity.onMouseDown)
    if entity.onMouseUp? then @io.on(IO.MOUSE_UP, entity.onMouseUp)
    if entity.onRightClick? then @io.on(IO.RIGHT_CLICK, entity.onRightClick)
    if entity.onRightDown? then @io.on(IO.RIGHT_DOWN, entity.onRightDown)
    if entity.onRightUp? then @io.on(IO.RIGHT_UP, entity.onRightUp)
    if entity.onKeyDown? then @io.on(IO.KEY_DOWN, entity.onKeyDown)

    if entity.afterAdded? then entity.afterAdded(this)
    return entity

  # Slates an entity for removal
  removeEntity: (entity) =>
    @entities.toRemove.push(entity)
    return entity
  
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

      if entity.onClick? then @io.off(IO.CLICK, entity.onClick)
      if entity.onMouseDown? then @io.off(IO.MOUSE_DOWN, entity.onMouseDown)
      if entity.onMouseUp? then @io.off(IO.MOUSE_UP, entity.onMouseUp)
      if entity.onRightClick? then @io.off(IO.RIGHT_CLICK, entity.onRightClick)
      if entity.onRightDown? then @io.off(IO.RIGHT_DOWN, entity.onRightDown)
      if entity.onRightUp? then @io.off(IO.RIGHT_UP, entity.onRightUp)
      if entity.onKeyDown? then @io.off(IO.KEY_DOWN, entity.onKeyDown)
      
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

  # Called after physics
  afterTick: =>
    @cleanupEntities()
    for entity in @entities.afterTick
      entity.afterTick()
  
  # Called before rendering
  render: =>
    @cleanupEntities()
    for entity in @entities.render
      entity.render()

  # Handle collision begin between things.
  # Fired during narrowphase.
  beginContact: (e) =>
    if e.bodyA.beginContact?
      e.bodyA.beginContact(e.bodyB)
    if e.bodyB.beginContact?
      e.bodyB.beginContact(e.bodyA)

    if e.shapeA.beginContact?
      e.shapeA.beginContact(e.shapeB)
    if e.shapeB.beginContact?
      e.shapeB.beginContact(e.shapeA)

  # Handle collision end between things.
  # Fired after narrowphase.
  endContact: (e) =>
    if e.bodyA.endContact?
      e.bodyA.endContact(e.bodyB)
    if e.bodyB.endContact?
      e.bodyB.endContact(e.bodyA)

    if e.shapeA.endContact?
      e.shapeA.endContact(e.shapeB)
    if e.shapeB.endContact?
      e.shapeB.endContact(e.shapeA)

  # Handle impact (called after physics is done)
  impact: (e) =>
    if e.bodyA.impact?
      e.bodyA.impact(e.bodyB)
    if e.bodyB.impact?
      e.bodyB.impact(e.bodyA)

module.exports = Game