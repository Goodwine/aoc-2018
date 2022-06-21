import 'package:aoc2018/aoc.dart';
import 'package:stack/stack.dart';

void main() {
  solve(
    (path) async => (await read(path)).first,
    part1,
    part2,
    extra: "medium",
  );
}

int part1(String data) {
  var grid = Grid.explore(data);
  print(grid);
  return 0;
}

int part2(String data) {
  throw Error();
  return 0;
}

enum State { wall, room, door }

const mid = 10;

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

    Stack<List<List<Direction>>?> stack = Stack();
    List<List<Direction>> curr = [[]];
    // List<Point> points = [Point(mid, mid)];

    for (var i = 1; i < data.length - 1; i++) {
      switch (data[i]) {
        case ")":
          while (stack.top() != null) {
            curr.addAll(stack.pop()!);
          }
          stack.pop(); // remove spacer
          var prev = stack.pop()!;

          // var doors = points.map((e) => e.move(dir));
          // for (var d in doors) grid[d.y][d.x] = State.door;
          // points = doors.map((e) => e.move(dir)).toList();
          // for (var p in points) grid[p.y][p.x] = State.room;

          curr = [
            for (var c in curr)
              for (var p in prev) [...p, ...c]
          ];
          break;

        case "(":
          stack.push(curr);
          stack.push(null); // add spacer
          curr = [[]];
          break;

        case "|":
          stack.push(curr);
          curr = [[]];
          break;

        case "N":
        case "E":
        case "W":
        case "S":
          var dir = mapping[data[i]]!;
          for (var c in curr) c.add(dir);

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
            ;
          }).join(""))
      .join("\n");
}
