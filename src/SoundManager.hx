
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;

class SoundManager {

	public static var sounds:Map<String, Sound>;
	public static var channels:Map<String, Array<SoundChannel>>;

	public static function init():Void {
		sounds = new Map<String, Sound>();
		channels = new Map<String, Array<SoundChannel>>();
		var mp3ToLoad = ["missile_launch", "laser", "laser_hit", "explosion1"];
		for (name in mp3ToLoad) {
			sounds.set(name, loadMP3(name));
			channels.set(name, new Array<SoundChannel>());
		}
	}

	static function loadWAV(name:String):Sound {
		var sound = new flash.media.Sound();
		var data = haxe.Resource.getBytes("s_" + name);
		trace("data: " + data + " length: " + data.length);
		sound.loadCompressedDataFromByteArray(data.getData(), data.length);
		return sound;
	}

	static function loadMP3(name:String):Sound {
		var sound = new flash.media.Sound();
		var data = haxe.Resource.getBytes("s_" + name);
		sound.loadCompressedDataFromByteArray(data.getData(), data.length);
		return sound;
	}

	public static function playSound(name:String):Void {
		if (sounds.exists(name)) {
			var numStarted = 0;
			for (channel in channels.get(name)) {
				if (channel.position < 30) {
					numStarted++;
				}
			}

			if (numStarted < 3) {
				var channel = sounds.get(name).play();
				channels.get(name).push(channel);
				channels.get(name).push(channel);
				channel.addEventListener(Event.SOUND_COMPLETE, function(e: Event): Void {
					channels.get(name).remove(e.target);
				});
			} else {
				Main.log("Too many sounds playing: " + name);
			}
		}
	}
}