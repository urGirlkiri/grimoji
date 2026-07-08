import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/config/levels/game_level.dart';
import 'package:grimoji/features/alchemy/recipe_book.dart';

class TestLevel {
  static GameLevel create({
    int number = 1,
    int timeLimit = 60,
    GameEmoji? targetEmoji,
    int targetAmount = 10,
    List<GameEmoji>? availableEmojis,
    String goal = 'Test goal',
    String description = 'Test description',
  }) {
    RecipeBook.initialize();

    final allKnownEmojis = RecipeBook.allRecipes
        .map((r) => r.ingredient)
        .toSet()
        .toList();

    return GameLevel(
      number: number,
      timeLimit: timeLimit,
      targetEmoji:
          targetEmoji ??
          (allKnownEmojis.isNotEmpty ? allKnownEmojis.first : Emojis.fire),
      targetAmount: targetAmount,
      availableEmojis:
          availableEmojis ??
          [Emojis.fire, Emojis.rock, Emojis.droplet, Emojis.alien],
      goal: goal,
      description: description,
    );
  }
}
