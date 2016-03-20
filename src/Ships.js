import * as Parts from './ship/Parts';
import Blueprint from './ship/Blueprint';

/**
 * Create a blueprint for a basic starting ship.
 * @returns {Blueprint}
 */
export function starterShip() {
  const blueprint = new Blueprint();
  blueprint.addPart(new Parts.Chair([0, 1]));
  blueprint.addPart(new Parts.Generator([0, 2]));

  blueprint.addPart(new Parts.Thruster([1, 2], 0));
  blueprint.addPart(new Parts.Thruster([-1, 2], 0));

  blueprint.addPart(new Parts.Thruster([1, -1], 2));
  blueprint.addPart(new Parts.Thruster([-1, -1], 2));

  blueprint.addPart(new Parts.Thruster([-2, 0], 1));
  blueprint.addPart(new Parts.Thruster([-2, 1], 1));
  blueprint.addPart(new Parts.Thruster([2, 0], 3));
  blueprint.addPart(new Parts.Thruster([2, 1], 3));

  blueprint.addPart(new Parts.Interior([-1, 1]));
  blueprint.addPart(new Parts.Interior([1, 1]));

  blueprint.addPart(new Parts.AirVent([-1, 0]));
  blueprint.addPart(new Parts.AirVent([1, 0]));

  return blueprint;
}


/**
 * Create a blueprint for a simple station.
 * @returns {Blueprint}
 */
export function simpleStation() {
  const blueprint = new Blueprint();
  const start = -5;
  for (var x = start; start < 5 ? x <= 5 : x >= 5; start < 5 ? x++ : x--) {
    for (var y = start; start < 5 ? y <= 5 : y >= 5; start < 5 ? y++ : y--) {
      const [ax, ay] = [Math.abs(x), Math.abs(y)];
      if (x !== 0 || y !== 0) {
        if (ax === 5 || ay === 5) { // Outside
          if (x === 0 || y === 0) {
            blueprint.addPart(new Parts.Door([x, y]));
          } else {
            blueprint.addPart(new Parts.Hull([x, y]));
          }
        } else {
          if (ax === 2 && ay === 2) {
            blueprint.addPart(new Parts.AirVent([x, y]));
          } else if (ax === 4 && ay === 4) {
            blueprint.addPart(new Parts.Generator([x, y]));
          } else {
            blueprint.addPart(new Parts.Interior([x, y]));
          }
        }
      }
    }
  }
  return blueprint;
}