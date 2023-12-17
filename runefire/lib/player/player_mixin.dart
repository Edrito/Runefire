import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_animate/flutter_animate.dart' hide MoveEffect;
import 'package:hive/hive.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/entities/entity_class.dart';

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
  TimerComponent? previousLevelUpDelay;

  void levelUp() {
    levelUpFunctionsCall();
    game.gameStateComponent.gameState.pauseGame(attributeSelection.key);
  }

  Future<void> preLevelUp() async {
    if (previousLevelUpDelay != null) {
      levelUpQueue++;
      return;
    }

    previousLevelUpDelay = TimerComponent(
      period: .3,
      repeat: true,
      onTick: () {
        if (levelUpQueue > 0) {
          levelUpQueue--;
          levelUp();
        } else {
          previousLevelUpDelay?.removeFromParent();
          previousLevelUpDelay = null;
        }
      },
    )..addToParent(this);

    levelUp();
  }

  void levelUpFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onLevelUp.isNotEmpty) {
      for (final element in attr.onLevelUp) {
        element.call();
      }
    }
  }

  int calculateExperienceRequired(int level) {
    // Define the base experience required for level 1
    final experienceRequired =
        (baseExperiencePerLevel * pow(growthMultiplier, level - 1)).round();

    return experienceRequired;
  }

  // int get nextLevelExperienceRequired => pow(2, currentLevel + 1).toInt();
  // int get currentLevelExperienceRequired => pow(2, currentLevel).toInt();
  int get nextLevelExperienceRequired {
    var returnInt = 0;
    for (var i = 1; i < currentLevel + 1; i++) {
      returnInt += calculateExperienceRequired(i);
    }
    return returnInt;
  }

  int get currentLevelExperienceRequired {
    var returnInt = 0;
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

      gainExperience(remainingExperience.abs());
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

mixin PlayerStatisticsRecorder
    on
        Entity,
        StaminaFunctionality,
        HealthFunctionality,
        AimFunctionality,
        AttackFunctionality,
        AttributeFunctionality,
        AttributeCallbackFunctionality,
        MovementFunctionality,
        JumpFunctionality,
        ExperienceFunctionality,
        DodgeFunctionality,
        DashFunctionality,
        HealthRegenFunctionality,
        PlayerStatistics {
  @override
  Future<void> onLoad() {
    onPreDamageOtherEntity.add((damage) {
      for (final element in damage.damageMap.entries) {
        damageDealt.update(
          element.key,
          (value) => value + element.value,
          ifAbsent: () => element.value,
        );
      }
      return false;
    });

    onKillOtherEntity.add((instance) {
      if (instance.victim is! Enemy) {
        return;
      }
      final enemy = instance.victim as Enemy;
      enemiesKilled.update(
        enemy.enemyType,
        (value) => value + 1,
        ifAbsent: () => 1,
      );

      switch (instance.attackType) {
        case AttackType.magic:
          enemiesKilledMagic.update(
            enemy.enemyType,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
          break;
        case AttackType.guns:
          enemiesKilledGuns.update(
            enemy.enemyType,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
          break;
        case AttackType.melee:
          enemiesKilledMelee.update(
            enemy.enemyType,
            (value) => value + 1,
            ifAbsent: () => 1,
          );
          break;
        default:
      }
    });

    onHitByOtherEntity.add((damage) {
      for (final element in damage.damageMap.entries) {
        totalDamageTaken.update(
          element.key,
          (value) => value + element.value,
          ifAbsent: () => element.value,
        );
      }
      return false;
    });

    onHeal.add((instance) {
      damageHealed += instance.damageMap[DamageType.healing] ?? 0;
      return false;
    });

    onDodge.add((instance) {
      damageDodged += instance.damageMap[DamageType.physical] ?? 0;
      return false;
    });

    onAttack.add((instance) {
      switch (instance.weaponType.attackType) {
        case AttackType.magic:
          magicCast++;
          break;
        case AttackType.guns:
          projectilesShot++;
          break;
        case AttackType.melee:
          meleeSwings++;
          break;
      }
      return false;
    });

    dashBeginFunctions.add(() {
      dashed++;
    });

    jumpBeginFunctions.add(() {
      jumped++;
    });

    onReload.add((instance) {
      timesReloaded++;
      return false;
    });

    onStaminaModified.add((stamina) {
      if (stamina >= 0) {
        return;
      }
      totalStaminaUsed += stamina.abs();
    });

    onItemPickup.add((item) {
      itemsPickedUp++;
    });
    onExpendableUsed.add((item) {
      expendableItemsUsed++;
    });

    if (this is Player) {
      final player = this as Player;
      player.interactableFunctions.add((interactable) {
        interactablesInteractedWith++;
        if (interactable is InteractableWeaponPickup) {
          weaponsFound++;
        } else if (interactable is InteractableRunePickup) {
          runesFound++;
        }
      });
    }

    return super.onLoad();
  }
}

enum EndGameState {
  win,
  playerDeath,
  quit,
}

mixin PlayerStatistics {
  Player? player;

  @HiveField(100)
  @HiveField(101)
  Map<DamageType, double> damageDealt = {};
  @HiveField(102)
  Map<DamageType, double> totalDamageTaken = {};
  @HiveField(103)
  double damageHealed = 0;
  @HiveField(104)
  double damageDodged = 0;

  @HiveField(110)
  Map<EnemyType, int> enemiesKilled = {};
  @HiveField(111)
  Map<EnemyType, int> enemiesKilledMagic = {};
  @HiveField(112)
  Map<EnemyType, int> enemiesKilledGuns = {};
  @HiveField(113)
  Map<EnemyType, int> enemiesKilledMelee = {};

  @HiveField(150)
  int projectilesShot = 0;
  @HiveField(151)
  int meleeSwings = 0;
  @HiveField(151)
  int magicCast = 0;
  @HiveField(153)
  int timesReloaded = 0;

  @HiveField(200)
  int jumped = 0;
  @HiveField(201)
  int dashed = 0;
  @HiveField(202)
  double distanceTraveled = 0;
  @HiveField(202)
  double totalStaminaUsed = 0;

  @HiveField(300)
  int itemsPickedUp = 0;
  @HiveField(301)
  int expendableItemsUsed = 0;
  @HiveField(302)
  int interactablesInteractedWith = 0;
  @HiveField(303)
  int weaponsFound = 0;
  @HiveField(304)
  int runesFound = 0;
  List<(String, String)> buildStatStrings(bool includeGameStats) {
    final returnList = <(String, String)>[];
    if (includeGameStats) {
      // returnList.add(
      //     ("Games Won", gamesWon.values.reduce((a, b) => a + b).toString()));
      // returnList.add(
      //     ("Games Lost", gamesLost.values.reduce((a, b) => a + b).toString()));
      // returnList.add(
      //     ("Games Quit", gamesQuit.values.reduce((a, b) => a + b).toString()));
      // returnList.add((
      //   "Longest Game",
      //   longestGame.values.reduce((a, b) => a + b).toString()
      // ));
    }
    returnList.add(
      (
        'Damage Dealt',
        damageDealt.values
            .fold(0.0, (previousValue, element) => previousValue + element)
            .toStringAsFixed(0)
      ),
    );
    returnList.add(
      (
        'Damage Taken',
        totalDamageTaken.values
            .fold(0.0, (previousValue, element) => previousValue + element)
            .toStringAsFixed(0)
      ),
    );
    returnList.add(('Damage Healed', damageHealed.toStringAsFixed(0)));
    returnList.add(('Damage Dodged', damageDodged.toStringAsFixed(0)));

    returnList.add(
      (
        'Enemies Killed',
        enemiesKilled.values
            .fold(0, (previousValue, element) => previousValue + element)
            .toStringAsFixed(0)
      ),
    );
    returnList.add(
      (
        'Enemies Killed Magic',
        enemiesKilledMagic.values
            .fold(0, (previousValue, element) => previousValue + element)
            .toStringAsFixed(0)
      ),
    );
    returnList.add(
      (
        'Enemies Killed Guns',
        enemiesKilledGuns.values
            .fold(0, (previousValue, element) => previousValue + element)
            .toStringAsFixed(0)
      ),
    );
    returnList.add(
      (
        'Enemies Killed Melee',
        enemiesKilledMelee.values
            .fold(0, (previousValue, element) => previousValue + element)
            .toStringAsFixed(0)
      ),
    );

    returnList.add(('Projectiles Shot', projectilesShot.toString()));
    returnList.add(('Melee Swings', meleeSwings.toString()));
    returnList.add(('Magic Cast', magicCast.toString()));
    returnList.add(('Times Reloaded', timesReloaded.toString()));

    returnList.add(('Jumped', jumped.toString()));
    returnList.add(('Dashed', dashed.toString()));
    returnList.add(('Distance Traveled', distanceTraveled.toString()));
    returnList.add(('Total Stamina Used', totalStaminaUsed.toString()));

    returnList.add(('Items Picked Up', itemsPickedUp.toString()));
    returnList.add(('Expendable Items Used', expendableItemsUsed.toString()));

    return returnList;
  }

  void resetStatistics() {
    damageDealt = {};
    totalDamageTaken = {};
    damageHealed = 0;
    damageDodged = 0;

    enemiesKilled = {};
    enemiesKilledMagic = {};
    enemiesKilledGuns = {};
    enemiesKilledMelee = {};

    projectilesShot = 0;
    meleeSwings = 0;
    magicCast = 0;
    timesReloaded = 0;

    jumped = 0;
    dashed = 0;
    distanceTraveled = 0;
    totalStaminaUsed = 0;

    itemsPickedUp = 0;
    expendableItemsUsed = 0;
    runesFound = 0;
    weaponsFound = 0;
    interactablesInteractedWith = 0;
  }

  void modifyGameVariables(EndGameState gameState, GameEnviroment enviroment) {
    final key = (enviroment.level, enviroment.difficulty);
    switch (gameState) {
      case EndGameState.win:
        gamesWon.update(
          key,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        break;
      case EndGameState.playerDeath:
        gamesLost.update(
          key,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        break;
      case EndGameState.quit:
        gamesQuit.update(
          key,
          (value) => value + 1,
          ifAbsent: () => 1,
        );
        break;
    }

    final currentGameTime = enviroment.timePassed;
    final longestGameTime = longestGame[key] ?? 0;
    if (currentGameTime > longestGameTime) {
      longestGame.update(
        key,
        (value) => currentGameTime,
        ifAbsent: () => currentGameTime,
      );
    }
  }

  @HiveField(400)
  Map<(GameLevel, GameDifficulty), int> gamesWon = {};
  @HiveField(401)
  Map<(GameLevel, GameDifficulty), int> gamesLost = {};
  @HiveField(402)
  Map<(GameLevel, GameDifficulty), int> gamesQuit = {};
  @HiveField(403)
  Map<(GameLevel, GameDifficulty), double> longestGame = {};
}
