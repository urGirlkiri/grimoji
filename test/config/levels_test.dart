import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/features/match/constants.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:flutter/widgets.dart';
import '../mocks/mock_audio_controller.dart';
import 'package:logging/logging.dart';

const maxMoves = 50000;

void main() {
  setUpAll(() {
    RecipeBook.initialize();
  });

  Logger.root.level = Level.WARNING;

  group('Levels Test', () {
    for (var level in gameLevels) {
      test(
        'Level ${level.number}  should not have the target emoji in its starting emojis',
        () {
          expect(
            level.availableEmojis.contains(level.targetEmoji),
            false,
            reason:
                'Level ${level.number} has ${level.targetEmoji.visual} in starting emojis',
          );
        },
      );
      test('Level ${level.number} target is mathematically craftable', () {
        Set<GameEmoji> craftableEmojis = Set.from(level.availableEmojis);
        bool discoveredNewEmoji = true;

        while (discoveredNewEmoji) {
          discoveredNewEmoji = false;

          for (var recipe in RecipeBook.allRecipes) {
            if (!craftableEmojis.contains(recipe.yields)) {
              if (craftableEmojis.contains(recipe.ingredient)) {
                craftableEmojis.add(recipe.yields);
                discoveredNewEmoji = true;
              }
            }
          }

          for (var reaction in RecipeBook.allReactions) {
            bool hasTrigger = reaction.triggers.any(
              (triggerEmoji) => craftableEmojis.contains(triggerEmoji),
            );

            if (hasTrigger) {
              for (var entry in reaction.transformations.entries) {
                if (craftableEmojis.contains(entry.key) &&
                    !craftableEmojis.contains(entry.value)) {
                  craftableEmojis.add(entry.value);
                  discoveredNewEmoji = true;
                }
              }
            }
          }
        }

        bool hasRecipe = false;

        for (var recipe in RecipeBook.allRecipes) {
          if (recipe.yields == level.targetEmoji) {
            hasRecipe = true;
            if (craftableEmojis.contains(recipe.ingredient)) {
              craftableEmojis.add(level.targetEmoji);
            }
          }
        }

        for (var reaction in RecipeBook.allReactions) {
          for (var entry in reaction.transformations.entries) {
            if (entry.value == level.targetEmoji) {
              hasRecipe = true;
              break;
            }
          }
          if (hasRecipe) break;
        }

        expect(
          hasRecipe,
          true,
          reason:
              'Level ${level.number}\'s target ${level.targetEmoji.visual} has no recipe ',
        );

        final availableNames = level.availableEmojis
            .map((e) => e.visual)
            .join(', ');
        final craftableNames = craftableEmojis.map((e) => e.visual).join(', ');

        expect(
          craftableEmojis.contains(level.targetEmoji),
          isTrue,
          reason:
              '\n🚨 LEVEL ${level.number} IS IMPOSSIBLE!\n'
              'Target: ${level.targetEmoji.visual}\n'
              'Base Emojis: [$availableNames]\n'
              'Max Craftable: [$craftableNames]\n',
        );
      });

      test(
        'Level ${level.number} should be winnable within a reasonable number of moves',
        () async {
          fakeAsync((async) async {
            int finalStars = 0;
            bool gameEnded = false;

            final levelState = LevelState(
              level: level,
              onWin: (stars) {
                finalStars = stars;
                gameEnded = true;
              },
              onLose: () {
                finalStars = 0;
                gameEnded = true;
              },
              audio: MockAudioController(),
              lifecycleNotifier: ValueNotifier<AppLifecycleState>(
                AppLifecycleState.resumed,
              ),
            );

            levelState.startLevel();
            async.elapse(fallDuration);

            int moveCount = 0;

            while (moveCount < maxMoves && !gameEnded) {
              final hint = await levelState.engine.getHintMove();

              if (hint != null) {
                levelState.coordinator.resolveSwipe(hint[0], hint[1]);

                while (levelState.gameState.isProcessing) {
                  async.elapse(const Duration(milliseconds: 100));
                }

                moveCount++;
              } else {
                levelState.coordinator.shuffleBoard();

                while (levelState.gameState.isShuffling) {
                  async.elapse(const Duration(milliseconds: 100));
                }

                levelState.coordinator.resetHintTimer();
                moveCount++;
              }

              async.elapse(const Duration(milliseconds: 500));
            }

            levelState.dispose();

            expect(
              finalStars,
              greaterThanOrEqualTo(1),
              reason:
                  'Auto-player failed to beat Level ${level.number} in $maxMoves moves. '
                  'Collected ${levelState.collectedAmount} / ${level.targetAmount} ${level.targetEmoji.visual}. ',
            );
          });
        },
        skip: level.skipAutoPlayer
            ? 'Too complex for AutoPlayer algorithm, skipping.'
            : false,
      );

      test('Level ${level.number} should respect design constraints', () {
        expect(
          level.availableEmojis.length,
          lessThanOrEqualTo(4),
          reason:
              'Level ${level.number} has ${level.availableEmojis.length} starting emojis. Max is 4.',
        );

        if (level.number > 1) {
          final previousLevel = gameLevels.firstWhere(
            (l) => l.number == level.number - 1,
          );
          final shared = level.availableEmojis.toSet().intersection(
            previousLevel.availableEmojis.toSet(),
          );

          final sharedExcludingTarget = shared
              .where((e) => e != previousLevel.targetEmoji)
              .toList();

          expect(
            sharedExcludingTarget.length,
            lessThan(1),
            reason:
                'Level ${level.number} reuses base emojis from level ${level.number - 1} '
                'that are not the target reward. Shared: ${sharedExcludingTarget.map(((e) => e.visual))}',
          );
        }
      });
    }
  });

  test('No two levels should have the same number', () {
    final numbers = gameLevels.map((e) => e.number).toList();
    final duplicates = numbers.fold<Map<int, int>>(
      {},
      (prev, n) => prev..[n] = (prev[n] ?? 0) + 1,
    );
    final duplicateNumbers = duplicates.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .toList();

    expect(
      duplicateNumbers,
      isEmpty,
      reason: 'Duplicate level numbers found: $duplicateNumbers',
    );
  });

  test('No two levels should have the same target emoji', () {
    final targetToLevels = <GameEmoji, List<int>>{};
    for (var level in gameLevels) {
      targetToLevels.putIfAbsent(level.targetEmoji, () => []).add(level.number);
    }
    final duplicates = targetToLevels.entries
        .where((e) => e.value.length > 1)
        .toList();

    final duplicateInfo = duplicates
        .map((e) => '${e.key.visual}: levels ${e.value.join(", ")}')
        .join('\n');

    expect(
      duplicates,
      isEmpty,
      reason: 'Duplicate target emojis found:\n$duplicateInfo',
    );
  });
}
