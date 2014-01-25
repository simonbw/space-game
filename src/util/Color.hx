package util;

/**
 * Helper class for working with colors.
 */
class Color {
	
	/**
	 * Return a color a given percent between two colors.
	 * @param  a       
	 * @param  b       
	 * @param  percent 
	 * @return         
	 */
	public static inline function interpolate(c1:Int, c2:Int, percent:Float = 0.5):Int {
		percent = MyMath.limit(percent);
		var percent2 = 1.0 - percent;
		
		var r = Std.int(percent2 * red(c1) + percent * red(c2));
		var g = Std.int(percent2 * green(c1) + percent * green(c2));
		var b = Std.int(percent2 * blue(c1) + percent * blue(c2));

		return makeColor(r, g, b);
	}

	public static inline function red(c:Int):Int {
		return (0xFF0000 & c) >> 16;
	}

	public static inline function green(c:Int):Int {
		return ((0x00FF00) & c) >> 8;
	}
	
	public static inline function blue(c:Int):Int {
		return (0x0000FF) & c;
	}

	public static inline function makeColor(r:Int, g:Int, b:Int):Int {
		return r << 16 | g << 8 | b;
	}

	public static inline function makeGray(v:Int):Int {
		return return v << 16 | v << 8 | v;
	}

}