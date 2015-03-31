

Util = {
  mod: (a, b) ->
    return ((a % b) + b) % b

  clamp: (value, min=-1, max=1) ->
    return Math.max(min, Math.min(max, value))
}

module.exports = Util