import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (path) async => World.from(["", ...(await read(path)).map((line) => " ${line} "), ""]),
    part1,
    part2,
  );
}

enum Direction {
  up(dy: 1, dx: 0),
  right(dy: 0, dx: 1),
  down(dy: -1, dx: 0),
  left(dy: 0, dx: -1);

  const Direction({required this.dy, required this.dx});
  final int dy, dx;

  Coordinate next(Coordinate c) => Coordinate(c.item1 + dy, c.item2 + dx);
}

class Meta {
  final Coordinate coordinate;
  Meta(this.coordinate);
}

// item1 = Y, item2 = X
typedef Coordinate = Tuple2<int, int>;
typedef Track = DLinkedList<Coordinate>;

class World {
  List<Track> tracks = [];
  List<Direction> carts = [];

  World.from(List<String> data) {
    var startingPoints = data
        .asMap()
        .entries
        .expand(
            (line) => line.value.allMatches("/").map((cell) => Coordinate(line.key, cell.start)))
        .toSet();

    Set<Coordinate> usedStartingPoints = {};

    for (final cell in startingPoints) {
      if (usedStartingPoints.contains(cell)) continue;

      var dir = data[cell.item1][cell.item2] == "|" ? Direction.down : Direction.up;

      var track = Track(cell);
      var coordinate = dir.next(cell);
      Direction cart;
      switch (data[coordinate.item1][coordinate.item2]) {
        // No change
        case "|":
        case "-":
        case "+":
          break;

        // Direction change
        case "/":
          usedStartingPoints.add(coordinate);
          switch (dir) {
            case Direction.up:
              dir = Direction.right;
              break;
            case Direction.right:
              dir = Direction.up;
              break;
            case Direction.down:
              dir = Direction.left;
              break;
            case Direction.left:
              dir = Direction.down;
              break;
          }
          break;
        case "\\":
          switch (dir) {
            case Direction.up:
              dir = Direction.left;
              break;
            case Direction.right:
              dir = Direction.down;
              break;
            case Direction.down:
              dir = Direction.right;
              break;
            case Direction.left:
              dir = Direction.up;
              break;
          }
          break;

        // Cart found
        case "^":
          carts.add(Direction.up);
          break;
        case ">":
          carts.add(Direction.right);
          break;
        case "v":
          carts.add(Direction.down);
          break;
        case "<":
          carts.add(Direction.left);
          break;

        default:
          throw new Exception("unexpected direction at ${coordinate}");
      }
    }
  }
}

int part1(World data) => 0;

int part2(World data) => 0;
