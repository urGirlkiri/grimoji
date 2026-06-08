// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

class Vector2 {
  final double x, y;
  const Vector2(this.x, this.y);
  @override
  String toString() => 'Vector2(${x.toStringAsFixed(3)}, ${y.toStringAsFixed(3)})';
}

class AffineMatrix {
  double a = 1, b = 0, c = 0, d = 1, e = 0, f = 0;

  AffineMatrix();
  AffineMatrix._(this.a, this.b, this.c, this.d, this.e, this.f);
  AffineMatrix clone() => AffineMatrix._(a, b, c, d, e, f);

  void multiply(double na, double nb, double nc, double nd, double ne, double nf) {
    double ta = a * na + c * nb;
    double tb = b * na + d * nb;
    double tc = a * nc + c * nd;
    double td = b * nc + d * nd;
    double te = a * ne + c * nf + e;
    double tf = b * ne + d * nf + f;
    a = ta; b = tb; c = tc; d = td; e = te; f = tf;
  }

  void multiplyMatrix(AffineMatrix o) => multiply(o.a, o.b, o.c, o.d, o.e, o.f);

  Vector2 apply(double x, double y) {
    return Vector2(a * x + c * y + e, b * x + d * y + f);
  }
}

AffineMatrix _parseTransform(String? transformStr) {
  final matrix = AffineMatrix();
  if (transformStr == null || transformStr.isEmpty) return matrix;

  final reg = RegExp(r'(matrix|translate|scale|rotate)\s*\(([^)]+)\)');
  for (final match in reg.allMatches(transformStr)) {
    final type = match.group(1);
    final args = match.group(2)!.split(RegExp(r'[,\s]+')).map(double.tryParse).whereType<double>().toList();
    
    if (type == 'matrix' && args.length >= 6) {
      matrix.multiply(args[0], args[1], args[2], args[3], args[4], args[5]);
    } else if (type == 'translate' && args.isNotEmpty) {
      matrix.multiply(1, 0, 0, 1, args[0], args.length > 1 ? args[1] : 0);
    } else if (type == 'scale' && args.isNotEmpty) {
      matrix.multiply(args[0], 0, 0, args.length > 1 ? args[1] : args[0], 0, 0);
    } else if (type == 'rotate' && args.isNotEmpty) {
      double angle = args[0] * pi / 180.0;
      double cx = args.length >= 3 ? args[1] : 0;
      double cy = args.length >= 3 ? args[2] : 0;
      if (cx != 0 || cy != 0) matrix.multiply(1, 0, 0, 1, cx, cy);
      matrix.multiply(cos(angle), sin(angle), -sin(angle), cos(angle), 0, 0);
      if (cx != 0 || cy != 0) matrix.multiply(1, 0, 0, 1, -cx, -cy);
    }
  }
  return matrix;
}

String? _extractAttr(String element, String attr) {
  final match = RegExp('$attr\\s*=\\s*["\']([^"\']+)["\']').firstMatch(element);
  return match?.group(1);
}

double _extractDouble(String element, String attr, [double def = 0.0]) {
  final str = _extractAttr(element, attr);
  return str != null ? double.tryParse(str) ?? def : def;
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
    print('CRITICAL ERROR: Found 0 emojis! Aborting.');
    exit(1);
  }

  print('Deploying Ultimate Physics Engine. Processing ${matches.length} emojis...');

  final StringBuffer newFileBuffer = StringBuffer();
  newFileBuffer.writeln('/// GENERATED FILE - DO NOT EDIT MANUALLY');
  newFileBuffer.writeln('library;');
  newFileBuffer.writeln('import \'package:flame_forge2d/flame_forge2d.dart\';\n');
  newFileBuffer.writeln('class GameEmoji {');
  newFileBuffer.writeln('  final String svg, lottie, visual;');
  newFileBuffer.writeln('  final List<Vector2> physicsVertices;');
  newFileBuffer.writeln('  const GameEmoji(this.svg, this.lottie, this.visual, this.physicsVertices);\n}\n');
  newFileBuffer.writeln('class Emojis {\n  Emojis._();\n');

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
      List<Vector2> pointCloud = [];

      List<AffineMatrix> transformStack = [AffineMatrix()];
      final tagRegExp = RegExp(r'<(/?)(g|path|circle|ellipse|rect|polygon|polyline)([^>]*)>');

      for (final tm in tagRegExp.allMatches(svgContent)) {
        final isClosing = tm.group(1) == '/';
        final tag = tm.group(2)!;
        final attrs = tm.group(3)!;

        if (tag == 'g') {
          if (isClosing) {
            if (transformStack.length > 1) transformStack.removeLast();
          } else {
            final localTransform = _parseTransform(_extractAttr(attrs, 'transform'));
            transformStack.add(transformStack.last.clone()..multiplyMatrix(localTransform));
          }
        } else if (!isClosing) {
          final localTransform = _parseTransform(_extractAttr(attrs, 'transform'));
          final globalTransform = transformStack.last.clone()..multiplyMatrix(localTransform);

          if (tag == 'path') {
            final dData = _extractAttr(attrs, 'd') ?? '';
            _parseSvgPathData(dData, globalTransform, pointCloud);
          } else if (tag == 'circle') {
            final cx = _extractDouble(attrs, 'cx'), cy = _extractDouble(attrs, 'cy'), r = _extractDouble(attrs, 'r');
            for (int i = 0; i < 16; i++) {
              double angle = (i * pi * 2) / 16;
              pointCloud.add(globalTransform.apply(cx + cos(angle) * r, cy + sin(angle) * r));
            }
          } else if (tag == 'ellipse') {
            final cx = _extractDouble(attrs, 'cx'), cy = _extractDouble(attrs, 'cy');
            final rx = _extractDouble(attrs, 'rx'), ry = _extractDouble(attrs, 'ry');
            for (int i = 0; i < 16; i++) {
              double angle = (i * pi * 2) / 16;
              pointCloud.add(globalTransform.apply(cx + cos(angle) * rx, cy + sin(angle) * ry));
            }
          }
        }
      }

      if (pointCloud.isNotEmpty) {
        final List<Vector2> hull = _computeConvexHull(pointCloud);
        final List<Vector2> decimatedHull = _decimateHull(hull, 8);
        finalHull = _normalizeHull(decimatedHull);
      }
    }

    if (finalHull.isEmpty) finalHull = _generateDefaultOctagon();

    newFileBuffer.writeln('  static final GameEmoji $variableName = GameEmoji(');
    newFileBuffer.writeln('    \'$svgPath\', \'$lottiePath\', \'$visual\', [');
    for (final v in finalHull) {
      newFileBuffer.writeln('      Vector2(${v.x.toStringAsFixed(3)}, ${v.y.toStringAsFixed(3)}),');
    }
    newFileBuffer.writeln('    ],');
    newFileBuffer.writeln('  );');

    successCount++;
  }

  newFileBuffer.writeln('}');
  await configFile.writeAsString(newFileBuffer.toString());
  print('SUCCESS: Processed $successCount emojis!');
}

void _parseSvgPathData(String path, AffineMatrix transform, List<Vector2> points) {
  final RegExp regex = RegExp(r'([a-zA-Z])|(-?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)');
  final List<String> matches = regex.allMatches(path).map((m) => m.group(0)!).toList();
  
  double cx = 0, cy = 0;
  double lastCpX = 0, lastCpY = 0; 
  String currentCmd = '';
  int i = 0;
  
  void addPoint(double x, double y) => points.add(transform.apply(x, y));

  void sampleCubic(double startX, double startY, double cp1x, double cp1y, double cp2x, double cp2y, double ex, double ey) {
    for (double t = 0.25; t <= 1.0; t += 0.25) {
      double mt = 1 - t;
      addPoint(
        mt * mt * mt * startX + 3 * mt * mt * t * cp1x + 3 * mt * t * t * cp2x + t * t * t * ex,
        mt * mt * mt * startY + 3 * mt * mt * t * cp1y + 3 * mt * t * t * cp2y + t * t * t * ey
      );
    }
  }

  while (i < matches.length) {
    final String token = matches[i];
    
    if (RegExp(r'^[a-zA-Z]$').hasMatch(token)) {
      currentCmd = token;
      i++;
      if (i >= matches.length) break;
    }
    if (RegExp(r'^[a-zA-Z]$').hasMatch(matches[i])) continue;
    
    if (currentCmd == 'M' || currentCmd == 'm') {
      cx = currentCmd == 'm' ? cx + double.parse(matches[i++]) : double.parse(matches[i++]);
      cy = currentCmd == 'm' ? cy + double.parse(matches[i++]) : double.parse(matches[i++]);
      addPoint(cx, cy);
      lastCpX = cx; lastCpY = cy;
      currentCmd = currentCmd == 'm' ? 'l' : 'L';
    } else if (currentCmd == 'L' || currentCmd == 'l') {
      cx = currentCmd == 'l' ? cx + double.parse(matches[i++]) : double.parse(matches[i++]);
      cy = currentCmd == 'l' ? cy + double.parse(matches[i++]) : double.parse(matches[i++]);
      addPoint(cx, cy);
      lastCpX = cx; lastCpY = cy;
    } else if (currentCmd == 'H' || currentCmd == 'h') {
      cx = currentCmd == 'h' ? cx + double.parse(matches[i++]) : double.parse(matches[i++]);
      addPoint(cx, cy);
      lastCpX = cx; lastCpY = cy;
    } else if (currentCmd == 'V' || currentCmd == 'v') {
      cy = currentCmd == 'v' ? cy + double.parse(matches[i++]) : double.parse(matches[i++]);
      addPoint(cx, cy);
      lastCpX = cx; lastCpY = cy;
    } else if (currentCmd == 'C' || currentCmd == 'c') {
      double cp1x = double.parse(matches[i++]), cp1y = double.parse(matches[i++]);
      double cp2x = double.parse(matches[i++]), cp2y = double.parse(matches[i++]);
      double ex = double.parse(matches[i++]), ey = double.parse(matches[i++]);
      if (currentCmd == 'c') { cp1x += cx; cp1y += cy; cp2x += cx; cp2y += cy; ex += cx; ey += cy; }
      
      sampleCubic(cx, cy, cp1x, cp1y, cp2x, cp2y, ex, ey);
      cx = ex; cy = ey;
      lastCpX = cp2x; lastCpY = cp2y; 
    } else if (currentCmd == 'S' || currentCmd == 's') {
      double cp1x = cx * 2 - lastCpX;
      double cp1y = cy * 2 - lastCpY;
      double cp2x = double.parse(matches[i++]), cp2y = double.parse(matches[i++]);
      double ex = double.parse(matches[i++]), ey = double.parse(matches[i++]);
      if (currentCmd == 's') { cp2x += cx; cp2y += cy; ex += cx; ey += cy; }
      
      sampleCubic(cx, cy, cp1x, cp1y, cp2x, cp2y, ex, ey);
      cx = ex; cy = ey;
      lastCpX = cp2x; lastCpY = cp2y;
    } else if (currentCmd == 'A' || currentCmd == 'a') {
      i += 5; 
      double ex = double.parse(matches[i++]), ey = double.parse(matches[i++]);
      if (currentCmd == 'a') { ex += cx; ey += cy; }
      addPoint(ex, ey);
      cx = ex; cy = ey;
      lastCpX = cx; lastCpY = cy;
    } else if (currentCmd == 'Z' || currentCmd == 'z') {
      lastCpX = cx; lastCpY = cy;
    } else {
      i++; 
    }
  }
}

List<Vector2> _computeConvexHull(List<Vector2> points) {
  if (points.length <= 3) return points;
  points.sort((a, b) => a.x == b.x ? a.y.compareTo(b.y) : a.x.compareTo(b.x));
  double cross(Vector2 o, Vector2 a, Vector2 b) => (a.x - o.x) * (b.y - o.y) - (a.y - o.y) * (b.x - o.x);

  List<Vector2> lower = [];
  for (var p in points) {
    while (lower.length >= 2 && cross(lower[lower.length - 2], lower.last, p) <= 0) {
      lower.removeLast();
    }
    lower.add(p);
  }
  List<Vector2> upper = [];
  for (var p in points.reversed) {
    while (upper.length >= 2 && cross(upper[upper.length - 2], upper.last, p) <= 0) {
      upper.removeLast();
    }
    upper.add(p);
  }
  lower.removeLast(); upper.removeLast();
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
      double area = ((current[prev].x * (current[i].y - current[next].y)) + (current[i].x * (current[next].y - current[prev].y)) + (current[next].x * (current[prev].y - current[i].y))).abs() / 2.0;
      if (area < minArea) { minArea = area; minIndex = i; }
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
  return hull.map((p) => Vector2((p.x - cx) / maxDim, (p.y - cy) / maxDim)).toList();
}

List<Vector2> _generateDefaultOctagon() {
  List<Vector2> points = [];
  for (int i = 0; i < 8; i++) {
    double angle = (i * pi * 2) / 8;
    points.add(Vector2(cos(angle) * 0.5, sin(angle) * 0.5));
  }
  return points;
}