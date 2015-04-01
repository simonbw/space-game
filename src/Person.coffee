CollisionGroups = require 'CollisionGroups'
Entity = require 'Entity'
p2 = require 'p2'
Pixi = require 'pixi.js'

# A person
class Person extends Entity
  RADIUS = 0.1
  WALK_FORCE = 5
  WALK_FRICTION = 0.4
  JETPACK_FORCE = 0.4
  MAXIMUM_FRICTION = 1.0

  constructor: (x=0, y=0, ship=null) ->
    @body = new p2.Body({
      position: [x, y]
      mass: 0.1
      angularDamping: 0.01
      damping: 0
    })
    shape = new p2.Circle(RADIUS)
    shape.collisionGroup = CollisionGroups.PERSON
    shape.collisionMask = CollisionGroups.OBSTACLES
    @body.addShape(shape)

    @sprite = new Pixi.Graphics()
    @sprite.beginFill(0x00FF00)
    @sprite.drawCircle(0, 0, RADIUS)
    @sprite.endFill()

    @board(ship)

  @property 'position',
    get: ->
      return @body.position

  board: (ship) =>
    @ship = ship
    if ship?
      @shipPosition = @ship.worldToLocal(@body.position)
    else
      @shipPosition = null

  move: ([x, y]) =>
    part = @getPart()
    floor = @getFloor()
    speed = if floor then WALK_FORCE else JETPACK_FORCE
    [fx, fy] = [x * speed, y * speed]
    @body.force[0] += fx
    @body.force[1] += fy
    if floor
      @ship.body.applyForce([-fx, -fy], @position)

  render: () =>
    [@sprite.x, @sprite.y] = @body.position

  getPart: () =>
    if not ship? then return undefined
    return @ship.partAtWorld(@position)

  getFloor: () =>
    part = @getPart()
    return part? and part.room? and part.room.sealed

  tick: () =>
    if @getFloor()
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

module.exports = Person
