package ui;

import flash.ui.Mouse;
import flash.ui.MouseCursorData;
import flash.display.BitmapData;

/**
 * Creates custom cursors.
 */
class Cursor {
	public static inline var C_CROSSHAIR = "c_crosshair";

	public static function init():Void {
		makeCrosshair();
		Mouse.cursor = C_CROSSHAIR;
	}

	static inline function makeCrosshair():Void {
		var cursorData = new MouseCursorData();

		var data = new flash.Vector<BitmapData>();
		var image = new BitmapData(24, 24, true, 0xCCCCCC);
		data.push(image);

		image.lock();
		for (i in 0...10) {
			image.setPixel32(i, Std.int(image.height / 2), 0xFF00FF00);
			image.setPixel32(Std.int(image.width / 2), i, 0xFF00FF00);
			image.setPixel32(image.width - i, Std.int(image.height / 2), 0xFF00FF00);
			image.setPixel32(Std.int(image.width / 2), image.height - i, 0xFF00FF00);
		}
		image.unlock();

		cursorData.data = data;
		cursorData.hotSpot = new flash.geom.Point(16, 16);
		cursorData.frameRate = 0;

		Mouse.registerCursor(C_CROSSHAIR, cursorData);
	}
}