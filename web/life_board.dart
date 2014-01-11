part of Life;

typedef Cell CellGenerator(int x, int y);

class LifeBoard {
  CanvasElement canvas;
  CanvasRenderingContext2D canvasContext;
  int _width;
  int _height;
  bool wrap;
  List<List<Cell>> cells = [];
  num _cellDrawSize;
  Color gridColor = new Color.gray50();
  bool drawGrid;

  LifeBoard(CanvasElement this.canvas, {int width, int height, bool this.wrap:true, bool this.drawGrid:true, CellGenerator fillFunction}) {
    _width = width is int ? width : 20;
    _height = height is int ? height : 20;
    _cellDrawSize = calculateCellDrawSize();
    canvasContext = canvas.context2D;
    setCells(fillFunction is CellGenerator ? fillFunction : (x, y) => null);
  }

  LifeBoard.empty(CanvasElement canvas, {int width, int height, bool wrap, bool drawGrid}): this(
    canvas,
    width: width,
    height: height,
    wrap: wrap,
    drawGrid: drawGrid,
    fillFunction: (x, y) => new Cell.dead()
  );

  LifeBoard.random(CanvasElement canvas, {int width, int height, bool wrap, bool drawGrid}): this(
    canvas,
    width: width,
    height: height,
    wrap: wrap,
    drawGrid: drawGrid,
    fillFunction: (x, y) => new Cell.random()
  );

  void clear() {
    setCells((x, y) => getCell(x, y)..isAlive = false);
  }

  void randomize() {
    setCells((x, y) => getCell(x, y)..randomize());
  }

  invert() {
    setCells((x, y) => getCell(x, y)..toggle());
  }

  void setCells(CellGenerator fillFunction) {
    cells = createCellArray(fillFunction);
  }

  List<List<Cell>> createCellArray(CellGenerator fillFunction) {
    List<List<Cell>> array = new List(_width);
    for (int x = 0; x < _width; x++) {
      array[x] = new List(_height);
      for (int y = 0; y < _height; y++) {
        array[x][y] = fillFunction(x, y);
      }
    }
    return array;
  }

  get width => _width;
  get height => _height;

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

  bool toggleGrid() => drawGrid = !drawGrid;

  void draw() {
    canvasContext.clearRect(0, 0, canvas.width, canvas.height);
    for (int x = 0; x < _width; x++) {
      for (int y = 0; y < _height; y++) {
        Cell cell = getCell(x, y);
        if (cell is Cell){
          if (cell.isAlive) {
            canvasContext.setFillColorRgb(cell.liveColor.r, cell.liveColor.g, cell.liveColor.b);
          } else {
            canvasContext.setFillColorRgb(cell.deadColor.r, cell.deadColor.g, cell.deadColor.b);
          }
        }
        canvasContext.fillRect(x * _cellDrawSize, y * _cellDrawSize, _cellDrawSize, _cellDrawSize);
        if (drawGrid) {
          canvasContext.setStrokeColorRgb(gridColor.r, gridColor.g, gridColor.b);
          canvasContext.strokeRect(x * _cellDrawSize, y * _cellDrawSize, _cellDrawSize, _cellDrawSize);
        }
      }
    }
  }
}