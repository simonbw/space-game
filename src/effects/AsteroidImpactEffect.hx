package effects;

class AsteroidImpactEffect extends ImpactEffect {
	public function new(position:nape.geom.Vec2, size:Float) {
		super(position, 0x555555, size);
	}
}