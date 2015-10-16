

Util = {
# Real modulo operator
  mod: (a, b) ->
    return ((a % b) + b) % b

# Return the value clamped between min and max.
  clamp: (value, min=-1, max=1) ->
    return Math.max(min, Math.min(max, value))

# Return the length of a vector
  length: ([x, y]) ->
    return Math.sqrt(x * x + y * y)

# Return the difference between two angles, clamped to [-pi, pi]
  angleDelta: (a, b) ->
    diff = b - a
    return Util.mod(diff + Math.PI, Math.PI * 2) - Math.PI
}

module.exports = Util
