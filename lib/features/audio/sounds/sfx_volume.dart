import 'package:grimoji/features/audio/sounds/sfx.dart';

double soundTypeToVolume(Sfx type) {
  switch (type) {
    case Sfx.congrats:
    case Sfx.celebration:
    case Sfx.explode:
    case Sfx.explosion:
    case Sfx.fail:
    case Sfx.recipeLocked:
    case Sfx.recipeUnlock:
    case Sfx.recipeCollection:
    case Sfx.recipeRead:
    case Sfx.purchase:
    case Sfx.strongWhoosh:
    case Sfx.wheelRoll:
      return 1.0;

    case Sfx.bloodSplatter:
    case Sfx.potionDrop:
    case Sfx.poopSquelch:
    case Sfx.ufoAbduct:
    case Sfx.ufoBeam:
      return 0.9;

    case Sfx.transmute:
    case Sfx.clownLaugh:
    case Sfx.bonusChime:
    case Sfx.ufoFlight:
    case Sfx.mediumWhoosh:
    case Sfx.ghostHaunt:
    case Sfx.ghostDive:
      return 0.8;

    case Sfx.targetCollected:
      return 0.7;

    case Sfx.merge:
    case Sfx.targetFlight:
    case Sfx.trigger:
    case Sfx.swipe:
    case Sfx.liteWhoosh:
      return 0.6;

    case Sfx.buttonTap:
      return 0.5;

    case Sfx.invalidMove:
    case Sfx.hint:
    case Sfx.fall:
      return 0.3;
  }
}
