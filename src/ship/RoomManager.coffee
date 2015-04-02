Entity = require 'Entity'
Util = require 'util/Util'

roomCount = 0

class Room
  constructor: (@manager) ->
    @roomId = roomCount++
    @parts = new Set()
    @totalAir = 0
    @airCapacity = 0
    @dirty = true
    @_holes = new Set()
    @doors = []

  tick: () =>
    @giveAir(0.01)
    if not @sealed
      @giveAir(@holes.size * -0.01)

  addPart: (part) =>
    if not part?
      throw new Error("Bad Part: #{part}")
    @parts.add(part)
    part.room = this
    @dirty = true
    @airCapacity += 1

  # TODO: Possibly splits room
  removePart: (part) =>
    @parts.delete(part)
    if part.room == this
      part.room = null
    @dirty = true
    @airCapacity -= 1

  hasPart: (part) =>
    return @parts.has(part)

  @property 'pressure',
    get: ->
      return (@totalAir / @airCapacity) || 0

  # True if the room is air tight
  @property 'sealed',
    get: ->
      return @holes.size == 0
  
  # The set of grid positions where holes are
  @property 'holes',
    get: ->
      if @dirty
        @_holes = @findHoles()
      return @_holes

  # join this room with another, keeping this room, destroying the other
  join: (other) =>
    if other == this
      throw new Error("Joining room #{@roomId} with itself")
    iter = other.parts.values()
    next = iter.next()
    while not next.done
      part = next.value
      @addPart(part)
      next = iter.next()
    @giveAir(other.totalAir)

  findHoles: () =>
    holes = new Set()
    iter = @parts.values()
    next = iter.next()
    while not next.done
      part = next.value
      for pos in part.getAdjacentPoints()
        adjacentPart = @manager.ship.partAtGrid(pos)
        if not adjacentPart?
          holes.add(pos)
      next = iter.next()
    return holes

  giveAir: (amount) =>
    @totalAir += amount
    @totalAir = Util.clamp(@totalAir, 0, @airCapacity)

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
    if part.interior
      @parts.push(part)
      @partSet.add(part)

      adjacentRooms = @getAdjacentRooms(part)

      if adjacentRooms.length == 0
        console.log "part makes new room"
        room = new Room(this)
        room.addPart(part)
        @rooms.push(room)
      else if adjacentRooms.length == 1
        console.log "part added to room #{adjacentRooms[0].roomId}"
        adjacentRooms[0].addPart(part)
      else
        ids = adjacentRooms.map (r) ->
          return r.roomId
        console.log "part joins rooms #{ids}"
        room = adjacentRooms.pop()
        room.addPart(part)
        for otherRoom in adjacentRooms
          room.join(otherRoom)
          @rooms.splice(@rooms.indexOf(otherRoom), 1)

    for room in @getAdjacentRooms(part)
      room.dirty = true

  # Called when any part is added
  partRemoved: (part) =>
    if @partSet.has(part)
      @parts.splice(@parts.indexOf(part), 1)

      @calculateRooms() # TODO: Don't be dumb
    
    for room in @getAdjacentRooms(part)
      room.dirty = true

  tick: () =>
    for room in @rooms
      room.tick()

  # Return all the rooms adjacent to a part
  getAdjacentRooms: (part) =>
    adjacentRooms = new Set()
    for p in part.getAdjacentParts(@ship)
      if @partSet.has(p)
        for room in @rooms
          if room.hasPart(p)
            adjacentRooms.add(room)
    return Util.setToArray(adjacentRooms)

  # Calculate which rooms exist
  calculateRooms: () =>
    console.log "Calculating Rooms"
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


module.exports = RoomManager
