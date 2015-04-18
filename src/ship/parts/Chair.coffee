InteractivePart = require 'ship/parts/InteractivePart'
Interior = require 'ship/parts/Interior'
p2 = require 'p2'
Pixi = require 'pixi.js'

class Chair extends InteractivePart
  color: 0x333333
  interior: true
  maxHealth: 250
  name: 'Chair'

  constructor: (pos) ->
    super(pos)
    @isOpen = false
    @timer = 0
    @person = null

  makeSprite: () =>
    sprite = new Pixi.Container()
    sprite.floor = new Pixi.Graphics()
    sprite.addChild(sprite.floor)
    sprite.chair = new Pixi.Graphics()
    sprite.addChild(sprite.chair)
    
    sprite.floor.beginFill(Interior.prototype.color)
    sprite.floor.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.floor.endFill()

    sprite.chair.beginFill(@color)
    w = @width * 0.6
    h = @height * 0.6
    sprite.chair.drawRect(-0.5 * w, -0.5 * h, w, h)
    sprite.chair.endFill()
    return sprite

  getSensorSize: () =>
    return [@width, @height]

  interact: (person) =>
    if not @person?
      person.enterChair(this)
      @person = person
    else
      if @person is person
        @person.leaveChair()
        @person = null
      else
        console.log "Chair Full"

module.exports = Chair