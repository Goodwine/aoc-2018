import 'dart:math';

import 'package:aoc2018/aoc.dart';

void main() {
  solve((path) async => (await read(path))[0], part1, part2);
}

int part1(String data) => reduce(data).length;

String reduce(String data) {
  var result = data.replaceAll(RegExp(combinations.join("|")), "");
  return result == data ? result : reduce(result);
}

int part2(String data) => units
    .map((e) => e.map(String.fromCharCode))
    .map((e) => data.replaceAll(RegExp(e.join("|")), ""))
    .map(reduce)
    .map((e) => e.length)
    .reduce(min);

var units = List.generate('z'.codeUnits.first - 'a'.codeUnits.first + 1,
    (index) => ['a'.codeUnits.first + index, 'A'.codeUnits.first + index]);

var combinations = units.expand((e) => [String.fromCharCodes(e), String.fromCharCodes(e.reversed)]);
