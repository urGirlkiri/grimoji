import 'package:flutter/material.dart';
import 'package:grimoji/app/theme/palette.dart';
import 'package:grimoji/features/match/board/controllers/gesture.dart';
import 'package:grimoji/features/match/board/controllers/v_f_x.dart';
import 'package:grimoji/features/match/board/effects/blood_drop/index.dart';
import 'package:grimoji/features/match/board/effects/time_bonus/index.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/features/match/board/effects/ghost_dive/index.dart';
import 'package:grimoji/features/match/board/effects/wheel_roll/index.dart';
import 'package:grimoji/features/match/board/widgets/announcer/index.dart';
import 'package:grimoji/features/match/board/effects/line_clear/index.dart';
import 'package:grimoji/features/match/board/widgets/board_grid.dart';
import 'package:grimoji/features/match/board/effects/sparkle/index.dart';
import 'package:grimoji/features/match/board/widgets/tile_grid/index.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/board/manager.dart';
import 'package:grimoji/utils/context_data.dart';
import 'package:provider/provider.dart';

class GameBoard extends StatefulWidget {
  const GameBoard({super.key});

  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> {
  final GlobalKey _boardKey = GlobalKey();
  final GlobalKey _tileKey = GlobalKey();

  LevelState? _levelState;
  double? _tileWidth;
  double? _tileHeight;

  late final VFXController _vfx;
  late final GestureController _gestures;

  @override
  void initState() {
    super.initState();
    _vfx = VFXController();
    _gestures = GestureController();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newLevelState = context.read<LevelState>();

    if (_levelState != newLevelState) {
      if (_levelState != null) _vfx.unbindState(_levelState!);
      _levelState = newLevelState;
      _vfx.bindState(_levelState!);
    }
  }

  @override
  void dispose() {
    if (_levelState != null) _vfx.unbindState(_levelState!);
    _vfx.dispose();
    _gestures.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    final levelState = context.read<LevelState>();

    const int gridColumns = BoardManager.cols;
    const int gridRows = BoardManager.rows;
    const int totalTiles = gridColumns * gridRows;
    const double maxAllowedBoardWidth = 350.0;

    return LayoutBuilder(
      builder: (context, screenConstraints) {
        final screenWidth = context.screenWidth;
        final isLargeSCreen = context.isLargeScreen;

        final double constrainedBoardWidth = isLargeSCreen
            ? (screenWidth > maxAllowedBoardWidth
                  ? maxAllowedBoardWidth
                  : screenWidth * largeScreenBoardWidthFactor)
            : screenWidth * smallScreenBoardWidthFactor;

        final double proportionalBoardHeight =
            ((constrainedBoardWidth * gridRows) / gridColumns) *
            boardHeightMultiplier;

        return Center(
          child: SizedBox(
            width: constrainedBoardWidth,
            height: proportionalBoardHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  padding: EdgeInsets.all(isLargeSCreen ? 8.0 : 6.0),
                  clipBehavior: Clip.hardEdge,
                  decoration: ShapeDecoration(
                    color: palette.mist,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: LayoutBuilder(
                    builder: (context, gridAreaConstraints) {
                      _tileWidth =
                          (gridAreaConstraints.maxWidth -
                              (tileSpacingGap * (gridColumns - 1))) /
                          gridColumns;
                      _tileHeight =
                          (gridAreaConstraints.maxHeight -
                              (tileSpacingGap * (gridRows - 1))) /
                          gridRows;
                      _vfx.setBoardDimensions(
                        gridAreaConstraints.maxWidth,
                        gridAreaConstraints.maxHeight,
                      );

                      return GestureDetector(
                        onTapUp: (details) => _gestures.onTapped(
                          details,
                          _tileWidth!,
                          _tileHeight!,
                          levelState,
                          _vfx,
                        ),
                        onPanStart: (details) => _gestures.onPanStart(
                          details,
                          _tileWidth!,
                          _tileHeight!,
                          levelState,
                          _vfx,
                        ),
                        onPanUpdate: (details) => _gestures.onPanUpdate(
                          details,
                          _tileWidth!,
                          _tileHeight!,
                          levelState,
                          _vfx,
                        ),
                        onPanEnd: (_) => _gestures.clearDrag(),
                        onPanCancel: () => _gestures.clearDrag(),

                        child: Stack(
                          key: _boardKey,
                          clipBehavior: Clip.none,
                          children: [
                            BoardGrid(
                              gridColumns: gridColumns,
                              totalTiles: totalTiles,
                              firstTileKey: _tileKey,
                              tWidth: _tileWidth!,
                              tHeight: _tileHeight!,
                            ),

                            ListenableBuilder(
                              listenable: _gestures.activeTileIdNotifier,
                              builder: (context, _) => TileGrid(
                                activeTileId:
                                    _gestures.activeTileIdNotifier.value,
                                tWidth: _tileWidth!,
                                tHeight: _tileHeight!,
                              ),
                            ),

                            SparkleOverlay(
                              sparklesNotifier: _vfx.sparkleManager.notifier,
                            ),

                            OverflowBox(
                              maxWidth: constrainedBoardWidth,
                              child: IgnorePointer(
                                child: TimeBonusOverlay(
                                  effectsNotifier:
                                      _vfx.timeBonusManager.notifier,
                                ),
                              ),
                            ),
                            OverflowBox(
                              maxWidth: constrainedBoardWidth,
                              child: IgnorePointer(
                                child: LineClearOverlay(
                                  notifier: _vfx.lineClearManager.notifier,
                                  tileWidth: _tileWidth!,
                                  tileHeight: _tileHeight!,
                                  cols: gridColumns,
                                  rows: gridRows,
                                ),
                              ),
                            ),

                            OverflowBox(
                              maxWidth: constrainedBoardWidth,
                              child: IgnorePointer(
                                child: WheelRollOverlay(
                                  notifier: _vfx.wheelRollManager.notifier,
                                  tileWidth: _tileWidth!,
                                  tileHeight: _tileHeight!,
                                ),
                              ),
                            ),

                            OverflowBox(
                              maxWidth: constrainedBoardWidth,
                              child: IgnorePointer(
                                child: GhostDiveOverlay(
                                  notifier: _vfx.ghostDiveManager.notifier,
                                  tileWidth: _tileWidth!,
                                  tileHeight: _tileHeight!,
                                ),
                              ),
                            ),

                            OverflowBox(
                              maxWidth: constrainedBoardWidth,
                              child: IgnorePointer(
                                child: BloodDropOverlay(
                                  notifier: _vfx.bloodDropManager.notifier,
                                  tileWidth: _tileWidth!,
                                  tileHeight: _tileHeight!,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                OverflowBox(
                  maxWidth: constrainedBoardWidth,
                  child: const AnnouncerWidget(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
