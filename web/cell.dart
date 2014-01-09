part of Life;

class Cell {
  Map<String, int> liveColor = new Color.blue();
  Map<String, int> deadColor = new Color.white();
  bool isAlive = false;

  Cell({bool this.isAlive}) {}

  Cell.dead() : this(isAlive: false);

  Cell.alive() : this(isAlive: true);

  Cell.random() : this(isAlive: (new Random()).nextBool());

  bool toggle() => isAlive = !isAlive;

  bool randomize() => isAlive = (new Random()).nextBool();
}