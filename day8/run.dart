import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    ((path) async => Node(1)..process((await readLineInts(path)).toList())),
    part1,
    part2,
    // https://www.reddit.com/r/adventofcode/comments/a4kmic/
    extra: "medium",
  );
}

class Node {
  final int id;
  late List<int> metadata;
  List<Node> children = [];

  Node(this.id);

  /// Process the data and return whatever wasn't processed, aka "the rest".
  Tuple2<List<int>, int> process(List<int> data) {
    var nodeLength = data[0];
    var metaLength = data[1];

    assert(metaLength > 0);

    var lastId = id;
    data = data.sublist(2);
    while (nodeLength-- > 0) {
      var n = Node(lastId + 1);
      children.add(n);
      var result = n.process(data);
      data = result.item1;
      lastId = result.item2;
    }

    metadata = data.sublist(0, metaLength);
    return Tuple2(data.sublist(metaLength), lastId);
  }

  String toString() => "$metadata: $children";

  int checksum() => children.map((e) => e.checksum()).followedBy(metadata).reduce((a, b) => a + b);

  late int _beterChecksum = -1;
  int betterChecksum() {
    if (_beterChecksum != -1) return _beterChecksum;

    var addUp = children.isEmpty
        ? metadata
        : metadata
            .map((e) => e - 1)
            .where((e) => e < children.length)
            .map((e) => children[e].betterChecksum());

    _beterChecksum = addUp.fold<int>(0, (a, b) => a + b);
    return _beterChecksum;
  }
}

int part1(Node data) {
  return data.checksum();
}

int part2(Node data) {
  return data.betterChecksum();
}
