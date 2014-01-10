part of Life;

class Color {
  final int r;
  final int g;
  final int b;

  Color(int this.r, int this.g, int this.b) {
  }

  Color.black() : this(0, 0, 0);
  Color.gray75() : this(195, 195, 195);
  Color.gray50() : this(127, 127, 127);
  Color.gray25() : this(63, 63, 63);
  Color.white() : this(255, 255, 255);
  Color.red() : this(204, 0, 0);
  Color.orange() : this(255, 136, 0);
  Color.yellow() : this(232, 232, 0);
  Color.green() : this(0, 153, 0);
  Color.blue() : this(0, 0, 153);
  Color.purple() : this(136, 0, 204);

  factory Color.byName(String colorName) {
    switch (colorName) {
      case 'black':
        return new Color.black();
      case 'gray75':
        return new Color.gray75();
      case 'gray50':
        return new Color.gray50();
      case 'gray25':
        return new Color.gray25();
      case 'white':
        return new Color.white();
      case 'red':
        return new Color.red();
      case 'orange':
        return new Color.orange();
      case 'yellow':
        return new Color.yellow();
      case 'green':
        return new Color.green();
      case 'blue':
        return new Color.blue();
      case 'purple':
        return new Color.purple();
      default:
        throw new Exception("Invalid colorName passed '$colorName' to Color.byName().");
    }
  }

  operator ==(Color o) => r == o.r && g == o.g && b == o.b;
}