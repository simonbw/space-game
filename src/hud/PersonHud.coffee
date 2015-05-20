Entity = require 'core/Entity'
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
    @interactionList = new InteractionListSprite(@person)

  added: () =>
    @game.addEntity(@interactionList)

  # Make the string to be displayed by the hud
  makeText: () =>
    velocity = @person.body.velocity
    xspeed = Math.round(velocity[0] * 10)
    yspeed = Math.round(velocity[1] * 10)

    pressure = Math.round(100 * @person.getPressure())
    return "pressure: #{pressure}, velocity: <#{xspeed}, #{yspeed}>"
    
  render: =>
    @interactionList.person = @person
    @text.text = @makeText()

  destroy: () =>
    @interactionList.destroy()
    super()


class InteractionListSprite extends Entity
  HEIGHT = 15

  constructor: (@person) ->
    @sprite = new Pixi.Container()
    @layer = 'hud'
    @texts = []

  makeTextBox: () =>
    console.log "New new textbox #{@texts.length}"
    size = if @texts.length is 0 then 16 else 12
    text = new Pixi.Text('', {
      font: "#{size}px Arial"
      fill: '#FFFFFF'
    })
    text.y = @texts.length * HEIGHT
    @texts.push(text)
    @sprite.addChild(text)

  render: () =>
    # make sure there are the right number of text boxes
    while @texts.length > @person.interactions.length
      @sprite.removeChild(@texts.pop())
    while @texts.length < @person.interactions.length
      @makeTextBox()

    for part, i in @person.interactions
      @texts[i].text = "#{part.name}"
    
    [x, y] = @game.camera.toScreen(@person.position)
    @sprite.x = x + 20
    @sprite.y = y - @texts.length * HEIGHT / 2

module.exports = PersonHud