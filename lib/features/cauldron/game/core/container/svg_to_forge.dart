// ignore_for_file: avoid_print
import 'dart:io';
import 'dart:math';

class Vector2 {
  final double x, y;
  const Vector2(this.x, this.y);

  @override
  String toString() => 'Vector2(${x.toStringAsFixed(2)}, ${y.toStringAsFixed(2)})';
}

void main() async {
  const String svgInputPath = 'assets/images/cauldron/path.svg';
  const String dartOutputPath = 'lib/features/cauldron/game/core/container/vertices.dart';
  const double targetWorldWidth = 10.5;

  final File svgFile = File(svgInputPath);

  if (!await svgFile.exists()) {
    print('ERROR: Missing target vector asset file at: ${svgFile.absolute.path}');
    exit(1);
  }

  print('Processing source coordinates from: $svgInputPath...');
  final String rawSvgContent = await svgFile.readAsString();

  final String svgPathData = _extractPathData(rawSvgContent);
  if (svgPathData.isEmpty) {
    print('ERROR: Failed to parse a valid <path d="..." /> definition out of the SVG.');
    exit(1);
  }

  final List<Vector2> rawPoints = parseSvgPath(svgPathData, curveSubdivisions: 6);
  if (rawPoints.isEmpty) {
    print('ERROR: No valid coordinates extracted from the path string.');
    exit(1);
  }

  final List<Vector2> filteredPoints = removeCollinear(rawPoints, epsilon: 0.05);

  final double minX = filteredPoints.map((p) => p.x).reduce(min);
  final double maxX = filteredPoints.map((p) => p.x).reduce(max);
  final double minY = filteredPoints.map((p) => p.y).reduce(min);
  final double maxY = filteredPoints.map((p) => p.y).reduce(max);

  final double offsetX = (minX + maxX) / 2;
  final double offsetY = (minY + maxY) / 2;
  final double actualPathWidth = maxX - minX;
  final double scale = targetWorldWidth / actualPathWidth;

  final File outputFile = File(dartOutputPath);
  final Directory outputDir = outputFile.parent;
  if (!await outputDir.exists()) {
    await outputDir.create(recursive: true);
  }

  final StringBuffer codeBuffer = StringBuffer();
  codeBuffer.writeln('import \'package:flame_forge2d/flame_forge2d.dart\';');
  codeBuffer.writeln();
  codeBuffer.writeln('/// GENERATED FILE - DO NOT EDIT MANUALLY');
  codeBuffer.writeln('/// Run lib/features/cauldron/game/core/container/svg_to_forge.dart');
  codeBuffer.writeln('/// To Generate');
  codeBuffer.writeln();
  codeBuffer.writeln('final List<Vector2> vertices = [');

  for (final point in filteredPoints) {
    final double worldX = (point.x - offsetX) * scale;
    final double worldY = (point.y - offsetY) * scale;
    codeBuffer.writeln('  Vector2(${worldX.toStringAsFixed(2)}, ${worldY.toStringAsFixed(2)}),');
  }

  codeBuffer.writeln('];');

  await outputFile.writeAsString(codeBuffer.toString());
  
  print('SUCCESS: Normalized data array generated cleanly! Vertex count: ${filteredPoints.length}');
  print('Target output written to: -> ${outputFile.absolute.path}');
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

    final double crossProduct = (b.x - a.x) * (c.y - a.y) - (b.y - a.y) * (c.x - a.x);

    if (crossProduct.abs() > epsilon) {
      result.add(b);
    }
  }

  result.add(points.last);
  return result;
}

List<Vector2> parseSvgPath(String path, {int curveSubdivisions = 6}) {
  final List<Vector2> points = [];
  
  // Clean extraction expression isolates alphabetic commands from float parameters smoothly
  final RegExp regex = RegExp(r'([a-zA-Z])|(-?[0-9]*\.?[0-9]+(?:[eE][-+]?[0-9]+)?)');
  final List<String> matches = regex.allMatches(path).map((m) => m.group(0)!).toList();

  double cx = 0, cy = 0;
  String currentCmd = '';
  int i = 0;

  while (i < matches.length) {
    final String token = matches[i];
    
    // CRITICAL FIX: If the current token is a new command character letter,
    // intercept it immediately and break sequence execution out of the old command loop!
    if (RegExp(r'[a-zA-Z]').hasMatch(token)) {
      currentCmd = token;
      i++;
      if (i >= matches.length) break;
    }

    // Safety fallback: If an unexpected command block left trailing string fragments,
    // do not evaluate it as a double coordinate value.
    if (RegExp(r'[a-zA-Z]').hasMatch(matches[i])) {
      continue; 
    }

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
        cp1x += cx; cp1y += cy;
        cp2x += cx; cp2y += cy;
        ex += cx; ey += cy;
      }

      for (int step = 1; step <= curveSubdivisions; step++) {
        final double t = step / curveSubdivisions;
        final double mt = 1 - t;
        
        final double x = pow(mt, 3) * cx +
            3 * pow(mt, 2) * t * cp1x +
            3 * mt * pow(t, 2) * cp2x +
            pow(t, 3) * ex;
            
        final double y = pow(mt, 3) * cy +
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