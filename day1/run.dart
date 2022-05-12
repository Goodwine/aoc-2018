import 'package:aoc2018/aoc.dart';

void main() {
  solve(readInts, part1, part2);
}

int part1(Iterable<int> data) {
  return data.reduce((acc, v) => acc + v);
}

int part2(Iterable<int> data) {
  var list = data.toList();
  var seen = {0};
  var loc = 0;
  var idx = 0;
  while (true) {
    loc += list[idx];
    if (!seen.add(loc)) return loc;
    idx = (idx + 1) % data.length;
  }
}
