import 'dart:io';
import 'package:tuple/tuple.dart';

void main() {
  print("part 1 - ${part1()}");
  print("part 2 - ${part2()}");
}

Tuple2<T, String> timeRun<T, D>(T Function() fn) {
  Stopwatch sw = new Stopwatch()..start();
  T result = fn();
  return Tuple2(result, sw.elapsed.toString());
}

Future<List<String>> read(String path) async {
  File f = new File(path);
  return f.readAsLines();
}

int part1() {
  return 1;
}

int part2() {
  return 1;
}
