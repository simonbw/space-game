Util = require 'util/Util'

# Controls the thrusters
class ThrustBalancer
  constructor: (@ship) ->
    @thrusters = []
    @thrusterData = new Map() # stores calculated info about thrusters
    @throttlePresets = new ThrottlePresets()
    @dirty = true

  partAdded: (part) ->
    if part.thruster
      @addThruster(part)
    @dirty = true

  partRemoved: (part) ->
    if part.thruster
      @removeThruster(part)
    @dirty = true

  # Add an engine to be controlled by this thrust balancer
  addThruster: (thruster) =>
    @thrusters.push(thruster)
    @thrusterData.set(thruster, {})

  # Relinquish throttle control of an engine
  removeThruster: (thruster) =>
    @thrusters.splice(@thrusters.indexOf(thruster), 1)
    @thrusterData.delete(thruster)

  # Calculate thrust data for all thrusters
  calculateThrusterData: () =>
    @dirty = false

    @maxXForce = 0
    @minXForce = 0
    @maxYForce = 0
    @minYForce = 0
    @maxTorque = 0
    @minTorque = 0

    if @thrusters.length == 0
      return

    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      center = thruster.getLocalPosition()
      if thruster.direction == 0 # forward
        data.xForce = 0
        data.yForce = -thruster.maxThrust
        data.torque = -thruster.maxThrust * center[0]
      else if thruster.direction == 1 # right
        data.xForce = thruster.maxThrust
        data.yForce = 0
        data.torque = -thruster.maxThrust * center[1]
      else if thruster.direction == 2 # backward
        data.xForce = 0
        data.yForce = thruster.maxThrust
        data.torque = thruster.maxThrust * center[0]
      else if thruster.direction == 3 # left
        data.xForce = -thruster.maxThrust
        data.yForce = 0
        data.torque = thruster.maxThrust * center[1]

      @maxXForce += Math.max(0, data.xForce)
      @minXForce += Math.min(0, data.xForce)
      @maxYForce += Math.max(0, data.yForce)
      @minYForce += Math.min(0, data.yForce)
      @maxTorque += Math.max(0, data.torque)
      @minTorque += Math.min(0, data.torque)

    none = (0 for _ in @thrusters)
    for xControl in [-1, 0, 1]
      for yControl in [-1, 0, 1]
        for torque in [-1, 0, 1]
#          console.log xControl, yControl, torque
          if xControl == yControl == torque == 0
            @throttlePresets.setThrottles(xControl, yControl, torque, none)
            continue

          lp = new ThrustLP(@thrusters, @thrusterData)

          if xControl == 0
            lp.lockX()
          if yControl == 0
            lp.lockY()
          if torque == 0
            lp.lockTorque()

          lp.maximize(xControl, yControl, torque)
          if not lp.solve()
            console.log "error on", xControl, yControl, torque

          @throttlePresets.setThrottles(xControl, yControl, torque, lp.x || none)

  setThrottles: (throttles, scale = 1) =>
    for thruster, i in @thrusters
      thruster.throttle = throttles[i] * scale

  mixThrottles: (a, b, mix = 0.5, scale = 1) =>
    for thruster, i in @thrusters
      thruster.throttle = (a[i] * mix + b[i] * (1 - mix)) * scale

  # Set the throttles of the engines
  balance: (yControl=0, xControl=0, turn=0) =>
    if @dirty
      @calculateThrusterData()

    scale = Math.max(Math.abs(xControl), Math.abs(yControl), Math.abs(turn));
    @setThrottles(@throttlePresets.getThrottles(xControl, yControl, turn), scale)

    # TODO: Average corners of box

  # Backup method for thruster balancing
  oldBalance: (yControl, xControl, turn) =>
      for thruster in @thrusters
        throttle = 0
        x = thruster.x - @ship.offset[0]
        y = thruster.y - @ship.offset[1]

        switch thruster.direction
          when 0 # forward
            if yControl > 0
              throttle += yControl
            if turn > 0 and x < 0
              throttle += turn
            if turn < 0 and x > 0
              throttle += -turn
          when 1 # right?
            if xControl > 0
              throttle += xControl
            if turn > 0 and y < 0
              throttle += turn
            if turn < 0 and y > 0
              throttle += -turn
          when 2 # backward
            if yControl < 0
              throttle += -yControl
            if turn > 0 and x > 0
              throttle += turn
            if turn < 0 and x < 0
              throttle += -turn
          when 3 # left?
            if xControl < 0
              throttle += -xControl
            if turn > 0 and y < 0
              throttle += turn
            if turn < 0 and y > 0
              throttle += -turn
        throttle = Util.clamp(throttle)
        thruster.setThrottle(throttle)


# Stores throttle presets
class ThrottlePresets
  constructor: () ->
    @data = {}

  makeKey: (x, y, t) =>
    return "#{[Math.sign(x), Math.sign(y), Math.sign(t)]}"

  getThrottles: (x, y, t) =>
    return @data[@makeKey(x, y, t)]

  setThrottles: (x, y, t, throttles) =>
    @data[@makeKey(x, y, t)] = throttles


# A linear program for solving thrust balancing
class ThrustLP
  constructor: (@thrusters, @thrusterData) ->
    @reset()

  reset: =>
    @a = [] # inequalities LHS
    @b = [] # inequalities RHS
    @ae = [] # equalities LHS
    @be = [] # equalities RHS
    @c = [] # coefficients in minimization
    @x = null
    @limitThrottles()

  maximize: (xControl = 0, yControl = 0, torque = 0) =>
    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      x = data.xForce * -Math.sign(xControl)
      y = data.yForce * -Math.sign(yControl)
      t = data.torque * -Math.sign(torque)
      @c.push((x + y + t) || 0.001)

  # Make sure throttles stay between min and max
  limitThrottles: (min = 0, max = 1) =>
    n = @thrusters.length
    for i in [0...n]
      aMax = (0 for [0...n])
      aMin = (0 for [0...n])
      aMax[i] = 1.0
      aMin[i] = -1.0
      @a.push(aMin, aMax)
      @b.push(min, max)

  # Guarantee minimum torque
  minTorque: (sign=1.0) =>
    torques = []
    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      torques.push(data.torque * Math.sign(sign))
    if torques.some((x) -> return x != 0)
      @a.push(torques)
      @b.push(0)

  # Guarantee minimum x force
  minXForce: (sign=1.0) =>
    forces = []
    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      forces.push(data.xForce * Math.sign(-sign))
    if forces.some((x) -> return x != 0)
      @a.push(forces)
      @b.push(0)

  # Guarantee minimum y force
  minYForce: (sign=1.0) =>
    forces = []
    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      forces.push(data.yForce * Math.sign(-sign))
    if forces.some((x) -> return x != 0)
      @a.push(forces)
      @b.push(0)

  # Guarantee no torque
  lockTorque: =>
    torques = []
    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      torques.push(data.torque)
    if torques.some((x) -> return x != 0)
      @ae.push(torques)
      @be.push(0)

  # Guarantee no x force
  lockX: =>
    forces = []
    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      forces.push(data.xForce)
    if forces.some((x) -> return x != 0)
      @ae.push(forces)
      @be.push(0)

  # Guarantee no y force
  lockY: =>
    forces = []
    for thruster in @thrusters
      data = @thrusterData.get(thruster)
      forces.push(data.yForce)
    if forces.some((x) -> return x != 0)
      @ae.push(forces)
      @be.push(0)

  solve: () =>
    try
      @result = numeric.solveLP(@c, @a, @b, @ae, @be)
    catch e
#      console.log this.toString()
      @x = null
      return @x
    @x = @result.solution
    return @x

  # Pretty print the equations
  toString: ->
    s = ""

    s += "size: #{@c.length}\n"

    cx = []
    for ci, i in @c
      cx.push("#{ci.toFixed(2)}x_#{i}")
    s += "minimize: " + cx.join(' + ') + '\n'

    # inequalities
    inequalities = []
    for ai, i in @a
      aix = []
      for aij, j in ai
        if aij == 0
          continue
        else if aij == 1
          aix.push("x_#{j}")
        else if aij == -1
          aix.push("-x_#{j}")
        else
          aix.push("#{aij.toFixed(2)}x_#{j}")
      inequalities.push(aix.join(' + ') + ' <= ' + @b[i])
    s += inequalities.join(' ; ') + '\n'

    # equalities
    equalities = []
    for ei, i in @ae
      eix = []
      for eij, j in ei
        if eij == 0
          eix.push("0")
        else if eij == 1
          eix.push("x_#{j}")
        else if eij == -1
          eix.push("-x_#{j}")
        else
          eix.push("#{eij.toFixed(2)}x_#{j}")
      equalities.push(eix.join(' + ') + ' = ' + @be[i])
    s += equalities.join('\n') + '\n'

    solution = []
    if @x
      for xi, i in @x
        solution.push("x_#{i} = #{xi.toFixed(2)}")
      s += solution.join(' ; ') + '\n'

    return s

module.exports = ThrustBalancer
