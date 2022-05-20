import 'dart:math';

import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';
import 'package:quiver/iterables.dart' show zip;

void main() {
  solve(process, part1, part2);
}

Future<Graph> process(String path) async {
  var edges = (await read(path))
      .map((e) => e.split(" "))
      .map((e) => [e[1].codeUnits.first, e[7].codeUnits.first]);

  var graph = edges.fold<Graph>(
      {0: Node(0)},
      (g, e) => g
        ..putIfAbsent(e[0], () => Node(e[0]))
        ..putIfAbsent(e[1], () => Node(e[1]))
        ..update(e[0], (n) => n..addChild(e[1]))
        ..update(e[1], (n) => n..addParent(e[0])));

  var topLevel = graph.values.where((n) => n.parents.length == 0);
  for (var n in topLevel) {
    n.addParent(0);
    graph[0]!.addChild(n.id);
  }

  return graph;
}

typedef Graph = Map<int, Node>;

class Node {
  final int id;
  Set<int> children = {};
  Set<int> parents = {};

  Node(this.id);

  void addChild(int v) => children.add(v);
  void addParent(int v) => parents.add(v);

  String toString() => "$children";
}

String part1(Graph data) {
  var first = data[0]!;
  List<int> codes = [0];
  var seen = {first.id};

  while (codes.length < data.length) {
    var availableTasks = seen
        .expand((id) => data[id]!.children)
        .toSet()
        .where((id) => !seen.contains(id))
        .map((id) => data[id]!)
        .where((n) => n.parents.every((id) => seen.contains(id)))
        .map((n) => n.id)
        .toList();

    var next = (availableTasks..sort()).first;

    codes.add(next);
    seen.add(next);
  }

  return String.fromCharCodes(codes, 1);
}

int part2(Graph data) {
  var adjust = "A".codeUnits.first - 1;
  var numWorkers = data.length > 10 ? 5 : 2;
  var buffer = data.length > 10 ? 60 : 0;

  var first = data[0]!;
  Set<int> completed = {first.id};
  Set<int> inProgress = {};
  var time = 0;

  // Tuple(ETA, task)
  var workers = List.filled(numWorkers, Tuple2(0, 0));

  while (completed.length < data.length) {
    var availableWorkers =
        workers.asMap().entries.where((e) => e.value.item1 <= time).map((e) => e.key).toList();
    completed.addAll(availableWorkers.map((w) => workers[w].item2));
    inProgress.removeAll(completed);

    if (completed.length == data.length) break;

    var availableTasks = completed
        .expand((id) => data[id]!.children)
        .toSet()
        .difference(inProgress)
        .where((id) => !completed.contains(id))
        .map((id) => data[id]!)
        .where((n) => n.parents.every((id) => completed.contains(id)))
        .map((n) => n.id)
        .toList();
    availableTasks.sort();

    var next = availableTasks.take(availableWorkers.length).toList();

    for (var i = 0; i < next.length; i++) {
      workers[availableWorkers[i]] = Tuple2(time + buffer + next[i] - adjust, next[i]);
      inProgress.add(next[i]);
    }
    var nextTime = workers.map((e) => e.item1).where((t) => t > time).fold(1 << 20, min);
    time = nextTime == 1 << 20 ? time + 1 : nextTime;
  }

  return time;
}
