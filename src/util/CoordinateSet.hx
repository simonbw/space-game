package util;

import de.polygonal.ds.IntHashSet;
import flash.Boot;

/**
 * Needs Work.
 */
class CoordinateSet {
	
	public var map:Map<Int,IntHashSet>;
	public var size:Int;
	
	public function new() {
		map = new Map<Int,IntHashSet>();
		size = 0;
	}
	
	public function has(x:Int, y:Int):Bool {
		if (map.exists(x)) {
			return map.get(x).has(y);
		} else {
			return false;
		}
	}
	
	public function set(x:Int, y:Int):Void {
		if (!has(x, y)) {
			if (!map.exists(x)) {
				map.set(x, new IntHashSet(2<<4));
			}
			size++;
			map.get(x).set(y);
			
			dirty();
		}
	}
	
	public function remove(x:Int, y:Int):Void {
		if (hasXY(x, y)) {
			size--;
			map.get(x).remove(y);
			
			dirty();
		}
	}
	
	/**
	 * Remove all elements.
	 */
	public function clear():Void {
		for (s in map) {
			s.clear();
		}
		size = 0;
		
		dirty();
	}
	
	public function toString():String {
		return "[CoordinateSet size=" + size + "]";
	}
}