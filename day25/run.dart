import 'package:aoc2018/aoc.dart';

void main() {
  solve(
    (path) async => (await read(path)).map(P4.from).toSet(),
    part1,
    part2,
    extra: "medium",
  );
}

int part1(Set<P4> data) {
  var count = 0;
  while (data.isNotEmpty) {
    var prevSize = 0;
    var constelation = {data.first};
    while (prevSize != constelation.length) {
      prevSize = constelation.length;
      constelation.addAll(data.where((e) => constelation.map(e.dist).any((d) => d <= 3)));
      data.removeAll(constelation);
    }
    count++;
  }
  return count;
}

int part2(Set<P4> data) => 0;

class P4 {
  final int x, y, z, w;

  @override
  operator ==(Object b) => b is P4 && x == b.x && y == b.y && z == b.z && w == b.w;
  @override
  int get hashCode => Object.hash(x, y, z, w);

  P4(this.x, this.y, this.z, this.w);
  factory P4.from(String line) {
    var c = line.split(",").map(int.parse).toList();
    return P4(c[0], c[1], c[2], c[3]);
  }

  int dist(P4 b) => (x - b.x).abs() + (y - b.y).abs() + (z - b.z).abs() + (w - b.w).abs();
}
