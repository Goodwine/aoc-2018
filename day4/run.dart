import 'package:aoc2018/aoc.dart';

void main() {
  solve(
    (String path) async => (await read(path)).map(Instruction.parse),
    part1,
    part2,
  );
}

int part1(Iterable<Instruction> data) => 0;

int part2(Iterable<Instruction> data) => 0;

class Grid {}

enum Action { start, sleep, wake }

class Instruction {
  int year, month, day;
  int hour, minute;
  int? guard;
  Action action;

  Instruction(this.year, this.month, this.day, this.hour, this.minute, this.action, [this.guard]);

  /*
   * [1518-11-01 00:00] Guard #10 begins shift
   * [1518-11-01 00:05] falls asleep
   * [1518-11-01 00:25] wakes up
   */
  static Instruction parse(String line) {
    var parts = line.split("] ");

    var timestamp = parts[0].substring(1).split(" ");
    var date = timestamp[0].split("-").map(int.parse).toList(growable: false);
    var time = timestamp[1].split(":").map(int.parse).toList(growable: false);

    switch (parts[1][0]) {
      case 'f':
        return Instruction(date[0], date[1], date[2], time[0], time[1], Action.sleep);
      case 'w':
        return Instruction(date[0], date[1], date[2], time[0], time[1], Action.wake);
    }

    var guard = int.parse(parts[1].split("#")[1].split(" ")[0]);

    return Instruction(date[0], date[1], date[2], time[0], time[1], Action.wake, guard);
  }
}
