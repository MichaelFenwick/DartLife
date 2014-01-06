part of Life;

class LifeEngine {
  LifeBoard lifeBoard;
  List<int> birthRules;
  List<int> surviveRules;
  int sightRange;

  LifeEngine(LifeBoard this.lifeBoard, {List<int> this.birthRules, List<int> this.surviveRules, int this.sightRange}) {
    birthRules = [3];
    surviveRules = [2, 3];
    sightRange = 1;
  }

  void tick() {
    List<List<Cell>> newCells = lifeBoard.createCellArray((x, y) => null);
    for (int x = 0; x < lifeBoard.width; x++) {
      for (int y = 0; y < lifeBoard.height; y++) {
        Cell cell = lifeBoard.getCell(x, y);
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
    lifeBoard.cells = newCells;
  }

  int countNeighbors(x, y) {
    int count = 0;
    for (int i = x - sightRange; i <= x + sightRange; i++) {
      for (int j = y - sightRange; j <= y + sightRange; j++) {
        if (!(x == i && y == j)) { //don't count the cell in question
          Cell cell = lifeBoard.getCell(i, j);
          if (cell is Cell && cell.isAlive) {
            count += 1;
          }
        }
      }
    }

    return count;
  }

}