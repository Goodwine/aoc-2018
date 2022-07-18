import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (path) async => (await read(path)).map((v) => v.split(", ")).map((parts) {
      var coordinates = parts[0]
          .substring("pos=<".length, parts[0].length - 1)
          .split(",")
          .map(int.parse)
          .toList();
      var range = int.parse(parts[1].substring("r=".length));
      return Robot(coordinates[0], coordinates[1], coordinates[2], range);
    }).toList(),
    part1,
    part2,
    extra: "medium",
  );
}

class Robot {
  final int x, y, z, range;
  const Robot(this.x, this.y, this.z, this.range);

  int dist(Robot b) => (x - b.x).abs() + (y - b.y).abs() + (z - b.z).abs();
}

int part1(List<Robot> data) {
  var strongest = data.reduce((m, v) => v.range > m.range ? v : m);
  return data.map(strongest.dist).where((d) => d <= strongest.range).length;
}

int part2(List<Robot> data) {
  return 0;
}
