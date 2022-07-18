import 'dart:math';

import 'package:aoc2018/aoc.dart';
import 'package:collection/collection.dart';

void main() {
  solve(
    (path) async => (await read(path)).map((v) => v.split(", ")).map((parts) {
      var coordinates = parts[0]
          .substring("pos=<".length, parts[0].length - 1)
          .split(",")
          .map(int.parse)
          .toList();
      var range = int.parse(parts[1].substring("r=".length));
      return Robot(P3(coordinates[0], coordinates[1], coordinates[2]), range);
    }).toList(),
    part1,
    part2,
    extra: "medium",
  );
}

class Robot {
  final P3 p;
  final int range;
  const Robot(this.p, this.range);

  bool overlap(Rectangle r) {
    var closest = P3(
      min(max(r.a.x, p.x), r.b.x),
      min(max(r.a.y, p.y), r.b.y),
      min(max(r.a.z, p.z), r.b.z),
    );

    return closest.dist(p) <= range;
  }
}

class P3 {
  final int x, y, z;
  const P3(this.x, this.y, this.z);
  int dist(P3 b) => (x - b.x).abs() + (y - b.y).abs() + (z - b.z).abs();

  @override
  bool operator ==(Object b) => b is P3 && x == b.x && y == b.y && z == b.z;

  @override
  int get hashCode => Object.hash(x, y, z);

  @override
  String toString() => "$x,$y,$z";
}

int part1(List<Robot> data) {
  var strongest = data.reduce((m, v) => v.range > m.range ? v : m);
  return data.map((e) => strongest.p.dist(e.p)).where((d) => d <= strongest.range).length;
}

const zero = P3(0, 0, 0);

class Rectangle {
  /// point a is closest to positive infinity, point b is closest from negative infinity
  final P3 a, b;

  Rectangle._(this.a, this.b);

  factory Rectangle(P3 a, P3 b) => Rectangle._(
        P3(min(a.x, b.x), min(a.y, b.y), min(a.z, b.z)),
        P3(max(a.x, b.x), max(a.y, b.y), max(a.z, b.z)),
      );

  bool get isPoint => a == b;

  Set<Rectangle> split() {
    var mid = P3(
      (a.x + b.x) ~/ 2,
      (a.y + b.y) ~/ 2,
      (a.z + b.z) ~/ 2,
    );

    return {
      // A plane (see Z)
      Rectangle(mid, a),
      Rectangle(mid, P3(a.x, b.y, a.z)),
      Rectangle(mid, P3(b.x, a.y, a.z)),
      Rectangle(mid, P3(b.x, b.y, a.z)),
      // B plane (see Z)
      Rectangle(mid, b),
      Rectangle(mid, P3(a.x, b.y, b.z)),
      Rectangle(mid, P3(b.x, a.y, b.z)),
      Rectangle(mid, P3(a.x, a.y, b.z)),
    }..remove(this);
  }

  int _memoInRange = -1;
  int inRange(List<Robot> robots) {
    if (_memoInRange != -1) return _memoInRange;

    var result = robots.where((e) => e.overlap(this)).length;

    _memoInRange = result;
    return _memoInRange;
  }

  int get approxDistZero => min(a.dist(zero), b.dist(zero));
  int get size => a.dist(b);

  @override
  operator ==(Object that) => that is Rectangle && that.a == a && that.b == b;

  @override
  int get hashCode => Object.hash(a, b);

  @override
  String toString() => "${a} to ${b}";
}

int part2(List<Robot> data) {
  int mx = data.map((e) => e.p.x.abs() + e.range).reduce(max);
  int my = data.map((e) => e.p.y.abs() + e.range).reduce(max);
  int mz = data.map((e) => e.p.z.abs() + e.range).reduce(max);

  var p = PriorityQueue<Rectangle>((a, b) {
    int ra = a.inRange(data);
    int rb = b.inRange(data);
    if (ra != rb) return rb - ra; // DESC number of robots

    var za = a.approxDistZero;
    var zb = b.approxDistZero;
    if (za != zb) return za - zb; // ASC closest to zero

    return a.size - b.size; // ASC size
  });

  p.add(Rectangle(
    P3(mx, my, mz),
    P3(-mx, -my, -mz),
  ));

  while (true) {
    var r = p.removeFirst();

    if (r.isPoint) return r.approxDistZero;

    p.addAll(r.split());
  }
}
