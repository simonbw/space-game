package ;

/**
 * Something that can be hit by a projectile.
 */
interface Hittable {
	/**
	 * Called when hit by a projectile.
	 * @param  position.geom.Vec2    [description]
	 * @param  projectile.Projectile [description]
	 * @return                       [description]
	 */
	function hit(position:nape.geom.Vec2, projectile:projectiles.Projectile):Void;
}