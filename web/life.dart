library Life;

import 'dart:html';
import 'dart:async';
import 'dart:math';

void main() {
  CanvasElement canvas = querySelector('#canvas');
  LifeBoard lifeBoard = new LifeBoard(canvas, width: 25, height: 25, wrap: true);

//TODO: Add the ability to toggle cells on or off via clicking or click + drag
//TODO: Add controls for things like random
//add a glider as an initial population
  lifeBoard.getCell(10, 10).isAlive = true;
  lifeBoard.getCell(10, 11).isAlive = true;
  lifeBoard.getCell(10, 12).isAlive = true;
  lifeBoard.getCell(11, 12).isAlive = true;
  lifeBoard.getCell(12, 11).isAlive = true;

//TODO: Add a control to adjust the speed of the ticks
  new Timer.periodic(new Duration(milliseconds: 50), (Timer timer) {
    lifeBoard.tick();
  });

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
  int width;
  int height;
  bool wrap;
  List<List<Cell>> cells = [];
  num _cellDrawSize;

  //TODO: Allow these to be modified at time of construction, and maybe on the fly too.
  List<int> birthRules = [3];
  List<int> surviveRules = [2, 3];
  int sightRange = 1;

  LifeBoard(CanvasElement this.canvas, {int this.width:20, int this.height:20, bool this.wrap:true}) {
    cells = createCellArray(() => new Cell(isAlive: false));
    _cellDrawSize = calculateCellDrawSize();
    canvasContext = canvas.context2D;
  }

  num calculateCellDrawSize() {
    return min(canvas.width / width, canvas.height / height);
  }

  List<List<Cell>> createCellArray(Function fillFunction) {
    List<List<Cell>> array = new List(width);
    for (int x = 0; x < width; x++) {
      array[x] = new List(height);
      for (int y = 0; y < height; y++) {
        array[x][y] = fillFunction();
      }
    }
    return array;
  }

  void tick() {
    List<List<Cell>> newCells = createCellArray(() => null);
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        Cell cell = getCell(x, y);
        int neighborCount = countNeighbors(x, y);
        if (cell.isAlive) {
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
        if (!(x == i && y == j)) {
//don't count the cell in question
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
        x %= width;
        y %= height;
      }
      return cells[x][y];
    }
    on RangeError catch (e) {
// If we don't wrap, it's possible to go out of the list bounds.  Return null if that happens (there is no cell there).
      return null;
    }
  }

  void draw() {
    for (int x = 0; x < width; x++) {
      for (int y = 0; y < height; y++) {
        Cell cell = getCell(x, y);
        if (cell.isAlive) {
          canvasContext.setFillColorRgb(cell.liveColor['r'], cell.liveColor['g'], cell.liveColor['b']);
        } else {
          canvasContext.setFillColorRgb(cell.deadColor['r'], cell.deadColor['g'], cell.deadColor['b']);
        }
        canvasContext.fillRect(x * _cellDrawSize, y * _cellDrawSize, _cellDrawSize, _cellDrawSize);
      }
    }
  }
}
