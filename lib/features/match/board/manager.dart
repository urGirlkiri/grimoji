import 'dart:math';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/config/levels/difficulty.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/powerups.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/match/models/tile.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/types.dart';
import 'package:logging/logging.dart';

class BoardManager {
  final Logger _log = Logger('BoardManager');
  static const int rows = 8;
  static const int cols = 5;

  late List<List<Tile>> gridTiles;
  final GameLevel level;
  final Random _random = Random();
  final void Function(SfxType)? playSfx;

  BoardManager(this.level, {this.playSfx});

  void initialize() {
    gridTiles = List.generate(
      rows,
      (r) => List.generate(
        cols,
        (c) => Tile(
          coordinate: TileCoordinate(row: r - rows, col: c),
          emoji: level.availableEmojis[0],
        ),
      ),
    );

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].emoji = getRandomSafeEmoji(r, c);
      }
    }

    if (_random.nextDouble() < LevelDifficulty.prankChanceFor(level.number)) {
      final prankRow = _random.nextInt(rows);
      final prankCol = _random.nextInt(cols);
      gridTiles[prankRow][prankCol].emoji = Emojis.impSmile;
    }
  }

  GameEmoji getRandomSafeEmoji(int row, int col) {
    GameEmoji candidate = level.availableEmojis[0];
    bool isSafe = false;

    while (!isSafe) {
      candidate =
          level.availableEmojis[_random.nextInt(level.availableEmojis.length)];
      isSafe = true;

      if (col > 1 &&
          gridTiles[row][col - 1].emoji == candidate &&
          gridTiles[row][col - 2].emoji == candidate) {
        isSafe = false;
      }
      if (row > 1 &&
          gridTiles[row - 1][col].emoji == candidate &&
          gridTiles[row - 2][col].emoji == candidate) {
        isSafe = false;
      }
      if (row > 0 &&
          col > 0 &&
          gridTiles[row - 1][col - 1].emoji == candidate &&
          gridTiles[row - 1][col].emoji == candidate &&
          gridTiles[row][col - 1].emoji == candidate) {
        isSafe = false;
      }
      if (row > 0 &&
          col < cols - 1 &&
          gridTiles[row - 1][col + 1].emoji == candidate &&
          gridTiles[row - 1][col].emoji == candidate &&
          gridTiles[row][col + 1].emoji == candidate) {
        isSafe = false;
      }
    }
    return candidate;
  }

  void swapTiles(TileCoordinate aCoord, TileCoordinate bCoord) {
    Tile tileA = gridTiles[aCoord.row][aCoord.col];
    Tile tileB = gridTiles[bCoord.row][bCoord.col];

    gridTiles[bCoord.row][bCoord.col] = tileA.copyWith(
      coordinate: TileCoordinate(row: bCoord.row, col: bCoord.col),
    );

    gridTiles[aCoord.row][aCoord.col] = tileB.copyWith(
      coordinate: TileCoordinate(row: aCoord.row, col: aCoord.col),
    );
  }

  void triggerInitialFall() {
    playSfx?.call(SfxType.fall);
    settleTileCoordinates();
  }

  void settleTileCoordinates() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].coordinate.row = r;
        gridTiles[r][c].coordinate.col = c;
      }
    }
  }

  bool collectFlyingTiles() {
    TileSet collected = {};
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (gridTiles[r][c].isFlying) {
          collected.add(TileCoordinate(row: r, col: c));
          gridTiles[r][c].isFlying = false;
        }
      }
    }

    if (collected.isEmpty) return false;

    applyGravity(collected);
    return true;
  }

  GravityResult applyGravity(TileSet tilesToDestroy) {
    final Set<int> affectedColumns = {};
    final Set<int> affectedRows = {};
    bool clownOnBoard = false;
    bool clownSpawned = false;

    bool pranksterOnBoard = false;
    bool pranksterSpawned = false;

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (gridTiles[r][c].emoji == Emojis.clown) {
          clownOnBoard = true;
          break;
        }
      }
      if (clownOnBoard) break;
    }

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (gridTiles[r][c].emoji == Emojis.impSmile) {
          pranksterOnBoard = true;
          break;
        }
      }
      if (pranksterOnBoard) break;
    }

    final shouldSpawnClown =
        !clownOnBoard &&
        _random.nextDouble() < LevelDifficulty.clownChanceFor(level.number);

    final shouldSpawnPrankster =
        !pranksterOnBoard &&
        _random.nextDouble() < LevelDifficulty.prankChanceFor(level.number);

    for (int c = 0; c < cols; c++) {
      List<Tile> remainingTiles = [];
      int destroyedCount = 0;
      int highestDestroyedRow = -1;

      for (int r = 0; r < rows; r++) {
        if (tilesToDestroy.any((m) => m.row == r && m.col == c)) {
          destroyedCount++;
          if (r > highestDestroyedRow) {
            highestDestroyedRow = r;
          }
        } else {
          remainingTiles.add(gridTiles[r][c]);
        }
      }

      if (destroyedCount == 0) continue;

      if (destroyedCount > 0) {
        _log.info(
          'Gravity col $c: destroyed=$destroyedCount highestRow=$highestDestroyedRow remaining=${remainingTiles.length}',
        );
      }

      affectedColumns.add(c);

      for (int r = 0; r <= highestDestroyedRow; r++) {
        affectedRows.add(r);
      }

      playSfx?.call(SfxType.fall);

      List<Tile> skyTiles = List.generate(destroyedCount, (i) {
        GameEmoji emoji;
        if (shouldSpawnClown && !clownSpawned && i == 0) {
          emoji = Emojis.clown;
          clownSpawned = true;
        } else if (shouldSpawnPrankster && !pranksterSpawned && i == 0) {
          emoji = Emojis.impSmile;
          pranksterSpawned = true;
        } else {
          emoji = level
              .availableEmojis[_random.nextInt(level.availableEmojis.length)];
        }
        final tile = Tile(
          coordinate: TileCoordinate(row: -destroyedCount + i, col: c),
          emoji: emoji,
        );
        return tile;
      });

      List<Tile> newColumn = [...skyTiles, ...remainingTiles];

      for (int r = 0; r < rows; r++) {
        gridTiles[r][c] = newColumn[r];
        gridTiles[r][c].coordinate.col = c;
      }
    }

    return (cols: affectedColumns, rows: affectedRows);
  }

  ({int x, int y})? findAdjacentEmptyTile(int centerX, int centerY) {
    final List<({int x, int y})> candidates = [];

    for (final (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
      final nx = centerX + dx;
      final ny = centerY + dy;

      if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
        if (gridTiles[nx][ny].emoji.visual.isEmpty) {
          candidates.add((x: nx, y: ny));
        }
      }
    }

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  ({int x, int y})? findAdjacentFilledTile(int centerX, int centerY) {
    final List<({int x, int y})> candidates = [];

    for (final (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
      final nx = centerX + dx;
      final ny = centerY + dy;

      if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
        if (gridTiles[nx][ny].emoji.visual.isNotEmpty) {
          candidates.add((x: nx, y: ny));
        }
      }
    }

    if (candidates.isEmpty) return null;
    return candidates[_random.nextInt(candidates.length)];
  }

  List<Tile> getAdjacentTiles(int row, int col) {
    final List<Tile> adjacent = [];
    for (final (dx, dy) in [(-1, 0), (1, 0), (0, -1), (0, 1)]) {
      final nx = row + dx;
      final ny = col + dy;
      if (nx >= 0 && nx < rows && ny >= 0 && ny < cols) {
        adjacent.add(gridTiles[nx][ny]);
      }
    }
    return adjacent;
  }

  void flagFlyingTargetEmojis(TileSet coordinates) {
    for (var coord in coordinates) {
      if (gridTiles[coord.row][coord.col].emoji == level.targetEmoji) {
        gridTiles[coord.row][coord.col].isFlying = true;
      }
    }
  }

  void clearTransmutingFlags() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].isTransmuting = false;
      }
    }
  }

  bool hasClownShuffling() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (gridTiles[r][c].isClownShuffling) return true;
      }
    }
    return false;
  }

  void clearShufflingFlags() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].isShuffling = false;
        gridTiles[r][c].isClownShuffling = false;
      }
    }
  }

  void clearAllFlyingFlags() {
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        gridTiles[r][c].isFlying = false;
      }
    }
  }

  void shuffleGrid() {
    List<GameEmoji> allEmojis = gridTiles
        .expand((row) => row.map((tile) => tile.emoji))
        .toList();
    allEmojis.shuffle();

    int index = 0;
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = gridTiles[r][c];
        tile.emoji = allEmojis[index++];
        tile.reset();
        tile.clearBehavior();
      }
    }
  }

  List<Tile> getTriggeredEmojis() {
    final List<Tile> emojis = [];
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (gridTiles[r][c].isTriggered) {
          emojis.add(gridTiles[r][c]);
        }
      }
    }
    return emojis;
  }

  void spawnBomb() {
    final List<TileCoordinate> candidates = [];
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        final tile = gridTiles[r][c];
        if (!tile.isTriggered && tile.behavior == null) {
          candidates.add(TileCoordinate(row: r, col: c));
        }
      }
    }

    if (candidates.isEmpty) return;

    candidates.shuffle();
    final coord = candidates[0];
    gridTiles[coord.row][coord.col].emoji = Emojis.bomb;
  }

  void triggerAllBombs() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (gridTiles[r][c].emoji == Emojis.bomb &&
            !gridTiles[r][c].isTriggered) {
          gridTiles[r][c].isTriggered = true;
        }
      }
    }
  }

  Tile? getSafeBomb() {
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (gridTiles[r][c].emoji == Emojis.bomb &&
            !gridTiles[r][c].isTriggered) {
          return gridTiles[r][c];
        }
      }
    }
    return null;
  }

  void triggerNextBomb() {
    final bomb = getSafeBomb();
    if (bomb != null) {
      bomb.isTriggered = true;
    }
  }

  int countSafeBombs() {
    int count = 0;
    for (int r = 0; r < BoardManager.rows; r++) {
      for (int c = 0; c < BoardManager.cols; c++) {
        if (gridTiles[r][c].emoji == Emojis.bomb &&
            !gridTiles[r][c].isTriggered) {
          count++;
        }
      }
    }
    return count;
  }

  void placeStartingBoosters(List<String> boosterIds) {
    final List<TileCoordinate> available = [];

    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (gridTiles[r][c].behavior == null) {
          available.add(TileCoordinate(row: r, col: c));
        }
      }
    }

    available.shuffle(_random);

    final Set<String> placed = {};

    for (final id in boosterIds) {
      if (placed.contains(id)) continue;
      if (id == 'crystal_ball') {
        placed.add(id);
        continue;
      }
      final List<GameEmoji> emojis;
      if (id == 'board_sweep') {
        emojis = [Emojis.barberPole, Emojis.bomb];
      } else {
        final emoji = Powerup.emojiForId(id);
        emojis = emoji != null ? [emoji] : [];
      }
      if (emojis.isEmpty) continue;
      if (available.length < emojis.length) break;

      var coords = <TileCoordinate>[];
      if (id == 'board_sweep' && emojis.length == 2) {
        coords = _findPair(available);
        if (coords.isEmpty) {
          coords = [available.removeAt(0), available.removeAt(0)];
        } else {
          available.removeWhere((p) => coords.contains(p));
        }
      } else {
        coords = [];
        for (int i = 0; i < emojis.length; i++) {
          coords.add(available.removeAt(0));
        }
      }

      for (int i = 0; i < emojis.length; i++) {
        final coord = coords[i];
        final tile = gridTiles[coord.row][coord.col];
        tile.emoji = emojis[i];
        tile.reset();
        tile.clearBehavior();
      }
      placed.add(id);
    }
  }

  List<TileCoordinate> _findPair(List<TileCoordinate> positions) {
    for (int i = 0; i < positions.length; i++) {
      final a = positions[i];
      for (int j = i + 1; j < positions.length; j++) {
        final b = positions[j];
        if (a.row == b.row && (a.col - b.col).abs() == 1) {
          return [a, b];
        }
      }
    }
    return [];
  }
}
