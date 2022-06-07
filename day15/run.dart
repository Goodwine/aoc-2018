import 'package:aoc2018/aoc.dart';

void main() {
  solve(readInts, part1, part2);
}

int part1(Iterable<int> data) {
  return data.reduce((acc, v) => acc + v);
}

int part2(Iterable<int> data) {
  return 0;
}
