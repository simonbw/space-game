import initPolyfills from './core/Polyfills';
initPolyfills();

import BlueprintEditor from './BlueprintEditor';
import CameraController from './controllers/CameraController';
import FPSCounter from './gameutil/FPSCounter';
import Game from './core/Game';
import Person from './Person';
import PlayerPersonController from './controllers/PlayerPersonController';
import Ship from './ship/Ship';
import * as Ships from './Ships';
import ShipHud from './hud/ShipHud';
import PersonHud from './hud/PersonHud';


window.addEventListener('load', () => {
  const game = new Game();
  window.game = game; // for debugging
  game.start();

  game.addEntity(new BlueprintEditor(Ships.starterShip(), (bp) => {
    const ship = new Ship(bp);
    const station = new Ship(Ships.simpleStation(), [0, -20]);
    game.addEntity(station);
    const person = new Person([0, 1]);
    person.board(ship);
    game.addEntity(new ShipHud(ship));
    game.addEntity(new PersonHud(person));
    game.addEntity(ship);
    game.addEntity(person);
    game.addEntity(new PlayerPersonController(person));
    game.addEntity(new CameraController(game.camera, person));
    game.addEntity(new FPSCounter());

    window.ship = ship;
    window.station = station;
  }));
});