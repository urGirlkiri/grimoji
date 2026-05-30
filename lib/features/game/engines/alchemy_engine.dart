import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:grimoji/features/game/board/utils/manager.dart';
import 'package:grimoji/features/game/model/cascade_step_result.dart';
import 'package:grimoji/features/game/model/collected_emoji.dart';
import 'package:grimoji/features/game/model/detonation_step_result.dart';
import 'package:grimoji/features/game/utils/match_detector.dart';
import 'package:logging/logging.dart';

typedef BehaviorInitCallback = void Function(Tile tile);

class AlchemyEngine {
  final BoardManager boardManager;
  final List<Recipe>? Function(GameEmoji) getRecipes;
  final Reaction? Function(GameEmoji) getReactionFor;
  final Map<GameEmoji, GameEmoji> Function(ReactionType) getTransformationsForType;
  final int Function(ReactionType) getAoERadiusForType;
  final BehaviorInitCallback? initializeBehavior;

  final Logger _log = Logger('AlchemyEngine');

  AlchemyEngine({
    required this.boardManager,
    required this.getRecipes,
    required this.getReactionFor,
    required this.getTransformationsForType,
    required this.getAoERadiusForType,
    this.initializeBehavior,
  });

  CascadeStepResult processCascadeStep({
    required List<MatchGroup> matchedGroups,
    required TileCoordinate targetCoordinate,
    required bool isFirstMatch,
  }) {
    final List<CollectedEmoji> collectedEmojis = [];
    final Set<TileCoordinate> tilesToDestroy = {};
    final Set<TileCoordinate> transmutedTiles = {};
    
    int mergedEmojis = 0;

    for (var group in matchedGroups) {
      final emoji = group.emoji;
      final coords = group.coordinates;

      bool isAlreadyTriggered = coords.any((c) => boardManager.gridTiles[c.row][c.col].isTriggered);
      bool mergeHappened = false;

      if (!isAlreadyTriggered) {
        final rawRecipes = getRecipes(emoji);
        if (rawRecipes != null && rawRecipes.isNotEmpty) {
          
          final recipes = List<Recipe>.from(rawRecipes);
          recipes.sort((a, b) => b.requiredAmount.compareTo(a.requiredAmount));
          
          for (var recipe in recipes) {
            if (coords.length >= recipe.requiredAmount) {
              final TileCoordinate spawnPoint = coords.contains(targetCoordinate) && isFirstMatch
                  ? targetCoordinate
                  : coords.first;

              final Tile targetTile = boardManager.gridTiles[spawnPoint.row][spawnPoint.col];
              targetTile.emoji = recipe.yields;
              targetTile.reset();

              if (recipe.yields == boardManager.level.targetEmoji) {
                collectedEmojis.add(CollectedEmoji(emoji: recipe.yields, count: 1));
                targetTile.isFlying = true;
              }

              final Set<TileCoordinate> sources = coords.where((c) => c != spawnPoint).toSet();
              tilesToDestroy.addAll(sources);

              mergedEmojis++;

              if (initializeBehavior != null) {
                initializeBehavior!(targetTile);
              }

              mergeHappened = true;
              break;
            }
          }
        }
      }

      if (!mergeHappened) {
        final reaction = getReactionFor(emoji);
        if (reaction != null) {
          if (reaction.type == ReactionType.explosive) {
            for (var coord in coords) {
              boardManager.gridTiles[coord.row][coord.col].isTriggered = true;
            }
            _log.info('Matched explosives primed at $coords');
          } else {
            collectedEmojis.add(CollectedEmoji(emoji: emoji, count: coords.length));
            tilesToDestroy.addAll(coords);
            final transformations = getTransformationsForType(reaction.type);
            final aoeRadius = reaction.aoeRadius;

            for (var centerCoord in coords) {
              for (int r = centerCoord.row - aoeRadius; r <= centerCoord.row + aoeRadius; r++) {
                for (int c = centerCoord.col - aoeRadius; c <= centerCoord.col + aoeRadius; c++) {
                  if (r >= 0 && r < BoardManager.rows && c >= 0 && c < BoardManager.cols) {
                    final rowDist = (r - centerCoord.row).abs();
                    final colDist = (c - centerCoord.col).abs();
                    if (rowDist + colDist > aoeRadius) continue; 

                    final Tile targetTile = boardManager.gridTiles[r][c];
                    final TileCoordinate targetCoord = TileCoordinate(row: r, col: c);
                    
                    if (coords.contains(targetCoord)) continue;
                    
                    final GameEmoji? resultingEmoji = transformations[targetTile.emoji];

                    if (resultingEmoji != null) {
                      targetTile.emoji = resultingEmoji;
                      targetTile.reset();
                      targetTile.isTransmuting = true;
                      transmutedTiles.add(targetCoord);
                      if (initializeBehavior != null) {
                        initializeBehavior!(targetTile);
                      }
                    } else if (!coords.contains(targetCoord) && !transmutedTiles.contains(targetCoord)) {
                      final targetReaction = getReactionFor(targetTile.emoji);
                      if (targetReaction != null && targetReaction.type == ReactionType.explosive) {
                      }
                    }
                  }
                }
              }
            }
          }
        } else {
          collectedEmojis.add(CollectedEmoji(emoji: emoji, count: coords.length));
          tilesToDestroy.addAll(group.coordinates);
        }
      }
    }

    final bool anyMerge = mergedEmojis > 0;
    if (!anyMerge) {
      final Set<TileCoordinate> allMatchedCoords = matchedGroups.expand((g) => g.coordinates).toSet();
      for (var match in allMatchedCoords) {
        final neighbors = boardManager.getAdjacentTiles(match.row, match.col);
        for (var neighbor in neighbors) {
          final reaction = getReactionFor(neighbor.emoji);
          final bool isPartOfMatch = allMatchedCoords.contains(neighbor.coordinate);

          if (!isPartOfMatch && reaction != null && reaction.type == ReactionType.explosive && !neighbor.isTriggered) {
            neighbor.isTriggered = true;
          }
        }
      }
    }

    tilesToDestroy.removeWhere((coord) => transmutedTiles.contains(coord));
    final bool hasTriggeredBombs = boardManager.getTriggeredEmojis().isNotEmpty;

    return CascadeStepResult(
      matchedGroups: matchedGroups,
      tilesToDestroy: tilesToDestroy,
      transmutedTiles: transmutedTiles,
      collectedEmojis: collectedEmojis,
      hasTriggeredBombs: hasTriggeredBombs,
    );
  }
  
  DetonationStepResult processDetonationStep() {
    final List<CollectedEmoji> collectedEmojis = [];
    final Set<TileCoordinate> allBlastedCoords = {};
    final Set<TileCoordinate> allTransformedCoords = {};

    List<Tile> primedBombs = boardManager.getTriggeredEmojis();
    bool chainReaction = primedBombs.isNotEmpty;

    while (primedBombs.isNotEmpty) {
      final currentBombs = List<Tile>.from(primedBombs);

      for (Tile activeBomb in currentBombs) {
        if (!activeBomb.isTriggered) continue;
        if (activeBomb.emoji == boardManager.level.targetEmoji) {
          collectedEmojis.add(CollectedEmoji(emoji: activeBomb.emoji, count: 1));
        }

        activeBomb.isTriggered = false;
        final blastResult = _executeBlastRadius(activeBomb.coordinate);
        allBlastedCoords.addAll(blastResult.destroyed);
        allTransformedCoords.addAll(blastResult.transformed);
      }

      primedBombs = boardManager.getTriggeredEmojis();
    }

    return DetonationStepResult(
      destroyed: allBlastedCoords,
      transformed: allTransformedCoords,
      collectedEmojis: collectedEmojis,
      hasChainReaction: chainReaction,
    );
  }

  ({Set<TileCoordinate> destroyed, Set<TileCoordinate> transformed}) _executeBlastRadius(TileCoordinate center) {
    final Set<TileCoordinate> destroyedTiles = {};
    final Set<TileCoordinate> transformedTiles = {};
    final transformations = getTransformationsForType(ReactionType.explosive);

    final centerTile = boardManager.gridTiles[center.row][center.col];
    final centerReaction = getReactionFor(centerTile.emoji);
    final radius = centerReaction?.aoeRadius ?? 1;

    for (int r = center.row - radius; r <= center.row + radius; r++) {
      if (r < 0 || r >= BoardManager.rows) continue;
      for (int c = center.col - radius; c <= center.col + radius; c++) {
        if (c < 0 || c >= BoardManager.cols) continue;

        final tile = boardManager.gridTiles[r][c];
        final reaction = getReactionFor(tile.emoji);
        final isExplosive = reaction != null && reaction.type == ReactionType.explosive;

        if (isExplosive && (r != center.row || c != center.col)) {
          if (!tile.isExploding) {
            tile.isTriggered = true;
          }
        } else {
          final resultingEmoji = transformations[tile.emoji];
          if (resultingEmoji != null) {
            tile.emoji = resultingEmoji;
            tile.reset();
            tile.isTransmuting = true;
            transformedTiles.add(TileCoordinate(row: r, col: c));
          } else {
            tile.isExploding = true;
            destroyedTiles.add(TileCoordinate(row: r, col: c));
          }
        }
      }
    }
    return (destroyed: destroyedTiles, transformed: transformedTiles);
  }
}