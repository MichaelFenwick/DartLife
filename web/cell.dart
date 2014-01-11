part of Life;

class Cell {
  Color liveColor;
  Color deadColor;
  bool isAlive;

  Cell({bool this.isAlive: false, Color this.liveColor, Color this.deadColor}) {
    liveColor = liveColor is Color ? liveColor : getActiveColor();
    deadColor = deadColor is Color ? deadColor : new Color.white();
  }

  Cell.dead() : this(isAlive: false);

  Cell.alive() : this(isAlive: true);

  Cell.random() : this(isAlive: (new Random()).nextBool());

  Cell.fromParents(List<Cell> parents) {
    List<Color> popularColors = [];
    Map<Color, int> colorFrequency = {};

    if (parents.length > 0) {
      parents.forEach((parent) {
        Color colorKey = colorFrequency.keys.firstWhere(
            (Color color) => parent.liveColor == color,
            orElse: () => parent.liveColor
        );
        if (colorFrequency[colorKey] == null) {
          colorFrequency[colorKey] = 0;
        }
        colorFrequency[colorKey] += 1;
      });

      int topFrequency = colorFrequency.values.reduce(max);

      colorFrequency.forEach((color, frequency) {
        if (frequency == topFrequency) {
          popularColors.add(color);
        }
      });
      this.liveColor = popularColors[(new Random()).nextInt(popularColors.length)];
    } else {
      this.liveColor = getActiveColor();
    }

    this.deadColor = new Color.white();
    this.isAlive = true;
  }

  bool toggle() {
    if (!isAlive) {
      liveColor = getActiveColor();
    };
    isAlive = !isAlive;
  }

  bool randomize() {
    liveColor = getActiveColor();
    return isAlive = (new Random()).nextBool();
  }
}