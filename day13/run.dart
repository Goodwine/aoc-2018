import 'dart:io';
import 'dart:math';

import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    prepare,
    part1,
    part2,
    extra: "medium",
  );
}

Future<Tuple2<List<String>, List<Coordinate>>> prepare(String path) async {
  var data = await read(path);

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
          .map((cell) =>
              Coordinate(line.key, cell.key, cartDirMap[cell.value]!, Decision.counterClockWise)))
      .expand((e) => e)
      .toList();

  return Tuple2(trackMap, carts);
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

enum Decision { counterClockWise, straight, clockWise }

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

/// item1=Y, item2=X, item3=direction, item4=decision turn
typedef Coordinate = Tuple4<int, int, Direction, Decision>;

Tuple2<int, int> part1(Tuple2<List<String>, List<Coordinate>> data) {
  List<String> trackMap = data.item1;
  List<Coordinate> carts = data.item2.map((e) => e).toList();
  while (true) {
    final collisions = tick(trackMap, carts);
    if (collisions.isNotEmpty)
      return Tuple2(carts[collisions.first].item2, carts[collisions.first].item1);
  }
}

Set<int> tick(List<String> trackMap, List<Coordinate> carts, {keepGoing = false}) {
  carts.sort((a, b) => a.item1 != b.item1 ? a.item1 - b.item1 : a.item2 - b.item2);

  Set<int> collisions = {};
  for (final cart in carts.asMap().entries) {
    if (collisions.contains(cart.key)) continue;

    final nextCart = next(trackMap, cart.value);

    for (final otherCart in carts.asMap().entries) {
      if (collisions.contains(otherCart.key)) continue;

      if (otherCart.value.item1 == nextCart.item1 && otherCart.value.item2 == nextCart.item2) {
        // print("collided at: ${nextCart.item2},${nextCart.item1}");
        if (!keepGoing) return {otherCart.key};
        collisions.addAll({cart.key, otherCart.key});
        break;
      }
    }

    carts[cart.key] = nextCart;
  }
  return collisions;
}

final Map<Direction, Map<String, Direction Function(Decision)>> want = {
  Direction.up: {
    "|": (_) => Direction.up,
    "/": (_) => Direction.right,
    "\\": (_) => Direction.left,
    "+": (turn) {
      switch (turn) {
        case Decision.counterClockWise:
          return Direction.left;
        case Decision.clockWise:
          return Direction.right;
        case Decision.straight:
          return Direction.up;
      }
    },
  },
  Direction.right: {
    "-": (_) => Direction.right,
    "/": (_) => Direction.up,
    "\\": (_) => Direction.down,
    "+": (turn) {
      switch (turn) {
        case Decision.counterClockWise:
          return Direction.up;
        case Decision.clockWise:
          return Direction.down;
        case Decision.straight:
          return Direction.right;
      }
    },
  },
  Direction.down: {
    "|": (_) => Direction.down,
    "/": (_) => Direction.left,
    "\\": (_) => Direction.right,
    "+": (turn) {
      switch (turn) {
        case Decision.counterClockWise:
          return Direction.right;
        case Decision.clockWise:
          return Direction.left;
        case Decision.straight:
          return Direction.down;
      }
    },
  },
  Direction.left: {
    "-": (_) => Direction.left,
    "/": (_) => Direction.down,
    "\\": (_) => Direction.up,
    "+": (turn) {
      switch (turn) {
        case Decision.counterClockWise:
          return Direction.down;
        case Decision.clockWise:
          return Direction.up;
        case Decision.straight:
          return Direction.left;
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
      case Decision.counterClockWise:
        turn = Decision.straight;
        break;
      case Decision.straight:
        turn = Decision.clockWise;
        break;
      case Decision.clockWise:
        turn = Decision.counterClockWise;
        break;
    }
  }

  return Coordinate(y, x, dir, turn);
}

Tuple2<int, int> part2(Tuple2<List<String>, List<Coordinate>> data) {
  List<String> trackMap = data.item1;
  List<Coordinate> carts = data.item2;
  while (true) {
    final collisions = tick(trackMap, carts, keepGoing: true).toList()..sort((a, b) => b - a);
    for (final idx in collisions) {
      carts.removeAt(idx);
    }
    if (carts.isEmpty) return Tuple2(-1, -1);
    if (carts.length == 1) {
      return Tuple2(carts.first.item2, carts.first.item1);
    }
  }
}
