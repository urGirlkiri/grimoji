// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

class Vector2 {
  final double x, y;
  const Vector2(this.x, this.y);
  @override
  String toString() =>
      'Vector2(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)})';
}

void main() async {
  final File configFile = File('lib/config/emojis/index.dart');

  if (!await configFile.exists()) {
    print('ERROR: Could not find lib/config/emojis/index.dart');
    exit(1);
  }

  print('Reading emoji registry...');
  final String content = await configFile.readAsString();

  final RegExp emojiRegex = RegExp(
    r"static\s+(?:const|final)\s+GameEmoji\s+(\w+)\s*=\s*GameEmoji\s*\(\s*'([^']+)'\s*,\s*'([^']+)'\s*,\s*'([^']+)'[^;]*\);",
  );

  final matches = emojiRegex.allMatches(content).toList();

  if (matches.isEmpty) {
    print('CRITICAL ERROR: Found 0 emojis! Aborting to prevent file wipe.');
    print(
      'Check if the regex matches your lib/config/emojis/index.dart formatting.',
    );
    exit(1);
  }

  print(
    'Found ${matches.length} emojis to process. Generating physics hulls...',
  );

  final StringBuffer newFileBuffer = StringBuffer();

  newFileBuffer.writeln('/// GENERATED FILE - DO NOT EDIT MANUALLY');
  newFileBuffer.writeln(
    '/// Mapping for emojis with Lottie animations and auto-generated physics hulls.',
  );
  newFileBuffer.writeln(
    '/// Run dart run lib/config/emojis/physics.dart to update.',
  );
  newFileBuffer.writeln('');
  newFileBuffer.writeln('library;');
  newFileBuffer.writeln('import \'package:flame_forge2d/flame_forge2d.dart\';');
  newFileBuffer.writeln();
  newFileBuffer.writeln('class GameEmoji {');
  newFileBuffer.writeln('  final String svg;');
  newFileBuffer.writeln('  final String lottie;');
  newFileBuffer.writeln('  final String visual;');
  newFileBuffer.writeln('  final List<Vector2> physicsVertices;');
  newFileBuffer.writeln();
  newFileBuffer.writeln(
    '  const GameEmoji(this.svg, this.lottie, this.visual, this.physicsVertices);',
  );
  newFileBuffer.writeln('}');
  newFileBuffer.writeln();
  newFileBuffer.writeln('class Emojis {');
  newFileBuffer.writeln('  Emojis._();');
  newFileBuffer.writeln();

  int successCount = 0;

  for (final match in matches) {
    final String variableName = match.group(1)!;
    final String svgPath = match.group(2)!;
    final String lottiePath = match.group(3)!;
    final String visual = match.group(4)!;

    final File svgFile = File(svgPath);
    List<Vector2> finalHull = [];

    if (await svgFile.exists()) {
      final String svgContent = await svgFile.readAsString();

      final RegExp pathRegExp = RegExp(r'''d\s*=\s*["']([^"']+)["']''');
      final pathMatches = pathRegExp.allMatches(svgContent);

      List<Vector2> pointCloud = [];
      for (final pm in pathMatches) {
        final pathData = pm.group(1) ?? '';
        pointCloud.addAll(_parseSvgPath(pathData, curveSubdivisions: 4));
      }

      if (pointCloud.isNotEmpty) {
        final List<Vector2> hull = _computeConvexHull(pointCloud);
        final List<Vector2> decimatedHull = _decimateHull(hull, 8);
        finalHull = _normalizeHull(decimatedHull);
      }
    } else {
      print('WARNING: SVG file not found for $variableName -> $svgPath');
    }

    if (finalHull.isEmpty) {
      finalHull = _generateDefaultOctagon();
    }

    newFileBuffer.writeln(
      '  static final GameEmoji $variableName = GameEmoji(',
    );
    newFileBuffer.writeln('    \'$svgPath\',');
    newFileBuffer.writeln('    \'$lottiePath\',');
    newFileBuffer.writeln('    \'$visual\',');
    newFileBuffer.writeln('    [');
    for (final v in finalHull) {
      newFileBuffer.writeln(
        '      Vector2(${v.x.toStringAsFixed(3)}, ${v.y.toStringAsFixed(3)}),',
      );
    }
    newFileBuffer.writeln('    ],');
    newFileBuffer.writeln('  );');

    successCount++;
  }

  newFileBuffer.writeln('}');

  await configFile.writeAsString(newFileBuffer.toString());
  print(
    'SUCCESS: Processed $successCount emojis and updated lib/config/emojis/index.dart!',
  );
}

List<Vector2> _computeConvexHull(List<Vector2> points) {
  if (points.length <= 3) return points;
  points.sort((a, b) => a.x == b.x ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
  double cross(Vector2 o, Vector2 a, Vector2 b) {
    return (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);
  }

  List<Vector2> lower = [];
  for (var p in points) {
    while (lower.length >= 2 &&
        cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  List<Vector2> upper = [];
  for (var p in points.reversed) {
    while (upper.length >= 2 &&
        cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast();
  upper.removeLast();
  return [...lower, ...upper];
}

List<Vector2> _decimateHull(List<Vector2> hull, int maxVertices) {
  List<Vector2> current = List.from(hull);
  while (current.length > maxVertices) {
    double minArea = double.infinity;
    int minIndex = -1;
    for (int i = 0; i < current.length; i++) {
      int prev = (i - 1 + current.length) % current.length;
      int next = (i + 1) % current.length;
      double area =
          ((current[prev].x * (current[i].y - current[next].y)) +
                  (current[i].x * (current[next].y - current[prev].y)) +
                  (current[next].x * (current[prev].y - current[i].y)))
              .abs() /
          2.0;
      if (area < minArea) {
        minArea = area;
        minIndex = i;
      }
    }
    current.removeAt(minIndex);
  }
  return current;
}

List<Vector2> _normalizeHull(List<Vector2> hull) {
  if (hull.isEmpty) return hull;
  double minX = hull.map((p) => p.x).reduce(min);
  double maxX = hull.map((p) => p.x).reduce(max);
  double minY = hull.map((p) => p.y).reduce(min);
  double maxY = hull.map((p) => p.y).reduce(max);
  double cx = (minX + maxX) / 2;
  double cy = (minY + maxY) / 2;
  double maxDim = max(maxX - minX, maxY - minY);
  if (maxDim == 0) maxDim = 1;
  return hull
      .map((p) => Vector2((p.x - cx) / maxDim, (p.y - cy) / maxDim))
      .toList();
}

List<Vector2> _generateDefaultOctagon() {
  List<Vector2> points = [];
  for (int i = 0; i < 8; i++) {
    double angle = (i * pi * 2) / 8;
    points.add(Vector2(cos(angle) * 0.5, sin(angle) * 0.5));
  }
  return points;
}

List<Vector2> _parseSvgPath(String path, {int curveSubdivisions = 4}) {
  final List<Vector2> points = [];
  final RegExp regex = RegExp(
    r'([a-zA-Z])|(-?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)',
  );
  final List<String> matches = regex
      .allMatches(path)
      .map((m) => m.group(0)!)
      .toList();
  double cx = 0, cy = 0;
  String currentCmd = '';
  int i = 0;
  while (i < matches.length) {
    final String token = matches[i];
    if (RegExp(r'[a-zA-Z]').hasMatch(token)) {
      currentCmd = token;
      i++;
      if (i >= matches.length) break;
    }
    if (RegExp(r'[a-zA-Z]').hasMatch(matches[i])) continue;
    if (currentCmd == 'M' || currentCmd == 'm') {
      cx = (currentCmd == 'm')
          ? cx + double.parse(matches[i++])
          : double.parse(matches[i++]);
      cy = (currentCmd == 'm')
          ? cy + double.parse(matches[i++])
          : double.parse(matches[i++]);
      points.add(Vector2(cx, cy));
      currentCmd = (currentCmd == 'm') ? 'l' : 'L';
    } else if (currentCmd == 'L' || currentCmd == 'l') {
      cx = (currentCmd == 'l')
          ? cx + double.parse(matches[i++])
          : double.parse(matches[i++]);
      cy = (currentCmd == 'l')
          ? cy + double.parse(matches[i++])
          : double.parse(matches[i++]);
      points.add(Vector2(cx, cy));
    } else if (currentCmd == 'H' || currentCmd == 'h') {
      cx = (currentCmd == 'h')
          ? cx + double.parse(matches[i++])
          : double.parse(matches[i++]);
      points.add(Vector2(cx, cy));
    } else if (currentCmd == 'V' || currentCmd == 'v') {
      cy = (currentCmd == 'v')
          ? cy + double.parse(matches[i++])
          : double.parse(matches[i++]);
      points.add(Vector2(cx, cy));
    } else if (currentCmd == 'C' || currentCmd == 'c') {
      double cp1x = double.parse(matches[i++]);
      double cp1y = double.parse(matches[i++]);
      double cp2x = double.parse(matches[i++]);
      double cp2y = double.parse(matches[i++]);
      double ex = double.parse(matches[i++]);
      double ey = double.parse(matches[i++]);
      if (currentCmd == 'c') {
        cp1x += cx;
        cp1y += cy;
        cp2x += cx;
        cp2y += cy;
        ex += cx;
        ey += cy;
      }
      for (int step = 1; step <= curveSubdivisions; step++) {
        double t = step / curveSubdivisions;
        double mt = 1 - t;
        points.add(
          Vector2(
            pow(mt, 3) * cx +
                3 * pow(mt, 2) * t * cp1x +
                3 * mt * pow(t, 2) * cp2x +
                pow(t, 3) * ex,
            pow(mt, 3) * cy +
                3 * pow(mt, 2) * t * cp1y +
                3 * mt * pow(t, 2) * cp2y +
                pow(t, 3) * ey,
          ),
        );
      }
      cx = ex;
      cy = ey;
    } else if (currentCmd == 'Z' || currentCmd == 'z') {
      if (points.isNotEmpty) {
        cx = points.first.x;
        cy = points.first.y;
      }
    } else {
      i++;
    }
  }
  return points;
}
