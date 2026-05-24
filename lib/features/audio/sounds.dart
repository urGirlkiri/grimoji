List<String> soundTypeToFilename(SfxType type) => switch (type) {
  SfxType.buttonTap => const [
    'whirl_test_tube.mp3',
    'whirl_test_tube_2.mp3',
    'whirl_test_tube_3.mp3',
    'whirl_test_tube_4.mp3',
  ],

  SfxType.congrats => const [
    'congrats.mp3',
    'congrats2.mp3',
    'congrats3.mp3',
  ],

  SfxType.celebration => const [
    'witch_laugh.mp3',
    'witch_crackle.mp3',
    'witch_laugh_down.mp3'
  ],

  SfxType.fail => const [
    'slow_trumpet_fail.mp3',
    'trumpet_fail.mp3',
    'fail.mp3',
  ]
};

double soundTypeToVolume(SfxType type) {
  switch (type) {
    case SfxType.buttonTap:
    case SfxType.congrats:
    case SfxType.celebration:
    case SfxType.fail:
      return 1.0;
  }
}

enum SfxType { buttonTap, congrats, celebration, fail }