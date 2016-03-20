/*
 * Basic random functions.
 * Kinda based on python's random module.
 */


/**
 * Return a uniformly distributed number between `min` and `max`.
 * @param min {number}
 * @param max {number}
 * @returns {number}
 */
export function uniform(min = 0, max = 1) {
  if (min == null) {
    return Math.random();
  }
  if (max == null) {
    max = min;
    min = 0;
  }
  return (max - min) * Math.random() + min;
}


/**
 * Return a random integer x in the range `min <= x < max`.
 * @param min
 * @param max
 * @returns {number}
 */
export function integer(min = 0, max = 2) {
  return Math.floor(uniform(min, max));
}


/**
 * Return an approximately normally distributed random number.
 * @param mean {number} Center of the distribution
 * @param deviation {number} Standard deviation
 * @returns {number}
 */
export function normal(mean = 0, deviation = 1) {
  return deviation * (Math.random() + Math.random() + Math.random() + Math.random() + Math.random() + Math.random() - 3) / 3 + mean;
}

/**
 * Choose a random element.
 * If multiple arguments are passed, will choose from them.
 * Otherwise, will choose from an array.
 * @param options
 * @returns {*}
 */
export function choose(...options) {
  if (options.length === 1) {
    options = options[0];
  }
  return options[integer(options.length)];
}


/**
 * Shuffles an array in place (Fisher-Yates).
 * @param a
 * @returns {*} - a
 */
export function shuffle(a) {
  var i = a.length;
  while (--i > 0) {
    const j = integer(0, i + 1);
    const temp = a[j];
    a[j] = a[i];
    a[i] = temp;
  }
  return a;
}

