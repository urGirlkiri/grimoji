import 'package:flutter_test/flutter_test.dart';
import 'package:fake_async/fake_async.dart';
import 'package:grimoji/features/audio/voices/dialog.dart';
import 'package:grimoji/features/match/announcer.dart';
import '../../mocks/audio_controller.dart';

void main() {
  group('BoardAnnouncer', () {
    test(
      'should keep second queued announcement active for full voiceTime after it starts',
      () {
        fakeAsync((async) {
          final mockAudio = MockAudioController();
          final announcer = BoardAnnouncer(mockAudio);

          announcer.evaluateTurn(
            events: {TurnEvent.merge},
            combo: 3,
            tilesCleared: 0,
          );

          async.elapse(const Duration(milliseconds: 200));
          announcer.evaluateTurn(
            events: {TurnEvent.legendaryEmoji},
            combo: 3,
            tilesCleared: 0,
          );

          async.elapse(const Duration(milliseconds: 1300));
          expect(announcer.activeAnnouncement, Dialog.catastrophicMasterpiece);

          async.elapse(const Duration(milliseconds: 1400));
          expect(
            announcer.activeAnnouncement,
            Dialog.catastrophicMasterpiece,
            reason: 'Second announcement should still be visible',
          );

          async.elapse(const Duration(milliseconds: 200));
          expect(announcer.activeAnnouncement, isNull);
        });
      },
    );
  });
}
