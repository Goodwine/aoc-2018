import 'dart:collection';
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
  // Less than 50 probably works but I am hackingly setting a different target
  // which sets the coordinate as "rocky" affecting the finding algorithm.
  // This new tile should be put far away from the actual target but not too
  // far because otherwise it takes a long long time.
  var maxSize = Point(data.item2.x + 50, data.item2.y + 50);
  var grid = gridify(maxSize, data.item1);
  grid[data.item2.y][data.item2.x] = Tile.rocky;

  return DP(data.item2, maxSize, grid).navigate();
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

  int navigate() {
    Queue<Tuple3<Point, Tool, int>> queue = Queue.from([
      Tuple3(
        Point(0, 0),
        Tool.torch,
        0,
      )
    ]);

    int currMin = 1 << 62; // infinite-ish
    while (queue.isNotEmpty) {
      var args = queue.removeFirst();
      Point p = args.item1;
      Tool t = args.item2;
      int time = args.item3;

      var toolSet = allowed[grid[p.y][p.x]]!;
      if (!toolSet.contains(t)) continue; // invalid move
      if (p == target) {
        currMin = min(currMin, time + (t == Tool.torch ? 0 : 7));
        continue;
      }
      var dpk = Tuple2(p, t);
      if (dp[dpk] != null && time >= dp[dpk]!) continue; // there is a better path
      dp[dpk] = time;

      var theOtherTool = toolSet.where((v) => v != t).first;

      var next = directions
          .map(p.move)
          .where((n) => n.x >= 0)
          .where((n) => n.y >= 0)
          .where((n) => n.x <= maxSize.x)
          .where((n) => n.y <= maxSize.y);

      for (var n in next) {
        queue.add(Tuple3(n, t, time + 1));
        queue.add(Tuple3(n, theOtherTool, time + 8));
      }
    }
    return currMin;
  }
}
