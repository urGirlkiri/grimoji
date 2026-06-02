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
    'witch_crackle.mp3',
    'witch_laugh_down.mp3',
  ],

  SfxType.fail => const [
    'slow_trumpet_fail.mp3',
    'trumpet_fail.mp3',
    'fail.mp3',
  ],

  SfxType.swipe => const [
  ],

  SfxType.invalidMove => const [
  ],

  SfxType.hint => const [
  ],

  SfxType.trigger => const [
  ],

  SfxType.merge => const [
  ],

  SfxType.transmute => const [
  ],

  SfxType.fall => const [
  ],

  SfxType.explode => const [
  ],

  SfxType.fly => const [
  ],

  SfxType.recipeCollection => const [
  ],

  SfxType.targetHit => const [
  ],

  SfxType.recipeRead => const [
  ],

  SfxType.recipeUnlock => const [
  ],
};
