import 'package:aoc2018/aoc.dart';

void main() {
  solve(
    (path) async => grid((await readInts(path)).first),
    part1,
    part2,
    extra: "medium",
  );
}

const size = 300;
List<List<int>> grid(int serialNumber) =>
    List.generate(size, (y) => List.generate(size, (x) => powerLevel(x + 1, y + 1, serialNumber)));

/**
 * - Find the fuel cell's rack ID, which is its X coordinate plus 10.
 * - Begin with a power level of the rack ID times the Y coordinate.
 * - Increase the power level by the value of the grid serial number (your puzzle input).
 * - Set the power level to itself multiplied by the rack ID.
 * - Keep only the hundreds digit of the power level (so 12345 becomes 3; numbers with no hundreds digit become 0).
 * - Subtract 5 from the power level.
 */
int powerLevel(int x, int y, int serialNumber) {
  var rackId = (x + 10);
  var power = (rackId * y + serialNumber) * rackId;
  var digit = (power % 1000) ~/ 100;
  return digit - 5;
}

int square(List<List<int>> data, int x, int y, int s) {
  var sum = 0;
  for (var dy = 0; dy < s && y + dy < size; dy++) {
    for (var dx = 0; dx < s && x + dx < size; dx++) {
      sum += data[y + dy][x + dx];
    }
  }
  return sum;
}

List<int> maxForSize(List<List<int>> data, int s) {
  var max = -1000;
  var mx = -1;
  var my = -1;

  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      var v = square(data, x, y, s);
      if (v > max) {
        max = v;
        mx = x;
        my = y;
      }
    }
  }

  return [mx + 1, my + 1, max];
}

Iterable<int> part1(List<List<int>> data) => maxForSize(data, 3).take(2);

Iterable<int> part2(List<List<int>> data) {
  var max = -1000;
  var mx = -1;
  var my = -1;
  var ms = -1;

  for (var s = 1; s <= 30; s++) {
    var v = maxForSize(data, s);
    if (v[2] > max) {
      max = v[2];
      mx = v[0];
      my = v[1];
      ms = s;
    }
  }

  return [mx, my, ms];
}
