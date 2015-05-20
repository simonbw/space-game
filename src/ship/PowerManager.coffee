Generator = require 'ship/parts/Generator'


class PowerManager
  constructor: (@ship) ->
    @generators = []
    @energyUsers = []
    @energy = 0
    @capacity = 0


  tick: () =>
    for generator in @generators
      @energy += 1

  afterTick: () =>
    @energy = Math.min(@energy, @capacity)

  partAdded: (part) =>
    if part instanceof Generator
      @generators.push(part)

    if part.energyCapacity?
      @capacity += part.energyCapacity

  partRemoved: (part) =>
    if part instanceof Generator
      @generators.splice(@generators.indexOf(part), 1)
    
    if part.energyCapacity?
      @capacity += -part.energyCapacity


module.exports = PowerManager