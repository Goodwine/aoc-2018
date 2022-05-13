import 'dart:io';
import "package:path/path.dart" show dirname;
import 'package:tuple/tuple.dart';

void solve<T, D>(
  Future<D> Function(String path) reader,
  T Function(D) part1,
  T Function(D) part2,
) async {
  await _solve("small", reader, part1, part2);
  await _solve("input", reader, part1, part2);
}

Future<void> _solve<T, D>(
  String size,
  Future<D> Function(String path) reader,
  T Function(D) part1,
  T Function(D) part2,
) async {
  var path = dirname(Platform.script.path);

  print("$size:");
  var dataTuple = timeRun(() => reader("${path}/${size}.txt"));
  var data = await dataTuple.item2;
  print("read   - [${dataTuple.item1}]");
  print("part 1 - ${timeRun(() => part1(data))}");
  print("part 2 - ${timeRun(() => part2(data))}\n");
}

Tuple2<String, T> timeRun<T, D>(T Function() fn) {
  Stopwatch sw = new Stopwatch()..start();
  T result = fn();
  return Tuple2(formatDuration(sw.elapsed), result);
}

String formatDuration(Duration duration) {
  var micros = duration.inMicroseconds;
  var millis = duration.inMilliseconds;
  var seconds = duration.inSeconds;
  var minutes = duration.inMinutes;

  var pretty = "";
  if (minutes > 0) {
    pretty += "${minutes}m";
    seconds -= minutes * 60;
    millis -= minutes * 60 * 1000;
    micros -= minutes * 60 * 1000 * 1000;
  }
  if (seconds > 0) {
    pretty += "${seconds}s";
    millis -= seconds * 1000;
    micros -= seconds * 1000 * 1000;
  }
  if (millis > 0) {
    pretty += "${millis}ms";
    micros -= millis * 1000;
  }
  if (micros > 0) {
    pretty += "${micros}µ";
  }
  return pretty;
}

Future<Iterable<int>> readInts(String path) async {
  return (await read(path)).map(int.parse);
}

Future<List<String>> read(String path) {
  File f = new File(path);
  return f.readAsLines();
}
