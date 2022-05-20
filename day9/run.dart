import 'dart:math';

import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (path) async {
      var line = (await read(path))[0].split(" ");
      return Tuple2(int.parse(line[0]), int.parse(line[6]));
    },
    part1,
    part2,
    extra: "medium",
  );
}

const special = 23;
const remove = 7;

class DLinkedList {
  int value;
  late DLinkedList prev, next;

  DLinkedList(this.value) {
    prev = this;
    next = this;
  }

  DLinkedList add(int v) {
    // Between the marbles 1 and 2 positions clockwise. Meaning after "next".
    var current = next;

    // New marbe with the correct pointers.
    var element = DLinkedList(v);
    element.next = current.next;
    element.prev = current;

    // Replace previous references to cross through new marble.
    current.next.prev = element;
    current.next = element;
    // New marble becomes curret.
    return element;
  }

  DLinkedList remove() {
    // Just delete the references to this marble.
    prev.next = next;
    next.prev = prev;
    // Marble clockwise to the one removed becomes current.
    return next;
  }
}

int part1(Tuple2<int, int> data) => play(data.item1, data.item2);

int play(int players, int n) {
  List<int> scores = List.filled(players, 0);

  var marble = DLinkedList(0);
  for (var i = 1; i <= n; i++) {
    if (i % special == 0) {
      for (var j = 0; j < remove; j++) {
        marble = marble.prev;
      }
      scores[i % scores.length] += i + marble.value;
      marble = marble.remove();
      continue;
    }

    marble = marble.add(i);
  }

  return scores.reduce(max);
}

int part2(Tuple2<int, int> data) => play(data.item1, data.item2 * 100);
