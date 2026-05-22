import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/game/state.dart';
import 'package:grimoji/features/game/board/models/tile.dart';
import 'package:grimoji/features/game/board/models/coordinate.dart';
import 'package:grimoji/features/alchemy/recipes/recipe.dart';
import 'package:grimoji/features/alchemy/reactions/reaction.dart';
import 'package:logging/logging.dart';
import '../board/manager.dart';

class AlchemyEngine {
  final GridManager gridManager;

  final List<Recipe>? Function(GameEmoji) getRecipes;
  final Reaction? Function(GameEmoji) getReactionFor;
  final Map<GameEmoji, GameEmoji> Function(ReactionType)
  getTransformationsForType;
  final int Function(ReactionType) getAoERadiusForType;

  final Logger _log = Logger('AlchemyEngine');

  AlchemyEngine({
    required this.gridManager,
    required this.getRecipes,
    required this.getReactionFor,
    required this.getTransformationsForType,
    required this.getAoERadiusForType,
  });

  Set<TileCoordinate> processMatches(
    Set<TileCoordinate> matches,
    GameState state, {
    TileCoordinate? mergePoint,
  }) {
    Set<TileCoordinate> tilesToDestroy = {};
    Set<TileCoordinate> transmutedTiles = {};

    _processMatches(
      matches,
      state,
      tilesToDestroy,
      transmutedTiles,
      mergePoint,
    );

    tilesToDestroy.removeWhere((coord) => 
      transmutedTiles.any((t) => t.row == coord.row && t.col == coord.col)
    );

    return tilesToDestroy; 
  }

  void _processMatches(
    Set<TileCoordinate> matches,
    GameState state,
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> transmutedTiles,
    TileCoordinate? mergePoint,
  ) {
    Map<GameEmoji, Set<TileCoordinate>> groupedMatches = {};
    for (var match in matches) {
      GameEmoji emoji = gridManager.gridTiles[match.row][match.col].emoji;
      groupedMatches.putIfAbsent(emoji, () => {}).add(match);
    }

    bool mergeHappened = false;

    groupedMatches.forEach((emoji, coords) {
      state.resolveEmoji(emoji, coords.length);

      bool isAlreadyTriggered = coords.any((c) => gridManager.gridTiles[c.row][c.col].isTriggered);

      if (!isAlreadyTriggered) {
        final recipes = getRecipes(emoji);
        if (recipes != null) {
          for (var recipe in recipes) {
            if (coords.length >= recipe.requiredAmount) {
              _executeMerge(recipe, coords, state, tilesToDestroy, mergePoint);
              mergeHappened = true;
              break; 
            }
          }
          if (mergeHappened) return;
        }
      }

      final reaction = getReactionFor(emoji);
      if (reaction != null) {
        if (reaction.type == ReactionType.explosive) {
          for (var coord in coords) {
            gridManager.gridTiles[coord.row][coord.col].isTriggered = true;
          }
          _log.info('Matched explosives primed at $coords');
        } else {
          _executeReaction(coords, tilesToDestroy, transmutedTiles, reaction);
        }
        return;
      }

      tilesToDestroy.addAll(coords);
    });

    if (!mergeHappened) {
      _triggerAdjacentBombs(matches);
    }
  }

  void _triggerAdjacentBombs(Set<TileCoordinate> matches) {
    for (var match in matches) {
      final neighbors = gridManager.getAdjacentTiles(match.row, match.col);
      for (var neighbor in neighbors) {
        
        final reaction = getReactionFor(neighbor.emoji);
        
        bool isPartOfMatch = matches.any((m) => 
          m.row == neighbor.coordinate.row && m.col == neighbor.coordinate.col
        );
        
        if (!isPartOfMatch && 
            reaction != null && 
            reaction.type == ReactionType.explosive && 
            !neighbor.isTriggered) {
          _log.info('Explosive ignited at ${neighbor.coordinate}!');
          neighbor.isTriggered = true;
        }
      }
    }
  }

  void _executeMerge(
    Recipe recipe,
    Set<TileCoordinate> coords,
    GameState state,
    Set<TileCoordinate> tilesToDestroy,
    TileCoordinate? mergePoint,
  ) {
    TileCoordinate spawnPoint = coords.contains(mergePoint)
        ? mergePoint!
        : coords.first;
    Tile targetTile = gridManager.gridTiles[spawnPoint.row][spawnPoint.col];

    targetTile.emoji = recipe.yields;
    targetTile.reset();

    if (recipe.yields == gridManager.level.targetEmoji) {
      state.resolveEmoji(recipe.yields, 1);
      targetTile.isFlying = true;
    }

    tilesToDestroy.addAll(coords.where((c) => 
      c.row != spawnPoint.row || c.col != spawnPoint.col
    ));
  }

  void _executeReaction(
    Set<TileCoordinate> coords,
    Set<TileCoordinate> tilesToDestroy,
    Set<TileCoordinate> transmutedTiles,
    Reaction reaction,
  ) {
    _log.info('Reaction Initiated: ${reaction.type}');

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
              r < GridManager.rows &&
              c >= 0 &&
              c < GridManager.cols) {
            Tile targetTile = gridManager.gridTiles[r][c];
            TileCoordinate targetCoord = TileCoordinate(row: r, col: c);

            GameEmoji? resultingEmoji = transformations[targetTile.emoji];

            if (resultingEmoji != null) {
              targetTile.emoji = resultingEmoji;
              targetTile.reset(); 
              targetTile.isTransmuting = true; 
              transmutedTiles.add(targetCoord);
              _log.fine('Reacted ${targetTile.emoji.visual} at $targetCoord');
              
            } else if (!coords.any((m) => m.row == targetCoord.row && m.col == targetCoord.col) &&
                       !transmutedTiles.any((t) => t.row == targetCoord.row && t.col == targetCoord.col)) {
              final targetReaction = getReactionFor(targetTile.emoji);
              if (targetReaction != null && targetReaction.type == ReactionType.explosive) {
                targetTile.isTriggered = true;
              } else {
                targetTile.isExploding = true; 
                tilesToDestroy.add(targetCoord);
              }
              
            }
          }
        }
      }
    }
  }
}
