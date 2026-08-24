import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/testtube/models/message.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/testtube/models/result.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';

void analyzeInIsolate(AnalysisMessage message) {
  final grid = message.grid;
  final target = message.target;
  final rows = grid.length;
  final cols = grid[0].length;

  final availableEmojis = Emojis.all;
  AnalysisResult? bestResult;
  int bestScore = -1;

  final originalEmoji = grid[target.row][target.col].emoji;

  for (final emoji in availableEmojis) {
    if (emoji == Emojis.hole ||
        emoji == Emojis.impSmile ||
        emoji == Emojis.clown ||
        emoji == Emojis.poop) {
      continue;
    }

    grid[target.row][target.col].emoji = emoji;

    final matches = MatchDetector.findMatchesInVectors(
      grid: grid,
      affectedColumns: {target.col},
      affectedRows: {target.row},
    );

    final targetMatches = matches
        .where((m) => m.coordinates.contains(target))
        .toList();

    if (targetMatches.isNotEmpty) {
      int currentScore = 0;
      int maxSize = 0;
      String matchType = 'simple';

      for (final match in targetMatches) {
        currentScore += match.coordinates.length;
        if (match.isSpecial) currentScore += 10;

        if (match.coordinates.length > maxSize) {
          maxSize = match.coordinates.length;
          if (maxSize >= 5) {
            matchType = 'five_in_row';
          } else if (match.isSpecial) {
            matchType = 'special_shape';
          } else {
            matchType = '3+';
          }
        }
      }

      if (currentScore > bestScore) {
        bestScore = currentScore;
        bestResult = AnalysisResult(
          bestEmoji: emoji,
          matchType: matchType,
          matchSize: maxSize,
        );
      }
    }
  }

  grid[target.row][target.col].emoji = originalEmoji;

  bestResult ??= _findFallbackMatch(grid, target, rows, cols, availableEmojis);

  bestResult ??= AnalysisResult(
    bestEmoji: availableEmojis.firstWhere((e) => e != Emojis.hole),
    matchType: 'none',
    matchSize: 0,
  );

  message.sendPort.send(bestResult);
}



AnalysisResult? _findFallbackMatch(
  List<List<Tile>> grid,
  TileCoordinate target,
  int rows,
  int cols,
  List<GameEmoji> availableEmojis,
) {
  final left = target.col > 0 ? grid[target.row][target.col - 1].emoji : null;
  final right = target.col < cols - 1
      ? grid[target.row][target.col + 1].emoji
      : null;

  if (left != null && right != null && left == right && left != Emojis.hole) {
    return AnalysisResult(
      bestEmoji: left,
      matchType: 'simple',
      matchSize: 3,
    );
  }
  if (left != null && left != Emojis.hole) {
    return AnalysisResult(
      bestEmoji: left,
      matchType: 'simple',
      matchSize: 2,
    );
  }
  if (right != null && right != Emojis.hole) {
    return AnalysisResult(
      bestEmoji: right,
      matchType: 'simple',
      matchSize: 2,
    );
  }

  final up = target.row > 0 ? grid[target.row - 1][target.col].emoji : null;
  final down = target.row < rows - 1
      ? grid[target.row + 1][target.col].emoji
      : null;

  if (up != null && down != null && up == down && up != Emojis.hole) {
    return AnalysisResult(
      bestEmoji: up,
      matchType: 'simple',
      matchSize: 3,
    );
  }
  if (up != null && up != Emojis.hole) {
    return AnalysisResult(
      bestEmoji: up,
      matchType: 'simple',
      matchSize: 2,
    );
  }
  if (down != null && down != Emojis.hole) {
    return AnalysisResult(
      bestEmoji: down,
      matchType: 'simple',
      matchSize: 2,
    );
  }

  return null;
}
