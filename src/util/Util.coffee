

Util = {
  setToArray: (s) ->
    return Array.from(s)

  mod: (a, b) ->
    return ((a % b) + b) % b

  clamp: (value, min=-1, max=1) ->
    return Math.max(min, Math.min(max, value))

  length: ([x, y]) ->
    return Math.sqrt(x * x + y * y)
}

module.exports = Util
