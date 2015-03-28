Entity = require 'Entity'
p2 = require 'p2'
Pixi = require 'pixi.js'
Hull = require 'ship/Hull'
Thruster = require 'ship/Thruster'

# A space ship
class Ship extends Entity
  BASE_MASS = 0.1

  constructor: (x = 0, y = 0) ->
    @sprite = new Pixi.Graphics()
    @layer = 'world'
    @parts = []
    # TODO: Parts Grid - part locations
    # TODO: Part connections
    @tickableParts = []
    @thrustBalancer = new ThrustBalancer()

    @offset = [0, 0] # offset of all the shapes
    @body = new p2.Body({
      position: [x, y]
      mass: BASE_MASS
      # angle: Math.PI
    })

    @addPart(new Hull(2, 1))
    @addPart(new Thruster(2, -1))
    @addPart(new Hull(2, 0))
    @addPart(new Hull(1, 0))
    @addPart(new Hull(0, 0))
    @addPart(new Hull(-1, 0))
    @addPart(new Hull(-2, 0))
    @addPart(new Hull(-2, 1))
    @addPart(new Thruster(-2, -1))

  render: () =>
    @sprite.x = @body.position[0] + @offset[0]
    @sprite.y = @body.position[1] + @offset[1]
    @sprite.rotation = @body.angle

  tick: () =>
    for part in @tickableParts
      part.tick(this)

  # Add a Part to this ship
  addPart: (part) =>
    @parts.push(part)
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
      @recenter() # TODO: don't redo the whole calculation

  removePart: (part) =>
    @parts.splice(@parts.indexOf(part), 1)
    if part.tick?
      @tickableParts.splice(@tickableParts.indexOf(part), 1)
    if part.sprite?
      @sprite.removeChild(part.sprite)
    if part.shape?
      @body.removeShape(part.shape)
    @body.mass -= part.mass
    @recenter() # TODO: don't redo the whole calculation

  # Recalculate the center of mass
  recenter: =>
    # do something to offset
    center = [0, 0] # the local center of mass
    
    totalMass = @body.mass - BASE_MASS
    for shape, i in @body.shapes
      mass = shape.owner.mass
      [x, y] = @body.shapeOffsets[i]
      center[0] += x * mass / totalMass
      center[1] += y * mass / totalMass

    for shape, j in @body.shapes
      # console.log center
      [a, b] = center
      @body.shapeOffsets[j][0] += -1 * a
      @body.shapeOffsets[j][1] += -1 * b

    [x1, y1] = center
    cosTheta = Math.cos(@body.angle)
    sinTheta = Math.sin(@body.angle)
    x2 = x1 * cosTheta - y * cosTheta
    y2 = x1 * sinTheta + y1 * cosTheta
    @body.position[0] += x2
    @body.position[1] += y2

    @offset[0] -= center[0]
    @offset[1] -= center[1]

    @body.updateMassProperties()
    @body.updateBoundingRadius()

  # Convert grid coordinates to local physics coordinates
  gridToLocal: (point) =>
    return [point[0] + @offset[0], point[1] + @offset[1]]

  # Convert local physics coordinates to world coordinates
  localToWorld: (point) =>
    world = [0, 0]
    @body.toWorldFrame(world, point)
    return world

  # Convert ship grid coordinates to world coordinates
  gridToWorld: (point) =>
    return @localToWorld(@gridToLocal(point))

# Controls the thrusters
class ThrustBalancer
  constructor: () ->
    @thrusters = []

  addThruster: (thruster) =>
    @thrusters.add(thruster)

  removeThruster: (thruster) =>
    @thrusters.splice(@thrusters.indexOf(thruster), 1)

  balance: (forward=0, strafe=0, angle=0) =>
    for thruster in @thrusters
      thruster.setThrust(0)



module.exports = Ship