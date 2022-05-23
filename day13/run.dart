import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(read, part1, part2);
}

enum Direction {
  up(dy: -1, dx: 0),
  right(dy: 0, dx: 1),
  down(dy: 1, dx: 0),
  left(dy: 0, dx: -1);

  const Direction({
    required this.dy,
    required this.dx,
  });
  final int dy, dx;
}

const directions = [
  Direction.up,
  Direction.right,
  Direction.down,
  Direction.left,
];

Map<int, Direction> cartDirMap = "^>v<"
    .codeUnits
    .asMap()
    .entries
    .fold({}, (acc, v) => acc..putIfAbsent(v.value, () => directions[v.key]));

// item1=Y, item2=X, item3=direction
typedef Coordinate = Tuple4<int, int, Direction, Direction>;

Iterable<Tuple2<int, int>> part1(List<String> data) {
  final trackMap = data
      .map((line) =>
          line.replaceAll("^", "|").replaceAll("v", "|").replaceAll(">", "-").replaceAll("<", "-"))
      .toList(growable: false);

  List<Coordinate> carts = data
      .asMap()
      .entries
      .map((line) => line.value.codeUnits
          .asMap()
          .entries
          .where((cell) => cartDirMap.containsKey(cell.value))
          .map((cell) => Coordinate(line.key, cell.key, cartDirMap[cell.value]!, Direction.left)))
      .expand((e) => e)
      .toList();

  while (check(carts)) {
    // print(carts);
    carts = run(trackMap, carts);
  }

  return carts
      .map((c) => Tuple2(c.item2, c.item1))
      .fold<Map<Tuple2<int, int>, int>>(
          {},
          (acc, v) => acc
            ..putIfAbsent(v, () => 0)
            ..update(v, (count) => count + 1))
      .entries
      .where((e) => e.value > 1)
      .map((e) => e.key);
}

List<Coordinate> run(List<String> trackMap, List<Coordinate> carts) =>
    carts.map((c) => next(trackMap, c)).toList();

final Map<Direction, Map<String, Direction Function(Direction)>> want = {
  Direction.up: {
    "|": (_) => Direction.up,
    "/": (_) => Direction.right,
    "\\": (_) => Direction.left,
    "+": (turn) {
      switch (turn) {
        case Direction.left:
          return Direction.left;
        case Direction.right:
          return Direction.right;
        case Direction.up:
          return Direction.up;
        case Direction.down:
          throw Error();
      }
    },
  },
  Direction.right: {
    "-": (_) => Direction.right,
    "/": (_) => Direction.up,
    "\\": (_) => Direction.down,
    "+": (turn) {
      switch (turn) {
        case Direction.left:
          return Direction.down;
        case Direction.right:
          return Direction.up;
        case Direction.up:
          return Direction.right;
        case Direction.down:
          throw Error();
      }
    },
  },
  Direction.down: {
    "|": (_) => Direction.down,
    "/": (_) => Direction.left,
    "\\": (_) => Direction.right,
    "+": (turn) {
      switch (turn) {
        case Direction.left:
          return Direction.right;
        case Direction.right:
          return Direction.left;
        case Direction.up:
          return Direction.down;
        case Direction.down:
          throw Error();
      }
    },
  },
  Direction.left: {
    "-": (_) => Direction.left,
    "/": (_) => Direction.down,
    "\\": (_) => Direction.up,
    "+": (turn) {
      switch (turn) {
        case Direction.left:
          return Direction.down;
        case Direction.right:
          return Direction.up;
        case Direction.up:
          return Direction.left;
        case Direction.down:
          throw Error();
      }
    },
  },
};

Coordinate next(List<String> trackMap, Coordinate cart) {
  var y = cart.item1 + cart.item3.dy;
  var x = cart.item2 + cart.item3.dx;
  var cell = trackMap[y][x];
  var turn = cart.item4;
  var dir = (want[cart.item3]![cell]!)(turn);
  if (cell == "+") {
    switch (turn) {
      case Direction.left:
        turn = Direction.up;
        break;
      case Direction.up:
        turn = Direction.right;
        break;
      case Direction.right:
        turn = Direction.left;
        break;
      case Direction.down:
        throw Error();
    }
  }

  return Coordinate(y, x, dir, turn);
}

bool check(List<Coordinate> carts) =>
    carts.map((c) => Tuple2(c.item1, c.item2)).toSet().length == carts.length;

int part2(List<String> data) => 0;
