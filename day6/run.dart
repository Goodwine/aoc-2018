import 'dart:math';

import 'package:aoc2018/aoc.dart';

void main() {
  solve(
    readPoints,
    part1,
    part2,
  );
}

Future<List<Point>> readPoints(String path) async => (await read(path))
    .map((line) => line.split(", ").map(int.parse))
    .toList()
    .asMap()
    .entries
    .map((e) => Point(e.value.first, e.value.last, e.key + 1))
    .toList();

class Voronoi {
  late List<List<int?>> grid;

  Voronoi.from(Iterable<Point> points) {
    // Minimize plane by reducing coordinates absolute value.
    var minX = points.map((p) => p.x).reduce(min);
    var minY = points.map((p) => p.x).reduce(min);
    points = points.map((p) => Point(p.x - minX, p.y - minY, p.id));

    // Adjust grid size to coordinates
    var maxSize = points.map((p) => p.x > p.y ? p.x : p.y).reduce(max) + 1;
    grid = List.generate(
      maxSize,
      (_) => List.filled(maxSize, null),
      growable: false,
    );

    // Slowly grow points a-la voronoi.
    while (points.isNotEmpty) {
      for (var p in points) {
        if (grid[p.y][p.x] == p.id) continue;
        grid[p.y][p.x] = grid[p.y][p.x] == null ? p.id : -1;
      }

      points = points
          .expand((p) => p.next(grid.length))
          .where((p) => grid[p.y][p.x] == null)
          .fold<Map<int, List<Point>>>(Map(), (acc, p) {
            // Group points by (x,y) pairs
            var key = p.x + p.y * grid.length;
            return acc
              ..putIfAbsent(key, () => [])
              ..update(key, (c) => c..add(p));
          })
          .entries
          .map((e) => e.value)
          .map((e) {
            // Deduplicate points, if different IDs return a -1
            if (e.length == 1) return e[0];
            var ids = e.map((p) => p.id).toSet();
            if (ids.length == 1) return e[0];
            return Point(e[0].x, e[0].y, -1);
          });
    }
  }
}

const pointsAround = [
  // -1s
  // Point(-1, -1),
  Point(-1, 0),
  // Point(-1, 1),
  // 0s
  Point(0, -1),
  Point(0, 1),
  // 1s
  // Point(1, -1),
  Point(1, 0),
  // Point(1, 1),
];

class Point {
  final int x, y, id;
  const Point(this.x, this.y, [this.id = -1]);

  Iterable<Point> next(int maxSize) => pointsAround
      .map((that) => Point(this.x + that.x, this.y + that.y, this.id))
      .where((p) => p.x >= 0 && p.y >= 0 && p.x < maxSize && p.y < maxSize);

  int distance(Point p) => (p.x - x).abs() + (p.y - y).abs();

  String toString() => "(ID=$id)[x:$x,y:$y]";

  @override
  operator ==(that) => that is Point && that.x == x && that.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

int part1(List<Point> data) {
  var voronoi = Voronoi.from(data);

  var exclude = voronoi.grid.first
      .followedBy(voronoi.grid.last)
      .followedBy(
          voronoi.grid.skip(1).take(voronoi.grid.length - 1).expand((e) => [e.first, e.last]))
      .toSet();

  var areas = voronoi.grid.expand((e) => e).where((e) => !exclude.contains(e)).fold<Map<int, int>>(
      Map(),
      (acc, v) => acc
        ..putIfAbsent(v!, () => 0)
        ..update(v, (c) => c + 1));

  return areas.entries.map((e) => e.value).reduce(max);
}

int part2(List<Point> data) {
  var threshold = data.length < 10 ? 32 : 10000;

  var seed = data.firstWhere((p) => underThreshold(p, data, threshold));

  Set<Point> area = {};
  Iterable<Point> points = [seed];
  while (points.isNotEmpty) {
    area.addAll(points);
    points = points
        .expand((p) => p.next(10000))
        .toSet()
        .where((p) => !area.contains(p))
        .where((p) => underThreshold(p, data, threshold))
        .toList();
  }

  return area.length;
}

bool underThreshold(Point p, List<Point> data, int threshold) =>
    data.map(p.distance).reduce((acc, v) => acc + v) < threshold;
