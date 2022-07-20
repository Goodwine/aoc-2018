import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (path) async {
      var lines = await read(path);
      var immune = lines
          .takeWhile((value) => value.isNotEmpty)
          .skip(1)
          .map((e) => UnitGroup.from(e, "immune"))
          .toList();
      var infection =
          lines.sublist(immune.length + 3).map((e) => UnitGroup.from(e, "infection")).toList();
      return Tuple2(immune, infection);
    },
    (Tuple2<List<UnitGroup>, List<UnitGroup>> data) => part1(data)!.abs(),
    part2,
  );
}

int? part1(Tuple2<List<UnitGroup>, List<UnitGroup>> data) {
  var immune = {...data.item1};
  var infection = {...data.item2};
  var everything = [...immune, ...infection];

  while (immune.isNotEmpty && infection.isNotEmpty) {
    // target selection
    everything.sort();
    var chosen = <UnitGroup, UnitGroup>{}; // target: aggresor
    for (var ug in everything) {
      var enemies = ug.kind == "immune" ? infection : immune;
      var possibleEnemies =
          enemies.where((e) => !chosen.containsKey(e)).where((e) => ug.dmgTo(e) > 0);
      if (possibleEnemies.isEmpty) continue;
      var target = ug.chooseTarget(possibleEnemies);
      chosen.putIfAbsent(target, () => ug);
    }

    // attack phase
    var stalemate = true;
    var attacks = chosen.entries.toList()
      ..sort((a, b) => b.value.initiative - a.value.initiative); // DESC initiative
    for (var attack in attacks) {
      var aggressor = attack.value;
      var target = attack.key;
      if (aggressor.size <= 0) continue;

      var delta = aggressor.dmgTo(target) ~/ target.hp; // attack
      if (delta != 0) stalemate = false;
      target.size -= delta;

      if (target.size <= 0) {
        immune.remove(target);
        infection.remove(target);
        everything.remove(target);
      }
    }

    if (stalemate) return null;
  }

  return everything.map((e) => e.kind == "immune" ? e.size : -e.size).reduce((a, b) => a + b);
}

int part2(Tuple2<List<UnitGroup>, List<UnitGroup>> data) {
  var immune = data.item1;
  var infection = data.item2;
  var everything = [...immune, ...infection];

  var lo = 0, hi = 100000;
  while (lo + 1 <= hi) {
    var mid = (lo + hi) ~/ 2;

    everything.forEach((e) => e.reset());
    immune.forEach((e) => e.boost = mid);

    var result = part1(data);
    if (result == null || result <= 0) {
      lo = mid + 1;
    } else {
      if (result > 0) hi = mid;
    }
  }
  // evaluate smallest boost
  everything.forEach((e) => e.reset());
  immune.forEach((e) => e.boost = lo);

  return part1(data)!;
}

class UnitGroup implements Comparable<UnitGroup> {
  late int size;
  int boost = 0;
  late final int _size;
  late final int hp, dmg, initiative;
  late final String dmgType;
  final Set<String> weaknesses = {}, immunities = {};
  final String kind, line;

  int get effectiveDmg => (dmg + boost) * size;
  bool operator ==(Object b) => b is UnitGroup && b.kind == kind && b.line == line;
  int get hashCode => Object.hash(kind, line);

  void reset() => size = _size;

  /// Parses single line like this:
  ///
  /// 418 units each with 17587 hit points (immune to fire, slashing; weak to radiation, cold)
  /// 0   1     2    3    4     5   6      7?
  ///
  /// with an attack that does 73 bludgeoning damage at initiative 6
  /// N-11 N-10 N-9  N-8  N-7  N-6 N-5        N-4    N-3 N-2       N-1
  UnitGroup.from(this.line, this.kind) {
    var parts = line.split(" ");

    size = int.parse(parts[0]);
    _size = int.parse(parts[0]);
    hp = int.parse(parts[4]);

    initiative = int.parse(parts[parts.length - 1]);
    dmgType = parts[parts.length - 5];
    dmg = int.parse(parts[parts.length - 6]);

    if (parts[7][0] != "(") return;

    var props = parts.sublist(7, parts.length - 11).join(" ");
    props = props.substring(1, props.length - 1); // cut parenthesis
    parts = props.split("; ");
    if (parts.length == 2) {
      if (parts[0][0] == "i") {
        immunities.addAll(parseProps(parts[0]));
        weaknesses.addAll(parseProps(parts[1]));
      } else {
        weaknesses.addAll(parseProps(parts[0]));
        immunities.addAll(parseProps(parts[1]));
      }
    } else if (parts[0][0] == "i") {
      immunities.addAll(parseProps(parts[0]));
    } else {
      weaknesses.addAll(parseProps(parts[0]));
    }
  }

  @override
  String toString() =>
      "[$kind] $size units each with $hp hit points (weak to ${weaknesses}; immune to ${immunities}) with an attack that does ${dmg + boost} radiation damage at initiative $initiative\n";

  @override
  int compareTo(UnitGroup b) {
    var ed = b.effectiveDmg - effectiveDmg;
    return ed == 0 ? b.initiative - initiative : ed;
  }

  UnitGroup chooseTarget(Iterable<UnitGroup> enemies) => (enemies.toList()
        ..sort((a, b) {
          var dmgToA = dmgTo(a);
          var dmgToB = dmgTo(b);
          if (dmgToA != dmgToB) return dmgToB - dmgToA; // DESC damage dealt
          var ed = b.effectiveDmg - a.effectiveDmg; // DESC enemy effective dmg
          if (ed != 0) return ed;
          return b.initiative - a.initiative; // DESC enemy initiative
        }))
      .first;

  int dmgTo(UnitGroup target) {
    if (target.immunities.contains(dmgType)) return 0;
    if (target.weaknesses.contains(dmgType)) return effectiveDmg * 2;
    return effectiveDmg;
  }
}

/// immune to fire, slashing
/// or
/// weak to foo, bar
List<String> parseProps(String data) => data.split(" to ")[1].split(", ");
