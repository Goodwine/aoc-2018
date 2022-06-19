import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';
import 'package:collection/collection.dart';

void main() => solve(process, part1, part2);

typedef Test = Tuple3<List<int>, List<int>, List<int>>;

Future<Tuple2<List<Test>, RawProgram>> process(String path) async {
  var data = await read(path);
  var parts = data.join("\n").split("\n\n\n\n");

  var tests = parts[0].split("\n\n").map((e) => e.split("\n")).map((e) {
    var before =
        e[0].substring("before: [".length, e[0].length - 1).split(", ").map(int.parse).toList();
    var input = e[1].split(" ").map(int.parse).toList();
    var after =
        e[2].substring("after:  [".length, e[2].length - 1).split(", ").map(int.parse).toList();

    return Test(before, input, after);
  }).toList();

  return Tuple2(tests, parts.length == 1 ? [] : rawProgram(parts[1].split("\n")));
}

final listEquals = const ListEquality().equals;

int part1(Tuple2<List<Test>, RawProgram> data) {
  var tests = data.item1;
  return tests.map((e) => possible(e, OpCode.values)).where((ops) => ops.length >= 3).length;
}

Set<OpCode> possible(Test test, Iterable<OpCode> opcodes) {
  Set<OpCode> good = {};
  for (final opcode in opcodes) {
    final comp = Computer(test.item1);
    comp.runSingle(opcode, test.item2[1], test.item2[2], test.item2[3]);
    if (listEquals(comp.reg, test.item3)) good.add(opcode);
  }
  return good;
}

int part2(Tuple2<List<Test>, RawProgram> data) {
  Iterable<Test> tests = data.item1;
  var program = data.item2;

  if (program.isEmpty) return 0;

  var mapping = List.generate(OpCode.values.length, (_) => OpCode.values.toSet());

  while (mapping.any((e) => e.length > 1)) {
    for (final test in tests) {
      var rawOp = test.item2[0];

      if (mapping[rawOp].length == 1) continue;
      mapping[rawOp] = possible(test, mapping[rawOp]);

      if (mapping[rawOp].length != 1) continue;
      for (final pending in mapping) {
        if (pending.length == 1) continue;
        pending.remove(mapping[rawOp].first);
      }
    }

    for (final op in mapping.where((e) => e.length == 1)) {
      for (final pending in mapping) {
        if (pending.length == 1) continue;
        pending.remove(op.first);
      }
    }
  }

  final comp = Computer([0, 0, 0, 0]);
  for (var line in program) {
    comp.runSingle(mapping[line[0]].first, line[1], line[2], line[3]);
  }
  return comp.reg[0];
}
