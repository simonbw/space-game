
interface Renderable 
{
	var renderDepth:Int;
	function render(surface:flash.display.BitmapData, camera:Camera):Void;
}