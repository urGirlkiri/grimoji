import 'package:grimoji/features/audio/sounds/sfx_type.dart';

List<String> soundTypeToFilename(SfxType type) => switch (type) {
  SfxType.buttonTap => const [
    'whirl_test_tube.mp3',
    'whirl_test_tube_2.mp3',
    'whirl_test_tube_3.mp3',
    'whirl_test_tube_4.mp3',
  ],

  SfxType.congrats => const ['congrats.mp3', 'congrats2.mp3', 'congrats3.mp3'],

  SfxType.celebration => const [
    'witch_laugh.mp3',
    'witch_laugh_2.mp3',
    'witch_crackle.mp3',
    'witch_laugh_down.mp3',
  ],

  SfxType.fail => const [
    'slow_trumpet_fail.mp3',
    'trumpet_fail.mp3',
    'fail.mp3',
  ],

  SfxType.fall => const [
    'fall.wav',
  ],

  SfxType.swipe => const [
    'critter.wav'
  ],

  SfxType.invalidMove => const [
    'bwuu.wav'
  ],

  SfxType.hint => const [
    'swoosh.wav'
  ],

  SfxType.trigger => const [
    'trittle.wav'
  ],

  SfxType.merge => const [
    'ripple.wav',
  ],

  SfxType.transmute => const [
    'twihu.wav',
  ],

  SfxType.explode => const [
    'poof.wav'
  ],

  SfxType.explosion => const [
    'bomb.wav'
  ],

  SfxType.targetFlight => const [
    'swoosh.wav'
  ],

  SfxType.targetCollected => const [
    'tee.wav'
  ],

  SfxType.recipeUnlock => const [
  ],

  SfxType.recipeCollection => const [
  ],

  SfxType.recipeRead => const [
  ],

};
