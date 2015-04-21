CollisionGroups = require 'CollisionGroups'
p2 = require 'p2'
Pixi = require 'pixi.js'
InteractivePart = require 'ship/parts/InteractivePart'
Interior = require 'ship/parts/Interior'

TIME = 60 * 10

class AirVent extends InteractivePart
  PRESSURIZE = 0
  OFF = 1
  DEPRESSURIZE = 2
  SPEED = 0.02

  color: 0xBBBBBB
  interior: true
  maxHealth: 250
  name: 'Air Vent'


  constructor: (pos) ->
    super(pos)
    @setState(OFF)

  # Called when a person interacts with this
  interact: (person) =>
    @setState switch @state
      when PRESSURIZE then DEPRESSURIZE
      when DEPRESSURIZE then OFF
      when OFF then PRESSURIZE

  setState: (state) =>
    @state = state
    @sprite.pressurizeLight.visible = (@state is PRESSURIZE)
    @sprite.depressurizeLight.visible = (@state is DEPRESSURIZE)

  makeSprite: () =>
    sprite = new Pixi.Container()
    sprite.floor = new Pixi.Graphics()
    sprite.addChild(sprite.floor)
    sprite.vent = new Pixi.Graphics()
    sprite.addChild(sprite.vent)
    sprite.pressurizeLight = new Pixi.Graphics()
    sprite.addChild(sprite.pressurizeLight)
    sprite.depressurizeLight = new Pixi.Graphics()
    sprite.addChild(sprite.depressurizeLight)
    
    sprite.floor.beginFill(Interior.prototype.color)
    sprite.floor.drawRect(-0.5 * @width, -0.5 * @height, @width, @height)
    sprite.floor.endFill()

    sprite.vent.beginFill(@color)
    w = @width * 0.8
    h = @height * 0.8
    sprite.vent.drawRect(-0.5 * w, -0.5 * h, w, h)
    sprite.vent.endFill()

    sprite.pressurizeLight.beginFill(0x00FF00)
    sprite.pressurizeLight.drawCircle(-0.35, -0.35, 0.08)
    sprite.pressurizeLight.endFill()

    sprite.depressurizeLight.beginFill(0xFF0000)
    sprite.depressurizeLight.drawCircle(-0.35, -0.35, 0.08)
    sprite.depressurizeLight.endFill()
    return sprite

  getSensorSize: () =>
    return [@width, @height]

  tick: () =>
    if @room?
      if @state is PRESSURIZE
        @room.giveAir(SPEED)
      else if @state is DEPRESSURIZE
        @room.giveAir(-SPEED)
      


module.exports = AirVent