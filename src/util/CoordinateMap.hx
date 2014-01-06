
package util;

class CoordinateMap<T> {

	var m:Map<Int,Map<Int,T>>;

	public function new() {
		m = new Map<Int,Map<Int,T>>();
	}

	/**
	 * Get the value at (x,y).
	 */
	public function get(x: Int, y: Int):T {
		try {
			if (!m.exists(x)) {
				m.set(x, new Map < Int, T > ());
			}
			return m.get(x).get(y);
		} catch (error:Dynamic) {
			trace(error);
			return null;
		}
	}

	/**
	 * Set the value at (x,y).
	 */
	public function set(x:Int, y:Int, value:T):Void {
		try {
			if (!m.exists(x)) {
				m.set(x, new Map < Int, T > ());
			}
			m.get(x).set(y, value);
		} catch (error: Dynamic) {
			trace(error);
		}
	}

	/**
	 * Return true if the value at (x,y) exists
	 */
	public function exists(x:Int, y:Int):Bool {
		try {
			if (m.exists(x)) {
				return m.get(x).exists(y);
			} else {
				return false;
			}
		} catch (error: Dynamic) {
			trace(error);
			return false;
		}
	}

	/**
	 * Remove the value at (x,y) if it exists.
	 */
	public function remove(x:Int, y:Int):Void {
		if (m.exists(x)) {
			m.get(x).remove(y);
		}
	}

	/**
	 * @return String representation
	 */
	public function toString():String {
		var s = "{\n";
		for (key in m.keys()) {
			s += "" + key + " : " + m.get(key).toString() + "\n";
		}
		s += "}";
		return s;
	}
}