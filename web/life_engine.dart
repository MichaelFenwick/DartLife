part of Life;

class LifeEngine {
  LifeBoard lifeBoard;
  RuleSet ruleSet;

  LifeEngine(LifeBoard this.lifeBoard, RuleSet this.ruleSet) {
  }

  LifeEngine.conway(LifeBoard lifeBoard) : this(lifeBoard, new RuleSet.conway());

  LifeEngine.highLife(LifeBoard lifeBoard) : this(lifeBoard, new RuleSet.highLife());

  LifeEngine.lifeWithoutDeath(LifeBoard lifeBoard) : this(lifeBoard, new RuleSet.lifeWithoutDeath());

  LifeEngine.dayAndNight(LifeBoard lifeBoard) : this(lifeBoard, new RuleSet.dayAndNight());

  LifeEngine.seeds(LifeBoard lifeBoard) : this(lifeBoard, new RuleSet.seeds());

  void tick() {
    List<List<Cell>> newCells = lifeBoard.createCellArray((x, y) => null);
    for (int x = 0; x < lifeBoard.width; x++) {
      for (int y = 0; y < lifeBoard.height; y++) {
        Cell cell = lifeBoard.getCell(x, y);
        List<Cell> neighbors = getNeighbors(x, y);
        int neighborCount = neighbors.length;
        if (cell is Cell && cell.isAlive) {
          if (ruleSet.surviveRules.contains(neighborCount)) {
            newCells[x][y] = cell;
          } else {
            newCells[x][y] = new Cell.dead();
          }
        } else {
          if (ruleSet.birthRules.contains(neighborCount)) {
            newCells[x][y] = new Cell.fromParents(neighbors);
          } else {
            newCells[x][y] = new Cell.dead();
          }
        }
      }
    }
    lifeBoard.cells = newCells;
  }

  List<Cell> getNeighbors(x, y) {
    List<Cell> neighbors = [];
    for (int i = x - ruleSet.sightRange; i <= x + ruleSet.sightRange; i++) {
      for (int j = y - ruleSet.sightRange; j <= y + ruleSet.sightRange; j++) {
        if (!(x == i && y == j)) { //don't count the cell in question
          Cell cell = lifeBoard.getCell(i, j);
          if (cell is Cell && cell.isAlive) {
            neighbors.add(cell);
          }
        }
      }
    }

    return neighbors;
  }
}