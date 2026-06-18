import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/behavior.dart';
import 'package:grimoji/features/match/board/models/coordinate.dart';
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
  bool isTaggedForDestruct = false;

  bool hasFlown = false;
  bool isFlying = false;

  bool isHinting = false;

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
    
    newTile.isTaggedForDestruct = isTaggedForDestruct;

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

    isTaggedForDestruct = false;
  }

  void clearBehavior() {
    behavior = null;
  }

  @override
  String toString() =>
      'Tile(${coordinate.row}, ${coordinate.col}: ${emoji.visual})';
}
