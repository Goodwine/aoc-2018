import 'package:aoc2018/aoc.dart';
import 'package:tuple/tuple.dart';

void main() {
  solve(
    (String path) async => Schedule.process((await read(path)).map(Instruction.parse)),
    part1,
    part2,
  );
}

int part1(Schedule schedule) {
  var mostAsleep = schedule.timeline
      .where((state) => !state.awake)
      .fold<Map<int, int>>(
          Map<int, int>(),
          (acc, state) => acc
            ..putIfAbsent(state.who, () => 0)
            ..update(state.who, (c) => c + state.duration.inMinutes))
      .entries
      .reduce((max, v) => max.value < v.value ? v : max)
      .key;

  var mostMinute = schedule.mostMinute(mostAsleep).key;

  return mostAsleep * mostMinute;
}

int part2(Schedule schedule) {
  var mostMinute = schedule.timeline
      .map((e) => e.who)
      .toSet()
      .map((e) => Tuple2(e, schedule.mostMinute(e)))
      .reduce((max, v) => max.item2.value < v.item2.value ? v : max);

  return mostMinute.item1 * mostMinute.item2.key;
}

class State {
  int who;
  DateTime start;
  Duration duration;
  bool awake;

  State(this.who, this.start, this.duration, this.awake);
}

class Schedule {
  List<State> timeline = [];

  Schedule.process(Iterable<Instruction> data) {
    var ins = data.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    var lastTime = ins.first.timestamp;
    var lastState = Action.awake;
    var guard = ins.first.guard!;

    for (var ins in ins.skip(1)) {
      var duration = ins.timestamp.difference(lastTime);
      assert(!duration.isNegative);

      timeline.add(State(guard, lastTime, duration, lastState != Action.sleep));

      if (ins.guard != null) guard = ins.guard!;
      lastTime = ins.timestamp;
      lastState = ins.action;
    }
  }

  MapEntry<int, int> mostMinute(int who) => timeline
      .where((state) => state.who == who && state.awake == false)
      .map((state) => List.generate(state.duration.inMinutes, (i) => (state.start.minute + i) % 60))
      .expand((v) => v)
      .fold<Map<int, int>>(
          Map<int, int>(),
          (acc, min) => acc
            ..putIfAbsent(min, () => 0)
            ..update(min, (c) => c + 1))
      .entries
      .fold(MapEntry<int, int>.new(0, 0), (max, v) => max.value < v.value ? v : max);
}

enum Action { start, sleep, awake }

class Instruction {
  DateTime timestamp;
  int? guard;
  Action action;

  Instruction(this.timestamp, this.action, [this.guard]);

  /*
   * [1518-11-01 00:00] Guard #10 begins shift
   * [1518-11-01 00:05] falls asleep
   * [1518-11-01 00:25] wakes up
   */
  static Instruction parse(String line) {
    var parts = line.split("] ");
    var timestamp = DateTime.parse(parts[0].substring(1));

    switch (parts[1][0]) {
      case 'f':
        return Instruction(timestamp, Action.sleep);
      case 'w':
        return Instruction(timestamp, Action.awake);
    }

    var guard = int.parse(parts[1].split("#")[1].split(" ")[0]);

    return Instruction(timestamp, Action.awake, guard);
  }
}
