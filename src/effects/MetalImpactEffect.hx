package effects;

class MetalImpactEffect extends ImpactEffect {
	public function new(position:nape.geom.Vec2, size:Float) {
		super(position, 0xFFFF00, size);
	}
}