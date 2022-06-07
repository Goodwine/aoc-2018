import 'dart:io';
import "package:path/path.dart" show dirname;
import 'package:tuple/tuple.dart';

void solve<T, D>(Future<D> Function(String path) reader, T Function(D) part1, T Function(D) part2,
    {String extra = "", bool skipSmall = false}) async {
  if (!skipSmall) {
    await _solve("small", reader, part1, part2);
  }
  if (extra != "") {
    await _solve(extra, reader, part1, part2);
  }
  await _solve("input", reader, part1, part2);
}

String sourceDir() => dirname(Platform.script.path);

Future<void> _solve<T, D>(
  String size,
  Future<D> Function(String path) reader,
  T Function(D) part1,
  T Function(D) part2,
) async {
  print("$size:");
  var dataTuple = await timeRun(() => reader("${sourceDir()}/${size}.txt"));
  var data = await dataTuple.item2;
  print("read   - [${dataTuple.item1}]");
  print("part 1 - ${await timeRun(() async => await part1(data))}");
  print("part 2 - ${await timeRun(() async => await part2(data))}\n");
}

Future<Tuple2<String, T>> timeRun<T, D>(T Function() fn) async {
  Stopwatch sw = new Stopwatch()..start();
  T result = await fn();
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

Future<Iterable<int>> readLineInts(String path) async {
  return (await read(path)).expand((e) => e.split(" ")).map(int.parse);
}

Future<List<String>> read(String path) {
  File f = new File(path);
  return f.readAsLines();
}

class DLinkedList<T> {
  T value;
  late DLinkedList<T> prev, next;

  DLinkedList(this.value) {
    prev = this;
    next = this;
  }

  DLinkedList<T> add(T v) {
    // Between the marbles 1 and 2 positions clockwise. Meaning after "next".
    var current = next;

    // New marbe with the correct pointers.
    var element = DLinkedList(v);
    element.next = current.next;
    element.prev = current;

    // Replace previous references to cross through new marble.
    current.next.prev = element;
    current.next = element;
    // New marble becomes curret.
    return element;
  }

  DLinkedList<T> remove() {
    // Just delete the references to this marble.
    prev.next = next;
    next.prev = prev;
    // Marble clockwise to the one removed becomes current.
    return next;
  }
}

enum Direction {
  up(dy: -1, dx: 0),
  right(dy: 0, dx: 1),
  down(dy: 1, dx: 0),
  left(dy: 0, dx: -1);

  const Direction({
    required this.dy,
    required this.dx,
  });
  final int dy, dx;
}

const directions = [
  Direction.up,
  Direction.right,
  Direction.down,
  Direction.left,
];
