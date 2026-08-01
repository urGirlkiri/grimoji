import 'package:grimoji/features/audio/sounds/sfx.dart';

List<String> soundTypeToFilename(Sfx type) => switch (type) {
  Sfx.buttonTap => const [
    'whirl_test_tube.m4a',
    'whirl_test_tube_2.m4a',
    'whirl_test_tube_3.m4a',
    'whirl_test_tube_4.m4a',
  ],

  Sfx.congrats => const ['congrats.m4a', 'congrats2.m4a', 'congrats3.m4a'],

  Sfx.celebration => const [
    'witch_laugh.m4a',
    'witch_laugh_2.m4a',
    'witch_crackle.m4a',
    'witch_laugh_down.m4a',
  ],

  Sfx.fail => const [
    'slow_trumpet_fail.m4a',
    'trumpet_fail.m4a',
    'fail.m4a',
  ],

  Sfx.fall => const ['fall.m4a'],

  Sfx.swipe => const ['critter.m4a'],

  Sfx.invalidMove => const ['bwuu.m4a'],

  Sfx.hint => const ['swoosh.m4a'],

  Sfx.trigger => const ['trittle.m4a'],

  Sfx.merge => const ['ripple.m4a'],

  Sfx.transmute => const ['twihu.m4a'],

  Sfx.explode => const ['poof.m4a'],

  Sfx.explosion => const ['bomb.m4a'],

  Sfx.targetFlight => const ['swoosh.m4a'],

  Sfx.targetCollected => const ['twubi.m4a'],

  Sfx.recipeLocked => const ['recipe_locked.m4a'],

  Sfx.recipeUnlock => const ['recipe_unlock.m4a'],

  Sfx.recipeCollection => const ['recipe_collection.m4a'],

  Sfx.recipeRead => const ['recipe_read.m4a'],

  Sfx.purchase => const ['cha-ching.m4a'],
};
