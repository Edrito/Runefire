import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/player/player_mixin.dart';

import '../../attributes/attributes_permanent.dart';
import '../../player/player.dart';
import '../enums.dart';
import 'package:hive/hive.dart';

import 'base.dart';

class PlayerDataComponent extends DataComponent {
  PlayerDataComponent(super.dataObject);

  @override
  PlayerData get dataObject => super.dataObject as PlayerData;
}

@HiveType(typeId: 1)
class PlayerData extends DataClass with PlayerStatistics {
  //XP
  int experiencePoints = 6000;
  int spentExperiencePoints = 0;

  ///Update information from player, saving to file
  void updateInformation(Player player) {
    //Parse player data
    experiencePoints += player.experiencePointsGained.round();

    for (var element in DamageType.values) {
      damageDealt[element] =
          (damageDealt[element] ?? 0) + (player.damageDealt[element] ?? 0);
      totalDamageTaken[element] = (totalDamageTaken[element] ?? 0) +
          (player.totalDamageTaken[element] ?? 0);
    }

    damageHealed += player.damageHealed;
    damageDodged += player.damageDodged;

    for (var element in EnemyType.values) {
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

  GameDifficulty selectedDifficulty = GameDifficulty.regular;

  GameLevel selectedLevel = GameLevel.hexedForest;
  CharacterType selectedPlayer = CharacterType.regular;

  List<GameLevel> completedLevels = [];
  List<CharacterType> unlockedCharacters = [CharacterType.regular];

  bool characterUnlocked() {
    return unlockedCharacters.contains(selectedPlayer);
  }

  bool unlockCharacter() {
    if (characterUnlocked()) {
      return true;
    }

    if (enoughMoney(selectedPlayer.unlockCost)) {
      experiencePoints -= selectedPlayer.unlockCost;
      unlockedCharacters.add(selectedPlayer);
      parentComponent?.notifyListeners();
      return true;
    }
    return false;
  }

  Map<int, WeaponType> selectedWeapons = {
    0: WeaponType.scryshot,
    1: WeaponType.prismaticBeam,
  };
  Map<int, SecondaryType> selectedSecondaries = {
    0: SecondaryType.reloadAndRapidFire,
    1: SecondaryType.reloadAndRapidFire,
  };

  Map<WeaponType, int> unlockedWeapons = {
    WeaponType.crystalPistol: 0,
    WeaponType.crystalSword: 0,
    WeaponType.icecicleMagic: 0,
  };

  Set<WeaponType> availableWeapons = {
    WeaponType.crystalPistol,
    // WeaponType.phaseDagger,
    WeaponType.scryshot,
    // WeaponType.flameSword,
    ...WeaponType.values
  }..remove(WeaponType.flameSword);

  Map<SecondaryType, int> unlockedSecondarys = {
    SecondaryType.pistol: 0,
    SecondaryType.reloadAndRapidFire: 0
  };

  Map<AttributeType, int> unlockedPermanentAttributes = {};

  bool enoughMoney(int cost) {
    return experiencePoints >= cost;
  }

  bool unlockPermanentAttribute(AttributeType? attributeType) {
    if (attributeType == null) return false;
    final currentLevel = unlockedPermanentAttributes[attributeType] ?? 0;
    final currentAttribute = attributeType.buildAttribute(
      currentLevel,
      null,
    );
    if ((currentAttribute.upgradeLevel == currentAttribute.maxLevel) ||
        currentAttribute is! PermanentAttribute) {
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
