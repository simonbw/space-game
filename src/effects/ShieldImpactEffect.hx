package effects;

class ShieldImpactEffect extends ImpactEffect {
	public function new(position:nape.geom.Vec2, size:Float) {
		super(position, 0x00FFFF, size);
	}
}