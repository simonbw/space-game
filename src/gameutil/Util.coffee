

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

  # Pretty output of a linear program
  prettyPrintLP: (c, a, b, ae, be, x) ->
    console.log("")

    cx = []
    for _, i in c
      cx.push("#{c[i]}x_#{i}")
    console.log "minimize: " + cx.join(' + ')

    # inequalities
    inequalities = []
    for ai, i in a
      aix = []
      for aij, j in ai
        if aij == 0
          continue
        else if aij == 1
          aix.push("x_#{j}")
        else if aij == -1
          aix.push("-x_#{j}")
        else
          aix.push("#{aij.toFixed(2)}x_#{j}")
      inequalities.push(aix.join(' + ') + ' <= ' + b[i])
    console.log inequalities.join(' ; ')

    # equalities
    equalities = []
    for ei, i in ae
      eix = []
      for eij, j in ei
        if eij == 0
          eix.push("0")
        else if eij == 1
          eix.push("x_#{j}")
        else if eij == -1
          eix.push("-x_#{j}")
        else
          eix.push("#{eij.toFixed(2)}x_#{j}")
      equalities.push(eix.join(' + ') + ' = ' + be[i])
    console.log equalities.join('\n')

    solution = []
    for xi, i in x
      solution.push("x_#{i} = #{xi.toFixed(2)}")
    console.log solution.join(' ; ')

    console.log("")
}

module.exports = Util
