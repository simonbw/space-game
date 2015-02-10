package ui;

import flash.display.Sprite;
import flash.display.BitmapData;

import ship.Ship;
import ship.EnergyType;

class Radar extends Entity implements Renderable implements Updatable {

	public var renderDepth:Int;

	var ship:Ship;
	var sprite:Sprite;	

	public function new(ship:Ship = null):Void {
		super();
		renderDepth = -2;
		if (ship != null) {
			setShip(ship);
		}
		sprite = util.Pool.sprite();
	}

	public function setShip(ship:Ship):Void {
		this.ship = ship;
	}

	public function update(timestep:Float):Void {

	}

	public function render(surface:BitmapData, camera:Camera):Void {
		var g = sprite.graphics;
		g.clear();

		for (e in game.entities) {
			if (Std.is(e, Ship)) {
				var s = cast(e, Ship);
				g.beginFill(0xFF0000);
				g.drawCircle(s.body.worldCOM.x, s.body.worldCOM.y, 5);
				g.endFill();
			}
		}

		surface.draw(sprite, camera.getMatrix());
	}

	override public function dispose():Void {
		super.dispose();
		util.Pool.disposeSprite(sprite);
	}
}