import 'package:aoc2018/aoc.dart';

void main() {
  solve((_) async => 0, part1, part2, skipSmall: true);
}

const jobs = 20;

int part1(int _) => input(1);
int part2(int _) => input(16777216);

int input(int maxLoops) {
  var a = 0;
  var b = 0;
  var seen = {0};
  var last = 0;

  for (var i = 0; i < maxLoops; i++) {
    a = b | 65536; // 2^16
    b = 2024736;
    while (true) {
      b = (((b + a % 256) % 16777216) * 65899) % 16777216;
      if (a < 256) break;
      a = a ~/ 256;
    }
    if (seen.add(b)) last = b;
  }
  return last;
}
