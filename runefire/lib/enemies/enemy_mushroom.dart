import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:forge2d/src/dynamics/body.dart';
import 'package:runefire/enemies/enemy_mixin.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/event_management.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/functions/custom.dart';

import '../resources/functions/functions.dart';
import '../resources/enums.dart';
import 'enemy.dart';
import 'enemy_mushroom_constants.dart';
import 'enemy_state_mixin.dart';

class MushroomDummy extends Enemy with JumpFunctionality

// MovementFunctionality,
// DumbFollowAI,
{
  MushroomDummy(
      {required super.initialPosition,
      required super.enviroment,
      required super.upgradeLevel,
      required super.eventManagement}) {
    height.baseParameter = mushroomHopperBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    maxHealth.baseParameter = 1000;
  }

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomHopperIdle1;
    entityAnimations[EntityStatus.jump] =
        await spriteAnimations.mushroomHopperJump1;
    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomHopperDead1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  EnemyType enemyType = EnemyType.mushroomDummy;
}

class MushroomRunner extends Enemy
    with MovementFunctionality, TouchDamageFunctionality, DumbFollowAI {
  MushroomRunner(
      {required super.initialPosition,
      required super.enviroment,
      required super.upgradeLevel,
      required super.eventManagement}) {
    height.baseParameter = 1.2;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    critChance.baseParameter = .5;
    maxHealth.baseParameter = 5.0 + rng.nextInt(5);
    speed.baseParameter = 1000.0 + rng.nextInt(500);
    touchDamage.damageBase[DamageType.physical] = (1, 5);
  }

  @override
  Map<ExpendableType, double> get expendableRate => {
        // ExpendableType.fearEnemiesRunes: 0.5,
        ExpendableType.healingRune: 0.001,
        // ExpendableType.experienceAttractRune: 0.5,
      };

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.9,
  };

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomRunnerIdle1;
    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomRunnerDead1;
    entityAnimations[EntityStatus.run] =
        await spriteAnimations.mushroomRunnerRun1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  EnemyType enemyType = EnemyType.mushroomDummy;
}

class MushroomHopper extends Enemy
    with
        JumpFunctionality,
        MovementFunctionality,
        HopFollowAI,
        TouchDamageFunctionality {
  MushroomHopper(
      {required super.initialPosition,
      required super.enviroment,
      required super.upgradeLevel,
      required super.eventManagement}) {
    height.baseParameter = mushroomHopperBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomHopperBaseMaxHealth;
    speed.baseParameter = mushroomHopperBaseSpeed;

    touchDamage.damageBase[DamageType.physical] = (1, 3);
  }

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomHopperIdle1;
    entityAnimations[EntityStatus.jump] =
        await spriteAnimations.mushroomHopperJump1;
    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomHopperDead1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  EnemyType enemyType = EnemyType.mushroomHopper;
}

class MushroomBoomer extends Enemy
    with MovementFunctionality, FollowThenSuicideAI {
  MushroomBoomer(
      {required super.initialPosition,
      required super.enviroment,
      required super.upgradeLevel,
      required super.eventManagement}) {
    height.baseParameter = mushroomBoomerBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomBoomerBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomBoomerBaseMaxHealth;
    speed.baseParameter = mushroomBoomerBaseSpeed;

    onDeath.add((instance) async {
      if (instance.damageMap.keys.contains(DamageType.fire)) {
        entityAnimationsGroup.animationTickers?[EntityStatus.dead]?.completed;
      } else {
        await entityAnimationsGroup
            .animationTickers?[EntityStatus.dead]?.completed;
      }

      final temp = AreaEffect(
          position: body.worldCenter,
          sourceEntity: this,
          radius: 4 * ((upgradeLevel / 2)) + 2,
          durationType: DurationType.instant,
          damage: {DamageType.fire: (2, 15)});
      gameEnviroment.addPhysicsComponent([temp]);
    });
  }

  @override
  bool get affectsAllEntities => true;

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  Map<ExperienceAmount, double> experienceRate = {
    // ExperienceAmount.large: 0.001,
    // ExperienceAmount.medium: 0.01,
    // ExperienceAmount.small: 0.4,
  };

  @override
  // TODO: implement expendableRate
  Map<ExpendableType, double> get expendableRate => {
        ExpendableType.fearEnemiesRunes: 0.001,
      };

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomBoomerIdle1;

    entityAnimations[EntityStatus.walk] =
        await spriteAnimations.mushroomBoomerWalk1;

    entityAnimations[EntityStatus.run] =
        await spriteAnimations.mushroomBoomerRun1;

    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomBoomerDead1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  EnemyType enemyType = EnemyType.mushroomBoomer;
}

class MushroomShooter extends Enemy
    with
        MovementFunctionality,
        AimFunctionality,
        AimControlFunctionality,
        AttackFunctionality,
        DumbShoot,
        DumbFollowRangeAI {
  MushroomShooter(
      {required super.initialPosition,
      required super.enviroment,
      required super.upgradeLevel,
      required super.eventManagement}) {
    height.baseParameter = mushroomShooterBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    speed.baseParameter = mushroomShooterBaseSpeed;
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  @override
  bool get affectsAllEntities => false;

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomShooterIdle1;

    entityAnimations[EntityStatus.attack] =
        await spriteAnimations.mushroomShooterAttack1;

    entityAnimations[EntityStatus.run] =
        await spriteAnimations.mushroomShooterRun1;

    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomShooterDead1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  EnemyType enemyType = EnemyType.mushroomBoomer;

  @override
  AimPattern aimPattern = AimPattern.player;
}

class MushroomSpinner extends Enemy
    with
        MovementFunctionality,
        AimFunctionality,
        TouchDamageFunctionality,
        AimControlFunctionality,
        AttackFunctionality,
        DumbFollowAI,
        StateManagedAI {
  MushroomSpinner(
      {required super.initialPosition,
      required super.enviroment,
      required super.upgradeLevel,
      required super.eventManagement}) {
    height.baseParameter = mushroomShooterBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    speed.baseParameter = mushroomShooterBaseSpeed;
    initialWeapons.add(WeaponType.blankProjectileWeapon);

    bool initState = false;

    baseState = EnemyState(this,
        priority: 0,
        randomFunctions: [],
        stateDuration: (0, 0),
        triggerFunctions: []);

    const spinDuration = 6.0;
    enemyStates = {
      //Walking
      0: EnemyState(this, priority: 0, randomFunctions: [],
          onStateStart: () async {
        await toggleIdleRunAnimations(false);

        if (initState) {
          setEntityStatus(EntityStatus.custom, customAnimationKey: "spin_end");
        } else {
          initState = true;
        }
        speed.baseParameter = .03;
        touchDamage.damageBase.clear();
      }, stateDuration: (4, 5), triggerFunctions: []),
      //Spinning
      1: EnemyState(this,
          priority: 5,
          randomFunctions: [],
          stateDuration: (spinDuration, spinDuration * 1.5),
          onStateStart: () async {
        await toggleIdleRunAnimations(true);

        setEntityStatus(EntityStatus.custom, customAnimationKey: "spin_start");
        speed.baseParameter = .05;
        for (var i = 1; i < 4; i++) {
          Future.delayed(((spinDuration / 4) * i).seconds, () {
            final count = 3 + (rng.nextBool() ? 0 : 3);
            currentWeapon?.attackCountIncrease.baseParameter = count;

            currentWeapon?.startAttacking();
            currentWeapon?.endAttacking();
          });
        }
        touchDamage.damageBase[DamageType.psychic] = (5, 10);
      }, triggerFunctions: [
        () => center.distanceTo(gameEnviroment.player!.center) < 10
      ]),
    };
  }

  @override
  bool get affectsAllEntities => false;

  @override
  void update(double dt) {
    if (entityAnimationsGroup.animations?[EntityStatus.run] ==
        entityAnimations["spin"]) {}

    moveCharacter();
    super.update(dt);
  }

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  Future<void> toggleIdleRunAnimations(bool isSpinning) async {
    if (isSpinning) {
      entityAnimations[EntityStatus.idle] = entityAnimations["spin"]!.clone();

      entityAnimations[EntityStatus.run] = entityAnimations["spin"]!.clone();
    } else {
      await loadRunIdleAnimations();
    }
    entityAnimationsGroup.resetTicker(EntityStatus.run);
    entityAnimationsGroup.resetTicker(EntityStatus.idle);
  }

  Future<void> loadRunIdleAnimations() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomSpinnerIdle1;

    entityAnimations[EntityStatus.run] =
        await spriteAnimations.mushroomSpinnerRun1;
  }

  @override
  Future<void> loadAnimationSprites() async {
    loadRunIdleAnimations();

    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomSpinnerDead1;

    entityAnimations["spin_start"] =
        await spriteAnimations.mushroomSpinnerSpinStart1;

    entityAnimations["spin_end"] =
        await spriteAnimations.mushroomSpinnerSpinEnd1;

    entityAnimations["spin"] = await spriteAnimations.mushroomSpinnerSpin1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  EnemyType enemyType = EnemyType.mushroomSpinner;

  @override
  late EnemyState baseState;

  @override
  late Map<int, EnemyState> enemyStates;

  @override
  AimPattern aimPattern = AimPattern.player;
}

class MushroomBurrower extends Enemy
    with
        MovementFunctionality,
        AimFunctionality,
        TouchDamageFunctionality,
        AttackFunctionality,
        StateManagedAI {
  MushroomBurrower(
      {required super.initialPosition,
      required super.enviroment,
      required super.upgradeLevel,
      required super.eventManagement}) {
    height.baseParameter = mushroomShooterBaseHeight;

    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;

    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    speed.baseParameter = 0;

    collision.baseParameter = false;

    initialWeapons.add(WeaponType.blankProjectileWeapon);

    bool initState = false;

    baseState = EnemyState(this,
        priority: 0,
        randomFunctions: [],
        stateDuration: (0, 0),
        triggerFunctions: []);

    const groundDuration = 2.0;
    enemyStates = {
      //Out
      0: EnemyState(this, priority: 0, randomFunctions: [], onStateStart: () {
        if (initState) {
          setEntityStatus(EntityStatus.custom, customAnimationKey: "burrow_out")
              .then((value) => setEntityStatus(EntityStatus.idle));
          body.setTransform(
              SpawnLocation.onPlayer.grabNewPosition(gameEnviroment), angle);
        } else {
          initState = true;
        }

        toggleIdleRunAnimations(false);

        Future.delayed(burrowSpeed.seconds).then((value) {
          touchDamage.damageBase[DamageType.physical] = (10, 15);
          collision.removeKey(entityId);
          for (var i = 1; i < 4; i++) {
            Future.delayed(((groundDuration / 4) * i).seconds, () {
              final count = 2 + (rng.nextBool() ? 0 : 2);
              currentWeapon?.attackCountIncrease.baseParameter = count;

              currentWeapon?.startAttacking();
              currentWeapon?.endAttacking();
            });
          }
        });
      }, stateDuration: (4, 5), triggerFunctions: []),
      //In
      1: EnemyState(this,
          priority: 5,
          randomFunctions: [],
          stateDuration: (groundDuration, groundDuration * 1.5),
          onStateStart: () {
        setEntityStatus(EntityStatus.custom, customAnimationKey: "burrow_in")
            .then((value) => setEntityStatus(EntityStatus.idle));
        toggleIdleRunAnimations(true);
        touchDamage.damageBase.clear();
        collision.setIncrease(entityId, false);
      }, triggerFunctions: []),
    };
  }

  @override
  bool get affectsAllEntities => false;

  double get burrowSpeed => 1.0;

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };
  Future<void> toggleIdleRunAnimations(bool isBurrowed) async {
    if (isBurrowed) {
      entityAnimations.remove(EntityStatus.idle);
      entityAnimationsGroup.resetTicker(EntityStatus.idle);
    } else {
      entityAnimations[EntityStatus.idle] =
          await spriteAnimations.mushroomBurrowerIdle1;

      if (isMounted) {
        entityAnimationsGroup.resetTicker(EntityStatus.idle);
      }
    }
  }

  @override
  Future<void> loadAnimationSprites() async {
    toggleIdleRunAnimations(false);
    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomBurrowerDead1;
    entityAnimations["burrow_in"] =
        await spriteAnimations.mushroomBurrowerBurrowIn1
          ..stepTime = burrowSpeed / 9;
    entityAnimations["burrow_out"] =
        await spriteAnimations.mushroomBurrowerBurrowOut1
          ..stepTime = burrowSpeed / 9;
  }

  // @override
  // Body createBody() {
  //   return super.createBody()
  //     ..fixtures.forEach((element) {
  //       element.setSensor(true);
  //     });
  // }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  EnemyType enemyType = EnemyType.mushroomBurrower;

  @override
  late EnemyState baseState;

  @override
  late Map<int, EnemyState> enemyStates;
}
