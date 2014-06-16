package util;

import flash.external.ExternalInterface;

class Input extends Entity implements Updatable {

	// key bindings
	static public inline var K_FORWARD = 87;             // W
    static public inline var K_BACKWARD = 83;           // S
    static public inline var K_TURN_LEFT = 65;      // A
    static public inline var K_TURN_RIGHT = 68;     // D
    static public inline var K_STRAFE_RIGHT = 69;   // E
    static public inline var K_STRAFE_LEFT = 81;    // Q

    static public inline var K_SHIELD_DOWN = 84;    // T
    static public inline var K_SHIELD_UP = 89;      // Y
    static public inline var K_STABILIZE = 67;      // C
    static public inline var K_KILL_ROTATION = 16;  // shift
    static public inline var K_MISSILE = 17;        // ctrl
    static public inline var K_LASER = 32;          // space
    static public inline var K_ASTEROID = 66;       // B

    static public inline var K_ZOOM_IN = 187;       // +
    static public inline var K_ZOOM_OUT = 189;      // -
	static public inline var K_CAMERA_LOCK = 70;	// F
    static public inline var K_FULLSCREEN = 71;     // G
	static public inline var K_RESET = 82;		    // R

	public var xAxis:Float;
	public var yAxis:Float;
	public var turn:Float;

	public function new() {
		super();
	}

	public function update(timestep:Float):Void {
		turn = (IO.keys[K_TURN_LEFT] ? -1 : 0) + (IO.keys[K_TURN_LEFT] ? 1 : 0);
		xAxis = (IO.keys[K_STRAFE_LEFT] ? -1 : 0) + (IO.keys[K_STRAFE_RIGHT] ? 1 : 0);
		yAxis = (IO.keys[K_FORWARD] ? 1 : 0) + (IO.keys[K_BACKWARD] ? -1 : 0);

		if (IO.gamepadEnabled()) {
			var axes = IO.getGamepadAxes();
			xAxis += Math.pow(MyMath.threshold(axes[0], 0.04), 3);
			yAxis += -Math.pow(MyMath.threshold(axes[1], 0.04), 3);
			turn += Math.pow(MyMath.threshold(axes[2], 0.04), 3);
			// limit in case buttons and keyboard are used
			xAxis = MyMath.limit(xAxis, -1, 1);
			yAxis = MyMath.limit(yAxis, -1, 1);
			turn = MyMath.limit(turn, -1, 1);
		} 
 	}

}