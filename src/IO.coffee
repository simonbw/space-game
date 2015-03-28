''

class IO
  LMB = 0
  RMB = 2
  MMB = 1

  constructor: (@view) ->
    @view.onclick = @click
    @view.onmousedown = @mousedown
    @view.onmouseup = @mouseup
    @view.onmousemove = @mousemove
    @view.onmousemove = @mousemove
    @view.oncontextmenu = (e) =>
      e.preventDefault()
      @click(e)
      false

    @mousePosition = [0, 0]

    @callbacks = {
      click: []
      mouseup: []
      mousedown: []
      mousemove: []
      rightup: []
      rightdown: []
      rightclick: []
    }

  # Add an event handler
  on: (e, callback) =>
    @callbacks[e].push(callback)

  # Remove an event handler
  off: (e, callback) =>
    @callbacks[e].splice(@callbacks[e].indexOf(callback), 1)

  # Update the position of the mouse
  mousemove: (e) =>
    @mousePosition = [e.clientX, e.clientY]
    for callback in @callbacks['mousemove']
      callback(@mousePosition)

  # Call all click handlers
  click: (e) =>
    switch e.button
      when LMB
        @mousePosition = [e.clientX, e.clientY]
        for callback in @callbacks['click']
          callback(@mousePosition)
      when RMB
        @mousePosition = [e.clientX, e.clientY]
        for callback in @callbacks['rightclick']
          callback(@mousePosition)

  # Call all mousedown handlers
  mousedown: (e) =>
    switch e.button
      when LMB
        @mousePosition = [e.clientX, e.clientY]
        for callback in @callbacks['mouseup']
          callback(@mousePosition)
      when RMB
        @mousePosition = [e.clientX, e.clientY]
        for callback in @callbacks['rightup']
          callback(@mousePosition)

  # Call all mouseup handlers
  mouseup: (e) =>
    switch e.button
      when LMB
        @mousePosition = [e.clientX, e.clientY]
        for callback in @callbacks['mousedown']
          callback(@mousePosition)
      when RMB
        @mousePosition = [e.clientX, e.clientY]
        for callback in @callbacks['rightdown']
          callback(@mousePosition)


module.exports = IO