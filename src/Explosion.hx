



class Explosion extends Entity implements Updatable implements Renderable {
	public var renderDepth:Int;
	public var lifespan:Float;
	public function new(position) {
		super();
		renderDepth = 10;
		lifespan = 0.2;
	}

	public function update(timestep:Float):Void {
		lifespan -= timestep;
		if (lifespan <=)
	}

	public function render(surface:flash.display.BitmapData, camera:Camera):Void {

	}
}