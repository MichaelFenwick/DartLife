library Life;

import 'dart:html';
import 'dart:async';
import 'dart:math';

part 'pausableTimer.dart';

void main() {
  bool runSimulation = false;
  PausableTimer simulationTimer;
  CanvasElement canvas = querySelector('#canvas');
  LifeBoard lifeBoard = new LifeBoard(
      canvas,
      width: int.parse((querySelector('#gridWidthSlider') as RangeInputElement).value),
      height: int.parse((querySelector('#gridHeightSlider') as RangeInputElement).value),
      wrap: true
  );

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

//TODO: Add the ability to toggle cells on or off via clicking or click + drag
//TODO: Add controls for things like random
//add a glider as an initial population
  lifeBoard.getCell(10, 10).isAlive = true;
  lifeBoard.getCell(10, 11).isAlive = true;
  lifeBoard.getCell(10, 12).isAlive = true;
  lifeBoard.getCell(11, 12).isAlive = true;
  lifeBoard.getCell(12, 11).isAlive = true;

  simulationTimer = new PausableTimer(new Duration(milliseconds: 50), (Timer timer) {
    lifeBoard.tick();
  })..cancel();

  void requestDraw() {
    window.animationFrame.then((_) {
      lifeBoard.draw();
      requestDraw();
    });
  }

  requestDraw();
}

class Cell {
  Map<String, int> liveColor = {'r': 0, 'g': 0, 'b': 127};
  Map<String, int> deadColor = {'r': 255, 'g': 255, 'b': 255};
  bool isAlive = false;

  Cell({bool this.isAlive: false}) {}
}

class LifeBoard {
  CanvasElement canvas;
  CanvasRenderingContext2D canvasContext;
  int _width;
  int _height;
  bool wrap;
  List<List<Cell>> cells = [];
  num _cellDrawSize;
  Map<String, int> gridColor = {'r': 127, 'g': 127, 'b': 127};

  //TODO: Allow these to be modified at time of construction, and maybe on the fly too.
  List<int> birthRules = [3];
  List<int> surviveRules = [2, 3];
  int sightRange = 1;

  LifeBoard(CanvasElement this.canvas, {int width:20, int height:20, bool this.wrap:true}) {
    _width = width;
    _height = height;
    _cellDrawSize = calculateCellDrawSize();
    cells = createCellArray(() => new Cell(isAlive: false));
    canvasContext = canvas.context2D;
  }

  set width(int width) {
    _width = width;
    _cellDrawSize = calculateCellDrawSize();
  }

  set height(int height) {
    _height = height;
    _cellDrawSize = calculateCellDrawSize();
  }

  num calculateCellDrawSize() {
    return min(canvas.width / _width, canvas.height / _height);
  }

  List<List<Cell>> createCellArray(Function fillFunction) {
    List<List<Cell>> array = new List(_width);
    for (int x = 0; x < _width; x++) {
      array[x] = new List(_height);
      for (int y = 0; y < _height; y++) {
        array[x][y] = fillFunction();
      }
    }
    return array;
  }

  void tick() {
    List<List<Cell>> newCells = createCellArray(() => null);
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        Cell cell = getCell(x, y);
        int neighborCount = countNeighbors(x, y);
        if (cell is Cell && cell.isAlive) {
          if (surviveRules.contains(neighborCount)) {
            newCells[x][y] = new Cell(isAlive: true);
          } else {
            newCells[x][y] = new Cell(isAlive: false);
          }
        } else {
          if (birthRules.contains(neighborCount)) {
            newCells[x][y] = new Cell(isAlive: true);
          } else {
            newCells[x][y] = new Cell(isAlive: false);
          }
        }
      }
    }
    cells = newCells;
  }

  int countNeighbors(x, y) {
    int count = 0;
    for (int i = x - sightRange; i <= x + sightRange; i++) {
      for (int j = y - sightRange; j <= y + sightRange; j++) {
        if (!(x == i && y == j)) { //don't count the cell in question
          Cell cell = getCell(i, j);
          if (cell is Cell && cell.isAlive) {
            count += 1;
          }
        }
      }
    }

    return count;
  }

  Cell getCell(x, y) {
    try {
      if (wrap) {
        x %= _width;
        y %= _height;
      }
      return cells[x][y];
    }
    on RangeError catch (e) {
      // If we don't wrap, it's possible to go out of the list bounds.  Return null if that happens (there is no cell there).
      return null;
    }
  }

  void draw() {
    canvasContext.clearRect(0, 0, canvas.width, canvas.height);
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        Cell cell = getCell(x, y);
        if (cell is Cell){
          if (cell.isAlive) {
            canvasContext.setFillColorRgb(cell.liveColor['r'], cell.liveColor['g'], cell.liveColor['b']);
          } else {
            canvasContext.setFillColorRgb(cell.deadColor['r'], cell.deadColor['g'], cell.deadColor['b']);
          }
        }
        canvasContext.fillRect(x * _cellDrawSize, y * _cellDrawSize, _cellDrawSize, _cellDrawSize);
        canvasContext.setStrokeColorRgb(gridColor['r'], gridColor['g'], gridColor['b']);
        canvasContext.strokeRect(x * _cellDrawSize, y * _cellDrawSize, _cellDrawSize, _cellDrawSize);
      }
    }
  }
}
