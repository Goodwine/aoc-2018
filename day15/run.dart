import 'dart:math';

import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(process, part1, part2);
}

Future<List<List<int>>> process(String path) async {
  var data = await read(path);
  return data.map((line) => line.codeUnits.map((e) => e).toList()).toList();
}

var code = "#.GE".codeUnits;
var pound = code[0];
var space = code[1];
var goblin = code[2];
var elf = code[3];

int part1(List<List<int>> data) {
  final allUnits = data
      .asMap()
      .entries
      .expand((line) => line.value
          .asMap()
          .entries
          .where((e) => {goblin, elf}.contains(e.value))
          .map((e) => Unit(Point(e.key, line.key, e.value))))
      .toList();

  var turns = combat(data, allUnits);
  var allHP = allUnits.map((e) => e.hp).where((e) => e > 0).reduce((acc, v) => acc + v);

  return turns * allHP;
}

int combat(List<List<int>> data, List<Unit> allUnits) {
  final maxSize = max(data.length, data[0].length);

  var turns = 0;
  while (true) {
    for (final unit in allUnits) {
      if (!turn(data, maxSize, allUnits, unit)) return turns;
    }
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

  void move(Direction dir) => point = point.move(dir);
  Iterable<Point> next(int maxSize) => point.next(maxSize);
}

bool turn(List<List<int>> area, int maxSize, List<Unit> allUnits, Unit unit) {
  var targets = allUnits.where((e) => e != unit).where((e) => e.hp > 0).toList();
  if (targets.isEmpty) return false; // combat ends - no more targets

  var closest = closestTarget(area, unit, targets);
  if (closest == null) return true; // turn ends - no target was reachable
  if (closest.path.length > 1) {
    unit.move(closest.path.first);
  }

  var possibleAttack =
      unit.next(maxSize).expand((e) => targets.where((target) => target.point == e));
  var maxHP = possibleAttack.map((e) => e.hp).reduce(max);
  var attack = possibleAttack.firstWhere((e) => e.hp == maxHP);
  attack.hp -= unit.dmg;

  return true; // turn ends - keep moving
}

class PathTarget {
  final List<Direction> path;
  final Point target;

  PathTarget(this.path, this.target);
}

PathTarget? closestTarget(List<List<int>> area, Unit unit, List<Unit> targets) {}
