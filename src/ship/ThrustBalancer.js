import * as Util from '../gameutil/Util';

/**
 * Controls the thrusters.
 */
export default class ThrustBalancer {
  constructor(ship) {
    this.dirty = true;
    this.maxTorque = 0;
    this.maxXForce = 0;
    this.maxYForce = 0;
    this.minTorque = 0;
    this.minXForce = 0;
    this.minYForce = 0;
    this.ship = ship;
    this.throttlePresets = new ThrottlePresets();
    this.thrusterData = new Map(); // stores calculated info about thrusters
    this.thrusters = [];
  }

  /**
   * Called when a part is added.
   * @param part {Part}
   */
  partAdded(part) {
    if (part.thruster) {
      this.addThruster(part);
    }
    this.dirty = true;
  }

  /**
   * Called when a part is removed.
   * @param part {Part}
   */
  partRemoved(part) {
    if (part.thruster) {
      this.removeThruster(part);
    }
    this.dirty = true;
  }

  /**
   * Add an engine to be controlled by this thrust balancer.
   * @param thruster {Thruster}
   * @returns {Map.<K, V>}
   */
  addThruster(thruster) {
    this.thrusters.push(thruster);
    return this.thrusterData.set(thruster, {});
  }

  /**
   * Relinquish throttle control of an engine
   * @param thruster {Thruster}
   */
  removeThruster(thruster) {
    this.thrusters.splice(this.thrusters.indexOf(thruster), 1);
    this.thrusterData.delete(thruster);
  }

  /**
   * Calculate thrust data for all thrusters
   */
  calculateThrusterData() {
    this.dirty = false;

    this.maxXForce = 0;
    this.minXForce = 0;
    this.maxYForce = 0;
    this.minYForce = 0;
    this.maxTorque = 0;
    this.minTorque = 0;

    if (this.thrusters.length === 0) {
      return;
    }

    this.thrusters.forEach((thruster) => {
      const data = this.thrusterData.get(thruster);
      const center = thruster.getLocalPosition();
      if (thruster.direction === 0) {
        data.xForce = 0;
        data.yForce = -thruster.maxThrust;
        data.torque = -thruster.maxThrust * center[0];
      } else if (thruster.direction === 1) {
        data.xForce = thruster.maxThrust;
        data.yForce = 0;
        data.torque = -thruster.maxThrust * center[1];
      } else if (thruster.direction === 2) {
        data.xForce = 0;
        data.yForce = thruster.maxThrust;
        data.torque = thruster.maxThrust * center[0];
      } else if (thruster.direction === 3) {
        data.xForce = -thruster.maxThrust;
        data.yForce = 0;
        data.torque = thruster.maxThrust * center[1];
      }

      this.maxXForce += Math.max(0, data.xForce);
      this.minXForce += Math.min(0, data.xForce);
      this.maxYForce += Math.max(0, data.yForce);
      this.minYForce += Math.min(0, data.yForce);
      this.maxTorque += Math.max(0, data.torque);
      this.minTorque += Math.min(0, data.torque);
    });

    const none = this.thrusters.map(() => 0);

    const controls = [-1, 0, 1];
    controls.forEach((xControl) => {
      controls.forEach((yControl) => {
        controls.forEach((torque) => {
          if (xControl === 0 && yControl === 0 && torque === 0) {
            this.throttlePresets.setThrottles(xControl, yControl, torque, none);
            return;
          }

          const lp = new ThrustLP(this.thrusters, this.thrusterData);

          if (xControl === 0) {
            lp.lockX();
          }
          if (yControl === 0) {
            lp.lockY();
          }
          if (torque === 0) {
            lp.lockTorque();
          }

          lp.maximize(xControl, yControl, torque);
          if (!lp.solve()) {
            console.log("Error solving ThrustLP for", xControl, yControl, torque);
          }

          this.throttlePresets.setThrottles(xControl, yControl, torque, lp.x || none);
        })
      });
    });

  }

  /**
   * Set the throttles of all thrusters.
   * @param throttles {Array.<number>} - the values of each thruster
   * @param scale {number} - a constant to multiply each thruster by.
   */
  setThrottles(throttles, scale = 1) {
    this.thrusters.forEach((thruster, i) => {
      thruster.throttle = throttles[i] * scale;
    });
  }

  /**
   * Return the result of mixing two sets of throttle calculations.
   * @param a {Array.<number>}
   * @param b {Array.<number>}
   * @param mix {number}
   * @param scale {number}
   * @returns {Array.<number>}
   */
  mixThrottles(a, b, mix = 0.5, scale = 1) {
    const result = [];
    for (var i = 0; i < this.thrusters.length; i++) {
      result.push((a[i] * mix + b[i] * (1 - mix)) * scale);
    }
    return result;
  }

  /**
   * Set the throttles of the thrusters to match control input.
   * @param yControl {number}
   * @param xControl {number}
   * @param turn {number}
   */
  balance(yControl = 0, xControl = 0, turn = 0) {
    if (this.dirty) {
      this.calculateThrusterData();
    }

    // TODO: This can probably be much prettier. At least better names
    const a = this.throttlePresets.getThrottles(Math.floor(xControl), Math.floor(yControl), Math.floor(turn));
    const b = this.throttlePresets.getThrottles(Math.floor(xControl), Math.floor(yControl), Math.ceil(turn));
    const c = this.throttlePresets.getThrottles(Math.floor(xControl), Math.ceil(yControl), Math.floor(turn));
    const d = this.throttlePresets.getThrottles(Math.floor(xControl), Math.ceil(yControl), Math.ceil(turn));
    const e = this.throttlePresets.getThrottles(Math.ceil(xControl), Math.floor(yControl), Math.floor(turn));
    const f = this.throttlePresets.getThrottles(Math.ceil(xControl), Math.floor(yControl), Math.ceil(turn));
    const g = this.throttlePresets.getThrottles(Math.ceil(xControl), Math.ceil(yControl), Math.floor(turn));
    const h = this.throttlePresets.getThrottles(Math.ceil(xControl), Math.ceil(yControl), Math.ceil(turn));

    const ab = this.mixThrottles(a, b, 1 - Util.mod(turn, 1));
    const cd = this.mixThrottles(c, d, 1 - Util.mod(turn, 1));
    const ef = this.mixThrottles(e, f, 1 - Util.mod(turn, 1));
    const gh = this.mixThrottles(g, h, 1 - Util.mod(turn, 1));

    const abcd = this.mixThrottles(ab, cd, 1 - Util.mod(yControl, 1));
    const efgh = this.mixThrottles(ef, gh, 1 - Util.mod(yControl, 1));

    const abcdefgh = this.mixThrottles(abcd, efgh, 1 - Util.mod(xControl, 1));

    this.setThrottles(abcdefgh);
  }

  /**
   * Backup method for thruster balancing
   * @param yControl {number}
   * @param xControl {number}
   * @param turn {number}
   */
  oldBalance(yControl, xControl, turn) {
    this.thrusters.forEach((thruster) => {
      var throttle = 0;
      const x = thruster.x - this.ship.offset[0];
      const y = thruster.y - this.ship.offset[1];

      switch (thruster.direction) {
        case 0: // forward
          if (yControl > 0) {
            throttle += yControl;
          }
          if (turn > 0 && x < 0) {
            throttle += turn;
          }
          if (turn < 0 && x > 0) {
            throttle += -turn;
          }
          break;
        case 1: // right
          if (xControl > 0) {
            throttle += xControl;
          }
          if (turn > 0 && y < 0) {
            throttle += turn;
          }
          if (turn < 0 && y > 0) {
            throttle += -turn;
          }
          break;
        case 2: // backward
          if (yControl < 0) {
            throttle += -yControl;
          }
          if (turn > 0 && x > 0) {
            throttle += turn;
          }
          if (turn < 0 && x < 0) {
            throttle += -turn;
          }
          break;
        case 3: // left
          if (xControl < 0) {
            throttle += -xControl;
          }
          if (turn > 0 && y < 0) {
            throttle += turn;
          }
          if (turn < 0 && y > 0) {
            throttle += -turn;
          }
          break;
      }
      throttle = Util.clamp(throttle);
      thruster.setThrottle(throttle);
    });
  }
}

/**
 * Stores throttle calculations.
 */
class ThrottlePresets {
  constructor() {
    this.makeKey = this.makeKey.bind(this);
    this.getThrottles = this.getThrottles.bind(this);
    this.setThrottles = this.setThrottles.bind(this);
    this.data = {};
  }

  /**
   * Create the key for the map.
   * @param x {number}
   * @param y {number}
   * @param t {number}
   * @returns {string}
   */
  makeKey(x, y, t) {
    return `${[Math.sign(x), Math.sign(y), Math.sign(t)]}`;
  }

  /**
   * Get calculated throttles.
   * @param x {number}
   * @param y {number}
   * @param t {number}
   * @returns {Array.<number>}
   */
  getThrottles(x, y, t) {
    return this.data[this.makeKey(x, y, t)];
  }

  /**
   * Set calculated throttles.
   * @param x {number}
   * @param y {number}
   * @param t {number}
   * @param throttles {Array.<number>}
   */
  setThrottles(x, y, t, throttles) {
    this.data[this.makeKey(x, y, t)] = throttles;
  }
}


/**
 * A linear program for solving thrust balancing
 */
class ThrustLP {
  /**
   * Create a new ThrustLP for specific thrusters.
   * @param thrusters {Array.<Thruster>}
   * @param thrusterData {Map.<Thruster, object>}
   */
  constructor(thrusters, thrusterData) {
    this.thrusters = thrusters;
    this.thrusterData = thrusterData;
    this.a = []; // inequalities LHS
    this.b = []; // inequalities RHS
    this.ae = []; // equalities LHS
    this.be = []; // equalities RHS
    this.c = []; // coefficients in minimization
    this.x = null;
    this.limitThrottles();
  }

  /**
   * Maximize throttles for particular controls.
   * @param xControl {number}
   * @param yControl {number}
   * @param torque {number}
   */
  maximize(xControl = 0, yControl = 0, torque = 0) {
    this.thrusters.forEach((thruster) => {
      const data = this.thrusterData.get(thruster);
      const x = data.xForce * -Math.sign(xControl);
      const y = data.yForce * -Math.sign(yControl);
      const t = data.torque * -Math.sign(torque);
      this.c.push((x + y + t) || 0.001)
    });
  }

  /**
   * Make sure throttles stay between min and max.
   * @param min {=number}
   * @param max {=number}
   */
  limitThrottles(min = 0, max = 1) {
    const n = this.thrusters.length;
    // TODO: WTF? I don't know what this is, but I think it works, so maybe don't touch it.
    for (var i = 0; 0 < n ? i < n : i > n; 0 < n ? i++ : i--) {
      const aMax = ((() => {
        const result1 = [];
        for (var _ = 0; 0 < n ? _ < n : _ > n; 0 < n ? _++ : _--) {
          result1.push(0);
        }
        return result1;
      })());
      const aMin = ((() => {
        const result1 = [];
        for (var _ = 0; 0 < n ? _ < n : _ > n; 0 < n ? _++ : _--) {
          result1.push(0);
        }
        return result1;
      })());
      aMax[i] = 1.0;
      aMin[i] = -1.0;
      this.a.push(aMin, aMax);
      this.b.push(min, max);
    }
  }

  /**
   * Guarantee minimum torque.
   * @param sign {=number} - -1, 0, or 1
   */
  minTorque(sign = 1.0) {
    const torques = [];
    this.thrusters.forEach((thruster) => {
      torques.push(this.thrusterData.get(thruster).torque * Math.sign(sign));
    });

    if (torques.some((x) => x !== 0)) {
      this.a.push(torques);
      this.b.push(0);
    }
  }

  /**
   * Guarantee no torque.
   */
  lockTorque() {
    const torques = this.thrusters.map((thruster) => {
      return this.thrusterData.get(thruster).torque;
    });
    if (torques.some((x) => x !== 0)) {
      this.ae.push(torques);
      this.be.push(0);
    }
  }

  /**
   * Guarantee no x force.
   */
  lockX() {
    const forces = this.thrusters.map((thruster) => {
      return this.thrusterData.get(thruster).xForce;
    });
    if (forces.some((x) => x !== 0)) {
      this.ae.push(forces);
      this.be.push(0);
    }
  }

  /**
   * Guarantee no y force.
   */
  lockY() {
    const forces = this.thrusters.map((thruster) => {
      return this.thrusterData.get(thruster).yForce;
    });
    if (forces.some((x) => x !== 0)) {
      this.ae.push(forces);
      this.be.push(0);
    }
  }

  /**
   * Solve the system of equations.
   * @returns {Array.<number> | null} - the solution
   */
  solve() {
    try {
      this.x = numeric.solveLP(this.c, this.a, this.b, this.ae, this.be).solution;
    } catch (e) {
      this.x = null;
    }
    return this.x;
  }

  /**
   * Pretty print the equations
   * @returns {string}
   */
  toString() {
    var s = `size: ${this.c.length}\n`;

    const cx = this.c.map((ci, i) => `${ci.toFixed(2)}x_${i}`);
    s += "minimize: " + cx.join(' + ') + '\n';

    // TODO: Clean this up
    // inequalities
    const inequalities = [];
    for (var i = 0, ai; i < this.a.length; i++) {
      ai = this.a[i];
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
      inequalities.push(aix.join(' + ') + ' <= ' + this.b[i]);
    }
    s += inequalities.join(' ; ') + '\n';

    // equalities
    const equalities = [];
    const iterable2 = this.ae;
    for (var i = 0, ei; i < iterable2.length; i++) {
      ei = iterable2[i];
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
      equalities.push(eix.join(' + ') + ' = ' + this.be[i]);
    }
    s += equalities.join('\n') + '\n';

    const solution = [];
    if (this.x) {
      const iterable3 = this.x;
      for (var i = 0, xi; i < iterable3.length; i++) {
        xi = iterable3[i];
        solution.push(`x_${i} = ${xi.toFixed(2)}`);
      }
      s += solution.join(' ; ') + '\n';
    }

    return s;
  }
}
