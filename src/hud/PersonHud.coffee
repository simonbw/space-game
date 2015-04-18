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
    velocity = @person.body.velocity
    xspeed = Math.round(velocity[0] * 10)
    yspeed = Math.round(velocity[1] * 10)

    pressure = Math.round(100 * @person.getPressure())
    return "pressure: #{pressure}, velocity: <#{xspeed}, #{yspeed}>"
    

  render: =>
    @text.text = @makeText()


module.exports = PersonHud