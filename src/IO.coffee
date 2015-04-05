
# Manages 
class IO
  @LMB = LMB = 0
  @RMB = RMB = 2
  @MMB = MMB = 1

  @ESCAPE = 27
  @SPACE = 32

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

  constructor: (@view) ->
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

    @mousePosition = [0, 0]

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

    @buttons = [false, false, false, false, false ,false]

  # Add an event handler
  on: (e, callback) =>
    @callbacks[e] ?= []
    @callbacks[e].push(callback)

  # Remove an event handler
  off: (e, callback) =>
    @callbacks[e].splice(@callbacks[e].indexOf(callback), 1)

  # Update the position of the mouse
  mousemove: (e) =>
    @mousePosition = [e.clientX, e.clientY]
    for callback in @callbacks[MOUSE_MOVE]
      callback(@mousePosition)

  # Call all click handlers
  click: (e) =>
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
    @mousePosition = [e.clientX, e.clientY]
    @buttons[e.button] = true
    switch e.button
      when LMB
        for callback in @callbacks[MOUSE_UP]
          callback(@mousePosition)
      when RMB
        for callback in @callbacks[RIGHT_UP]
          callback(@mousePosition)

  # Call all mouseup handlers
  mouseup: (e) =>
    @mousePosition = [e.clientX, e.clientY]
    @buttons[e.button] = false
    switch e.button
      when LMB
        for callback in @callbacks[MOUSE_DOWN]
          callback(@mousePosition)
      when RMB
        for callback in @callbacks[RIGHT_DOWN]
          callback(@mousePosition)

  # Handle key down
  keydown: (e) =>
    key = e.which
    wasPressed = @keys[key]
    @keys[key] = true
    if not wasPressed
      for callback in @callbacks[KEY_DOWN]
        callback(key)

  # Handle key up
  keyup: (e) =>
    key = e.which
    @keys[key] = false
    for callback in @callbacks[KEY_UP]
      callback(key)


module.exports = IO