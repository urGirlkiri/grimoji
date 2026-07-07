import 'dart:async';
import 'package:grimoji/features/audio/audio_controller.dart';
import 'package:grimoji/features/audio/sounds/sfx_type.dart';
import 'package:grimoji/features/match/engines/game.dart';
import 'package:grimoji/features/match/state.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:grimoji/features/match/models/tile.dart';

class HintController {

  static const timeDelay = Duration(seconds: 2);

  final GameEngine engine;
  final GameState state;
  final AudioController audio;

  Timer? _hintTimer;
  List<TileCoordinate>? _currentHints;

  HintController({
    required this.engine,
    required this.state,
    required this.audio,
  });

  void reset() {
    clear();
    if (state.isDisposed ||
        state.isGameOver ||
        state.isFeverTime ||
        !state.hintsEnabled) {
      _hintTimer?.cancel();
      return;
    }

    _hintTimer?.cancel();
    _hintTimer = Timer(timeDelay, _triggerHint);
  }

  void clear() {
    _hintTimer?.cancel();
    _currentHints = null;

    _forEachTile((_, _, tile) {
      tile.isHinting = false;
      tile.hintPartner = null;
    });
    state.updateUI();
  }

  void cancel() {
    _hintTimer?.cancel();
  }

  Future<void> _triggerHint() async {
    if (state.isProcessing ||
        state.isShuffling ||
        state.isDisposed ||
        state.isGameOver ||
        state.isPaused ||
        state.isFeverTime) {
      return;
    }

    _currentHints = await engine.getHintMove();

    if (state.isDisposed) return;

    if (_currentHints != null) {
      audio.playSfx(SfxType.hint);
      Tile tileA = engine.grid[_currentHints![0].row][_currentHints![0].col];
      Tile tileB = engine.grid[_currentHints![1].row][_currentHints![1].col];

      tileA.isHinting = true;
      tileA.hintPartner = tileB.coordinate;
      tileB.isHinting = true;
      tileB.hintPartner = tileA.coordinate;

      state.updateUI();
    }
  }

  void _forEachTile(void Function(int row, int col, Tile tile) action) {
    for (int r = 0; r < engine.grid.length; r++) {
      for (int c = 0; c < engine.grid[r].length; c++) {
        action(r, c, engine.grid[r][c]);
      }
    }
  }

  void dispose() {
    _hintTimer?.cancel();
  }
}
