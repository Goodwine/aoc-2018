import 'dart:io';
import 'dart:math';

import 'package:aoc2018/aoc.dart';

void main() {
  solve(process, part1, part2, extra: "medium");
}

Future<List<List<int>>> process(String path) async {
  var data = (await read(path)).map((line) => [...line.codeUnits]).toList();
  if (data.length == data[0].length) return data;
  if (data.length < data[0].length) {
    return [
      ...data,
      ...List.filled(data[0].length - data.length, List.filled(data[0].length, wall)),
    ];
  }
  return data
      .map((line) => [
            ...line,
            ...List.filled(data.length - data[0].length, wall),
          ])
      .toList();
}

var code = "#.GE".codeUnits;
var wall = code[0];
var space = code[1];
var goblin = code[2];
var elf = code[3];

int part1(List<List<int>> area) {
  assert(area.length == area[0].length);

  final allUnits = area
      .asMap()
      .entries
      .expand((line) => line.value
          .asMap()
          .entries
          .where((e) => {goblin, elf}.contains(e.value))
          .map((e) => Unit(Point(e.key, line.key, e.value))))
      .toList();

  var turns = combat(area, allUnits);
  var allHP = allUnits.map((e) => e.hp).where((e) => e > 0).reduce((acc, v) => acc + v);

  return turns * allHP;
}

int combat(List<List<int>> area, List<Unit> allUnits) {
  var turns = 0;
  while (true) {
    for (final unit in allUnits.asMap().entries) {
      printArea(turns, unit.key, area, allUnits);
      if (!turn(area, allUnits, unit.value)) return turns;
    }
    allUnits = allUnits.where((e) => e.hp > 0).toList()
      ..sort(
        (a, b) => a.point.y != b.point.y ? a.point.y - b.point.y : a.point.x - b.point.x,
      );
    turns++;
  }
}

int part2(List<List<int>> data) {
  return data.length;
}

class Unit {
  Point point;
  int hp;
  int dmg;

  Unit(this.point, [this.hp = 200, this.dmg = 3]);

  @override
  operator ==(that) {
    if (that is! Unit) throw Exception("invalid comparison");
    return that.point == point;
  }

  @override
  int get hashCode => point.hashCode;
  @override
  String toString() => "$point,hp:$hp,dmg:$dmg";

  void move(Direction dir) => point = point.move(dir);
  Iterable<Point> next(int maxSize) => point.next(maxSize);
}

void printArea(int turn, int idx, List<List<int>> area, List<Unit> allUnits) {
  print("TURN: $turn, idx: $idx");
  allUnits.forEach(print);
  var emptyArea = area
      .map(String.fromCharCodes)
      .map((line) => line.replaceAll("G", ".").replaceAll("E", ".").codeUnits)
      .map((line) => [...line])
      .toList();

  for (final unit in allUnits.where((element) => element.hp > 0)) {
    emptyArea[unit.point.y][unit.point.x] = unit.point.id;
  }
  emptyArea.map(String.fromCharCodes).forEach(print);

  // stdin.readLineSync();
}

bool turn(List<List<int>> area, List<Unit> allUnits, Unit unit) {
  if (unit.hp < 0) return true; // turn ends - unit is dead
  var liveUnits = allUnits.where((e) => e.hp > 0).toList();
  var targets = liveUnits.where((e) => e.point.id != unit.point.id).toList();
  var allies = liveUnits.where((e) => e.point.id == unit.point.id).toList();
  if (targets.isEmpty) return false; // combat ends - no more targets

  var closest = closestTarget(area, unit, targets, allies);
  if (closest == null) return true; // turn ends - no target was reachable
  if (closest.path.length > 1) {
    unit.move(closest.path.first);
  }

  var possibleAttack =
      unit.next(area.length).expand((e) => targets.where((target) => target.point == e)).toList();
  if (possibleAttack.isEmpty) return true; // turn ends - nothing to attack

  var minHP = possibleAttack.map((e) => e.hp).reduce(min);
  var attack = possibleAttack.firstWhere((e) => e.hp == minHP);
  attack.hp -= unit.dmg;

  return true; // turn ends - keep moving
}

class PathTarget {
  final List<Direction> path;
  final Point point;

  PathTarget(this.path, this.point);
}

// bfs
PathTarget? closestTarget(List<List<int>> area, Unit unit, List<Unit> targets, List<Unit> allies) {
  final queue = [PathTarget([], unit.point)];
  final visited = allies.map((a) => a.point).toSet();
  final targetSet = targets.map((t) => t.point).toSet();

  while (queue.isNotEmpty) {
    final current = queue.removeAt(0);
    visited.add(current.point);

    var validDirections = directions.where((d) {
      final p = current.point.move(d);
      return p.x >= 0 &&
          p.y >= 0 &&
          p.x < area.length &&
          p.y < area.length &&
          !visited.contains(p) &&
          !{wall}.contains(area[p.y][p.x]);
    }).toList();
    var next = validDirections
        .map((d) => PathTarget(
            current.path.length > 1 ? current.path : [...current.path, d], current.point.move(d)))
        .toList();

    var maybe = next.where((n) => targetSet.contains(n.point));
    if (maybe.isNotEmpty) return maybe.first;

    queue.addAll(next);
  }
  return null;
}
