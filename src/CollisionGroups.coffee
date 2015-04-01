group = (groups...) ->
  mask = 0
  for i in groups
    mask |= Math.pow(2, i)
  console.log "mask: #{mask} for groups #{groups}"
  return mask

class CollisionGroups
  @SHIP_EXTERIOR = group 0
  @SHIP_INTERIOR = group 1
  @PERSON = group 2
  @ALL = group [0...16]...
  @OBSTACLES = @ALL ^ @SHIP_INTERIOR

module.exports = CollisionGroups