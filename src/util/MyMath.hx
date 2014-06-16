package util;

import nape.geom.Vec2;

/**
 * Class for useful math calculations.
 */
class MyMath {
	
	/**
	 * Returns a % b the proper way.
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public inline function mod(a:Float, b:Float):Float {
		return ((a % b) + b) % b;
	}
	
	/**
	 * Returns a % b the proper way.
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public inline function modInt(a:Int, b:Int):Int{
		return ((a % b) + b) % b;
	}

	/**
		 * Returns the sign of the number
		 * @return	-1, 1 or 0
		 */
	static public inline function sign(n:Float):Int {
		if (n < 0)
			return -1;
		else if (n > 0)
			return 1;
		else 
			return 0;
	}
	
	/**
	 * Returns the greater of two Floats;
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public inline function max(a:Float, b:Float):Float {
		return if (a > b) a else b;
	}
	
	/**
	 * Returns the lesser of two Floats.
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public inline function min(a:Float, b:Float):Float {
		return if (a < b) a else b;
	}
	
	/**
	 * Limit a float to between min and max.
	 * @param  a   value to limit
	 * @param  min minimum value
	 * @param  max maximum value
	 * @return     
	 */
	static public inline function limit(a:Float, min:Float = 0.0, max:Float = 1.0):Float {
		return Math.min(Math.max(a, min), max);
	}

	/**
	 * Requires a value to be a certain distance from center, otherwise returns center.
	 * @param  a         Value to affect
	 * @param  threshold minimum difference from center
	 * @param  center    
	 * @return           
	 */
	static public inline function threshold(a:Float, threshold:Float = 0.01, center:Float = 0):Float {
		// return a;
		return ((a > center + threshold) || (a < center - threshold)) ? a : center;
	}

	/**
	 * Returns the greater of two Ints.
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public inline function maxInt(a:Int, b:Int):Int {
		return if (a > b) a else b;
	}
	
	/**
	 * Returns the lesser of two Ints.
	 * @param	a
	 * @param	b
	 * @return
	 */
	static public inline function minInt(a:Int, b:Int):Int {
		return if (a < b) a else b;
	}
}