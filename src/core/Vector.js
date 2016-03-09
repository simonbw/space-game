/**
 * Add some hacky prototype methods onto arrays to use them as vectors.
 */
export default function (Array) {
  /**
   * Return the result of adding two vectors together.
   */
  Array.prototype.add = function (other) {
    return [this[0] + other[0], this[1] + other[1]];
  };

  /**
   * In place addition.
   * @param other
   * @returns {Array}
   */
  Array.prototype.iadd = function (other) {
    this[0] += other[0];
    this[1] += other[1];
    return this;
  };

  /**
   * Return the result of subtracting a vector from this one.
   * @param other
   * @returns {*[]}
   */
  Array.prototype.sub = function (other) {
    return [this[0] - other[0], this[1] - other[1]];
  };

  /**
   * In place subtraction.
   * @param other
   * @returns {Array}
   */
  Array.prototype.isub = function (other) {
    this[0] -= other[0];
    this[1] -= other[1];
    return this;
  };

  /**
   * Return a the result of multiplying this vector and a scalar.
   * @param scalar
   * @returns {*[]}
   */
  Array.prototype.mul = function (scalar) {
    return [this[0] * scalar, this[1] * scalar];
  };

  /**
   * In place scalar multiplication.
   * @param scalar
   * @returns {Array}
   */
  Array.prototype.imul = function (scalar) {
    this[0] *= scalar;
    this[1] *= scalar;
    return this;
  };

  /**
   * Return a normalized version of this vector.
   * @returns {*}
   */
  Array.prototype.normalize = function () {
    var ref;
    if (this[0] === (ref = this[1]) && ref === 0) {
      return [0, 0];
    }
    const magnitude = this.magnitude();
    return [this[0] / magnitude, this[1] / magnitude];
  };

  /**
   * Normalize this vector in place.
   * @returns {Array}
   */
  Array.prototype.inormalize = function () {
    var ref;
    if (this[0] === (ref = this[1]) && ref === 0) {
      return this;
    }
    const magnitude = this.magnitude();
    this[0] /= magnitude;
    this[1] /= magnitude;
    return this;
  };

  /**
   * Return this vector rotated 90 degrees clockwise.
   * @returns {*[]}
   */
  Array.prototype.rotate90cw = function () {
    return [this[1], -this[0]];
  };

  /**
   * Rotate this vector 90 degrees clockwise in place.
   * @returns {Array}
   */
  Array.prototype.irotate90cw = function () {
    [this[0], this[1]] = [this[1], -this[0]];
    return this;
  };

  /**
   * Return this vector rotated 90 degrees counterclockwise.
   * @returns {*[]}
   */
  Array.prototype.rotate90ccw = function () {
    return [-this[1], this[0]];
  };

  /**
   * Rotate this vector 90 degrees counterclockwise in place.
   * @returns {Array}
   */
  Array.prototype.irotate90ccw = function () {
    [this[0], this[1]] = [-this[1], this[0]];
    return this;
  };

  /**
   * Return the result of rotating this angle by `angle` radians ccw.
   * @param angle
   * @returns {*[]}
   */
  Array.prototype.rotate = function (angle) {
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const x = this[0];
    const y = this[1];
    return [cos * x - sin * y, sin * x + cos * y];
  };

  /**
   * Rotate this angle in place.
   * @param angle
   * @returns {Array}
   */
  Array.prototype.irotate = function (angle) {
    const cos = Math.cos(angle);
    const sin = Math.sin(angle);
    const x = this[0];
    const y = this[1];
    this[0] = cos * x - sin * y;
    this[1] = sin * x + cos * y;
    return this;
  };

  /**
   * Return the dot product of this vector and another vector.
   * @param other
   * @returns {number}
   */
  Array.prototype.dot = function (other) {
    return this[0] * other[0] + this[1] * other[1];
  };

  /**
   * Set the components of this vector.
   * @param x
   * @param y
   * @returns {Array}
   */
  Array.prototype.set = function (x, y) {
    if (typeof x === "number") {
      this[0] = x;
      this[1] = y;
    } else {
      this[0] = x[0];
      this[1] = x[1];
    }
    return this;
  };

  /**
   * Alias for [0].
   */
  Object.defineProperty(Array.prototype, 'x', {
    ['get']() {
      return this[0];
    },
    ['set'](value) {
      return this[0] = value;
    }
  });

  /**
   * Alias for [1]
   */
  Object.defineProperty(Array.prototype, 'y', {
    ['get']() {
      return this[1];
    },
    ['set'](value) {
      return this[1] = value;
    }
  });

  /**
   * The magnitude (length) of this vector.
   * Changing it does not change the angle.
   */
  Object.defineProperty(Array.prototype, 'magnitude', {
    ['get']() {
      return Math.sqrt(this[0] * this[0] + this[1] * this[1]);
    },
    ['set'](value) {
      return this.imul(value / this.magnitude);
    }
  });

  /**
   * The angle in radians ccw from east of this vector.
   * Changing it does not change the magnitude.
   */
  Object.defineProperty(Array.prototype, 'angle', {
    ['get']() {
      return Math.atan2(this[1], this[0]);
    },
    ['set'](value) {
      return this.irotate(value - this.angle);
    }
  });
}