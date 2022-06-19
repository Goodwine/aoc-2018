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
  Direction.left,
  Direction.right,
  Direction.down,
];

const cornerDirections = [
  [Direction.up],
  [Direction.left],
  [Direction.right],
  [Direction.down],
  [Direction.up, Direction.left],
  [Direction.up, Direction.right],
  [Direction.down, Direction.left],
  [Direction.down, Direction.right],
];

class Point {
  final int x, y, id;
  const Point(this.x, this.y, [this.id = -1]);

  Iterable<Point> next(int maxSize, {bool corners = false}) {
    Iterable<Point> points;
    if (corners) {
      points = cornerDirections.map((ds) {
        int dx = ds.map((e) => e.dx).reduce((acc, v) => acc + v);
        int dy = ds.map((e) => e.dy).reduce((acc, v) => acc + v);
        return Point(x + dx, y + dy, id);
      });
    } else {
      points = directions.map((d) => Point(x + d.dx, y + d.dy, id));
    }

    return points.where((p) => p.x >= 0 && p.y >= 0 && p.x < maxSize && p.y < maxSize);
  }

  Point move(Direction dir) => Point(x + dir.dx, y + dir.dy, id);

  int distance(Point p) => (p.x - x).abs() + (p.y - y).abs();

  String toString() => "(ID=$id)[x:$x,y:$y]";

  @override
  operator ==(that) {
    if (that is! Point) throw Exception("invalid comparison");
    return that.x == x && that.y == y;
  }

  @override
  int get hashCode => Object.hash(x, y);
}

enum OpCode {
  addr,
  addi,

  mulr,
  muli,

  andr,
  andi,

  orr,
  ori,

  setr,
  seti,

  gtir,
  gtri,
  gtrr,

  eqir,
  eqri,
  eqrr,
}

typedef Program = List<Tuple4<OpCode, int, int, int>>;
typedef RawProgram = List<List<int>>;

RawProgram rawProgram(Iterable<String> input) =>
    input.map((e) => e.split(" ").map(int.parse).toList()).toList();

Program parseProgram(Iterable<String> input) {
  return input
      .map((e) => e.split(" "))
      .map((e) => Tuple4(
            OpCode.values.asNameMap()[e[0]]!,
            int.parse(e[1]),
            int.parse(e[2]),
            int.parse(e[3]),
          ))
      .toList();
}

class Computer {
  late final List<int> reg;

  Computer(List<int> reg) {
    this.reg = [...reg];
  }

  void run(Program program, final int pcRegister, {int timeout = 10000000000}) {
    for (var i = 0; i < timeout; i++) {
      if (reg[pcRegister] >= program.length) break;

      var line = program[reg[pcRegister]];
      runSingle(line.item1, line.item2, line.item3, line.item4);
      reg[pcRegister]++;
    }
  }

  void runSingle(
    OpCode opcode,
    int a,
    int b,
    int out,
  ) {
    switch (opcode) {
      case OpCode.addr:
        reg[out] = reg[a] + reg[b];
        break;
      case OpCode.addi:
        reg[out] = reg[a] + b;
        break;
      case OpCode.mulr:
        reg[out] = reg[a] * reg[b];
        break;
      case OpCode.muli:
        reg[out] = reg[a] * b;
        break;
      case OpCode.andr:
        reg[out] = reg[a] & reg[b];
        break;
      case OpCode.andi:
        reg[out] = reg[a] & b;
        break;
      case OpCode.orr:
        reg[out] = reg[a] | reg[b];
        break;
      case OpCode.ori:
        reg[out] = reg[a] | b;
        break;
      case OpCode.gtir:
        reg[out] = a > reg[b] ? 1 : 0;
        break;
      case OpCode.gtri:
        reg[out] = reg[a] > b ? 1 : 0;
        break;
      case OpCode.gtrr:
        reg[out] = reg[a] > reg[b] ? 1 : 0;
        break;
      case OpCode.eqir:
        reg[out] = a == reg[b] ? 1 : 0;
        break;
      case OpCode.eqri:
        reg[out] = reg[a] == b ? 1 : 0;
        break;
      case OpCode.eqrr:
        reg[out] = reg[a] == reg[b] ? 1 : 0;
        break;
      case OpCode.setr:
        reg[out] = reg[a];
        break;
      case OpCode.seti:
        reg[out] = a;
        break;
    }
  }
}
