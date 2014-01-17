package util;

import flash.display.BitmapData;
import flash.text.TextField;
import flash.text.TextFormat;
import flash.Lib.getTimer;

/**
 * Class for profiling and displaying debug information.
 */
class Profiler {
	/** Maximum characters in a line */
	static inline var MAX_LOG_CHAR = 120;
	/** Maximum log messages */
	public var maxLogs = 10;

	var field:TextField;
	var field2:TextField;
	var sections:Map<String, Section>;
	var sectionNames:Array<String>;
	var logList:Array<String>;
	var customData:Array<String>;
	var lastCall:Int;
	var totalTime:Int;
	var fps:Float;
	var avgFps:Float;
	var lastMem:Int;
	var memDiff:Int;

	/**
	 * Create a new profiler.
	 */
	public function new() {
		field = new TextField();
		field.defaultTextFormat = new TextFormat("Helvetica", 12, 0xFFFFFF);
		field2 = new TextField();
		field2.defaultTextFormat = new TextFormat("Helvetica", 12, 0xFFFFFF, null, null, null, null, null, flash.text.TextFormatAlign.RIGHT);

		sections = new Map<String, Section>();
		sectionNames = new Array<String>();

		var lastCall = flash.Lib.getTimer();
		fps = 60.0;
		avgFps = 60.0;

		logList = new Array<String>();
		customData = new Array<String>();
	}

	/**
	 * Add a section to be profiled.
	 * @param section section name
	 */
	public function addSection(name:String):Void {
		sections.set(name, new Section(name));
		sectionNames.push(name);
	}

	/**
	 * Start a section to profile.
	 */
	public function startSection(section:String):Void {
		sections.get(section).start();
	}

	/**
	 * End a section.
	 * @return duration of section in milliseconds
	 */
	public function endSection(section:String):Int {
		return sections.get(section).end();
	}

	public function log(entry:String):Void {
		if (entry.length > MAX_LOG_CHAR) {
			entry = entry.substr(0, MAX_LOG_CHAR - 3) + "...";
		}
		logList.push(entry);
		while (logList.length > maxLogs) {
			logList.shift();
		}
	}
	
	public function setCustomData(data:String, position:Int):Void {
		if (data == null) {
			customData.splice(position, 1);
		} else {
			if (customData.length < position) {
				customData.push(data);
			} else {
				customData[position] = data;
			}
		}
	}

	/**
	 * Call once per frame.
	 * @return milliseconds since last frame.
	 */
	public function update():Int {
		var mem = flash.system.System.totalMemory;
		memDiff = Std.int(0.9 * memDiff + 0.1 * (mem - lastMem));
		lastMem = mem;

		var weight = 0.95;
		var now = getTimer();
		var diff = now - lastCall;
		fps = (1000.0 / diff);
		avgFps = weight * avgFps + (1.0 - weight) * fps;

		lastCall = now;
		return diff;
	}

	/**
	 * Draw the profiler data.
	 * @param  surface
	 * @param  camera
	 */
	public function render(surface: BitmapData): Void {
		var frameTime = 1000.0 / avgFps;

		field.text = Std.int(avgFps) + " fps\n";
		field.text += lastMem / 1024 + " kB (" + Std.int(memDiff / 1024) + "kB) \n" ;

		for (name in sectionNames) {
			var section = sections.get(name);
			field.text += section.name + ": " + Std.int(100 * (section.avgDuration / frameTime)) + "% \n";
		}
		field.text += "\n";
		for (line in customData) {
			field.text += line + "\n";
		}

		field.width = field.textWidth + 10;
		field.height = field.textHeight + 10;
		surface.draw(field, null, null, null, null, true);
		
		field2.text = "";
		for (entry in logList) {
			field2.text += entry + "\n";
		}

		field2.width = field2.textWidth + 10;
		field2.height = field2.textHeight + 10;

		var m = new flash.geom.Matrix();
		m.translate(Main.currentGame.stage.stageWidth - field2.width, 0);
		surface.draw(field2, m, null, null, null, true);
	}
}

private class Section {
	public var name:String;
	public var lastCall:Int;
	public var totalTime:Int;
	public var totalCalls:Int;
	public var avgDuration:Float;

	/**
	 * Create a new section
	 * @param  name name of the section
	 */
	public function new(name:String) {
		this.name = name;
		avgDuration = 0.0;
	}

	/**
	 * Start the section
	 * @return [description]
	 */
	public function start():Void {
		lastCall = getTimer();
	}

	/**
	 * End the section
	 * @return duration in milliseconds
	 */
	public function end():Int {
		var now = getTimer();
		var diff = now - lastCall;
		totalTime += diff;
		totalCalls++;
		var weight = 0.95;
		avgDuration = weight * avgDuration + (1.0 - weight) * diff;
		lastCall = now;
		return diff;
	}
}