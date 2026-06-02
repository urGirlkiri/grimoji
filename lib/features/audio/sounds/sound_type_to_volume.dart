import 'package:grimoji/features/audio/sounds/sfx_type.dart';

double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.buttonTap:
    case SfxType.congrats:
    case SfxType.celebration:
    case SfxType.transmute:
    case SfxType.explode:
    case SfxType.targetHit:
    case SfxType.fail:
    case SfxType.recipeUnlock:
    case SfxType.recipeCollection:
    case SfxType.recipeRead:
      return 1.0;

    case SfxType.merge:
    case SfxType.fly:
    case SfxType.trigger:
    case SfxType.swipe:
      return 0.6;

    case SfxType.invalidMove:
    case SfxType.hint:
    case SfxType.fall:
      return 0.3;
  }
}
