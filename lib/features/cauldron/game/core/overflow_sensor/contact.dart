import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:grimoji/features/cauldron/game/core/emoji_spawner/emoji.dart';
import 'package:grimoji/features/cauldron/game/core/overflow_sensor/index.dart';

class OverflowContactCallback with ContactCallbacks {
  final OverflowSensor sensor;

  OverflowContactCallback(this.sensor);

  @override
  void beginContact(Object other, Contact contact) {
    if (other is EmojiBody) {
      sensor.addEmoji(other);
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is EmojiBody) {
      sensor.removeEmoji(other);
    }
  }
}
