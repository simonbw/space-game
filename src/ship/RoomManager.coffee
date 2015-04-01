Entity = require 'Entity'

class Room
  constructor: (@manager) ->
    @parts = new Set()
    @pressure = 0.0
    @dirtySeal = true
    @_seaeled = false

  addPart: (part) =>
    if not part?
      throw new Error("Bad Part: #{part}")
    @parts.add(part)
    part.room = this
    @dirtySeal = true

  # TODO: Possibly splits room
  removePart: (part) =>
    @parts.delete(part)
    part.room = null
    @dirtySeal = true

  hasPart: (part) =>
    return @parts.has(part)

  # True if the room is air tight
  @property 'sealed',
    get: ->
      if @dirtySeal
        @_sealed = @calulateSealed()
      return @_sealed
  
  # join this room with another, keeping this room
  join: (other) =>
    self = this
    # TODO: calculate oxygen and stuff
    @dirtySeal = true
    other.parts.forEach (part) ->
      self.addPart(part)

  # Figure out if the room is sealed
  calulateSealed: () =>
    iter = @parts.values()
    next = iter.next()
    while not next.done
      part = next.value
      for pos in part.getAdjacentPoints()
        adjacentPart = @manager.ship.partAtGrid(pos)
        if not adjacentPart?
          return false
      next = iter.next()
    return true

  destroy: () =>
    iter = @parts.values()
    next = iter.next()
    while not next.done
      part = next.value
      part.room = null
      next = iter.next()
    @parts.clear()

  toString: () =>
    return "<Room size: #{@parts.size} #{@sealed}>"

class RoomManager extends Entity
  constructor: (@ship) ->
    @parts = []
    @partSet = new Set()
    @rooms = []
    @calculateRooms()

  # Called when any part is added
  partAdded: (part) =>
    if part.type.interior
      @parts.push(part)
      @partSet.add(part)

      adjacentRooms = @getAdjacentRooms(part)
      console.log "#{adjacentRooms}"

      if adjacentRooms.length == 0
        room = new Room(this)
        room.addPart(part)
        @rooms.push(room)
      else if adjacentRooms.length == 1
        adjacentRooms[0].addPart(part)
      else
        room = adjacentRooms.pop()
        for otherRoom in adjacentRooms
          room.join(otherRoom)
          @rooms.splice(@rooms.indexOf(otherRoom), 1)

    for room in @getAdjacentRooms(part)
      room.dirtySeal = true

  # Called when any part is added
  partRemoved: (part) =>
    if @partSet.has(part)
      @parts.splice(@parts.indexOf(part), 1)

      @calculateRooms() # TODO: Don't be dumb
    
    for room in @getAdjacentRooms(part)
      room.dirtySeal = true

  getAdjacentRooms: (part) =>
    adjacentRooms = []
    for p in part.getAdjacentParts(@ship)
      for room in @rooms
        if room.hasPart(p)
          adjacentRooms.push(room)
          continue
    return adjacentRooms

  # Calculate which rooms exist
  # TODO: Don't be dumb
  calculateRooms: () =>
    while @rooms.length
      @rooms.pop().destroy()

    remaining = new Set()
    for part in @parts
      remaining.add(part)

    while remaining.size > 0
      room = new Room(this)
      @rooms.push(room)
      queue = [remaining.values().next().value]
      while queue.length > 0
        currentPart = queue.pop()
        room.addPart(currentPart)
        remaining.delete(currentPart)
        for adjacentPart in currentPart.getAdjacentParts(@ship)
          if remaining.has(adjacentPart)
            queue.push(adjacentPart)
    console.log "calculateRooms: #{@rooms}"


module.exports = RoomManager
