Blueprint = require 'ship/Blueprint'
Entity = require 'Entity'
Grid = require 'util/Grid'
Hull = require 'ship/parts/Hull'
p2 = require 'p2'
Pixi = require 'pixi.js'
RoomManager = require 'ship/RoomManager'
ThrustBalancer = require 'ship/ThrustBalancer'
Thruster = require 'ship/parts/Thruster'
Util = require 'util/Util'

# A space ship
class Ship extends Entity
  BASE_MASS = 0.1

  constructor: (@blueprint, x = 0, y = 0) ->
    @blueprint ?= new Blueprint()
    @sprite = new Pixi.Graphics()
    @layer = 'world'
    @parts = []
    @partGrid = new Grid()
    # TODO: Part connections
    @tickableParts = []
    @thrustBalancer = new ThrustBalancer(this)
    @roomManager = new RoomManager(this)

    # local vector from center of mass to center of grid
    @offset = [0, 0]

    @body = new p2.Body({
      position: [x, y]
      mass: BASE_MASS
      angularDamping: 0.01
      damping: 0.0
    })

    for part in @blueprint.parts
      @addPart(part.clone())

  @property 'position',
    get: ->
      return @body.position
  
  render: () =>
    @sprite.clear()
    @sprite.beginFill(0x00FFFF)
    @sprite.drawCircle(-@offset[0], -@offset[1], 0.1)
    @sprite.endFill()

    [@sprite.x, @sprite.y] = @gridToWorld([0, 0])
    @sprite.rotation = @body.angle

  tick: () =>
    for part in @tickableParts
      part.tick(this)

  # Add a Part to this ship
  addPart: (part) =>
    @parts.push(part)
    @partGrid.set([part.x, part.y], part)
    if part.tick?
      @tickableParts.push(part)
    
    angle = if part.direction? then Math.PI / 2 * part.direction else 0
    
    if part.sprite?
      @sprite.addChild(part.sprite)
      @sprite.rotation = angle
    
    if part.shape?
      shapePosition = [part.x + @offset[0], part.y + @offset[1]]
      @body.addShape(part.shape, shapePosition, angle)
      @body.mass += part.mass
      @recenter()

    @roomManager.partAdded(part)

    if part.type.thruster
      @thrustBalancer.addThruster(part)

  removePart: (part) =>
    @parts.splice(@parts.indexOf(part), 1)
    @partGrid.remove([part.x, part.y])
    @roomManager.partRemoved(part)
    if part.tick?
      @tickableParts.splice(@tickableParts.indexOf(part), 1)
    if part.sprite?
      @sprite.removeChild(part.sprite)
    if part.shape?
      @body.removeShape(part.shape)
    if part.type.thruster
      @thrustBalancer.removeThruster(part)
    @body.mass -= part.mass
    @recenter()

  # Recalculate the center of mass
  recenter: =>
    before = [@body.position[0], @body.position[1]]
    @body.adjustCenterOfMass()
    dx = @body.position[0] - before[0]
    dy = @body.position[1] - before[1]
    beforeLocal = @worldToLocal(before)
    @offset[0] += beforeLocal[0]
    @offset[1] += beforeLocal[1]

  # Convert grid coordinates to local physics coordinates
  gridToLocal: (point) =>
    return [point[0] + @offset[0], point[1] + @offset[1]]

  # Convert local physics coordinates to grid coordinates
  localToGrid: (point) =>
    return [point[0] - @offset[0], point[1] - @offset[1]]

  # Convert local physics coordinates to world coordinates
  localToWorld: (point) =>
    world = [0, 0]
    @body.toWorldFrame(world, point)
    return world

  # Convert world coordinates to local physics coordinates
  worldToLocal: (point) =>
    local = [0, 0]
    @body.toLocalFrame(local, point)
    return local

  # Convert ship grid coordinates to world coordinates
  gridToWorld: (point) =>
    return @localToWorld(@gridToLocal(point))

  # Convert world coordinates to ship grid coordinates
  worldToGrid: (point) =>
    return @localToGrid(@worldToLocal(point))

  # Return the part at a grid point or undefined
  partAtGrid: ([x, y]) =>
    x = Math.round(x)
    y = Math.round(y)
    return @partGrid.get([x, y])

  # Return the part at a local point or undefined
  partAtLocal: (point) =>
    return @partAtGrid(@localToGrid(point))
    
  # Return the part at a world point or undefined
  partAtWorld: (point) =>
    return @partAtGrid(@worldToGrid(point))

  # Return the velocity of the ship at a world point
  velocityAtWorldPoint: (point) =>
    # base linear velocity
    [xl, yl] = @body.velocity

    # relative position
    x = point[0] - @body.position[0]
    y = point[1] - @body.position[1]

    # relative angle
    theta = Math.atan2(y, x) + Math.PI / 2

    # tangential velocity
    r = Math.sqrt(x * x + y * y)
    tangentialSpeed = @body.angularVelocity * r
    xt = Math.cos(theta) * tangentialSpeed
    yt = Math.sin(theta) * tangentialSpeed

    return [xl + xt, yl + yt]

module.exports = Ship