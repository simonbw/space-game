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
    return "pressure: #{Math.round(100 * @person.getPressure())}"
    

  render: =>
    @text.text = @makeText()


module.exports = PersonHud