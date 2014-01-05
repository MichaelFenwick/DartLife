library Life;

import 'dart:html';
import 'dart:async';
import 'dart:math';

part 'pausableTimer.dart';

void main() {
  bool runSimulation = false;
  PausableTimer simulationTimer;
  CanvasElement canvas = querySelector('#canvas');

  LifeBoard lifeBoard = new LifeBoard.empty(
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
    lifeBoard = new LifeBoard.empty(
      lifeBoard.canvas,
      width: lifeBoard.width,
      height: lifeBoard.height,
      wrap: lifeBoard.wrap
    );
  });

  querySelector('#randomButton').onClick.listen((Event e) {
    lifeBoard = new LifeBoard.random(
      lifeBoard.canvas,
      width: lifeBoard.width,
      height: lifeBoard.height,
      wrap: lifeBoard.wrap
    );
  });

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

  bool toggle() {
    return isAlive = !isAlive;
  }
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

  LifeBoard(CanvasElement this.canvas, {int width:20, int height:20, bool this.wrap:true, Function fillFunction}) {
    _width = width;
    _height = height;
    _cellDrawSize = calculateCellDrawSize();
    cells = createCellArray(fillFunction is Function ? fillFunction : () => null);
    canvasContext = canvas.context2D;
  }

  LifeBoard.empty(CanvasElement canvas, {int width:20, int height:20, bool wrap:true}): this(
      canvas,
      width: width,
      height: height,
      wrap: wrap,
      fillFunction: () => new Cell(isAlive: false)
  );

  LifeBoard.random(CanvasElement canvas, {int width:20, int height:20, bool wrap:true}): this(
      canvas,
      width: width,
      height: height,
      wrap: wrap,
      fillFunction: () => new Cell(isAlive: (() {
        Random rand = new Random();
        return rand.nextBool();
      })())
  );

  set width(int width) {
    _width = width;
    _cellDrawSize = calculateCellDrawSize();
  }

  set height(int height) {
    _height = height;
    _cellDrawSize = calculateCellDrawSize();
  }

  get width => _width;
  get height => _height;

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

  Cell getCellByCanvasCoords(x, y) {
    return getCell(
        (x / _cellDrawSize).floor(),
        (y / _cellDrawSize).floor()
    );
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
