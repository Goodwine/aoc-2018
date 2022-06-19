import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (path) async {
      var data = await read(path);
      return parseProgram(data.skip(1));
    },
    part1,
    part2,
    skipSmall: true,
  );
}

int part1(Program program) {
  var n = (Computer([0, 0, 0, 0, 0, 0])..run(program, 2, timeout: 100)).reg[3];
  return sumOfFactors(n);
}

int part2(Program program) {
  var n = (Computer([1, 0, 0, 0, 0, 0])..run(program, 2, timeout: 100)).reg[3];
  return sumOfFactors(n);
}

int sumOfFactors(int n) =>
    Iterable.generate(n + 1).skip(1).where((v) => n % v == 0).reduce((a, b) => a + b);
