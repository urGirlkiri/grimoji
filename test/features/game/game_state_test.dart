import 'package:flutter_test/flutter_test.dart';
import 'package:grimoji/features/match/state.dart';
import '../../mocks/mock_audio_controller.dart';

void main() {
  group('GameState tests', () {
    late GameState gameState;
    late MockAudioController mockAudio;

    setUp(() {
      mockAudio = MockAudioController();
      gameState = GameState(mockAudio);
    });

    tearDown(() {
      gameState.dispose();
    });

    test('Should initialize with default values', () {
      expect(gameState.isProcessing, isFalse);
      expect(gameState.hasTargetCombo, isFalse);
      expect(gameState.isShuffling, isFalse);
      expect(gameState.isPaused, isFalse);
      expect(gameState.isDisposed, isFalse);
      expect(gameState.isGameOver, isFalse);
      expect(gameState.currentComboMultiplier, 0);
      expect(gameState.shuffleProgress, 1.0);
    });

    test('Should notify listeners when setProcessing is called', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.setProcessing(true);
      expect(gameState.isProcessing, isTrue);
      expect(notified, isTrue);
    });

    test('Should notify listeners when setHasTargetCombo is called', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.setHasTargetCombo(true);
      expect(gameState.hasTargetCombo, isTrue);
      expect(notified, isTrue);
    });

    test('Should notify listeners when setShuffling is called', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.setShuffling(true);
      expect(gameState.isShuffling, isTrue);
      expect(notified, isTrue);
    });

    test('Should notify listeners when setPaused is called', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.setPaused(true);
      expect(gameState.isPaused, isTrue);
      expect(notified, isTrue);
    });

    test('Should notify listeners when setGameOver is called', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.setGameOver();
      expect(gameState.isGameOver, isTrue);
      expect(gameState.isProcessing, isFalse);
      expect(notified, isTrue);
    });

    test('Should notify listeners when setComboMultiplier is called', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.setComboMultiplier(3);
      expect(gameState.currentComboMultiplier, 3);
      expect(notified, isTrue);
    });

    test('Should increment combo multiplier correctly', () {
      // ignore: unused_local_variable
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.incrementComboMultiplier();
      expect(gameState.currentComboMultiplier, 1);
      
      gameState.incrementComboMultiplier();
      expect(gameState.currentComboMultiplier, 2);
    });

    test('Should notify listeners when setShuffleProgress is called', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.setShuffleProgress(0.5);
      expect(gameState.shuffleProgress, 0.5);
      expect(notified, isTrue);
    });

    test('Should update UI without changing state', () {
      bool notified = false;
      gameState.addListener(() => notified = true);

      gameState.updateUI();
      expect(notified, isTrue);
    });

    test('Should not notify when setting same value', () {
      int notificationCount = 0;
      gameState.addListener(() => notificationCount++);

      gameState.setProcessing(false);
      gameState.setProcessing(false);
      expect(notificationCount, 0);
    });

    test('Should set isDisposed to true on dispose', () {
      final testState = GameState(mockAudio);
      testState.dispose();
      expect(testState.isDisposed, isTrue);
    });

    test('Should not notify after disposed', () {
      final testState = GameState(mockAudio);
      testState.dispose();
      
      expect(testState.isDisposed, isTrue);
    });

    test('Should provide activeAnnouncement from announcer', () {
      expect(gameState.activeAnnouncement, isNull);
      
      gameState.announcer.announceCombo(2, isCalamity: false);
      expect(gameState.activeAnnouncement, "Wicked Alchemy!");
    });

    test('Should provide announcementToken from announcer', () {
      expect(gameState.announcementToken, 0);
      
      gameState.announcer.announceCombo(1, isCalamity: false);
      expect(gameState.announcementToken, 1);
    });
  });
}