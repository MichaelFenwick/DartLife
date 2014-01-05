library Life;

import 'dart:html';
import 'dart:async';

void main() {
  CanvasElement canvas = querySelector('#canvas');
  LifeBoard lifeBoard = new LifeBoard(canvas, width: 20, height: 20, wrap: true);

  //add a glider as an initial population
  lifeBoard.getCell(10,10).isAlive = true;
  lifeBoard.getCell(10,11).isAlive = true;
  lifeBoard.getCell(10,12).isAlive = true;
  lifeBoard.getCell(11,12).isAlive = true;
  lifeBoard.getCell(12,11).isAlive = true;

  //TODO: Add a control to adjust the speed of the ticks
  new Timer.periodic(new Duration(milliseconds: 500), (Timer timer) {
    lifeBoard.draw();
    lifeBoard.tick();
  });

  //TODO: Add a requestAnimationFrame loop that calls lifeBoard.draw()
}


class Cell {
  bool isAlive = false;

  Cell({bool this.isAlive: false}) {}
}

class LifeBoard {
  CanvasElement canvas;
  int width;
  int height;
  bool wrap;
  List<List<Cell>> cells = [];

  //TODO: Allow these to be modified at time of construction, and maybe on the fly too.
  List<int> birthRules = [3];
  List<int> surviveRules = [2, 3];
  int sightRange = 1;


  LifeBoard(CanvasElement this.canvas, {int this.width:20, int this.height:20, bool this.wrap:true}) {
    cells = createCellArray(() => new Cell(isAlive: false));
  }

  List<List<Cell>> createCellArray(fillFunction) {
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
        x %= width;
        y %= height;
      }
      return cells[x][y];
    } on RangeError catch (e) {
      // If we don't wrap, it's possible to go out of the list bounds.  Return null if that happens (there is no cell there).
      return null;
    }
  }

  void draw() {
    for (int x = 0; x < width; x++) {
      StringBuffer string = new StringBuffer();
      for (int y = 0; y < height; y++) {
        if (getCell(x, y).isAlive) {
          string.write('[x]');
        } else {
          string.write('[ ]');
        }
      }
      print(string.toString());
    }
    print('');
    print('');
    print('');
  }
}
