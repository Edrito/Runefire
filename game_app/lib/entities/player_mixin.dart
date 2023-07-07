import 'dart:math';

import 'entity.dart';

mixin ExperienceFunctionality on Entity {
  double experiencePointsGained = 0;
  int currentLevel = 1;
  final double growthMultiplier = 1.2;
  final double baseExperiencePerLevel = 50;
  double get xpSensorRadius => baseXpSensorRadius + xpSensorRadiusIncrease;
  final double baseXpSensorRadius = 3;
  double xpSensorRadiusIncrease = 0;

  int calculateExperienceRequired(int level) {
    // Define the base experience required for level 1
    int experienceRequired =
        (baseExperiencePerLevel * pow(growthMultiplier, level - 1)).round();

    return experienceRequired;
  }

  // int get nextLevelExperienceRequired => pow(2, currentLevel + 1).toInt();
  // int get currentLevelExperienceRequired => pow(2, currentLevel).toInt();
  int get nextLevelExperienceRequired {
    int returnInt = 0;
    for (var i = 1; i < currentLevel + 1; i++) {
      returnInt += calculateExperienceRequired(i);
    }
    return returnInt;
  }

  int get currentLevelExperienceRequired {
    int returnInt = 0;
    for (var i = 1; i < currentLevel; i++) {
      returnInt += calculateExperienceRequired(i);
    }
    return returnInt;
  }

  void gainExperience(double experience) {
    final nextLevelExperienceRequired = this.nextLevelExperienceRequired;
    if (experiencePointsGained + experience >= nextLevelExperienceRequired) {
      final remainingExperience =
          (experience + experiencePointsGained) - nextLevelExperienceRequired;
      experiencePointsGained = nextLevelExperienceRequired.toDouble();
      currentLevel += 1;
      gameEnv.hud.levelCounter.text = currentLevel.toString();

      if (isDead) return;

      gameEnv.preLevelUp();
      gainExperience(remainingExperience);
    } else {
      experiencePointsGained += experience;
    }
  }

  double get percentOfLevelGained {
    final currentLevelExperienceRequired = this.currentLevelExperienceRequired;
    final gapBetweenCurrentLevels =
        nextLevelExperienceRequired - currentLevelExperienceRequired;
    final experienceTowardsNextLevel =
        experiencePointsGained - currentLevelExperienceRequired;
    return experienceTowardsNextLevel / gapBetweenCurrentLevels;
  }
}

mixin AttributeFunctionsFunctionality on Entity {}
