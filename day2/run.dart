import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(read, part1, part2);
}

int part1(Iterable<String> data) {
  var twoThree = data.map(countChars).fold(
      Tuple2(0, 0),
      (acc, counts) => Tuple2(
            acc.item1 + (repeats(2, counts) ? 1 : 0),
            acc.item2 + (repeats(3, counts) ? 1 : 0),
          ));
  return twoThree.toList().reduce((acc, v) => acc * v);
}

String part2(Iterable<String> data) {
  var list = data.toList();
  for (var i = 0; i < list.length; i++) {
    for (var j = i + 1; j < list.length; j++) {
      var diff = uniqueDiff(list[i], list[j]);
      if (diff == -1) continue;
      return list[i].replaceRange(diff, diff + 1, "");
    }
  }

  return "no";
}

int uniqueDiff(String a, String b) {
  var c = 0;
  var diff = -1;
  for (var i = 0; i < a.length; i++) {
    if (a[i] == b[i]) continue;
    diff = i;
    c++;
  }

  return c == 1 ? diff : -1;
}

Map<int, int> countChars(String data) {
  return data.codeUnits.fold({}, (acc, v) => acc..update(v, (c) => c + 1, ifAbsent: () => 1));
}

bool repeats(int n, Map<int, int> data) {
  return data.values.contains(n);
}
