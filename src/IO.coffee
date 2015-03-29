
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

  constructor: (@view) ->
    @view.onclick = @click
    @view.onmousedown = @mousedown
    @view.onmouseup = @mouseup
    @view.onmousemove = @mousemove
    @view.onmousemove = @mousemove
    document.onkeydown = @keydown
    @view.oncontextmenu = (e) =>
      e.preventDefault()
      @click(e)
      false

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
    switch e.button
      when LMB
        for callback in @callbacks[MOUSE_DOWN]
          callback(@mousePosition)
      when RMB
        for callback in @callbacks[RIGHT_DOWN]
          callback(@mousePosition)

  keydown: (e) =>
    for callback in @callbacks[KEY_DOWN]
      callback(e.which)


module.exports = IO