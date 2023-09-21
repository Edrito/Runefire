import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart' hide MoveEffect;
import 'package:runefire/resources/game_state_class.dart';

import '../entities/child_entities.dart';
import '../resources/data_classes/base.dart';
import '../resources/functions/custom.dart';
import '../menus/overlays.dart';
import '../resources/constants/priorities.dart';
import '../resources/visuals.dart';
import '../entities/entity_class.dart';

mixin ExperienceFunctionality on Entity {
  @override
  void initializeParentParameters() {
    xpSensorRadius = DoubleParameterManager(baseParameter: 2);

    xpIncreasePercent = DoubleParameterManager(baseParameter: 1);
    super.initializeParentParameters();
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    xpSensorRadius =
        (childEntity.parentEntity as ExperienceFunctionality).xpSensorRadius;

    xpIncreasePercent =
        (childEntity.parentEntity as ExperienceFunctionality).xpIncreasePercent;

    super.initializeChildEntityParameters(childEntity);
  }

  late final DoubleParameterManager xpSensorRadius;

  late final DoubleParameterManager xpIncreasePercent;

  double experiencePointsGained = 0;
  int currentLevel = 1;
  final double growthMultiplier = 1.2;
  final double baseExperiencePerLevel = 50;

  int levelUpQueue = 0;
  bool currentlyLevelingUp = false;
  TimerComponent? levelUpQueueTimer;

  void levelUp() {
    gameRef.gameStateComponent.gameState.pauseGame(attributeSelection.key);
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

  void gainExperience(double newExperience) {
    final nextLevelExperienceRequired = this.nextLevelExperienceRequired;
    final experience = xpIncreasePercent.parameter * newExperience;

    if (experiencePointsGained + experience >= nextLevelExperienceRequired) {
      final remainingExperience =
          (experience + experiencePointsGained) - nextLevelExperienceRequired;
      experiencePointsGained = nextLevelExperienceRequired.toDouble();
      if (!isDead) {
        currentLevel += 1;
        gameEnviroment.hud.setLevel(currentLevel);
        preLevelUp();
      }

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

mixin StatisticsRecord on Entity {
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
