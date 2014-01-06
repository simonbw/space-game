package ;

/**
 */
interface Hittable {

	function hit(position:nape.geom.Vec2, velocity:nape.geom.Vec2):Void;
}