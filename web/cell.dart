part of Life;

class Cell {
  Map<String, int> liveColor = {'r': 0, 'g': 0, 'b': 127};
  Map<String, int> deadColor = {'r': 255, 'g': 255, 'b': 255};
  bool isAlive = false;

  Cell({bool this.isAlive}) {}

  Cell.dead() : this(isAlive: false);

  Cell.alive() : this(isAlive: true);

  Cell.random() : this(isAlive: (() {
    Random rand = new Random();
    return rand.nextBool();
  })());

  bool toggle() {
    return isAlive = !isAlive;
  }
}