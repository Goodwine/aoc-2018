import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve((path) async {
    var lines = await read(path);
    var immune = lines.takeWhile((value) => value.isNotEmpty).skip(1).map(UnitGroup.from).toList();
    var infection = lines.sublist(immune.length + 3).map(UnitGroup.from).toList();
    return Tuple2(immune, infection);
  }, part1, part2);
}

int part1(Tuple2<List<UnitGroup>, List<UnitGroup>> data) {
  print(data);
  return 0;
}

int part2(Tuple2<List<UnitGroup>, List<UnitGroup>> data) {
  return 0;
}

class UnitGroup {
  late int size, hp;
  late final dmg, initiative;
  late final String dmgType;
  final Set<String> weaknesses = {}, immunities = {};

  /// Parses single line like this:
  ///
  /// 418 units each with 17587 hit points (immune to fire, slashing; weak to radiation, cold)
  /// 0   1     2    3    4     5   6      7?
  ///
  /// with an attack that does 73 bludgeoning damage at initiative 6
  /// N-11 N-10 N-9  N-8  N-7  N-6 N-5        N-4    N-3 N-2       N-1
  UnitGroup.from(String line) {
    var parts = line.split(" ");

    size = int.parse(parts[0]);
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
      "$size units each with $hp hit points (weak to ${weaknesses}; immune to ${immunities}) with an attack that does $dmg radiation damage at initiative $initiative\n";
}

/// immune to fire, slashing
/// or
/// weak to foo, bar
List<String> parseProps(String data) => data.split(" to ")[1].split(", ");
