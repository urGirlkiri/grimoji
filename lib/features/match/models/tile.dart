import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/match/models/coordinate.dart';
import 'package:uuid/uuid.dart';

class Tile {
  final String id;

  TileCoordinate coordinate;
  TileCoordinate? hintPartner;

  GameEmoji emoji;
  GameEmoji? morphTarget;

  EmojiBehavior? behavior;

  bool isTriggered = false;
  bool isExploding = false;

  bool isMerging = false;
  bool isMergePoint = false;

  bool isTransmuting = false;

  bool isSwallowTrigger = false;
  bool isSwallowTarget = false;

  bool isLineClearTrigger = false;
  bool isLineClearTarget = false;

  bool isRowClearTrigger = false;
  bool isColClearTrigger = false;

  bool isWheelTrigger = false;
  bool isWheelOrigin = false;

  bool isGhostTrigger = false;
  bool isGhostOrigin = false;
  bool isGhostTarget = false;

  bool isGhostBomb = false;

  bool isPowerupTarget = false;
  bool isBloodTarget = false;

  bool hasFlown = false;
  bool isFlying = false;

  bool isHinting = false;

  bool isShuffling = false;
  bool isClownShuffling = false;

  Tile({
    required this.coordinate,
    required this.emoji,
    String? id,
    this.behavior,
  }) : id = id ?? const Uuid().v4();

  Tile copyWith({
    TileCoordinate? coordinate,
    GameEmoji? emoji,
    EmojiBehavior? behavior,
  }) {
    final newTile = Tile(
      id: id,
      coordinate: coordinate ?? this.coordinate,
      emoji: emoji ?? this.emoji,
      behavior: behavior ?? this.behavior,
    );

    newTile.isExploding = isExploding;
    newTile.isTriggered = isTriggered;

    newTile.isMerging = isMerging;
    newTile.isMergePoint = isMergePoint;

    newTile.isTransmuting = isTransmuting;
    newTile.morphTarget = morphTarget;

    newTile.hasFlown = hasFlown;
    newTile.isFlying = isFlying;

    newTile.isHinting = isHinting;
    newTile.hintPartner = hintPartner;

    newTile.isSwallowTarget = isSwallowTarget;
    newTile.isSwallowTrigger = isSwallowTrigger;

    newTile.isLineClearTrigger = isLineClearTrigger;
    newTile.isLineClearTarget = isLineClearTarget;
    newTile.isRowClearTrigger = isRowClearTrigger;
    newTile.isColClearTrigger = isColClearTrigger;

    newTile.isGhostTrigger = isGhostTrigger;
    newTile.isGhostOrigin = isGhostOrigin;
    newTile.isGhostTarget = isGhostTarget;
    newTile.isGhostOrigin = isGhostOrigin;
    newTile.isGhostBomb = isGhostBomb;

    newTile.isPowerupTarget = isPowerupTarget;
    newTile.isBloodTarget = isBloodTarget;

    newTile.isShuffling = isShuffling;
    newTile.isClownShuffling = isClownShuffling;

    return newTile;
  }

  void reset() {
    isExploding = false;
    isTriggered = false;

    isMerging = false;
    isMergePoint = false;

    isTransmuting = false;
    morphTarget = null;

    hasFlown = false;
    isFlying = false;

    isHinting = false;
    hintPartner = null;

    isSwallowTarget = false;
    isSwallowTrigger = false;

    isLineClearTrigger = false;
    isLineClearTarget = false;
    isRowClearTrigger = false;
    isColClearTrigger = false;

    isWheelTrigger = false;
    isWheelOrigin = false;

    isGhostTrigger = false;
    isGhostOrigin = false;
    isGhostTarget = false;
    isGhostOrigin = false;
    isGhostBomb = false;

    isPowerupTarget = false;
    isBloodTarget = false;

    isShuffling = false;
    isClownShuffling = false;
  }

  void clearBehavior() {
    behavior = null;
  }

  @override
  String toString() =>
      'Tile(${coordinate.row}, ${coordinate.col}: ${emoji.visual})';
}
