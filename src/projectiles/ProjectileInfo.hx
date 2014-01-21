package projectiles;



class ProjectileInfo {
	// constants
	public static var LASER = new ProjectileInfo(40, DamageType.Energy);
	public static var MISSILE = new ProjectileInfo(500, DamageType.Physical);

	
	/** Base amount of damage to be done */
	public var damage:Float;
	/** Type of damage to do */
	public var damageType:DamageType;


	public function new(damage:Float, damageType:DamageType) {
		this.damage = damage;
		this.damageType = damageType;		
	}
}