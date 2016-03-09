r = Math.random

# Class for providing basic random functions.
Random = {
  # Return a uniformly distributed number between `min` and `max`.
  uniform: (min=0, max=1) ->
    if not min?
      return r()
    if not max?
      max = min
      min = 0
    return (max - min) * r() + min

  # Return a random integer x in the range `min <= x < max`.
  integer: (min=0, max=2) ->
    return Math.floor(Random.uniform(min, max))

  # Return an approximately normally distributed random number.
  # @param mean      [Number] Center of the distribution
  # @param deviation [Number] Standard deviation
  normal: (mean=0, deviation=1) ->
    return deviation * (r() + r() + r() + r() + r() + r() - 3) / 3 + mean

  # Choose a random element.
  # If multiple arguments are passed, will choose from them.
  # Otherwise, will choose from an array.
  choose: (options...) ->
    if options.length == 1
      options = options[0]
    return options[Random.integer(options.length)]

  # Shuffles an array in place (Fisher-Yates)
  shuffle: (a) ->
    i = a.length
    while --i > 0
      j = Random.integer(0, i + 1)
      temp = a[j]
      a[j] = a[i]
      a[i] = temp
    return a
}


module.exports = Random
