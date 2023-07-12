import '../../entities/player.dart';
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
  //XP
  int experiencePoints = 0;
  int spentExperiencePoints = 0;

  //STATS
  int totalEnemiesKilled = 0;
  int totalDamageDealt = 0;
  int totalAttacksDodged = 0;
  int totalJumps = 0;
  int totalDashes = 0;
  int totalAttributesUnlocked = 0;
  int totalGamesWon = 0;
  int totalGamesStarted = 0;
  int totalDeaths = 0;

  ///Update information from player, saving to file
  void updateInformation(Player player) {
    //Parse player data
    // save();
  }

  List<GameLevel> completedLevels = [];

  Map<int, WeaponType> selectedWeapons = {
    0: WeaponType.largeSword,
    1: WeaponType.pistol,
  };
  Map<int, SecondaryType> selectedSecondaries = {
    0: SecondaryType.explodeProjectiles,
    1: SecondaryType.pistol,
  };

  // WeaponType selectedWeapon1 = WeaponType.pistol;
  // SecondaryWeaponType selectedSecondary1 =
  //     SecondaryWeaponType.reloadAndRapidFire;

  // WeaponType selectedWeapon2 = WeaponType.shiv;
  // SecondaryWeaponType selectedSecondary2 = SecondaryWeaponType.pistol;

  Map<WeaponType, int> unlockedWeapons = {
    WeaponType.pistol: 0,
    WeaponType.dagger: 0,
  };
  Map<SecondaryType, int> unlockedSecondarys = {
    SecondaryType.pistol: 0,
    SecondaryType.reloadAndRapidFire: 0
  };
}
