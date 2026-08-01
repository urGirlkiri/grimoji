import 'package:grimoji/features/audio/sounds/sfx.dart';

double soundTypeToVolume(Sfx type) {
  switch (type) {
    case Sfx.buttonTap:
    case Sfx.congrats:
    case Sfx.celebration:
    case Sfx.transmute:
    case Sfx.explode:
    case Sfx.explosion:
    case Sfx.targetCollected:
    case Sfx.fail:
    case Sfx.recipeLocked:
    case Sfx.recipeUnlock:
    case Sfx.recipeCollection:
    case Sfx.recipeRead:
    case Sfx.purchase:
      return 1.0;

    case Sfx.merge:
    case Sfx.targetFlight:
    case Sfx.trigger:
    case Sfx.swipe:
      return 0.6;

    case Sfx.invalidMove:
    case Sfx.hint:
    case Sfx.fall:
      return 0.3;
  }
}
