import 'package:grimoji/features/audio/sounds/sfx_type.dart';

List<String> soundTypeToFilename(SfxType type) => switch (type) {
  SfxType.buttonTap => const [
    'whirl_test_tube.m4a',
    'whirl_test_tube_2.m4a',
    'whirl_test_tube_3.m4a',
    'whirl_test_tube_4.m4a',
  ],

  SfxType.congrats => const ['congrats.m4a', 'congrats2.m4a', 'congrats3.m4a'],

  SfxType.celebration => const [
    'witch_laugh.m4a',
    'witch_laugh_2.m4a',
    'witch_crackle.m4a',
    'witch_laugh_down.m4a',
  ],

  SfxType.fail => const [
    'slow_trumpet_fail.m4a',
    'trumpet_fail.m4a',
    'fail.m4a',
  ],

  SfxType.fall => const ['fall.m4a'],

  SfxType.swipe => const ['critter.m4a'],

  SfxType.invalidMove => const ['bwuu.m4a'],

  SfxType.hint => const ['swoosh.m4a'],

  SfxType.trigger => const ['trittle.m4a'],

  SfxType.merge => const ['ripple.m4a'],

  SfxType.transmute => const ['twihu.m4a'],

  SfxType.explode => const ['poof.m4a'],

  SfxType.explosion => const ['bomb.m4a'],

  SfxType.targetFlight => const ['swoosh.m4a'],

  SfxType.targetCollected => const ['twubi.m4a'],

  SfxType.recipeLocked => const ['recipe_locked.m4a'],

  SfxType.recipeUnlock => const ['recipe_unlock.m4a'],

  SfxType.recipeCollection => const ['recipe_collection.m4a'],

  SfxType.recipeRead => const ['recipe_read.m4a'],
};
