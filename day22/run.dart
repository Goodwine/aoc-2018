import 'dart:math';

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

int part1(Tuple2<int, Point> data) => gridify(data.item2, data.item1)
    .expand((e) => e)
    .map((e) => e.index)
    .reduce((acc, v) => acc + v);

int erosion(int v, int d) => ((v % modulo) + d) % modulo;

List<List<Tile>> gridify(Point target, int depth) {
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
    for (var row in grid) [for (var cell in row) Tile.values[cell % 3]]
  ];
}

int part2(Tuple2<int, Point> data) {
  var maxSize = Point(data.item2.x + 10, data.item2.y + 10);
  var grid = gridify(maxSize, data.item1);
  grid[data.item2.y][data.item2.x] = Tile.rocky;

  return DP(data.item2, maxSize, grid).navigate(Point(0, 0), Tool.gear, 1);
}

enum Tile { rocky, wet, narrow }

enum Tool { gear, torch, none }

const allowed = {
  Tile.rocky: {Tool.gear, Tool.torch},
  Tile.wet: {Tool.gear, Tool.none},
  Tile.narrow: {Tool.torch, Tool.none},
};

typedef DPKey = Tuple2<Point, Tool>;

class DP {
  List<List<Tile>> grid;
  Point target;
  Point maxSize;
  Map<DPKey, int> dp = {};

  DP(this.target, this.maxSize, this.grid);

  int navigate(Point p, Tool t, int time) {
    var toolSet = allowed[grid[p.y][p.x]]!;
    if (!toolSet.contains(t)) {
      return 1 << 62; // infinite-ish
    }
    if (p == target) {
      return time + (t == Tool.torch ? 1 : 7);
    }
    var dpk = Tuple2(p, t);
    if (dp[dpk] != null && time >= dp[dpk]!) {
      return 1 << 62; // infinite-ish
    }
    dp[dpk] = time;

    var theOtherTool = toolSet.where((v) => v != t).first;

    // Had to split because I am getting StackOverflow
    var next = directions
        .map(p.move)
        .where((n) => n.x >= 0)
        .where((n) => n.y >= 0)
        .where((n) => n.x <= maxSize.x)
        .where((n) => n.y <= maxSize.y)
        .toList();

    var currMin = 1 << 62; // infinite-ish
    for (var n in next) {
      // Had to split because I am getting StackOverflow
      var sameTool = navigate(n, t, time + 1);
      var otherTool = navigate(n, theOtherTool, time + 8);
      currMin = [sameTool, otherTool, currMin].reduce(min);
    }
    return currMin;
  }
}
