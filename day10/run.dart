import 'dart:math';
import 'package:dart_console/dart_console.dart';
import 'package:aoc2018/aoc.dart';
import 'dart:io';
import 'package:image/image.dart';

void main() {
  solve(
    (path) async => (await read(path)).map(Particle.from).toList(),
    part1,
    part2,
  );
}

const posLength = "position=<".length;

class Particle {
  late int x, y;
  final int ox, oy;
  final int dx, dy;

  Particle(this.ox, this.oy, this.dx, this.dy) {
    x = ox;
    y = oy;
  }

  factory Particle.from(String line) {
    var data = line
        // ["x, y", "dx, dy"]
        .substring(posLength, line.length - 1)
        .split("> velocity=<")
        // [x, y, dx, dy]
        .expand((e) => e.split(","))
        .map(int.parse)
        .toList();

    return Particle(data[0], data[1], data[2], data[3]);
  }

  void update() {
    x += dx;
    y += dy;
  }
}

const canvasSize = 100;

bool sky(List<Particle> particles, int count) {
  var minX = particles.map((e) => e.x).reduce(min);
  var maxX = particles.map((e) => e.x).reduce(max);

  var minY = particles.map((e) => e.y).reduce(min);
  var maxY = particles.map((e) => e.x).reduce(max);

  if ((maxX - minX).abs() > canvasSize) {
    // print("file too big, skipping");
    // print("minX:$minX,maxX:$maxX,minY:$minY,maxY:$maxY");
    return false;
  }

  // https://github.com/brendan-duncan/image/wiki/Examples
  Image image = Image(canvasSize, canvasSize + 14);
  fill(image, getColor(15, 15, 35));

  for (var pixel in particles) {
    drawPixel(
      image,
      (pixel.x - minX) % canvasSize,
      (pixel.y - minY) % canvasSize,
      getColor(204, 204, 204),
    );
  }

  drawString(
    image,
    arial_14,
    0,
    canvasSize,
    count.toString(),
    color: getColor(255, 255, 102),
  );

  File("${sourceDir()}/output.png").writeAsBytesSync(encodePng(image));
  return true;
}

Future<String> part1(List<Particle> data) async {
  final console = Console();

  for (var i = 0;; i++) {
    var result = await timeRun(() {
      var res = sky(data, i);
      for (var pixel in data) {
        pixel.update();
      }
      return res;
    });
    if (!result.item2) continue;

    print("... took ${result.item1} - press ENTER with empty line to continue.");

    if (stdin.readLineSync()!.trim().isNotEmpty) break;
  }

  return "Read output.png";
}

String part2(List<Particle> data) => "Read output.png";
