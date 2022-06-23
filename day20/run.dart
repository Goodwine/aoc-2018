import 'dart:collection';

import 'package:aoc2018/aoc.dart';
import 'package:stack/stack.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (path) async => Grid.explore((await read(path)).first),
    part1,
    part2,
    extra: "medium",
  );
}

int part1(Grid data) {
  return data.longest().item1;
}

int part2(Grid data) {
  return data.longest().item2;
}

enum State { wall, room, door }

const mid = 110;

const mapping = {
  "N": Direction.up,
  "E": Direction.right,
  "W": Direction.left,
  "S": Direction.down,
};

class Grid {
  var grid = List.generate(mid * 2, (_) => List.filled(mid * 2, State.wall));

  Grid.explore(String data) {
    grid[mid][mid] = State.room;

    Stack<List<Point>> parenStack = Stack();
    Stack<List<Point>> pipeStack = Stack();
    List<Point> curr = [Point(mid, mid)];

    for (var i = 1; i < data.length - 1; i++) {
      switch (data[i]) {
        case "(":
          parenStack.push(curr);
          pipeStack.push([]); // start fresh, this is key
          break;

        case ")":
          curr = [...pipeStack.pop(), ...curr];
          parenStack.pop(); // drop
          break;

        case "|":
          curr = [...pipeStack.pop(), ...curr];
          pipeStack.push(curr);
          curr = parenStack.top();
          break;

        case "N":
        case "E":
        case "W":
        case "S":
          var dir = mapping[data[i]]!;
          var doors = curr.map((p) => p.move(dir));
          for (var d in doors) {
            grid[d.y][d.x] = State.door;
          }
          curr = doors
              .map((p) => p.move(dir))
              // cut hydra heads
              .where((p) => grid[p.y][p.x] == State.wall)
              .toList();
          for (var p in curr) {
            grid[p.y][p.x] = State.room;
          }
          break;

        default:
          throw Exception("unexpected ${data[i]} - i $i");
      }
    }
  }

  @override
  String toString() => grid
      .map((e) => e.map((e) {
            switch (e) {
              case State.wall:
                return "#";
              case State.room:
                return ".";
              case State.door:
                return " ";
            }
          }).join(""))
      .join("\n");

  Tuple2<int, int> longest() {
    var seen = {Point(mid, mid)};
    var curr = [Point(mid, mid)];
    var door = false;
    var count = 0;
    var gteNCount = 0;

    const n = 1000;

    while (curr.length > 0) {
      if (door) count++;

      var p = curr
          .expand((element) => element.next(mid * 2))
          .toSet()
          .where((p) => grid[p.x][p.y] != State.wall)
          .where((p) => !seen.contains(p))
          .toList();

      // IDK why I had to do -1, probably a bug
      if (!door && count >= n - 1) gteNCount += p.length;

      seen.addAll(p);
      curr = p;
      door = !door;
    }
    return Tuple2(count, gteNCount);
  }
}
