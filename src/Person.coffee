CollisionGroups = require 'CollisionGroups'
Entity = require 'Entity'
p2 = require 'p2'
Part = require 'ship/parts/Part'
Pixi = require 'pixi.js'

# A person
class Person extends Entity
  RADIUS = 0.3
  WALK_FORCE = 10
  WALK_FRICTION = 0.4
  JETPACK_FORCE = 0.4
  MAXIMUM_FRICTION = 1.0

  constructor: (pos=[0,0], ship=null) ->
    @body = @makeBody(pos)
    @sprite = @makeSprite()
    @interactions = new Set()
    @board(ship)
    @room = null
    @chair = null

  @property 'position',
    get: ->
      return @body.position

  # Make the body for t
  makeBody: (pos) =>
    body = new p2.Body({
      position: pos
      mass: 0.1
      angularDamping: 0.01
      damping: 0.0
    })
    body.owner = this
    shape = new p2.Circle(RADIUS)
    shape.beginContact = @beginContact
    shape.endContact = @endContact
    shape.collisionGroup = CollisionGroups.PERSON
    shape.collisionMask = CollisionGroups.PERSON_MASK
    shape.owner = this
    body.addShape(shape)
    return body

  makeSprite: () =>
    sprite = new Pixi.Graphics()
    sprite.beginFill(0x00FF00)
    sprite.drawCircle(0, 0, RADIUS)
    sprite.endFill()
    return sprite

  # Interact with all the parts in range
  interact: () =>
    @interactions.forEach (part) =>
      part.interact(this)

  board: (ship) =>
    @ship = ship
    if ship?
      @shipPosition = @ship.worldToLocal(@body.position)
    else
      @shipPosition = null

  move: ([x, y]) =>
    if not @chair?
      part = @getPart()
      pressure = @getPressure()
      speed = if (pressure > 0.4) then WALK_FORCE * pressure else JETPACK_FORCE
      [fx, fy] = [x * speed, y * speed]
      @body.force[0] += fx
      @body.force[1] += fy
      if pressure
        @ship.body.applyForce([-fx, -fy], @position)

  render: () =>
    [@sprite.x, @sprite.y] = @body.position

  getPart: () =>
    if not ship? then return undefined
    return @ship.partAtWorld(@position)
    
  getPressure: () =>
    part = @getPart()
    if part?
      return part.getPressure()
    return 0

  beginContact: (otherShape) =>
    if otherShape.sensor and otherShape.owner? and otherShape.owner.interactive
      @interactions.add(otherShape.owner)
      if otherShape.owner.personEnter?
        otherShape.owner.personEnter(this)

  endContact: (otherShape) =>
    if otherShape.sensor and otherShape.owner? and otherShape.owner.interactive
      @interactions.delete(otherShape.owner)
      if otherShape.owner.personLeave?
        otherShape.owner.personLeave(this)

  enterChair: (chair) =>
    @chair = chair

  leaveChair: () =>
    @chair = null

  tick: () =>
    # Update Room
    if @room?
      @room.people.delete(this)
    part = @getPart()
    @room = if part? then part.room else null
    if @room?
      @room.people.add(this)

    # Apply Friction
    if not @chair
      pressure = @getPressure()
      if pressure > 0.4
        shipVelocity = @ship.velocityAtWorldPoint(@position)

        fx = shipVelocity[0] - @body.velocity[0]
        fy = shipVelocity[1] - @body.velocity[1]

        friction = WALK_FRICTION
        fx *= friction
        fy *= friction

        magnitude = Math.sqrt(fx * fx + fy * fy)
        if magnitude > MAXIMUM_FRICTION
          fx *= MAXIMUM_FRICTION / magnitude
          fy *= MAXIMUM_FRICTION / magnitude

        fx /= @body.mass
        fy /= @body.mass

        @body.force[0] += fx
        @body.force[1] += fy

        # Equal and opposite force on the ship
        @ship.body.applyForce([-fx, -fy], @position)

  afterTick: () =>
    if @chair
      @body.position = @chair.getWorldPosition()
      @body.velocity = @chair.getVelocity()

module.exports = Person
