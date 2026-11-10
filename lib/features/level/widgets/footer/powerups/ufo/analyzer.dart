import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/ufo/models/plan.dart';
import 'package:grimoji/features/match/board/effects/ufo/models/beam_type.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/detectors/ufo/scorer.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';

class UFOAnalyzer {
  static const int _beamCount = 3;
  static const int _abductCount = 2;

  static final _fallbackTargets = [
    TileCoordinate(row: 1, col: 1),
    TileCoordinate(row: 2, col: 3),
    TileCoordinate(row: 3, col: 2),
  ];
  static const _fallbackBeamTypes = [
    UFOBeamType.abduct,
    UFOBeamType.explosive,
    UFOBeamType.abduct,
  ];
  static const _fallbackBeamDelays = [
    Duration(milliseconds: 600),
    Duration(milliseconds: 1800),
    Duration(milliseconds: 3000),
  ];

  static Future<UFOPlan> analyzeBoard({
    required List<List<Tile>> grid,
    required GameEmoji targetEmoji,
  }) async {
    final rows = grid.length;
    final cols = grid[0].length;

    final unmatchableVisuals = MatchDetector.unmatchableEmojis
        .map((e) => e.visual)
        .toSet();
    final recipeChainSteps = RecipeBook.getRecipeChainSteps(
      targetEmoji,
    ).map((emoji, step) => MapEntry(emoji.visual, step));

    final abductRanked = <_Candidate>[];
    final explosiveRanked = <_Candidate>[];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        final tile = grid[r][c];
        if (!_isEligible(tile, targetEmoji)) continue;

        final coord = TileCoordinate(row: r, col: c);
        final tileId = tile.id;
        abductRanked.add(
          _Candidate(
            coord: coord,
            beamType: UFOBeamType.abduct,
            tileId: tileId,
            score: scoreAbductCandidate(
              grid,
              row: r,
              col: c,
              targetVisual: targetEmoji.visual,
              unmatchableVisuals: unmatchableVisuals,
              recipeChainSteps: recipeChainSteps,
            ),
          ),
        );
        explosiveRanked.add(
          _Candidate(
            coord: coord,
            beamType: UFOBeamType.explosive,
            tileId: tileId,
            score: scoreExplosiveCandidate(
              grid,
              row: r,
              col: c,
              targetVisual: targetEmoji.visual,
              unmatchableVisuals: unmatchableVisuals,
              recipeChainSteps: recipeChainSteps,
            ),
          ),
        );
      }
    }

    abductRanked.sort((a, b) => b.score.compareTo(a.score));
    explosiveRanked.sort((a, b) => b.score.compareTo(a.score));

    final picks = <_Candidate>[];
    final used = <TileCoordinate>{};

    for (final candidate in abductRanked) {
      if (picks.where((p) => p.beamType == UFOBeamType.abduct).length >=
          _abductCount) {
        break;
      }
      if (used.add(candidate.coord)) picks.add(candidate);
    }

    for (final candidate in explosiveRanked) {
      if (used.add(candidate.coord)) {
        picks.add(candidate);
        break;
      }
    }

    if (picks.length < _beamCount) {
      final rest = <_Candidate>[
        ...abductRanked.where((c) => !used.contains(c.coord)),
        ...explosiveRanked.where((c) => !used.contains(c.coord)),
      ]..sort((a, b) => b.score.compareTo(a.score));

      for (final candidate in rest) {
        if (picks.length >= _beamCount) break;
        if (used.add(candidate.coord)) picks.add(candidate);
      }
    }

    if (picks.isEmpty) {
      return UFOPlan(
        targets: _fallbackTargets,
        beamTypes: _fallbackBeamTypes,
        beamDelays: _fallbackBeamDelays,
      );
    }

    picks.sort((a, b) => a.coord.col.compareTo(b.coord.col));

    final delays = _beamDelays(picks.length);

    return UFOPlan(
      targets: picks.map((p) => p.coord).toList(),
      beamTypes: picks.map((p) => p.beamType).toList(),
      beamDelays: delays,
      tileIds: picks.map((p) => p.tileId).toList(),
    );
  }

  static bool _isEligible(Tile tile, GameEmoji targetEmoji) {
    final displayEmoji = tile.morphTarget ?? tile.emoji;
    if (displayEmoji == targetEmoji) return false;

    return !(tile.isExploding ||
        tile.isTriggered ||
        tile.isMerging ||
        tile.isMergePoint ||
        tile.isTransmuting ||
        tile.isFlying ||
        tile.isShuffling ||
        tile.isClownShuffling ||
        tile.isAbducted ||
        tile.isHinting ||
        tile.isPowerupTarget ||
        tile.isBloodTarget ||
        tile.isTestTubeTarget ||
        tile.isWheelOrigin ||
        tile.isGhostOrigin ||
        tile.isGhostPowerup ||
        tile.isRowClearTrigger ||
        tile.isColClearTrigger ||
        tile.isLineClearTrigger ||
        tile.isLineClearTarget ||
        tile.isSwallowTrigger ||
        tile.isSwallowTarget);
  }

  static List<Duration> _beamDelays(int count) {
    if (count <= 1) return const [Duration(milliseconds: 1800)];

    const startMs = 600;
    const endMs = 3000;
    final stepMs = (endMs - startMs) / (count - 1);

    return List.generate(
      count,
      (i) => Duration(milliseconds: (startMs + stepMs * i).round()),
    );
  }
}

class _Candidate {
  final TileCoordinate coord;
  final UFOBeamType beamType;
  final String tileId;
  final int score;

  const _Candidate({
    required this.coord,
    required this.beamType,
    required this.tileId,
    required this.score,
  });
}
