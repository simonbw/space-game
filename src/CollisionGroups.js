/**
 * Encode groups to an integer.
 * @param groups {Array.<number>}
 * @returns {number}
 */
export function group(...groups) {
  var mask = 0;
  groups.forEach(function (group) {
    mask |= Math.pow(2, group);
  });
  return mask;
}

// GROUPS - classification of stuff
export const ALL = group(...[0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15]);
export const SHIP_EXTERIOR = group(0);
export const SHIP_INTERIOR = group(1);
export const SHIP_SENSOR = group(2);
export const PERSON = group(3);

// MASKS - what stuff runs into
export const PERSON_MASK = SHIP_EXTERIOR | SHIP_SENSOR | PERSON;
