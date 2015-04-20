

Util = {
  setToArray: (s) ->
    a = []
    iter = s.values()
    next = iter.next()
    while not next.done
      a.push(next.value)
      next = iter.next()
    return a

  mod: (a, b) ->
    return ((a % b) + b) % b

  clamp: (value, min=-1, max=1) ->
    return Math.max(min, Math.min(max, value))

  length: (x, y) ->
    return Math.sqrt(x * x + y * y)
}

module.exports = Util
