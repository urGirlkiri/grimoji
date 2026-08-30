import 'package:grimoji/features/level/models/powerup_handler.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/blood.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/hourglass.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/punch.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/testtube/index.dart';
import 'package:grimoji/features/level/widgets/footer/powerups/ufo/index.dart';

class PowerupHandlerRegistry {
  static final Map<String, PowerupHandler> _handlers = {
    'hourglass': HourglassHandler(),
    'boxing_glove': PunchHandler(),
    'blood': BloodHandler(),
    'test_tube': TestTubeHandler(),
    'ufo': UFOHandler(),
  };

  static PowerupHandler? get(String id) => _handlers[id];
}
