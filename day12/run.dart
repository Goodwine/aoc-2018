import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

// Started with buffer size 100 but after solving I
// made this only size 10 because input moves right.
var buffer = " " * 10;

void main() {
  solve(
    (path) async {
      var lines = (await read(path)).map((s) => s.replaceAll(".", " "));

      return Tuple2(
        "${buffer}${lines.first.substring("initial state: ".length)}",
        lines.skip(2).where((s) => s.endsWith("#")).map((s) => s.substring(0, 5)).toSet(),
      );
    },
    part1,
    part2,
    // skipSmall: true,
  );
}

String runGeneration(String s, Set<String> rules) {
  var buffer = new StringBuffer();
  buffer.write("  ");

  s += "  ";

  for (var i = 2; i < s.length - 2; i++) {
    buffer.write(rules.contains(s.substring(i - 2, i + 3)) ? "#" : " ");
  }

  buffer.write("  ");
  return buffer.toString();
}

int part1(Tuple2<String, Set<String>> data) => run(data.item1, data.item2, 20);

int score(String s, {int generationsLeft = 0}) {
  var sum = 0;
  for (var i = 0; i < s.length; i++) {
    sum += s[i] == "#" ? i - buffer.length + generationsLeft : 0;
  }

  return sum;
}

int run(String s, Set<String> rules, int generations) {
  for (var i = 0; i < generations; i++) {
    var got = runGeneration(s, rules);
    if (s.trim() == got.trim()) return score(got, generationsLeft: generations - i - 1);
    s = got;
  }

  return score(s);
}

int part2(Tuple2<String, Set<String>> data) => run(data.item1, data.item2, 50000000000);
