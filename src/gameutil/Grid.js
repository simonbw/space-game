/**
 * A 2 dimensional map
 */
export default class Grid {
  constructor() {
    /**
     * @type {Map}
     */
    this.data = {};
  }

  /**
   * Set a value at a location
   * @param x {number}
   * @param y {number}
   * @param value {*}
   */
  set([x, y], value) {
    this.data[x] = this.data[x] || {};
    this.data[x][y] = value;
  }

  /**
   * Set a value at a location
   * @param x {number}
   * @param y {number}
   * @returns {*}
   */
  get([x, y]) {
    if (!this.data.hasOwnProperty(x)) {
      return undefined;
    }
    return this.data[x][y];
  }

  /**
   * Delete the value at a location
   * @param x {number}
   * @param y {number}
   * @returns {*} - the deleted value
   */
  remove([x, y]) {
    if (!this.data.hasOwnProperty(x)) {
      return undefined;
    }
    return delete this.data[x][y];
  }
}
