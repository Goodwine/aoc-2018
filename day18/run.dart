import 'dart:io';

import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';
import 'package:charcode/charcode.dart';

void main() {
  solve(
    (path) async => [
      for (var line in await read(path)) [...line.codeUnits]
    ],
    part1,
    part2,
  );
}

const ground = $dot;
const tree = $pipe;
const lumberyard = $hash;

int part1(List<List<int>> data) => conway(data, 10);

void printGrid(List<List<int>> data) {
  print(data.map(String.fromCharCodes).join("\n"));
  stdin.readLineSync();
}

int score(List<List<int>> data) {
  var treeCount = data.expand((e) => e).where((e) => e == tree).length;
  var lumberyardCount = data.expand((e) => e).where((e) => e == lumberyard).length;
  return treeCount * lumberyardCount;
}

int part2(List<List<int>> data) => conway(data, 1000000000);

int conway(List<List<int>> data, int n) {
  data = [
    for (var line in data) [...line]
  ];
  var coordinates = [
    for (var y = 0; y < data.length; y++)
      for (var x = 0; x < data.length; x++)
        Tuple2(Point(x, y), Point(x, y).next(data.length, corners: true))
  ];

  return _conway(data, coordinates, n);
}

int _conway(List<List<int>> data, List<Tuple2<Point, Iterable<Point>>> coordinates, int n) {
  var memo = <int, Tuple3<int, int, int>>{};

  for (var i = 0; i < n; i++) {
    // printGrid(data);
    var updates = <Point, int>{};
    final prevHashcode = hash(data);

    if (memo.containsKey(prevHashcode)) {
      var loopsLeft = n - i;
      var loopSize = i - memo[prevHashcode]!.item2;
      var stepsLeft = loopsLeft % loopSize;

      var hashCode = prevHashcode;
      // This loop goes to [stepsLeft - 1] because the memoizing map points to the next value.
      for (var j = 0; j < stepsLeft - 1; j++) {
        hashCode = memo[hashCode]!.item1;
      }
      return memo[hashCode]!.item3;
    }

    for (final coord in coordinates) {
      final p = coord.item1;
      var surroundings = coord.item2.map((e) => data[e.y][e.x]);
      switch (data[p.y][p.x]) {
        case ground:
          if (surroundings.where((e) => e == tree).length >= 3) {
            updates[p] = tree;
          }
          break;
        case lumberyard:
          if (!surroundings.any((e) => e == tree) || !surroundings.any((e) => e == lumberyard)) {
            updates[p] = ground;
          }
          break;
        case tree:
          if (surroundings.where((e) => e == lumberyard).length >= 3) {
            updates[p] = lumberyard;
          }
          break;
        default:
          throw Exception("character found ${data[p.y][p.x]}");
      }
    }

    if (updates.length == 0) return 0;

    for (final update in updates.entries) {
      final p = update.key;
      data[p.y][p.x] = update.value;
    }

    memo[prevHashcode] = Tuple3(hash(data), i, score(data));
  }

  return score(data);
}

int hash(List<List<int>> data) => Object.hashAll(data.expand((e) => e));
