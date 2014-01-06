library Life;

import 'dart:html';
import 'dart:async';
import 'dart:math';

part 'life_board.dart';
part 'life_engine.dart';
part 'cell.dart';
part 'pausable_timer.dart';

void main() {
  CanvasElement canvas = querySelector('#canvas');

  LifeBoard lifeBoard = new LifeBoard.empty(
      canvas,
      width: int.parse((querySelector('#gridWidthSlider') as RangeInputElement).value),
      height: int.parse((querySelector('#gridHeightSlider') as RangeInputElement).value),
      wrap: true
  );

  LifeEngine lifeEngine = new LifeEngine(lifeBoard);

  PausableTimer simulationTimer = new PausableTimer(
      new Duration(milliseconds: int.parse((querySelector('#simulationSpeedSlider') as RangeInputElement).value)),
      (Timer timer) {
        lifeEngine.tick();
      }
  )..cancel();

  void requestDraw() {
    window.animationFrame.then((_) {
      lifeBoard.draw();
      requestDraw();
    });
  }

  void setupEventListeners() {
    querySelector('#pauseButton').onClick.listen((Event e) {
      ButtonElement button = e.target;
      if (simulationTimer.toggle()) {
        button.text = "Pause";
      } else {
        button.text = "Start";
      }
    });

    querySelector('#simulationSpeedSlider').onChange.listen((Event e) {
      RangeInputElement simulationSpeedSlider = e.target;
      int newSimulationSpeed = int.parse(simulationSpeedSlider.value);
      querySelector('#simulationSpeedValue').text = newSimulationSpeed.toString();
      simulationTimer.setDuration(new Duration(milliseconds: newSimulationSpeed));
    });

    querySelector('#gridWidthSlider').onChange.listen((Event e) {
      RangeInputElement widthSlider = e.target;
      int newWidth = int.parse(widthSlider.value);
      querySelector('#widthValue').text = newWidth.toString();
      lifeBoard.width = newWidth;
    });

    querySelector('#gridHeightSlider').onChange.listen((Event e) {
      RangeInputElement heightSlider = e.target;
      int newHeight = int.parse(heightSlider.value);
      querySelector('#heightValue').text = newHeight.toString();
      lifeBoard.height = newHeight;
    });

    /* FIXME: The onClick event seems to be firing even when the mouse is moved between the mousedown and mouseup actions.
     * Not sure if this is a bug in Dart or intended, but it is interfering with the end of a drag event
     * where releasing the mouse to end the drag is also registering as a click at that location.
     */
    querySelector('#canvas').onClick.listen((MouseEvent e) {
      Cell clickedCell = lifeBoard.getCellByCanvasCoords(e.offsetX, e.offsetY);
      if (clickedCell is Cell) {
        clickedCell.toggle();
      }
    });

    querySelector('#canvas').onMouseDown.listen((MouseEvent mouseDownEvent) {
      CanvasElement canvas = mouseDownEvent.target;
      StreamSubscription moveSubscription;
      StreamSubscription mouseUpSubscription;
      Cell hoverCell;

      moveSubscription = canvas.onMouseMove.listen((MouseEvent moveEvent) {
        Cell targetCell = lifeBoard.getCellByCanvasCoords(moveEvent.offsetX, moveEvent.offsetY);
        if (targetCell is Cell && hoverCell != targetCell) {
          targetCell.toggle();
        }
        hoverCell = targetCell;
      });

      mouseUpSubscription = document.onMouseUp.listen((MouseEvent mouseUpEvent) {
        moveSubscription.cancel();
        mouseUpSubscription.cancel();
      });
    });

    querySelector('#clearButton').onClick.listen((Event e) {
      lifeBoard.clear();
    });

    querySelector('#randomButton').onClick.listen((Event e) {
      lifeBoard.randomize();
    });
  }

  setupEventListeners();
  requestDraw();
}