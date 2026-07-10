import 'package:grimoji/features/level/models/powerup_handler.dart';
import 'package:grimoji/features/level/powerup_handlers/hourglass.dart';

class PowerupHandlerRegistry {
  static final Map<String, PowerupHandler> _handlers = {
    'hourglass': HourglassHandler(),
  };

  static PowerupHandler? get(String id) => _handlers[id];
}
