import 'package:game_app/attributes/attributes_enum.dart';

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
  int experiencePoints = 6000;
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
    0: WeaponType.flameSword,
    1: WeaponType.pistol,
  };
  Map<int, SecondaryType> selectedSecondaries = {
    0: SecondaryType.reloadAndRapidFire,
    1: SecondaryType.reloadAndRapidFire,
  };

  Map<WeaponType, int> unlockedWeapons = {
    WeaponType.pistol: 0,
    WeaponType.dagger: 0,
  };
  Map<SecondaryType, int> unlockedSecondarys = {
    SecondaryType.pistol: 0,
    SecondaryType.reloadAndRapidFire: 0
  };
  Map<AttributeType, int> unlockedPermanentAttributes = {};

  bool enoughMoney(int cost) {
    return experiencePoints >= cost;
  }

  bool unlockAttribute(AttributeType? attributeType) {
    if (attributeType == null) return false;
    final currentLevel = unlockedPermanentAttributes[attributeType] ?? 0;
    final currentAttribute = attributeType.buildAttribute(
      currentLevel,
      null,
      null,
    );
    if (currentAttribute.upgradeLevel == currentAttribute.maxLevel) {
      return false;
    }

    final cost = currentAttribute.cost();
    final canAfford = enoughMoney(cost);

    if (canAfford) {
      if (unlockedPermanentAttributes.containsKey(attributeType)) {
        unlockedPermanentAttributes[attributeType] =
            unlockedPermanentAttributes[attributeType]! + 1;
      } else {
        unlockedPermanentAttributes[attributeType] = 1;
      }
      experiencePoints -= cost;
      spentExperiencePoints += cost;
    }
    parentComponent?.notifyListeners();
    return canAfford;
  }
}
