Door = require 'ship/parts/Door'
Entity = require 'Entity'
Util = require 'util/Util'

roomCount = 0

# Represents on contiguous set of interior pieces
# Controls air
class Room
  FLOW_CONSTANT = 0.1

  constructor: (@manager) ->
    @roomId = roomCount++
    @parts = new Set()
    @totalAir = 0
    @airCapacity = 0
    @dirty = true
    @_holes = new Set()
    @_doors = new Set()

  # Update calculations for air and stuff
  tick: () =>
    @giveAir(0.01)
    
    @holes.forEach (hole) =>
      @giveAir(-FLOW_CONSTANT)

    @doors.forEach (door) =>
      if door.isOpen
        adjacentRooms = door.getAdjacentRooms(@manager.ship)
        adjacentRooms.forEach (otherRoom) =>
          if otherRoom?
            pressureDifference = @pressure - otherRoom.pressure
            if pressureDifference > 0
              flowRate = -pressureDifference * FLOW_CONSTANT
              change = @giveAir(flowRate)
              otherRoom.giveAir(-change)
          else
            @giveAir(-FLOW_CONSTANT)

  # Include a part in this room
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

  # True if the part is part of this room
  hasPart: (part) =>
    return @parts.has(part)

  @property 'pressure',
    get: ->
      return (@totalAir / @airCapacity) || 0

  # True if the room is air tight
  @property 'sealed',
    get: ->
      return @holes.size == 0

  # All the doors that are connected to this room
  @property 'doors',
    get: ->
      if @dirty
        @findHoles()
      return @_doors
  
  # The set of grid positions where holes are
  @property 'holes',
    get: ->
      if @dirty
        @findHoles()
      return @_holes

  # Recalculate the positions of all the holes
  findHoles: () =>
    @_holes.clear()
    # TODO: Figure out cleaner set iteration
    iter = @parts.values()
    next = iter.next()
    while not next.done
      part = next.value
      for pos in part.getAdjacentPoints()
        adjacentPart = @manager.ship.partAtGrid(pos)
        if not adjacentPart?
          @_holes.add(pos)
        else if adjacentPart instanceof Door
          @_doors.add(adjacentPart)
      next = iter.next()

  # Add an amount of air into the room (can be negative)
  # Returns the amount of air actually added
  giveAir: (amount) =>
    old = @totalAir
    @totalAir += amount
    @totalAir = Util.clamp(@totalAir, 0, @airCapacity)
    return @totalAir - old

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

  # 
  destroy: () =>
    iter = @parts.values()
    next = iter.next()
    while not next.done
      part = next.value
      part.room = null
      next = iter.next()
    @parts.clear()

  # 
  toString: () =>
    return "<Room size: #{@parts.size} #{@sealed}>"


# Keeps track of rooms on a ship
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
        room = new Room(this)
        room.addPart(part)
        @rooms.push(room)
      else if adjacentRooms.length == 1
        adjacentRooms[0].addPart(part)
      else
        ids = adjacentRooms.map (r) ->
          return r.roomId
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
