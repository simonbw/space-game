CollisionGroups = require 'CollisionGroups'
Entity = require 'core/Entity'
p2 = require 'p2'
Part = require 'ship/parts/Part'
Pixi = require 'pixi.js'
Util = require 'util/Util'

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
    @interactions = []
    @board(ship)
    @room = null
    @chair = null

  @property 'position',
    get: ->
      return @body.position

  @property 'angle',
    get: ->
      return @body.angle
    set: (val) ->
      @body.angle = val

  @property 'x',
    get: ->
      return @position[0]
    set: (value) ->
      @position[0] = value

  @property 'y',
    get: ->
      return @position[1]
    set: (value) ->
      @position[0] = value

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

    sprite.lineStyle(0.05, 0xFFFFFF)
    sprite.moveTo(-0.5, -0.5)
    sprite.lineTo(RADIUS - 0.5, -0.5)
    return sprite

  # Interact with the first part in the list
  interact: () =>
    if @interactions.length > 0
      @interactions[0].interact(this)

  # Move the thing at the top of the interact list to the bottom
  nextInteraction: () =>
    if @interactions.length > 1
      @interactions.push(@interactions.shift())

  # Move the thing at bottom top of the interact list to the top
  previousInteraction: () =>
    if @interactions.length > 1
      @interactions.unshift(@interactions.pop())

  board: (ship) =>
    @ship = ship

  move: ([x, y]) =>
    if not @chair?
      pressure = @getPressure()
      speed = if (pressure > 0.4) then WALK_FORCE else JETPACK_FORCE
      [fx, fy] = [x * speed, y * speed]
      @body.force[0] += fx
      @body.force[1] += fy
      if pressure
        @ship.body.applyForce([-fx, -fy], @position)

  rotateTowards: (direction) =>
    k = 4.0 # spring constant
    m = @body.inertia
    d = 0.55 # damping coefficient
    c = 2 * Math.sqrt(m * k) * d
    v = @body.angularVelocity
    x = Util.angleDelta(@angle, direction)

    @body.angularForce += k * x - c * v

#    @angle += Util.clamp(diff, -0.1, 0.1)

  render: () =>
    [@sprite.x, @sprite.y] = @body.position
    @sprite.rotation = @body.angle

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
      @interactions.push(otherShape.owner)
      if otherShape.owner.personEnter?
        otherShape.owner.personEnter(this)

  endContact: (otherShape) =>
    if otherShape.sensor and otherShape.owner? and otherShape.owner.interactive
      @interactions.splice(@interactions.indexOf(otherShape.owner), 1)
      if otherShape.owner.personExit?
        otherShape.owner.personExit(this)

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
      @body.angle = @chair.ship.body.angle - Math.PI / 2

module.exports = Person
