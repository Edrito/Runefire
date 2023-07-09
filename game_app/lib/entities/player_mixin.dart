import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart' hide MoveEffect;

import '../functions/custom_mixins.dart';
import '../main.dart';
import '../overlays/overlays.dart';
import '../resources/constants/priorities.dart';
import '../resources/visuals.dart';
import 'entity.dart';

mixin ExperienceFunctionality on Entity {
  double experiencePointsGained = 0;
  int currentLevel = 1;
  final double growthMultiplier = 1.2;
  final double baseExperiencePerLevel = 50;
  double get xpSensorRadius => baseXpSensorRadius + xpSensorRadiusIncrease;
  final double baseXpSensorRadius = 2;
  double xpSensorRadiusIncrease = 0;

  int levelUpQueue = 0;
  bool currentlyLevelingUp = false;
  TimerComponent? levelUpQueueTimer;

  void levelUp() {
    pauseGame(attributeSelection.key);
    currentlyLevelingUp = false;

    if (levelUpQueue == 0) {
      levelUpQueueTimer?.timer.stop();
      levelUpQueueTimer?.removeFromParent();
      levelUpQueueTimer = null;
    }
  }

  void preLevelUp() async {
    if (currentlyLevelingUp) {
      levelUpQueue++;
      levelUpQueueTimer ??= TimerComponent(
        period: .1,
        removeOnFinish: true,
        repeat: true,
        onTick: () {
          if (!currentlyLevelingUp && !isDead) {
            preLevelUp();
            levelUpQueue--;
          }
        },
      )..addToParent(this);
      return;
    }
    currentlyLevelingUp = true;
    const count = 3;
    for (var i = 0; i < count; i++) {
      final upArrow = CaTextComponent(
          position: Vector2(1, -.25),
          anchor: Anchor.center,
          priority: menuPriority,
          textRenderer:
              TextPaint(style: defaultStyle.copyWith(fontSize: 1 * (i + 1))),
          text: "^");
      final effectController = EffectController(
        duration: .3,
        curve: Curves.fastLinearToSlowEaseIn,
        onMax: () {
          if (i == count - 1) {
            levelUp();
            levelUpFunctionsCall();
          }
          upArrow.removeFromParent();
        },
      );

      upArrow.addAll([
        MoveEffect.by(
          Vector2(0, -1),
          effectController,
        ),
      ]);
      add(upArrow);
      await Future.delayed(.3.seconds);
    }
  }

  void levelUpFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onLevelUp.isNotEmpty) {
      for (var element in attr.onLevelUp) {
        element();
      }
    }
  }

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
      gameEnviroment.hud.setLevel(currentLevel);

      if (isDead) return;

      preLevelUp();
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

mixin BaseStats on Entity {
  int enemiesKilled = 0;
  double damageDealt = 0;
  double damageTaken = 0;
  double damageHealed = 0;
  double damageDodged = 0;
  double damageReceived = 0;

  int jumped = 0;
  int dashed = 0;

  int projectilesShot = 0;
  int meleeSwings = 0;
  int timesReloaded = 0;
}
