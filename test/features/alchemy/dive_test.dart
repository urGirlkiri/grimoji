import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/config/emojis/index.dart';
import 'package:grimoji/features/alchemy/behaviors/dive.dart';
import 'package:grimoji/features/alchemy/behaviors/models/action_type.dart';

void main() {
  group('DiveBehavior', () {
    test('returns ghostDive action when swiped with bomb', () {
      final actions = DiveBehavior().onSwipedWith(0, 0, Emojis.bomb);

      expect(actions, hasLength(1));
      expect(actions.single.type, ActionType.ghostDive);
      expect(actions.single.emoji, Emojis.bomb);
    });

    test('returns ghostDive action when swiped with barber pole', () {
      final actions = DiveBehavior().onSwipedWith(0, 0, Emojis.barberPole);

      expect(actions, hasLength(1));
      expect(actions.single.type, ActionType.ghostDive);
      expect(actions.single.emoji, Emojis.barberPole);
    });

    test('returns empty actions for unrelated emoji', () {
      final actions = DiveBehavior().onSwipedWith(0, 0, Emojis.fire);

      expect(actions, isEmpty);
    });
  });
}
