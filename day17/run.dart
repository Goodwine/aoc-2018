import 'dart:io';
import 'dart:math';

import 'package:aoc2018/aoc.dart';

void main() {
  solve(
    (path) async => Grid((await read(path)).map(Range.from)),
    part1,
    part2,
  );
}

const offset = 5;
const origin = 500 + offset;

enum State {
  none,
  wall,
  stable,
  flowing;

  String toString() {
    switch (this) {
      case State.none:
        return ".";
      case State.wall:
        return "#";
      case State.stable:
        return "~";
      case State.flowing:
        return "|";
    }
  }

  get isWater => this == flowing || this == stable;
  get isStable => this == wall || this == stable;
}

class Grid {
  late final int minY, maxY;
  late final int minX, maxX;
  late final List<List<State>> grid;

  Grid(Iterable<Range> ranges) {
    minY = ranges.map((e) => e.point.y).reduce(min);
    maxY = ranges.map((e) => e.maxY).reduce(max);
    minX = ranges.map((e) => e.point.x).reduce(min);
    maxX = ranges.map((e) => e.maxX).reduce(max);

    grid = List.generate(maxY + 1, (_) => List.filled(max(maxX, origin) + offset, State.none));

    for (final r in ranges) {
      var dx = r.dir == Direction.down ? 0 : 1;
      var dy = r.dir == Direction.down ? 1 : 0;
      var x = r.point.x;
      var y = r.point.y;

      for (var i = 0; i <= r.length; i++) {
        grid[y][x] = State.wall;

        x += dx;
        y += dy;
      }
      grid[0][origin] = State.flowing;
    }
  }

  @override
  String toString() =>
      grid.map((e) => e.sublist(minX).map((e) => e.toString()).join("")).join("\n");

  bool update(Set<Point> flowing) {
    Set<Point> toAdd = {};
    Set<Point> toRemove = {};
    for (final p in flowing) {
      if (p.y + 1 > maxY) continue;
      switch (grid[p.y + 1][p.x]) {
        case State.none:
          grid[p.y + 1][p.x] = State.flowing;
          toAdd.add(Point(p.x, p.y + 1));
          break;
        case State.wall:
        case State.stable:
          for (final dir in [Direction.right, Direction.left]) {
            var dx = dir.dx;
            switch (grid[p.y][p.x + dx]) {
              case State.none:
                grid[p.y][p.x + dx] = State.flowing;
                toAdd.add(Point(p.x + dx, p.y));
                break;
              case State.wall:
              case State.stable:
                var stabilize = false;
                for (var i = -dx; grid[p.y + 1][p.x + i].isStable; i -= dx) {
                  if (grid[p.y][p.x + i] == State.none) break;
                  if (grid[p.y][p.x + i].isStable) {
                    stabilize = true;
                    break;
                  }
                }
                if (stabilize) {
                  grid[p.y][p.x] = State.stable;
                  toRemove.add(p);
                }
                break;
              case State.flowing:
                // do nothing.
                break;
            }
          }

          break;
        case State.flowing:
          // do nothing;
          break;
      }
    }
    flowing.removeAll(toRemove);
    flowing.addAll(toAdd);

    return toAdd.length > 0 || toRemove.length > 0;
  }
}

class Range {
  late final Point point;
  late final Direction dir;
  late final int length;

  Range.from(String line) {
    var parts = line.split(", ");
    var range = parts[1].substring(2).split("..").map(int.parse).toList();
    var m = {
      parts[0][0]: int.parse(parts[0].substring(2)),
      parts[1][0]: range[0],
    };

    length = range[1] - range[0];
    dir = parts[0][0] == "x" ? Direction.down : Direction.right;
    point = Point(m["x"]! + offset, m["y"]!);
  }

  int get maxY => dir == Direction.down ? point.y + length : point.y;
  int get maxX => dir == Direction.down ? point.x : point.x + length;
}

int part1(Grid data) {
  var flowing = data.grid
      .asMap()
      .entries
      // Don't update last row.
      .where((line) => line.key < data.maxY)
      .expand((line) => line.value
          .asMap()
          .entries
          .where((cell) => cell.value == State.flowing)
          .map((cell) => Point(cell.key, line.key)))
      .toSet();
  while (data.update(flowing)) {
    // print(data);
    // stdin.readLineSync();
  }

  return data.grid.skip(data.minY).expand((e) => e).where((e) => e.isWater).length;
}

int part2(Grid data) {
  // stdin.readLineSync();

  return data.grid.expand((e) => e).where((e) => e == State.stable).length;
}
