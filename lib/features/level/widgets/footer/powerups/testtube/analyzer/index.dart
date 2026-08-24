import 'dart:isolate';
import 'package:grimoji/features/level/widgets/footer/powerups/testtube/analyzer/isolate.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/testtube/models/message.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/testtube/models/result.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';

class TestTubeAnalyzer {
  static Future<AnalysisResult> analyzeTarget({
    required List<List<Tile>> grid,
    required TileCoordinate target,
  }) async {
    final receivePort = ReceivePort();

    await Isolate.spawn(
      analyzeInIsolate,
      AnalysisMessage(
        grid: grid,
        target: target,
        sendPort: receivePort.sendPort,
      ),
    );

    final result = await receivePort.first as AnalysisResult;
    receivePort.close();

    return result;
  }
}