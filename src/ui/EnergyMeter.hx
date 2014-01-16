package ui;

import flash.display.Sprite;
import flash.display.BitmapData;

import ship.Ship;
import ship.EnergyType;

class EnergyMeter extends Entity implements Renderable {

	var sprite:Sprite;	
	var ship:Ship;
	public var renderDepth:Int;

	public function new(ship:Ship = null):Void {
		renderDepth = -1;
		super();
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

		var overloaded = ship.energyManager.energyLoad > 1.0;
		var color = (ship.energyManager.energyLoad > 1.0) ? 0xFF3300 : 0x00FFFF;
		var maxH = 100;
		var w = 20;
		var i = 1;
		for (t in [EnergyType.ENGINE, EnergyType.SHIELD, EnergyType.WEAPON]) {
			var h = ship.energyManager.consumptions.get(t) / ship.energyManager.energyProduction * maxH;
			if (overloaded) {
				g.lineStyle(1, 0xFF3300, 0.6);
				g.moveTo(surface.width - (i - 1) * w, surface.height - h);
				g.lineTo(surface.width - (i) * w, surface.height - h);
				g.lineStyle();
				h = h / ship.energyManager.energyLoad;
				g.beginFill(0xFF3300, 0.2);
				g.drawRect(surface.width - i * w, surface.height - h, w, h);
			} else {
				g.beginFill(0x00FFFF, 0.2);
				g.drawRect(surface.width - i * w, surface.height - h, w, h);
			}
			g.endFill();
			i++;
		}

		var h = ship.energyManager.totalConsumption / ship.energyManager.energyProduction * maxH;
		g.beginFill(color, 0.5);
		g.drawRect(surface.width - i * w, surface.height - h, w, h);
		g.endFill();
		i++;

		h = ship.energy / ship.maxEnergy * maxH;
		g.beginFill(0xFFFF00, 0.7);
		g.drawRect(surface.width - i * w, surface.height - h, 5, h);
		g.endFill();

		g.lineStyle(1, 0x00FFFF);
		g.moveTo(surface.width, surface.height - maxH);
		g.lineTo(surface.width - 85, surface.height - maxH);
		surface.draw(sprite);
	}

	override public function dispose():Void {
		super.dispose();
		util.Pool.disposeSprite(sprite);
	}
}