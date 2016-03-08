Core = require 'ship/parts/Core'
Entity = require 'core/Entity'
Grid = require 'util/Grid'
Pixi = require 'pixi.js'

# A blueprint for the layout of parts on a ship
class Blueprint extends Entity
  BASE_MASS = 0.1

  constructor: (x = 0, y = 0) ->
    @sprite = new Pixi.Graphics()
    @layer = 'world'
    @parts = []
    @partGrid = new Grid()
    @core = @addPart(new Core([0, 0]))

  # Add a Part to this blueprint
  addPart: (part) =>
    @parts.push(part)
    if part.sprite?
      @sprite.addChild(part.sprite)

    @partGrid.set([part.x, part.y], part)
    return part

  # Take a part off this blueprint
  removePart: (part) =>
    @parts.splice(@parts.indexOf(part), 1)
    if part.sprite?
      @sprite.removeChild(part.sprite)

    @partGrid.remove([part.x, part.y])

    return part

  isValid: () =>
    connected = new Set()

    queue = [@core]
    while queue.length
      current = queue.pop()
      connected.add(current)
      [x, y] = current.position
      for adjacentPoint in [[x + 1, y], [x, y + 1], [x - 1, y], [x, y - 1]]
        adjacentPart = @partGrid.get(adjacentPoint)
        if adjacentPart? and not connected.has(adjacentPart)
          queue.push(adjacentPart)
    for part in @parts
      if not connected.has(part)
        return false
    return true

module.exports = Blueprint