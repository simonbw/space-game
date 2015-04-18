Entity = require 'Entity'



class CameraController extends Entity

  constructor: (@camera, @person) ->

  render: () =>
    if @person.chair?
      pos = @person.chair.ship.position
      vel = @person.chair.ship.body.velocity
      @camera.smoothCenter(pos, vel)
      @camera.smoothZoom(15)
    else
      pos = @person.position
      vel = @person.body.velocity
      @camera.smoothCenter(pos, vel)
      @camera.smoothZoom(25)


module.exports = CameraController