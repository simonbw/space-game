package util;
	
	/**
	 * A static class for generating differnent random Floats.
	 */
class Random {
	/**
	 * Generate a random Float between min and max.
	 * @param	min		the lower bounds. defaults to zero.
	 * @param	max		the upper bounds. defaults to one.
	 * @return
	 */
	public static inline function uniform(min:Float = 0.0, max:Float = 1.0):Float {
		return Math.random() * (max - min) + min;
	}
	
	/**
	 * Generate a random Int n where n in range [min,max)
	 * @param	min		the lower bounds. Defaults to zero
	 * @param	max		the upper bounds. Defaults to one.
	 * @return
	 */
	public static inline function integer(min:Float = 0, max:Float = 1):Int {
		return Std.int(uniform(min, max + 1.0));
	}
	
	/**
	 * Generate a random Float based on the normal distribution
	 * @param	mean	the mean of the distribution
	 * @param	sigma	the standard deviation of the distribution
	 * @return
	 */
	public static function normal(mean:Float = 0.0, sigma:Float = 1.0):Float {
		return (sigma * (-1.5 + Math.random() + Math.random() + Math.random())) + mean;
	}
	
	/**
	 * Returns either -1 or 1
	 * @return	-1 or 1
	 */
	public static function sign():Int {
		return Math.random() > 0.5 ? -1 : 1;
	}
	
	/**
	 * Return either true or false.
	 * @return	true or false
	 */
	public static function bool(chance:Float = 0.5):Bool {
		return (Math.random() < chance);
	}
	
	/**
	 * Create a completely random color
	 * @return	color
	 */
	public static function color():Int {
		return integer(0, 255) + integer(0, 255) * 0x100 + integer(0, 255) * 0x10000;
	}
	
	/**
	 * Create a color that deviates from another color by a random amount.
	 * @param	c	the color
	 * @param	r	red deviation
	 * @param	g	green deviation
	 * @param	b	blue deviation
	 * @return
	 */
	public static function colorDeviation(c:Int, dr:Int, dg:Int, db:Int):Int {
		var r:Int = c % 256;
		var g:Int = Std.int(c / 256) % 256;
		var b:Int = Std.int(c / 65536) % 256;
		
		r = integer(MyMath.max(0, r - dr), MyMath.min(255, r + dr));
		g = integer(MyMath.max(0, g - dg), MyMath.min(255, g + dg));
		b = integer(MyMath.max(0, b - db), MyMath.min(255, b + db));
		
		return r + g * 0x100 + b * 0x10000;
	}
	
	/**
	 * Choose an object from a list of objects.
	 * @param	list	list of objects to choose from
	 * @return	a random object from the list.
	 */
	public static function choose<T>(list:Array<T>):T {
		return list[integer(0, list.length)];
	}
}