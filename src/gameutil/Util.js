/**
 * Real modulo operator.
 * Guaranteed to return between 0 and b.
 * @param a {number}
 * @param b {number}
 * @returns {number}
 */
export function mod(a, b) {
  return ((a % b) + b) % b;
}

/**
 * Return the value clamped between min and max.
 * @param value {number}
 * @param min {number}
 * @param max {number}
 * @returns {number}
 */
export function clamp(value, min = -1, max = 1) {
  return Math.max(min, Math.min(max, value));
}

/**
 * Return the difference between two angles, clamped to [-pi, pi]
 * @param a {number}
 * @param b {number}
 * @returns {number}
 */
export function angleDelta(a, b) {
  const diff = b - a;
  return mod(diff + Math.PI, Math.PI * 2) - Math.PI;
}

/**
 * Pretty output of a linear program
 * @param c
 * @param a
 * @param b
 * @param ae
 * @param be
 * @param x
 * @returns {*}
 */
export function prettyPrintLP(c, a, b, ae, be, x) {
  console.log("");

  const cx = [];
  for (var i = 0, _; i < c.length; i++) {
    _ = c[i];
    cx.push(`${c[i]}x_${i}`);
  }
  console.log("minimize: " + cx.join(' + '));

  // inequalities
  const inequalities = [];
  for (var i = 0, ai; i < a.length; i++) {
    ai = a[i];
    const aix = [];
    for (var j = 0, aij; j < ai.length; j++) {
      aij = ai[j];
      if (aij === 0) {
        continue;
      } else if (aij === 1) {
        aix.push(`x_${j}`);
      } else if (aij === -1) {
        aix.push(`-x_${j}`);
      } else {
        aix.push(`${aij.toFixed(2)}x_${j}`);
      }
    }
    inequalities.push(aix.join(' + ') + ' <= ' + b[i]);
  }
  console.log(inequalities.join(' ; '));

  // equalities
  const equalities = [];
  for (var i = 0, ei; i < ae.length; i++) {
    ei = ae[i];
    const eix = [];
    for (var j = 0, eij; j < ei.length; j++) {
      eij = ei[j];
      if (eij === 0) {
        eix.push("0");
      } else if (eij === 1) {
        eix.push(`x_${j}`);
      } else if (eij === -1) {
        eix.push(`-x_${j}`);
      } else {
        eix.push(`${eij.toFixed(2)}x_${j}`);
      }
    }
    equalities.push(eix.join(' + ') + ' = ' + be[i]);
  }
  console.log(equalities.join('\n'));

  const solution = [];
  for (var i = 0, xi; i < x.length; i++) {
    xi = x[i];
    solution.push(`x_${i} = ${xi.toFixed(2)}`);
  }
  console.log(solution.join(' ; '));

  return console.log("");
}
