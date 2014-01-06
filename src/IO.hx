import flash.geom.Point;

/**
 * Static class for managing input.
 */
class IO {
    static public inline var K_UP = 87;             // W
    static public inline var K_DOWN = 83;           // S
    static public inline var K_TURN_LEFT = 65;      // A
    static public inline var K_TURN_RIGHT = 68;     // D
    static public inline var K_STRAFE_RIGHT = 69;   // E
    static public inline var K_STRAFE_LEFT = 81;    // Q

    static public inline var K_SHIELD = 84;         // T
    static public inline var K_STABILIZE = 67;      // C
    static public inline var K_KILL_ROTATION = 16;  // shift
    static public inline var K_MISSILE = 17;        // ctrl
    static public inline var K_LASER = 32;          // space
    static public inline var K_ASTEROID = 66;       // B

    static public inline var K_ZOOM_IN = 187;       // +
    static public inline var K_ZOOM_OUT = 189;      // -
	static public inline var K_CAMERA_LOCK = 70;	// F
	static public inline var K_FULLSCREEN = 71;		// G

    static public var mousePos:Point;
	static public var keys:Array<Bool>;
    static var keyDownCallbacks:Map<Int, Array<Void->Void>>;

	/**
	 * Call to initialize the IO system. Must be called before any of it's properties can be accessed.
	 * @return [description]
	 */
	static public function init() {
        mousePos = new Point(0,0);
		keys = new Array<Bool>();
		for (i in 0...255) {
			keys[i] = false;
		}

        keyDownCallbacks = new Map<Int, Array<Void->Void>>();

        flash.Lib.current.addEventListener(flash.events.MouseEvent.MOUSE_MOVE, onMouseMove);
        flash.Lib.current.addEventListener(flash.events.MouseEvent.MOUSE_DOWN, onMouseDown);
        flash.Lib.current.addEventListener(flash.events.MouseEvent.RIGHT_MOUSE_DOWN, onRightMouseDown);
        flash.Lib.current.addEventListener(flash.events.MouseEvent.MOUSE_WHEEL, onMouseWheel);
        flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_DOWN, onKeyDown);
        flash.Lib.current.stage.addEventListener(flash.events.KeyboardEvent.KEY_UP, onKeyUp);
	}

    public static function addKeyDownCallback(key:Int, f:Void->Void):Void {
        if (keyDownCallbacks.get(key) == null) {
            keyDownCallbacks.set(key, new Array<Void->Void>());
        }
        keyDownCallbacks.get(key).push(f);
    }

    /**
     * Update the mouse coordinates.
     * @param  x screen x
     * @param  y screen y
     */
    static function updateMouse(x:Float, y:Float):Void {
        mousePos.setTo(x,y);
    }

    /**
     * Event handler for mouse move to keep track of mouse position.
     */
    static function onMouseMove(e:flash.events.MouseEvent):Void {
        updateMouse(e.stageX,e.stageY);
    }

    /**
     * Event handler for mouse down.
     */
    static function onMouseDown(e:flash.events.MouseEvent):Void {
        updateMouse(e.stageX,e.stageY);
    }

    /**
     * Event handler for right mouse down.
     */
    static function onRightMouseDown(e:flash.events.MouseEvent):Void {
        updateMouse(e.stageX,e.stageY);
    }

    /**
     * Event handler for mouse wheel.
     */
    static function onMouseWheel(e:flash.events.MouseEvent):Void {
        updateMouse(e.stageX,e.stageY);
    }

    /**
     * Event handler for key press.
     */
    static function onKeyDown(e:flash.events.KeyboardEvent):Void {
    	keys[e.keyCode] = true;

        if (keyDownCallbacks.get(e.keyCode) != null) {
            for (f in keyDownCallbacks.get(e.keyCode)) {
                f();
            }
        }
    }

    /**
     * Event handler for key release.
     */
    static function onKeyUp(e:flash.events.KeyboardEvent):Void {
    	keys[e.keyCode] = false;
    }
}