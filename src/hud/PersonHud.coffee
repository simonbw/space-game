Entity = require 'Entity'
Pixi = require 'pixi.js'

# The hud drawn always
class PersonHud extends Entity
  constructor: (@person) ->
    @sprite = new Pixi.Container()
    @layer = 'hud'
    @text = new Pixi.Text('', {
      font: '14px Arial'
      fill: '#FFFFFF'
    })
    @sprite.addChild(@text)

  # Make the string to be displayed by the hud
  makeText: () =>
    room = @person.getRoom()
    if room?
      pressure = if room? then room.pressure else 0
      return "
        Pressure: #{Math.round(pressure * 100)}%,
        Sealed: #{room.sealed}
        id: #{room.roomId}"
    else
      return "Space"

  render: =>
    @text.text = @makeText()


module.exports = PersonHud