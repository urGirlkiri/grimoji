import 'package:uuid/uuid.dart';

abstract class BoardEffect {
  final String id;

  final DateTime timestamp;

  BoardEffect({String? id})
    : id = id ?? const Uuid().v4(),
      timestamp = DateTime.now();
}
