
interface Renderable {
	var renderDepth:Int;
	var disposed:Bool;
	function render(surface:flash.display.BitmapData, camera:Camera):Void;
}