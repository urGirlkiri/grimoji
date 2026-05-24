import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/config/levels/index.dart';
import 'package:grimoji/config/constants.dart';
import 'package:grimoji/config/emojis.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';
import 'package:grimoji/features/level/state.dart';
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

        expect(hasRecipe,true, reason: 'Level ${level.number}\'s target ${level.targetEmoji.visual} has no recipe ');

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
        () {
          fakeAsync((async) {
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
            );

            levelState.startLevel();
            async.elapse(gravityAnimationTime);

            int moveCount = 0;

            while (moveCount < maxMoves && !gameEnded) {
              final hint = levelState.engine.getHintMove();

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
}
