Entity = require 'Entity'
Pixi = require 'pixi.js'

# The HUD drawn while in a ship
class ShipHud extends Entity
  constructor: (@ship) ->
    @sprite = new Pixi.Container()
    @layer = 'hud'
    @text = new Pixi.Text('', {
      font: '14px Arial'
      fill: '#FFFFFF'
    })
    @text.y = 18
    @sprite.addChild(@text)

  # Make the string to be displayed by the hud
  makeText: () =>
    velocity = @ship.body.velocity
    xspeed = Math.round(velocity[0])
    yspeed = Math.round(velocity[1])
    return "Velocity: <#{xspeed}, #{yspeed}>"

  render: =>
    @text.text = @makeText()

module.exports = ShipHud