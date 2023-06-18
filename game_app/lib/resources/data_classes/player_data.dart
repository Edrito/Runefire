import 'package:game_app/entities/player.dart';

import '../enums.dart';
import 'package:hive/hive.dart';

import 'base.dart';

class PlayerDataComponent extends DataComponent {
  PlayerDataComponent(super.dataObject);

  @override
  PlayerData get dataObject => super.dataObject as PlayerData;
}

@HiveType(typeId: 1)
class PlayerData extends DataClass {
  int experiencePoints = 0;
  int spentExperiencePoints = 0;

  List<GameLevel> completedLevels = [];

  WeaponType selectedWeapon1 = WeaponType.pistol;
  WeaponType selectedWeapon2 = WeaponType.sword;

  Map<WeaponType, int> unlockedWeapons = {};
}
