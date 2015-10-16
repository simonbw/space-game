# Manages
class IO
  @LMB = LMB = 0
  @RMB = RMB = 2
  @MMB = MMB = 1

  @ESCAPE = ESCAPE = 27
  @SPACE = SPACE = 32
  @ENTER = ENTER = 13
  @TAB = TAB = 9

  @LEFT_X = 0
  @LEFT_Y = 1
  @RIGHT_X = 2
  @RIGHT_Y = 3

  @B_A = 0
  @B_B = 1
  @B_X = 2
  @B_Y = 3

  @MOUSE_MOVE = MOUSE_MOVE = 'mousemove'
  @CLICK = CLICK = 'click'
  @RIGHT_CLICK = RIGHT_CLICK = 'rightclick'
  @RIGHT_UP = RIGHT_UP = 'rightup'
  @RIGHT_DOWN = RIGHT_DOWN = 'rightdown'
  @MOUSE_UP = MOUSE_UP = 'mouseup'
  @MOUSE_DOWN = MOUSE_DOWN = 'mousedown'
  @MOUSE_MOVE = MOUSE_MOVE = 'mousemove'
  @KEY_DOWN = KEY_DOWN = 'keydown'
  @KEY_UP = KEY_UP = 'keyup'
  @BUTTON_DOWN = BUTTON_DOWN = 'buttondown'
  @BUTTON_UP = BUTTON_UP = 'buttonup'

  constructor: (@view) ->
    @usingGamepad = false # True if the gamepad is the main input device
    @mousePosition = [0, 0]
    @mouseButtons = [false, false, false, false, false, false]

    @view.onclick = @click
    @view.onmousedown = @mousedown
    @view.onmouseup = @mouseup
    @view.onmousemove = @mousemove
    @view.onmousemove = @mousemove
    document.onkeydown = @keydown
    document.onkeyup = @keyup
    @view.oncontextmenu = (e) =>
      e.preventDefault()
      @click(e)
      false

    @keys = []
    for i in [0..256]
      @keys.push(false)

    @callbacks = {}
    @callbacks[CLICK] = []
    @callbacks[RIGHT_CLICK] = []
    @callbacks[RIGHT_UP] = []
    @callbacks[RIGHT_DOWN] = []
    @callbacks[MOUSE_UP] = []
    @callbacks[MOUSE_DOWN] = []
    @callbacks[MOUSE_MOVE] = []
    @callbacks[KEY_DOWN] = []
    @callbacks[KEY_UP] = []
    @callbacks[BUTTON_DOWN] = []
    @callbacks[BUTTON_UP] = []

    @lastButtons = [] # buttons pressed last frame. Used for checking differences in state.
    setInterval(@handleGamepads, 1)

  # Left Mouse Button
  @property 'lmb',
    get: ->
      return @mouseButtons[LMB]

  # Right Mouse Button
  @property 'rmb',
    get: ->
      return @mouseButtons[RMB]

  # Create events for gamepad button presses
  handleGamepads: () =>
    gamepad = navigator.getGamepads()[0]
    if gamepad?
      buttons = (button.pressed for button in gamepad.buttons)
      for button, i in buttons
        if button and !@lastButtons[i]
          @usingGamepad = true
          for callback in @callbacks[BUTTON_DOWN]
            callback(i)
        else if !button and @lastButtons[i]
          for callback in @callbacks[BUTTON_UP]
            callback(i)

      @lastButtons = buttons
    else
      @lastButtons = []


  # Add an event handler
  on: (e, callback) =>
    @callbacks[e] ?= []
    @callbacks[e].push(callback)

  # Remove an event handler
  off: (e, callback) =>
    @callbacks[e].splice(@callbacks[e].indexOf(callback), 1)

  # Update the position of the mouse
  mousemove: (e) =>
    @usingGamepad = false
    @mousePosition = [e.clientX, e.clientY]
    for callback in @callbacks[MOUSE_MOVE]
      callback(@mousePosition)

  # Call all click handlers
  click: (e) =>
    @usingGamepad = false
    @mousePosition = [e.clientX, e.clientY]
    switch e.button
      when LMB
        for callback in @callbacks[CLICK]
          callback(@mousePosition)
      when RMB
        for callback in @callbacks[RIGHT_CLICK]
          callback(@mousePosition)

  # Call all mousedown handlers
  mousedown: (e) =>
    @usingGamepad = false
    @mousePosition = [e.clientX, e.clientY]
    @mouseButtons[e.button] = true
    switch e.button
      when LMB
        for callback in @callbacks[MOUSE_UP]
          callback(@mousePosition)
      when RMB
        for callback in @callbacks[RIGHT_UP]
          callback(@mousePosition)

  # Call all mouseup handlers
  mouseup: (e) =>
    @usingGamepad = false
    @mousePosition = [e.clientX, e.clientY]
    @mouseButtons[e.button] = false
    switch e.button
      when LMB
        for callback in @callbacks[MOUSE_DOWN]
          callback(@mousePosition)
      when RMB
        for callback in @callbacks[RIGHT_DOWN]
          callback(@mousePosition)

  shouldPreventDefault: (key) =>
    if key is TAB
      return true
    if key is 83 # s for save
      return true
    return false

  # Handle key down
  keydown: (e) =>
    key = e.which
    wasPressed = @keys[key]
    @keys[key] = true
    if not wasPressed
      for callback in @callbacks[KEY_DOWN]
        callback(key)
    if @shouldPreventDefault(key)
      e.preventDefault()
      return false

  # Handle key up
  keyup: (e) =>
    key = e.which
    @keys[key] = false
    for callback in @callbacks[KEY_UP]
      callback(key)
    if @shouldPreventDefault(key)
      e.preventDefault()
      return false

  getAxis: (axis) =>
    gamepad = navigator.getGamepads()[0]
    if gamepad?
      axis = gamepad.axes[axis]
      if Math.abs(axis) > 0.1
        @usingGamepad = true
      return axis
    return 0

  getButton: (button) =>
    gamepad = navigator.getGamepads()[0]
    if gamepad?
      return gamepad.buttons[button]
    return 0

module.exports = IO