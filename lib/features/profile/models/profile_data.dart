import 'package:hive/hive.dart';

part 'profile_data.g.dart';

@HiveType(typeId: 3)
class ProfileData extends HiveObject {
  @HiveField(0)
  bool isFirstTime;

  @HiveField(1)
  String avatar;

  @HiveField(2)
  List<String> unlockedRecipeIds;

  @HiveField(3)
  List<String> unreadRecipeIds;

  @HiveField(4)
  int cauldrons;

  @HiveField(5)
  int lastCauldronRegenTime;

  @HiveField(6)
  Map<String, int> inventory;

  @HiveField(7)
  int dices;

  @HiveField(8)
  int lastPlayedGameTime;

  @HiveField(9, defaultValue: false)
  bool hasClaimedDaily;

  @HiveField(10, defaultValue: 0)
  int lastDailyClaimTime;

  ProfileData({
    this.isFirstTime = true,
    this.avatar = 'cyber_goth',
    this.unlockedRecipeIds = const [],
    this.unreadRecipeIds = const [],
    this.cauldrons = 5,
    this.lastCauldronRegenTime = 0,
    this.lastPlayedGameTime = 0,
    this.dices = 0,
    this.inventory = const {},
    this.hasClaimedDaily = false,
    this.lastDailyClaimTime = 0,
  });

@override
  String toString() {
    return '''
    Avatar: $avatar
    ${isFirstTime ? "First Time Player" : "Recurring Player"}
    Last Played: ${DateTime.fromMillisecondsSinceEpoch(lastPlayedGameTime).toString()}
    $cauldrons Cauldrons
    $dices Dices
    ${unlockedRecipeIds.length} Unlocked Recipes
    ${unreadRecipeIds.length} Unread Recipes
    Daily Claimed: $hasClaimedDaily
    ''';
  }
}
