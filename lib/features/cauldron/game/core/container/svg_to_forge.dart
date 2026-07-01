// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

class Vector2 {
  final double x, y;
  const Vector2(this.x, this.y);
  @override
  String toString() =>
      'Vector2(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})';
}

void main() async {
  const String svgInputPath = 'assets/images/cauldron/path.svg';
  const String dartOutputPath =
      'lib/features/cauldron/game/core/container/vertices.dart';
  const double targetWorldWidth = 10.5;

  final File svgFile = File(svgInputPath);
  if (!await svgFile.exists()) {
    print(
      'ERROR: Missing target vector asset file at: ${svgFile.absolute.path}',
    );
    exit(1);
  }

  print('Processing source coordinates from: $svgInputPath...');
  final String rawSvgContent = await svgFile.readAsString();

  final Map<String, double> canvasSize = _extractCanvasSize(rawSvgContent);
  if (canvasSize['width'] == 0 || canvasSize['height'] == 0) {
    print(
      'ERROR: Could not parse viewBox or width/height attributes from the SVG tag.',
    );
    exit(1);
  }

  final double svgCanvasWidth = canvasSize['width']!;
  final double svgCanvasHeight = canvasSize['height']!;
  print('Detected SVG Canvas Size: ${svgCanvasWidth}x$svgCanvasHeight');

  final strokeWidthRegExp = RegExp(r'''stroke-width\s*=\s*["']([\d.]+)["']''');
  final strokeMatch = strokeWidthRegExp.firstMatch(rawSvgContent);
  final double strokeWidth = strokeMatch != null
      ? double.parse(strokeMatch.group(1)!)
      : 0.0;
  print('Detected Stroke Width: $strokeWidth');

  final String svgPathData = _extractPathData(rawSvgContent);
  if (svgPathData.isEmpty) {
    print(
      'ERROR: Failed to parse a valid <path d="..." /> definition out of the SVG.',
    );
    exit(1);
  }

  final List<Vector2> rawPoints = parseSvgPath(
    svgPathData,
    curveSubdivisions: 6,
  );
  if (rawPoints.isEmpty) {
    print('ERROR: No valid coordinates extracted from the path string.');
    exit(1);
  }

  final List<Vector2> filteredPoints = removeCollinear(
    rawPoints,
    epsilon: 0.05,
  );

  final List<Vector2> thickenedPoints = thickenPath(
    filteredPoints,
    strokeWidth,
  );

  final double scale = targetWorldWidth / svgCanvasWidth;
  final double offsetX = svgCanvasWidth / 2;
  final double offsetY = svgCanvasHeight / 2;

  final File outputFile = File(dartOutputPath);
  final Directory outputDir = outputFile.parent;
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final StringBuffer codeBuffer = StringBuffer();
  codeBuffer.writeln('import \'package:flame_forge2d/flame_forge2d.dart\';');
  codeBuffer.writeln();
  codeBuffer.writeln('/// GENERATED FILE - DO NOT EDIT MANUALLY');
  codeBuffer.writeln(
    '/// Run lib/features/cauldron/game/core/container/svg_to_forge.dart',
  );
  codeBuffer.writeln('/// To Generate');
  codeBuffer.writeln();
  codeBuffer.writeln('final List<Vector2> vertices = [');

  for (final point in thickenedPoints) {
    final double worldX = (point.x - offsetX) * scale;
    final double worldY = (point.y - offsetY) * scale;
    codeBuffer.writeln(
      '  Vector2(${worldX.toStringAsFixed(2)}, ${worldY.toStringAsFixed(2)}),',
    );
  }
  codeBuffer.writeln('];');

  await outputFile.writeAsString(codeBuffer.toString());

  print(
    'SUCCESS: Normalized data array generated cleanly! Vertex count: ${thickenedPoints.length}',
  );
  print('Target output written to: -> ${outputFile.absolute.path}');
}

Vector2 _sub(Vector2 a, Vector2 b) => Vector2(a.x - b.x, a.y - b.y);

Vector2 _normalize(Vector2 v) {
  final double len = sqrt(v.x * v.x + v.y * v.y);
  return len == 0 ? const Vector2(0, 0) : Vector2(v.x / len, v.y / len);
}

List<Vector2> thickenPath(List<Vector2> points, double strokeWidth) {
  if (strokeWidth <= 0 || points.length < 2) return points;

  final double hw = strokeWidth / 2;
  final List<Vector2> outer = [];
  final List<Vector2> inner = [];

  for (int i = 0; i < points.length; i++) {
    Vector2 n;

    if (i == 0) {
      final d = _normalize(_sub(points[1], points[0]));
      n = Vector2(-d.y, d.x);
    } else if (i == points.length - 1) {
      final d = _normalize(_sub(points[i], points[i - 1]));
      n = Vector2(-d.y, d.x);
    } else {
      final d1 = _normalize(_sub(points[i], points[i - 1]));
      final d2 = _normalize(_sub(points[i + 1], points[i]));
      final n1 = Vector2(-d1.y, d1.x);
      final n2 = Vector2(-d2.y, d2.x);

      n = _normalize(Vector2(n1.x + n2.x, n1.y + n2.y));

      final double dot = n1.x * n2.x + n1.y * n2.y;
      double miterFactor = 1.0;
      if (dot > -0.99) {
        miterFactor = 1.0 / sqrt((1 + dot) / 2);
      }
      n = Vector2(n.x * miterFactor, n.y * miterFactor);
    }

    final offset = Vector2(n.x * hw, n.y * hw);
    outer.add(Vector2(points[i].x + offset.x, points[i].y + offset.y));
    inner.add(Vector2(points[i].x - offset.x, points[i].y - offset.y));
  }

  final List<Vector2> result = [...outer, ...inner.reversed];
  result.add(outer.first);
  return result;
}

Map<String, double> _extractCanvasSize(String svgContent) {
  final viewBoxRegExp = RegExp(
    r'''viewBox\s*=\s*["'][\d.\-]+\s+[\d.\-]+\s+([\d.]+)\s+([\d.]+)["']''',
  );
  final viewBoxMatch = viewBoxRegExp.firstMatch(svgContent);

  if (viewBoxMatch != null) {
    return {
      'width': double.parse(viewBoxMatch.group(1)!),
      'height': double.parse(viewBoxMatch.group(2)!),
    };
  }

  final widthRegExp = RegExp(r'''<svg[^>]*\swidth\s*=\s*["']([\d.]+)''');
  final heightRegExp = RegExp(r'''<svg[^>]*\sheight\s*=\s*["']([\d.]+)''');
  final widthMatch = widthRegExp.firstMatch(svgContent);
  final heightMatch = heightRegExp.firstMatch(svgContent);

  if (widthMatch != null && heightMatch != null) {
    return {
      'width': double.parse(widthMatch.group(1)!),
      'height': double.parse(heightMatch.group(1)!),
    };
  }

  return {'width': 0.0, 'height': 0.0};
}

String _extractPathData(String svgContent) {
  final pathRegExp = RegExp(r'''d\s*=\s*["']([^"']+)["']''');
  final match = pathRegExp.firstMatch(svgContent);
  return match?.group(1) ?? '';
}

List<Vector2> removeCollinear(List<Vector2> points, {double epsilon = 0.05}) {
  if (points.length < 3) return points;
  final List<Vector2> result = [points.first];
  for (int i = 1; i < points.length - 1; i++) {
    final Vector2 a = result.last;
    final Vector2 b = points[i];
    final Vector2 c = points[i + 1];
    final double crossProduct =
        (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);
    if (crossProduct.abs() > epsilon) {
      result.add(b);
    }
  }
  result.add(points.last);
  return result;
}

List<Vector2> parseSvgPath(String path, {int curveSubdivisions = 6}) {
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
      final nx = double.parse(matches[i++]);
      final ny = double.parse(matches[i++]);
      cx = (currentCmd == 'm') ? cx + nx : nx;
      cy = (currentCmd == 'm') ? cy + ny : ny;
      points.add(Vector2(cx, cy));
      currentCmd = (currentCmd == 'm') ? 'l' : 'L';
    } else if (currentCmd == 'L' || currentCmd == 'l') {
      final nx = double.parse(matches[i++]);
      final ny = double.parse(matches[i++]);
      cx = (currentCmd == 'l') ? cx + nx : nx;
      cy = (currentCmd == 'l') ? cy + ny : ny;
      points.add(Vector2(cx, cy));
    } else if (currentCmd == 'H' || currentCmd == 'h') {
      final nx = double.parse(matches[i++]);
      cx = (currentCmd == 'h') ? cx + nx : nx;
      points.add(Vector2(cx, cy));
    } else if (currentCmd == 'V' || currentCmd == 'v') {
      final ny = double.parse(matches[i++]);
      cy = (currentCmd == 'v') ? cy + ny : ny;
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
        final double t = step / curveSubdivisions;
        final double mt = 1 - t;
        final double x =
            pow(mt, 3) * cx +
            3 * pow(mt, 2) * t * cp1x +
            3 * mt * pow(t, 2) * cp2x +
            pow(t, 3) * ex;
        final double y =
            pow(mt, 3) * cy +
            3 * pow(mt, 2) * t * cp1y +
            3 * mt * pow(t, 2) * cp2y +
            pow(t, 3) * ey;
        points.add(Vector2(x, y));
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
