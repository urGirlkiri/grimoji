// ==== Tile Grid Layout ===

import 'dart:ui';

/// Pixel gap between adjacent tiles in the grid.
const double tileSpacingGap = 2.0;

/// Emoji size relative to tile width.
const double emojiSizeFactor = 0.67;

/// Board width percentage for large screens when screen exceeds max allowed width.
const double largeScreenBoardWidthFactor = 0.9;

/// Board width percentage for non-large screens.
const double smallScreenBoardWidthFactor = 0.975;

/// Board height multiplier relative to width.
const double boardHeightMultiplier = 1.12;

// ==== Tile Grid Motion ===

/// How fast swapped tiles animate into their new positions.
const Duration swapSpeed = Duration(milliseconds: 400);

/// The "hang time" after a match forms, letting the player see the combo before tiles vanish.
const Duration matchFreezeDuration = Duration(milliseconds: 500);

/// Total time a tile spends falling through the air during a cascade drop.
const Duration fallDuration = Duration(milliseconds: 400);

/// A tiny fraction of a second to let tiles "settle" and lose their momentum before the next match check.
const Duration postFallSettleDelay = Duration(milliseconds: 50);

/// How long the tiny particle dust puff lingers after an emoji is popped.
const Duration popPuffDuration = Duration(milliseconds: 600);

/// The lifetime of the flash when a bomb detonates.
const Duration blastFxDuration = Duration(milliseconds: 500);

// ==== Turn Loops & Cascades ===

/// A split-second pause right after a finger swipe to let the animations register before scanning for matches.
const Duration postSwipeScanDelay = Duration(milliseconds: 100);

/// Skipped frames delay when a transmutation triggers but has no valid targets to morph.
const Duration emptyTransmuteDelay = Duration(milliseconds: 100);

/// How long the game engine freezes while a character/emoji custom destruction skill plays out.
const Duration dynamicBehaviorLock = Duration(milliseconds: 700);

/// The final "breath" at the very end of a massive cascade combo chain before the player is allowed to touch the screen again.
const Duration turnEndInputUnlockDelay = Duration(milliseconds: 300);

/// The default clock rate used to pulse-check if background actions are paused or busy.
const Duration flagPollingInterval = Duration(milliseconds: 250);

// ==== Board Shuffle ===

/// Half of the shuffle animation loop—how long it takes to wipe the board clean or bring new tiles back in.
const Duration shuffleWipeHalfTime = Duration(milliseconds: 400);

// ==== Board Effects ====

/// How long invalid sparkles stay alive on the grid.
const Duration sparkleLifetime = Duration(milliseconds: 800);

// ==== Line Clear ====

/// The duration of the expanding energetic beam slicing across a row or column.
const Duration lineClearBeamDuration = Duration(milliseconds: 150);

/// A micro-pause after the beam passes through, giving the player an instant to register the cut before tiles shatter.
const Duration preShatterDelay = Duration(milliseconds: 120);

/// The lifetime of the line clear effect animation.
const Duration lineClearDuration = Duration(milliseconds: 300);

// ==== Black Hole Swallow ===

/// The pacing lock that pauses the board logic while a black hole spins and sucks an emoji down.
const Duration swallowAnimationLock = Duration(milliseconds: 700);

// ==== Fever Mode ===

/// Pacing interval to scatter bonus fever bombs across the board rhythmically instead of all at once.
const Duration feverBombSpawnInterval = Duration(milliseconds: 200);

/// The distinct step delay between chain-reacting bomb explosions during fever time.
const Duration feverDetonationChainDelay = Duration(milliseconds: 300);

/// The interval  for updating the ticking down of the graphical fever clock.
const Duration feverClockTickInterval = Duration(milliseconds: 150);

/// The pause between fever ending and the win screen nav.
const Duration postFeverResultsDelay = Duration(milliseconds: 500);

// ====  Wheel Roll  ====

/// The dramatic wind-up time where the center tile swells in size before generating the wheel overlay.
const Duration wheelWindUpDuration = Duration(milliseconds: 180);

/// The delay as the spinning wheel stamps out new bombs onto surrounding tiles.
const Duration wheelBombDropInterval = Duration(milliseconds: 300);

/// silence after the last wheel lands before the chain reaction actually detonates.
const Duration wheelPostDropPause = Duration(milliseconds: 200);

/// The full lifetime of the rolling overlay graphic spinning over the grid.
const Duration wheelSpinTotalDuration = Duration(milliseconds: 1100);

/// The lifetime of the wheel roll effect animation.
const Duration wheelRollDuration = Duration(milliseconds: 1200);

/// How much bigger the rolling wheel element scales visually relative to the tile size underneath it.
const double wheelVisualScaleFactor = 1.3;

// ─── Ghost Diver ─────────────────────────────────────────────────────────────

/// How much smaller  the  diving ghost scales visually relative to the tile size underneath it.
const double ghostScaleFactor = .9;

/// Total time for the ghost dive animation — travel + target destruction.
const Duration ghostDiveDuration = Duration(milliseconds: 600);

/// How long a ghost-bomb target tile plays its emoji Lottie before destruction.
const Duration ghostBombTargetAnimDuration = Duration(milliseconds: 500);

// ─── Ghost + Powerup  ───────────────────────────────────────────────────────

/// How much the powerup scales down when attached to ghost after swipe.
const double powerupScaleFactor = 0.5;

// ─── Time Bonus ───────────────────────────────────────────────────────────

/// The lifetime of the time bonus effect animation.
const Duration timeBonusDuration = Duration(milliseconds: 1000);

// ─── Blood Drop ───────────────────────────────────────────────────────────

const bloodDrop = 400;
const bloodBurst = 600;

/// How long the blood drop takes to fall onto the target tile.
const Duration bloodDropDuration = Duration(milliseconds: bloodDrop);

/// How long the impact crimson flash and red particles linger after the drop lands.
const Duration bloodBurstDuration = Duration(milliseconds: bloodBurst);

/// Total lifetime of the blood drop effect animation.
const Duration bloodDropTotalDuration = Duration(
  milliseconds: bloodBurst + bloodDrop,
);

/// How long the blood drop effect entry lives in the effect manager after creation.
const Duration bloodDropLifetime = Duration(
  milliseconds: bloodBurst + bloodDrop + 300,
);

// ─── Test Tube  ───────────────────────────────────────────────────────────

const tubeTilt = 300;
const greenDropFall = 400;
const dropBurst = 600;
const dropColor = Color(0xFF00edcd);

/// How long the test tube tilts toward the target.
const Duration tubeTiltDuration = Duration(milliseconds: tubeTilt);

/// How long the green drop takes to fall from tube mouth to target.
const Duration greenDropFallDuration = Duration(milliseconds: greenDropFall);

/// How long it takes for the green filter to disappear from test tube target
const Duration greenDropDuration = Duration(milliseconds: 300);

/// Total lifetime of the test tube drop effect animation.
const Duration tubeDropTotalDuration = Duration(
  milliseconds: tubeTilt + greenDropFall + dropBurst,
);

/// How long the test tube drop effect entry lives in the effect manager after creation.
const Duration testTubeDropLifetime = Duration(
  milliseconds: tubeTilt + greenDropFall + dropBurst + 300,
);

// ─── UFO  ───────────────────────────────────────────────────────────

/// How long the ufo effect entry lives in the effect manager after creation.
const Duration ufoLifetime = Duration(
  milliseconds: 300,
);

// ─── Clown Shuffle ─────────────────────────────────────────────────────────

/// Total duration of the clown shuffle animation cycle.
const Duration clownShuffleDuration = Duration(milliseconds: 2000);

/// Duration for each emoji cycle during shuffle animation.
const Duration clownEmojiCycleDuration = Duration(milliseconds: 150);

/// Duration of the glow effect on the clown during shuffle.
const Duration clownGlowDuration = Duration(milliseconds: 2000);
