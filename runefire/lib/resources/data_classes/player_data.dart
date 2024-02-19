import 'package:runefire/achievements/achievements.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/player/player_mixin.dart';

import 'package:runefire/attributes/attributes_permanent.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/enums.dart';
import 'package:hive/hive.dart';

import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/damage_type_enum.dart';

class PlayerDataComponent extends DataComponent {
  PlayerDataComponent(super.dataObject);

  @override
  PlayerData get dataObject => super.dataObject as PlayerData;
}

@HiveType(typeId: 1)
class PlayerData extends DataClass with PlayerStatistics {
  Set<WeaponType> availableWeapons = {
    WeaponType.crystalPistol,
    WeaponType.crystalSword,
    // WeaponType.flameSword,
    ...WeaponType.values,
  };

  GameDifficulty selectedDifficulty = GameDifficulty.regular;
  GameLevel selectedLevel = GameLevel.hexedForest;
  CharacterType selectedPlayer = CharacterType.regular;
  Map<int, SecondaryType> selectedSecondaries = {
    0: SecondaryType.reloadAndRapidFire,
    1: SecondaryType.elementalBlast,
  };

  Map<int, WeaponType> selectedWeapons = {
    0: WeaponType.prismaticBeam,
    1: WeaponType.crystalSword,
  };

  int spentExperiencePoints = 0;
  Set<Achievements> unlockedAchievements = {};
  // List<GameLevel> completedLevels = [];
  List<CharacterType> unlockedCharacters = [CharacterType.regular];

  void addAchievement(Achievements achievement) {
    if (unlockedAchievements.contains(achievement)) {
      return;
    }
    unlockedAchievements.add(achievement);
    parentComponent?.notifyListeners();
  }

  Map<AttributeType, int> unlockedPermanentAttributes = {};
  Map<SecondaryType, int> unlockedSecondarys = {
    SecondaryType.pistolAttachment: 0,
    SecondaryType.reloadAndRapidFire: 0,
    SecondaryType.essentialFocus: 0,
  };

  Map<WeaponType, int> unlockedWeapons = {
    WeaponType.crystalPistol: 0,
    WeaponType.crystalSword: 0,
  };

  //XP
  int _experiencePoints = 600000;

  int get experiencePoints => _experiencePoints;

  bool characterUnlocked() {
    return unlockedCharacters.contains(selectedPlayer);
  }

  bool enoughMoney(int cost) {
    return experiencePoints >= cost;
  }

  set experiencePoints(int value) {
    _experiencePoints = value;
  }

  void selectSecondary(
    int primaryOrSecondarySlot,
    SecondaryType secondaryType,
  ) {
    selectedSecondaries[primaryOrSecondarySlot] = secondaryType;
    parentComponent?.notifyListeners();
  }

  void selectWeapon({
    required int primaryOrSecondarySlot,
    required WeaponType weaponType,
  }) {
    selectedWeapons[primaryOrSecondarySlot] = weaponType;
    final tempWeaponBuilt = weaponType.buildTemp(
      unlockedWeapons[weaponType] ?? 0,
    );
    final isCurrentSecondaryCompatible =
        selectedSecondaries[primaryOrSecondarySlot]?.compatibilityCheck(
              tempWeaponBuilt,
            ) ??
            true;

    if (!isCurrentSecondaryCompatible) {
      selectedSecondaries[primaryOrSecondarySlot] =
          SecondaryType.values.firstWhere(
        (element) => element.compatibilityCheck(tempWeaponBuilt),
        orElse: () => SecondaryType.pistolAttachment,
      );
    }

    parentComponent?.notifyListeners();
  }

  bool subtractExperience(int cost) {
    if (!enoughMoney(cost)) {
      return false;
    }
    experiencePoints -= cost;
    spentExperiencePoints += cost;
    return true;
  }

  bool unlockPermanentAttribute(AttributeType? attributeType) {
    if (attributeType == null) {
      return false;
    }
    final currentLevel = unlockedPermanentAttributes[attributeType] ?? 0;
    final currentAttribute = attributeType.buildAttribute(
      currentLevel,
      null,
      builtForInfo: true,
    );
    if ((currentAttribute.upgradeLevel == currentAttribute.maxLevel) ||
        currentAttribute is! PermanentAttribute) {
      return false;
    }

    final cost = currentAttribute.cost();

    if (!subtractExperience(cost)) {
      return false;
    }

    if (unlockedPermanentAttributes.containsKey(attributeType)) {
      unlockedPermanentAttributes[attributeType] =
          unlockedPermanentAttributes[attributeType]! + 1;
    } else {
      unlockedPermanentAttributes[attributeType] = 1;
    }

    parentComponent?.notifyListeners();
    return true;
  }

  ///Update information from player, saving to file
  void updateInformation(Player player) {
    //Parse player data
    experiencePoints += player.experiencePointsGained.round();

    for (final element in DamageType.values) {
      damageDealt[element] =
          (damageDealt[element] ?? 0) + (player.damageDealt[element] ?? 0);
      totalDamageTaken[element] = (totalDamageTaken[element] ?? 0) +
          (player.totalDamageTaken[element] ?? 0);
    }

    damageHealed += player.damageHealed;
    damageDodged += player.damageDodged;

    for (final element in EnemyType.values) {
      enemiesKilled[element] =
          (enemiesKilled[element] ?? 0) + (player.enemiesKilled[element] ?? 0);
      enemiesKilledGuns[element] = (enemiesKilledGuns[element] ?? 0) +
          (player.enemiesKilledGuns[element] ?? 0);
      enemiesKilledMagic[element] = (enemiesKilledMagic[element] ?? 0) +
          (player.enemiesKilledMagic[element] ?? 0);
      enemiesKilledMelee[element] = (enemiesKilledMelee[element] ?? 0) +
          (player.enemiesKilledMelee[element] ?? 0);
    }

    projectilesShot += player.projectilesShot;
    meleeSwings += player.meleeSwings;
    magicCast += player.magicCast;
    timesReloaded += player.timesReloaded;

    jumped += player.jumped;
    dashed += player.dashed;
    distanceTraveled += player.distanceTraveled;
    totalStaminaUsed += player.totalStaminaUsed;

    itemsPickedUp += player.itemsPickedUp;
    expendableItemsUsed += player.expendableItemsUsed;
    // save();
  }

  void upgradeSecondary(SecondaryType secondaryType, int cost) {
    if (!subtractExperience(cost)) {
      return;
    }

    if (unlockedSecondarys.containsKey(secondaryType)) {
      unlockedSecondarys[secondaryType] =
          unlockedSecondarys[secondaryType]! + 1;
    } else {
      unlockedSecondarys[secondaryType] ??= 0;
    }
    parentComponent?.notifyListeners();
  }

  void upgradeWeapon(WeaponType weaponType, int cost) {
    if (!subtractExperience(cost)) {
      return;
    }
    if (unlockedWeapons.containsKey(weaponType)) {
      unlockedWeapons[weaponType] = unlockedWeapons[weaponType]! + 1;
    } else {
      unlockedWeapons[weaponType] = 1;
    }
    parentComponent?.notifyListeners();
  }
}
