Util = require 'util/Util'

# Controls the thrusters
class ThrustBalancer
  constructor: (@ship) ->
    @thrusters = []

  # Add an engine to be controlled by this thrust balancer
  addThruster: (thruster) =>
    console.log "thruster added"
    @thrusters.push(thruster)

  # Relinquish throttle control of an engine
  removeThruster: (thruster) =>
    @thrusters.splice(@thrusters.indexOf(thruster), 1)

  # Set the throttles of the engines
  balance: (forward=0, side=0, turn=0) =>
    # TODO: Actually make sure there is no weird unbalanced spinning
    for thruster in @thrusters
      throttle = 0
      x = thruster.x - @ship.offset[0]
      y = thruster.y - @ship.offset[1]

      switch thruster.direction
        when 0 # forward
          if forward > 0
            throttle += forward
          if turn > 0 and x < 0
            throttle += turn
          if turn < 0 and x > 0
            throttle += -turn
        when 1 # right?
          if side > 0
            throttle += side
          if turn > 0 and y < 0
            throttle += turn
          if turn < 0 and y > 0
            throttle += -turn
        when 2 # backward
          if forward < 0
            throttle += -forward
          if turn > 0 and x > 0
            throttle += turn
          if turn < 0 and x < 0
            throttle += -turn
        when 3 # left?
          if side < 0
            throttle += -side
          if turn > 0 and y < 0
            throttle += turn
          if turn < 0 and y > 0
            throttle += -turn
      throttle = Util.clamp(throttle)
      thruster.setThrottle(throttle)

module.exports = ThrustBalancer
