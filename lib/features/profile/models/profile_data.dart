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

  ProfileData({
    this.isFirstTime = true,
    this.avatar = '',
    this.unlockedRecipeIds = const [],
    this.unreadRecipeIds = const [],
    this.cauldrons = 5,
    this.lastCauldronRegenTime = 0,
    this.inventory = const {},
  });

}