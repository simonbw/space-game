Generator = require 'ship/parts/Generator'

# There are 3 types of parts in the energy system
# storage - Store excess energy.
# producers - Create energy every turn.
# consumers - Use energy every turn.
#             Creates an energy deficit when using energy.
#             Has a maximum deficit which is generally the most amount of
#                 energy it could use in one turn.
#
# Every turn the PowerManager balances the energy.
#
#     First, the total amount of energy available is calculated by summing the
# energy produced by each generator and the energy currently in storage.
#     The total energy deficit is calculated by summing the energy deficits of
# all the consumers.
#     If the total deficit is less than or equal to the available energy, all
# consumers have their deficit filled and the total deficit is subtracted from
# the available energy.
#     If the total deficit is greater than the available energy, energy is
# distributed to each consumer proportional to its maximum deficit.
#     Any remaining available energy is put into storage.


# Balances energy production, consumption and storage.
class PowerManager
  constructor: (@ship) ->
    @generators = []
    @consumers = []
    @energyUsers = []
    @energy = 0
    @capacity = 0


  tick: () =>
    @energy += @generators.length * 5

  afterTick: () =>
# TODO: Cleanup energy distribution
    totalDeficit = 0
    for consumer in @consumers
      totalDeficit += consumer.energyDeficit

    if totalDeficit > @energy
      ratio = @energy / totalDeficit
    else
      ratio = 1

    for consumer in @consumers
      deficit = consumer.energyDeficit
      toGive = Math.min(deficit * ratio, @energy)
      consumer.energyDeficit -= toGive
      @energy -= toGive
    # give consumer energy
    @energy = Math.min(@energy, @capacity)

  partAdded: (part) =>
    if part instanceof Generator
      @generators.push(part)

    if part.maxEnergyDeficit
      @consumers.push(part)
      console.log("Added consumer")

    if part.energyCapacity?
      @capacity += part.energyCapacity

  partRemoved: (part) =>
    if part instanceof Generator
      @generators.splice(@generators.indexOf(part), 1)

    if part.maxEnergyDeficit
      @consumers.splice(@consumers.indexOf(part), 1)

    if part.energyCapacity?
      @capacity += -part.energyCapacity


module.exports = PowerManager