import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:grimoji/features/level/state.dart';
import 'package:grimoji/features/match/announcer.dart';
import 'package:grimoji/features/match/board/widgets/announcer/text.dart';
import 'package:provider/provider.dart';

class AnnouncerWidget extends StatefulWidget {
  const AnnouncerWidget({super.key});

  @override
  State<AnnouncerWidget> createState() => AnnouncerWidgetState();
}

class AnnouncerWidgetState extends State<AnnouncerWidget> {
  late final BoardAnnouncer _announcer;
  String? _currentPhrase;
  int _token = 0;

  @override
  void initState() {
    super.initState();
    _announcer = context.read<LevelState>().announcer;
    _announcer.addListener(_onAnnouncerChanged);
    _maybeCapture();
  }

  void _onAnnouncerChanged() {
    _maybeCapture();
  }

  void _maybeCapture() {
    final announcement = _announcer.activeAnnouncement;
    final token = _announcer.announcementToken;

    if (announcement == null || token == _token) return;

    setState(() {
      _currentPhrase = announcement.text;
      _token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    final phrase = _currentPhrase;

    if (phrase == null) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: IgnorePointer(
        key: ValueKey(_token),
        child: AnText(phrase: phrase)
            .animate(
              onComplete: (controller) {
                if (mounted && _token == _announcer.announcementToken) {
                   setState(() => _currentPhrase = null);
                }
              }
            )
            .fadeIn(duration: 100.ms)
            .moveY(begin: 30, end: 0, duration: 200.ms, curve: Curves.easeOut)
            .scale(
              begin: const Offset(0.5, 0.5),
              end: const Offset(1.0, 1.0),
              duration: 250.ms,
              curve: Curves.elasticOut,
            )
            .moveY(
              begin: 0,
              end: -40,
              delay: 1200.ms,
              duration: 250.ms,
              curve: Curves.easeIn,
            )
            .scale(
              begin: const Offset(1.0, 1.0),
              end: const Offset(0.5, 0.5),
              delay: 1200.ms,
              duration: 250.ms,
            )
            .fadeOut(delay: 1250.ms, duration: 200.ms),
      ),
    );
  }

  @override
  void dispose() {
    _announcer.removeListener(_onAnnouncerChanged);
    super.dispose();
  }
}