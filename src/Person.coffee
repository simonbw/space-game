CollisionGroups = require 'CollisionGroups'
Entity = require 'Entity'
p2 = require 'p2'
Pixi = require 'pixi.js'

# A person
class Person extends Entity
  RADIUS = 0.1
  WALK_FORCE = 5
  JETPACK_FORCE = 0.3
  MAXIMUM_FRICTION = 10

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
    speed = if @ship? then WALK_FORCE else JETPACK_FORCE
    @body.force[0] += x * speed
    @body.force[1] += y * speed

  render: () =>
    [@sprite.x, @sprite.y] = @body.position

  tick: () =>
    if @ship?
      shipVelocity = @ship.velocityAtWorldPoint(@position)

      dx = shipVelocity[0] - @body.velocity[0]
      dy = shipVelocity[1] - @body.velocity[1]

      dx *= 0.5
      dy *= 0.5

      magnitude = Math.sqrt(dx * dx + dy * dy)
      if magnitude > MAXIMUM_FRICTION
        dx *= MAXIMUM_FRICTION / magnitude
        dy *= MAXIMUM_FRICTION / magnitude

      @body.force[0] += dx / @body.mass
      @body.force[1] += dy / @body.mass

module.exports = Person
