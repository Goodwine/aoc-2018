import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (path) async {
      var lines = (await read(path));
      var depth = int.parse(lines[0].split(": ")[1]);
      var target = lines[1].split(": ")[1].split(",").map(int.parse).toList();
      return Tuple2(depth, Point(target[0], target[1]));
    },
    part1,
    part2,
  );
}

const modulo = 20183;
const xIncrement = 16807;
const yIncrement = 48271;

int part1(Tuple2<int, Point> data) =>
    gridify(data.item2, data.item1).expand((e) => e).reduce((acc, v) => acc + v);

int erosion(int v, int d) => ((v % modulo) + d) % modulo;

int part2(Tuple2<int, Point> data) => 0;

List<List<int>> gridify(Point target, int depth) {
  var grid = List.generate(target.y + 1, (_) => List.filled(target.x + 1, 0));

  for (int y = 0; y < grid.length; y++) {
    grid[y][0] = erosion(y * yIncrement, depth);
  }
  for (int x = 1; x < grid[0].length; x++) {
    grid[0][x] = erosion(x * xIncrement, depth);
    for (var y = 1; y < grid.length; y++) {
      grid[y][x] = erosion(grid[y - 1][x] * grid[y][x - 1], depth);
    }
  }

  grid.last.last = 0; // 🤔 🤷🏽‍♂️

  return [
    for (var row in grid) [for (var cell in row) cell % 3]
  ];
}
