import 'package:flutter/material.dart';
import 'package:grimoji/features/profile/models/profile_data.dart';
import 'package:grimoji/features/profile/persistance/persistence.dart';
import 'package:logging/logging.dart';

class ProfileController extends ChangeNotifier {
  final ProfilePersistence _persistence;
  final Logger _log = Logger('ProfileController');
  ProfileData? _profile;

  ProfileController({required ProfilePersistence persistence})
    : _persistence = persistence;

  Future<void> load() async {
    _log.info('Loading data...');
    _profile = await _persistence.loadProfile();
    _log.info('Loaded Profile\n$_profile');
    notifyListeners();
  }

  String get avatar => _profile?.avatar ?? 'cyber_goth';
  int get cauldrons => _profile?.cauldrons ?? 5;
  int get dices => _profile?.dices ?? 0;
  int get currency => _profile?.dices ?? 0;
  bool get isFirstTime => _profile?.isFirstTime ?? true;
  bool get isLoaded => _profile != null;

  List<String> get unlockedRecipes => _profile?.unlockedRecipeIds ?? [];
  int get unreadRecipeCount => _profile?.unreadRecipeIds.length ?? 0;

  bool isRecipeUnlocked(String id) =>
      _profile?.unlockedRecipeIds.contains(id) ?? false;
  bool isRecipeUnread(String id) =>
      _profile?.unreadRecipeIds.contains(id) ?? false;

  bool hasRecentlyPlayedGame() {
    if (_profile == null || _profile!.lastPlayedGameTime == 0) {
      return false;
    }

    final lastPlayedDate = DateTime.fromMillisecondsSinceEpoch(
      _profile!.lastPlayedGameTime,
    );
    final now = DateTime.now();

    final differenceInHours = now.difference(lastPlayedDate).inHours;

    return differenceInHours < 24;
  }

  void markGamePlayed() {
    if (_profile != null) {
      _profile!.lastPlayedGameTime = DateTime.now().millisecondsSinceEpoch;
      _save();
    }
  }

  void markTutorialComplete() {
    _profile?.isFirstTime = false;
    _save();
  }

  void unlockRecipe(String recipeId) {
    if (_profile != null) {
      if (!_profile!.unlockedRecipeIds.contains(recipeId)) {
        _profile?.unlockedRecipeIds.add(recipeId);
        _profile?.unreadRecipeIds.add(recipeId);
        _save();
      }
    }
  }

  void markRecipeAsRead(String recipeId) {
    if (_profile != null) {
      if (_profile!.unreadRecipeIds.contains(recipeId)) {
        _profile?.unreadRecipeIds.remove(recipeId);
        _save();
      }
    }
  }

  bool spendCauldron() {
    if (_profile != null) {
      if (_profile!.cauldrons > 0) {
        _profile!.cauldrons--;

        if (_profile!.cauldrons < 5) {
          _profile!.lastCauldronRegenTime =
              DateTime.now().millisecondsSinceEpoch;
        }
        _save();
        return true;
      }
    }
    return false;
  }

  void refillCauldrons() {
    if (_profile != null) {
      _profile!.cauldrons = 5;
      _profile!.lastCauldronRegenTime = 0;
      _save();
    }
  }

  void addCurrency(int amount) {
    int current = _profile?.dices ?? 0;
    _profile?.dices = current + amount;
    _save();
  }

  bool spendDice(int amount) {
    if (_profile == null) return false;
    int current = _profile!.dices;
    if (current < amount) return false;
    _profile!.dices = current - amount;
    _profile!.inventory['dice'] = current - amount;
    _save();
    return true;
  }

  bool get hasClaimedDaily => _profile?.hasClaimedDaily ?? false;
  int get lastDailyClaimTime => _profile?.lastDailyClaimTime ?? 0;

  bool canClaimDaily() {
    if (_profile == null) return true;
    if (!_profile!.hasClaimedDaily) return true;
    final lastClaim = DateTime.fromMillisecondsSinceEpoch(_profile!.lastDailyClaimTime);
    final now = DateTime.now();
    return now.difference(lastClaim).inHours >= 24;
  }

  Duration timeUntilNextDailyClaim() {
    if (_profile == null || !_profile!.hasClaimedDaily) return Duration.zero;
    final lastClaim = DateTime.fromMillisecondsSinceEpoch(_profile!.lastDailyClaimTime);
    final nextClaim = lastClaim.add(const Duration(hours: 24));
    final now = DateTime.now();
    return nextClaim.isBefore(now) ? Duration.zero : nextClaim.difference(now);
  }

  void claimDailyReward() {
    if (_profile != null) {
      _profile!.hasClaimedDaily = true;
      _profile!.lastDailyClaimTime = DateTime.now().millisecondsSinceEpoch;
      addCurrency(15);
    }
  }

  void resetDailyClaim() {
    if (_profile != null) {
      _profile!.hasClaimedDaily = false;
      _save();
    }
  }

  void _save() {
    if (_profile != null) {
      _persistence.saveProfile(_profile!);
      notifyListeners();
    }
  }
}
