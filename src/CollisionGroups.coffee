group = (groups...) ->
  mask = 0
  for i in groups
    mask |= Math.pow(2, i)
  console.log "mask: #{mask} for groups #{groups}"
  return mask

class CollisionGroups
  @ALL = group [0...16]...

  # GROUPS - classification of stuff
  @SHIP_EXTERIOR = group 0
  @SHIP_INTERIOR = group 1
  @SHIP_SENSOR = group 2
  @PERSON = group 3

  # MASKS - what stuff runs into
  @PERSON_MASK = @SHIP_EXTERIOR | @SHIP_SENSOR | @PERSON

module.exports = CollisionGroups