class Tile {
   dynamic number; // Can be int or String
  String colorName; // String representing the color name

  Tile(this.number, this.colorName);

  factory Tile.fromJson(List<dynamic> json) {
    return Tile(
      json[0],
      json[1],
    );
  }
}
