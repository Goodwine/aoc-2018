import 'package:aoc2018/aoc.dart';

void main() {
  solve<int, Iterable<Instruction>>(
    (String path) async => (await read(path)).map(Instruction.parse),
    part1,
    (v) => part2(v) + 1,
  );
}

int part1(Iterable<Instruction> data) => data
    .fold<Grid>(Grid(), (grid, v) => grid..insert(v))
    .grid
    .expand((v) => v)
    .where((v) => v >= 2)
    .length;

int part2(Iterable<Instruction> data) {
  var grid = data.fold<Grid>(Grid(), (grid, v) => grid..insert(v));
  return data.takeWhile((ins) {
    for (var j = ins.y; j < ins.maxY; j++) {
      for (var i = ins.x; i < ins.maxX; i++) {
        if (grid.grid[j][i] > 1) return true;
      }
    }
    return false;
  }).length;
}

const maxGridSize = 1020;

class Grid {
  List<List<int>> grid = List.generate(
    maxGridSize,
    (_) => List.filled(maxGridSize, 0, growable: false),
    growable: false,
  );

  void insert(Instruction ins) {
    for (var j = ins.y; j < ins.maxY; j++) {
      for (var i = ins.x; i < ins.maxX; i++) {
        grid[j][i]++;
      }
    }
  }
}

class Instruction {
  int x;
  int y;
  int height;
  int width;

  Instruction(this.x, this.y, this.width, this.height);

  // #2 @ 3,1: 4x4
  static Instruction parse(String line) {
    var parts = line.split("@ ")[1].split(": ");
    var coords = parts[0].split(",").map(int.parse).toList(growable: false);
    var size = parts[1].split("x").map(int.parse).toList(growable: false);
    return Instruction(coords[0], coords[1], size[0], size[1]);
  }

  get maxX => x + width;
  get maxY => y + height;
}
