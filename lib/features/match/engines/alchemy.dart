import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/alchemy/behaviors/clear.dart';
import 'package:grimoji/features/audio/sounds/sfx.dart';
import 'package:grimoji/features/match/models/match_group.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/alchemy/recipes/models/recipe.dart';
import 'package:grimoji/features/alchemy/reactions/models/reaction.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/features/match/models/cascade_step_result.dart';
import 'package:grimoji/features/match/models/collected_emoji.dart';
import 'package:grimoji/features/match/models/detonation_step_result.dart';
import 'package:grimoji/features/match/detectors/match.dart';
import 'package:grimoji/features/match/types.dart';
import 'package:logging/logging.dart';

typedef BehaviorInitCallback = void Function(Tile tile);
typedef TileBlastedCallback =
    void Function(Tile tile, int x, int y, ReactionType reactionType);
typedef TileMatchedCallback = void Function(Tile tile, int x, int y);

class AlchemyEngine {
  final BoardManager boardManager;
  final void Function(Sfx) playSfx;
  final List<Recipe>? Function(GameEmoji) getRecipes;
  final Reaction? Function(GameEmoji) getReactionFor;
  final Map<GameEmoji, GameEmoji> Function(ReactionType)
  getTransformationsForType;
  final int Function(ReactionType) getAoERadiusForType;
  final BehaviorInitCallback? initializeBehavior;
  final TileBlastedCallback? onTileBlasted;
  final TileMatchedCallback? onTileMatched;

  final Logger _log = Logger('AlchemyEngine');

  AlchemyEngine({
    required this.boardManager,
    required this.playSfx,
    required this.getRecipes,
    required this.getReactionFor,
    required this.getTransformationsForType,
    required this.getAoERadiusForType,
    this.initializeBehavior,
    this.onTileBlasted,
    this.onTileMatched,
  });

  CascadeStepResult processCascadeStep({
    required List<MatchGroup> matchedGroups,
    required TileCoordinate targetCoordinate,
    required bool isFirstMatch,
    bool isFeverTime = false,
  }) {
    final List<CollectedEmoji> collectedEmojis = [];
    final TileSet tilesToDestroy = {};
    final TileSet transmutedTiles = {};
    final TileSet transformed = {};

    _log.info(
      'Cascade step: ${matchedGroups.length} groups, tilesToDestroy=${tilesToDestroy.length}, transformed=${transformed.length}',
    );

    int mergedEmojis = 0;

    for (var group in matchedGroups) {
      final emoji = group.emoji;
      final coords = group.coordinates;

      _executeMatchedBehavior(group);

      if (group.isSpecial) {
        final TileCoordinate spawnPoint = MatchDetector.resolveShapePivot(
          group,
          swipeTarget: isFirstMatch ? targetCoordinate : null,
        );
        final Tile targetTile =
            boardManager.gridTiles[spawnPoint.row][spawnPoint.col];
        targetTile.emoji = group.yields!;
        targetTile.reset();

        if (group.yields! == boardManager.level.targetEmoji) {
          collectedEmojis.add(CollectedEmoji(emoji: group.yields!, count: 1));
          targetTile.isFlying = true;
        } else if (Powerup.forEmoji(group.yields!) != null) {
          targetTile.isCollectiblePowerup = true;
        }

        final TileSet sources = coords.where((c) => c != spawnPoint).toSet();
        tilesToDestroy.addAll(sources);

        transformed.add(spawnPoint);

        mergedEmojis++;

        if (initializeBehavior != null) {
          initializeBehavior!(targetTile);
        }
        continue;
      }

      bool isAlreadyTriggered = coords.any(
        (c) => boardManager.gridTiles[c.row][c.col].isTriggered,
      );
      bool mergeHappened = false;

      if (!isAlreadyTriggered) {
        final rawRecipes = getRecipes(emoji);
        if (rawRecipes != null && rawRecipes.isNotEmpty) {
          final recipes = List<Recipe>.from(rawRecipes);
          recipes.sort((a, b) => b.requiredAmount.compareTo(a.requiredAmount));

          for (var recipe in recipes) {
            if (coords.length >= recipe.requiredAmount) {
              final TileCoordinate spawnPoint =
                  coords.contains(targetCoordinate) && isFirstMatch
                  ? targetCoordinate
                  : coords.first;

              final Tile targetTile =
                  boardManager.gridTiles[spawnPoint.row][spawnPoint.col];
              targetTile.emoji = recipe.yields;
              targetTile.reset();

              if (recipe.yields == boardManager.level.targetEmoji) {
                collectedEmojis.add(
                  CollectedEmoji(emoji: recipe.yields, count: 1),
                );
                targetTile.isFlying = true;
              } else if (Powerup.forEmoji(recipe.yields) != null) {
                targetTile.isCollectiblePowerup = true;
              }

              final TileSet sources = coords
                  .where((c) => c != spawnPoint)
                  .toSet();
              tilesToDestroy.addAll(sources);

              transformed.add(spawnPoint);

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
            collectedEmojis.add(
              CollectedEmoji(emoji: emoji, count: coords.length),
            );
            tilesToDestroy.addAll(coords);
            final transformations = getTransformationsForType(reaction.type);
            final aoeRadius = reaction.aoeRadius;

            for (var centerCoord in coords) {
              for (
                int r = centerCoord.row - aoeRadius;
                r <= centerCoord.row + aoeRadius;
                r++
              ) {
                for (
                  int c = centerCoord.col - aoeRadius;
                  c <= centerCoord.col + aoeRadius;
                  c++
                ) {
                  if (r >= 0 &&
                      r < BoardManager.rows &&
                      c >= 0 &&
                      c < BoardManager.cols) {
                    final rowDist = (r - centerCoord.row).abs();
                    final colDist = (c - centerCoord.col).abs();
                    if (rowDist + colDist > aoeRadius) continue;

                    final Tile targetTile = boardManager.gridTiles[r][c];
                    final TileCoordinate targetCoord = TileCoordinate(
                      row: r,
                      col: c,
                    );

                    if (coords.contains(targetCoord)) continue;

                    final GameEmoji? resultingEmoji =
                        transformations[targetTile.emoji];

                    if (resultingEmoji != null) {
                      targetTile.emoji = resultingEmoji;
                      targetTile.reset();
                      targetTile.isTransmuting = true;
                      transmutedTiles.add(targetCoord);
                      playSfx(Sfx.transmute);
                      if (initializeBehavior != null) {
                        initializeBehavior!(targetTile);
                      }
                    } else if (!coords.contains(targetCoord) &&
                        !transmutedTiles.contains(targetCoord)) {
                      final targetReaction = getReactionFor(targetTile.emoji);
                      if (targetReaction != null &&
                          targetReaction.type == ReactionType.explosive) {}
                    }
                  }
                }
              }
            }
          }
        } else {
          collectedEmojis.add(
            CollectedEmoji(emoji: emoji, count: coords.length),
          );
          tilesToDestroy.addAll(
            group.coordinates.where(
              (c) => !boardManager.gridTiles[c.row][c.col].isLineClearTrigger,
            ),
          );
        }
      }
    }

    final bool anyMerge = mergedEmojis > 0;
    if (!anyMerge) {
      final TileSet allMatchedCoords = matchedGroups
          .expand((g) => g.coordinates)
          .toSet();
      for (var match in allMatchedCoords) {
        final neighbors = boardManager.getAdjacentTiles(match.row, match.col);
        for (var neighbor in neighbors) {
          final reaction = getReactionFor(neighbor.emoji);
          final bool isPartOfMatch = allMatchedCoords.contains(
            neighbor.coordinate,
          );

          if (!isPartOfMatch &&
              reaction != null &&
              reaction.type == ReactionType.explosive &&
              !neighbor.isTriggered) {
            neighbor.isTriggered = true;
            playSfx(Sfx.trigger);
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
      transformed: transformed,
      collectedEmojis: collectedEmojis,
      hasTriggeredBombs: hasTriggeredBombs,
    );
  }

  DetonationStepResult processDetonationStep() {
    final List<CollectedEmoji> collectedEmojis = [];
    final TileSet allBlastedCoords = {};
    final TileSet allTransformedCoords = {};

    List<Tile> primedBombs = boardManager.getTriggeredEmojis();
    bool chainReaction = primedBombs.isNotEmpty;

    while (primedBombs.isNotEmpty) {
      final currentBombs = List<Tile>.from(primedBombs);
      playSfx(Sfx.explosion);

      for (Tile activeBomb in currentBombs) {
        if (!activeBomb.isTriggered) continue;
        if (activeBomb.emoji == boardManager.level.targetEmoji) {
          collectedEmojis.add(
            CollectedEmoji(emoji: activeBomb.emoji, count: 1),
          );
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

  ({TileSet destroyed, TileSet transformed}) _executeBlastRadius(
    TileCoordinate center,
  ) {
    final TileSet destroyedTiles = {};
    final TileSet transformedTiles = {};
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
        final isExplosive =
            reaction != null && reaction.type == ReactionType.explosive;

        if (isExplosive && (r != center.row || c != center.col)) {
          if (!tile.isExploding) {
            tile.isTriggered = true;
          }
        } else {
          if (tile.behavior != null) {
            onTileBlasted?.call(
              tile,
              r,
              c,
              centerReaction?.type ?? ReactionType.explosive,
            );
          }

          final resultingEmoji = transformations[tile.emoji];
          if (resultingEmoji != null) {
            tile.emoji = resultingEmoji;
            tile.reset();
            tile.isTransmuting = true;
            transformedTiles.add(TileCoordinate(row: r, col: c));
          } else if (!tile.isSwallowTarget && !tile.isSwallowTrigger) {
            tile.isExploding = true;
            destroyedTiles.add(TileCoordinate(row: r, col: c));
          }
        }
      }
    }
    return (destroyed: destroyedTiles, transformed: transformedTiles);
  }

  void _executeMatchedBehavior(MatchGroup group) {
    if (onTileMatched == null) return;

    final rows = group.coordinates.map((c) => c.row).toSet();
    final cols = group.coordinates.map((c) => c.col).toSet();
    final bool isHorizontalGroup = rows.length == 1;
    final bool isVerticalGroup = cols.length == 1;

    for (var coord in group.coordinates) {
      final tile = boardManager.gridTiles[coord.row][coord.col];
      if (tile.behavior is ClearBehavior) {
        if (isHorizontalGroup) {
          tile.behavior = ClearBehavior(isHorizontal: true);
        } else if (isVerticalGroup) {
          tile.behavior = ClearBehavior(isHorizontal: false);
        }
      }
      onTileMatched!(tile, coord.row, coord.col);
    }
  }
}
