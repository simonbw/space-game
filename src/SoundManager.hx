
import flash.events.Event;
import flash.media.Sound;
import flash.media.SoundChannel;
import flash.media.SoundTransform;

import nape.geom.Vec2;

class SoundManager {

	/** Maps names to loaded sounds **/
	public static var sounds:Map<String, Sound>;
	/** Maps sound name to currently playing channels **/
	public static var soundChannels:Map<String, Array<SoundChannel>>;
	/** Maps channels in 2d space to their location **/
	public static var channelPositions:Map<SoundChannel, Vec2>;
	/** Maps channels to their sound name **/
	public static var channelNames:Map<SoundChannel, String>;

	static var earPosition:Vec2;

	/**
	 * Initialize the sound module
	 */
	public static function init():Void {
		sounds = new Map<String, Sound>();
		soundChannels = new Map<String, Array<SoundChannel>>();
		channelPositions = new Map<SoundChannel, Vec2>();
		channelNames = new Map<SoundChannel, String>();

		var mp3ToLoad = ["missile_launch", "laser", "laser_hit", "explosion1"];
		for (name in mp3ToLoad) {
			sounds.set(name, loadMP3(name));
			soundChannels.set(name, new Array<SoundChannel>());
		}

		earPosition = Vec2.get(0, 0);
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

	public static function playSoundAt(name:String, position:Vec2, maxPlaying:Int = 2):SoundChannel {
		try {
			var transform = new SoundTransform();
			makeTransform(transform, position);
			var channel = playSound(name, maxPlaying, transform);
			if (channel != null) {
				channelPositions.set(channel, position);
			}
			return channel;
		} catch (error:Dynamic) {
			Main.log("soundAt " + error);
			return null;
		}
	}

	static function onSoundEnd(e:Event):Void {
		try {
			var channel = cast(e.target, SoundChannel);
			channel.removeEventListener(Event.SOUND_COMPLETE, onSoundEnd);
			var name = channelNames.get(channel);
			soundChannels.get(name).remove(channel);

			if (channelPositions.exists(channel)) {
				channelPositions.get(channel).dispose();
				channelPositions.remove(channel);
			}
		} catch (error:Dynamic) {
			Main.log("SoundEndError: " + error);
		}
	}

	public static function playSound(name:String, maxPlaying:Int = 2, transform:SoundTransform = null):SoundChannel {
		var failedAt = "start";
		try {
			if (sounds.exists(name)) {
				failedAt = "counting";
				var numStarted = 0;
				for (channel in soundChannels.get(name)) {
					failedAt = "innerCount";
					if (channel.position < 20) {
						numStarted++;
					}
				}

				if (numStarted <= maxPlaying) {
					failedAt = "transform";
					if (transform == null) {
						transform = new SoundTransform();
					}
					failedAt = "get channel";
					var channel = sounds.get(name).play(0, 0, transform);
					if (channel != null) {
						failedAt = "set channelName";
						channelNames.set(channel, name);
						failedAt = "set soundChannels";
						soundChannels.get(name).push(channel);
						failedAt = "addListener";
						channel.addEventListener(Event.SOUND_COMPLETE, onSoundEnd);
					}
					return channel;
				} else {
					return null;
				}
			}
			return null;
		} catch (error:Dynamic) {
			throw "sound error: " + name + " " + failedAt + " " + error;
		}
		return null;
	}

	static inline function makeTransform(transform:SoundTransform, position:Vec2):Void {
		var diff = position.sub(earPosition);
		transform.pan = util.MyMath.limit(diff.x / 2000, -1, 1);
		transform.volume = util.MyMath.limit(500.0 / (diff.length));
		diff.dispose();
	}


	public static function setEarPosition(ear:Vec2):Void {
		earPosition.set(ear);
		for (channel in channelPositions.keys()) {
			var position = channelPositions.get(channel);
			makeTransform(channel.soundTransform, position);
		}
	}
}
