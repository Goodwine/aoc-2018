import 'dart:math';

import 'package:aoc2018/aoc.dart';

void main() {
  solve(
    (path) async => (await read(path)).first,
    part1,
    part2,
    extra: "medium",
  );
}

String part1(String data) {
  var recipes = [3, 7];
  var a = 0;
  var b = 1;
  var limit = int.parse(data);

  for (var i = 0; i < limit; i++) {
    var newReciepe = recipes[a] + recipes[b];
    recipes.addAll(newReciepe < 10 ? [newReciepe] : [1, newReciepe - 10]);

    a = (a + recipes[a] + 1) % recipes.length;
    b = (b + recipes[b] + 1) % recipes.length;
  }

  return recipes.sublist(limit).take(10).join("");
}

int part2(String data) {
  var zero = "0".codeUnitAt(0);
  var limit = data.codeUnits.map((e) => e - zero).toList();

  var recipes = [3, 7];
  var a = 0;
  var b = 1;

  for (var round = 1; round <= 1000; round++) {
    for (var i = 0; i < 1000 * round; i++) {
      var newReciepe = recipes[a] + recipes[b];
      recipes.addAll(newReciepe < 10 ? [newReciepe] : [1, newReciepe - 10]);

      a = (a + recipes[a] + 1) % recipes.length;
      b = (b + recipes[b] + 1) % recipes.length;
    }

    var found = findIndex(limit, recipes, round - 1);
    if (found != -1) return found;
  }

  throw Error();
}

int findIndex(List<int> limit, List<int> recipes, int round) {
  for (var i = max(0, round * 1000 - limit.length); i < recipes.length - limit.length; i++) {
    if (recipes[i] == limit[0]) {
      if (check(recipes.sublist(i, i + limit.length + 1), limit)) {
        return i;
      }
    }
  }
  return -1;
}

bool check(List<int> sublist, List<int> limit) {
  for (var i = 0; i < limit.length; i++) {
    if (sublist[i] != limit[i]) return false;
  }
  return true;
}
