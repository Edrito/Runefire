import 'package:runefire/resources/assets/assets.dart';

enum Achievements {
  completeFirstLevel,
  completeFirstHard,
  completeFirstChaos,
  findFirstWeapon,
  fullyLevelUpFirstWeapon,
  completeAllLevels,
  fullyUnlockElementalPower,
  beatFirstBoss,
  unlockEverything;

  String get getImage {
    return ImagesAssetsAttributes.topSpeed.path;
  }

  //Title then description

  List<String> get getInformation {
    switch (this) {
      case Achievements.completeFirstLevel:
        return ['First Steps', 'Complete your first level'];
      case Achievements.completeFirstHard:
        return ['Hardened', 'Complete your first hard level'];
      case Achievements.completeFirstChaos:
        return ['Chaos', 'Complete your first chaos level'];
      case Achievements.findFirstWeapon:
        return ['First Weapon', 'Find your first weapon'];
      case Achievements.fullyLevelUpFirstWeapon:
        return ['Fully Level Up', 'Fully level up your first weapon'];
      case Achievements.completeAllLevels:
        return ['Completionist', 'Complete all levels'];
      case Achievements.fullyUnlockElementalPower:
        return ['Elemental Power', 'Fully unlock elemental power'];
      case Achievements.beatFirstBoss:
        return ['First Boss', 'Beat your first boss'];
      case Achievements.unlockEverything:
        return ['Completionist', 'Unlock everything'];
    }
  }
}

// Complete first level
// Complete first hard
// Complete first chaos
// Find first weapon
// Fully level up first weapon
// Complete XYZ Level all diff
// Fully unlock elemental power
// Beat XYZ Boss
// Unlock Everything
