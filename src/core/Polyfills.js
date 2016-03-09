import initVector from './Vector';

/**
 * Attach all sorts of hacky stuff to the global state.
 */
export default function () {
  require('numeric');
  initVector(Array);
  Object.values = Object.values || ((o) => Object.keys(o).map((key) => o[key]));
  Object.entries = Object.entries || ((o) => Object.keys(o).map((key) => [key, o[key]]));
};