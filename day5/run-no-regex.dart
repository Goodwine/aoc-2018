import 'dart:math';
import 'package:quiver/iterables.dart' show zip;

import 'package:aoc2018/aoc.dart';

void main() {
  solve((path) async => (await read(path))[0].codeUnits, part1, part2);
}

int part1(List<int> data) => reduce(data).length;

var diff = 'a'.codeUnits.first - 'A'.codeUnits.first;

List<int> reduce(List<int> data) {
  var result = zip([
    [0].followedBy(data),
    data,
    data.skip(1).followedBy([0]),
  ]).where((e) => !drop(e[0], e[1], e[2])).map((e) => e[1]).toList();

  return data.length == result.length ? result : reduce(result);
}

bool drop(int a, int b, int c) => a + diff == b || a - diff == b || c + diff == b || c - diff == b;

int part2(List<int> data) => data
    .map((ch) => data.where((e) => e != ch && e != ch + diff && e != ch - diff).toList())
    .map(reduce)
    .map((e) => e.length)
    .reduce(min);
