import 'dart:async';
import 'dart:async' as async;
import 'dart:math';
import 'package:flame/effects.dart';
import 'package:forge2d/src/dynamics/filter.dart';
import 'package:runefire/entities/entity_class.dart';

import 'package:flutter_animate/flutter_animate.dart' hide RotateEffect;
import 'package:forge2d/src/dynamics/body.dart';
import 'package:runefire/enemies/enemy_mixin.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/entities/input_priorities.dart';
import 'package:runefire/events/event_class.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/enemies/enemy_mushroom_constants.dart';
import 'package:runefire/enemies/enemy_state_mixin.dart';

class MushroomDummy extends Enemy with JumpFunctionality

// MovementFunctionality,
// DumbFollowAI,
{
  MushroomDummy({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = mushroomHopperBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    maxHealth.baseParameter = 5;
  }

  @override
  EnemyType enemyType = EnemyType.mushroomDummy;

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
}

class MushroomRunner extends Enemy
    with MovementFunctionality, TouchDamageFunctionality, SimpleFollowAI {
  MushroomRunner({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = 3;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    critChance.baseParameter = .05;
    maxHealth.baseParameter = 5.0 + rng.nextInt(5) * (upgradeLevel + 1);
    speed.baseParameter = (1000.0 + rng.nextInt(500)) * (upgradeLevel + 1);
    touchDamage.damageBase[DamageType.physical] =
        (1 * (upgradeLevel + 1), 5 * (upgradeLevel + 1));
  }

  @override
  EnemyType enemyType = EnemyType.mushroomRunner;

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
}

class MushroomRunnerScared extends Enemy
    with MovementFunctionality, TouchDamageFunctionality, SimpleFollowScaredAI {
  MushroomRunnerScared({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = 3;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    critChance.baseParameter = .05;
    maxHealth.baseParameter = 5.0 + rng.nextInt(5) * (upgradeLevel + 1);
    speed.baseParameter = 3000.0 + (rng.nextInt(500) * (upgradeLevel + 1));
    touchDamage.damageBase[DamageType.physical] =
        (1 * (upgradeLevel + 1), 5 * (upgradeLevel + 1));
  }

  @override
  EnemyType enemyType = EnemyType.mushroomRunnerScared;

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.9,
  };

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomRunnerScaredIdle1;
    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomRunnerScaredDead1;
    entityAnimations[EntityStatus.run] =
        await spriteAnimations.mushroomRunnerScaredRun1;
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
}

class MushroomHopper extends Enemy
    with
        JumpFunctionality,
        MovementFunctionality,
        HopFollowAI,
        TouchDamageFunctionality {
  MushroomHopper({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = mushroomHopperBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomHopperBaseMaxHealth;
    speed.baseParameter = mushroomHopperBaseSpeed;

    touchDamage.damageBase[DamageType.physical] = (1, 3);
  }

  @override
  EnemyType enemyType = EnemyType.mushroomHopper;

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
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }
}

class MushroomBoomer extends Enemy
    with MovementFunctionality, FollowThenSuicideAI {
  MushroomBoomer({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = mushroomBoomerBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomBoomerBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomBoomerBaseMaxHealth;
    speed.baseParameter = mushroomBoomerBaseSpeed;

    onPermanentDeath.add((instance) {
      if (instance.damageMap.keys.contains(
            DamageType.fire,
          ) ||
          (upgradeLevel > 0 &&
              instance.damageMap.keys.contains(
                DamageType.psychic,
              ))) {
        bomb();
      } else {
        entityAnimationsGroup.animationTicker?.completed.then((_) {
          bomb();
        });
      }
      return null;
    });
  }

  @override
  BoolParameterManager affectsAllEntities = BoolParameterManager(
    baseParameter: true,
    frequencyDeterminesTruth: false,
  );

  @override
  EnemyType enemyType = EnemyType.mushroomBoomer;

  @override
  Map<ExperienceAmount, double> experienceRate = {
    // ExperienceAmount.large: 0.001,
    // ExperienceAmount.medium: 0.01,
    // ExperienceAmount.small: 0.4,
  };

  Future<void> bomb() async {
    final temp = AreaEffect(
      position: body.worldCenter,
      sourceEntity: this,
      animationComponent: SimpleStartPlayEndSpriteAnimationComponent(
        spawnAnimation: await (upgradeLevel > 0
            ? spriteAnimations.psychicOrbMedium1
            : spriteAnimations.fireOrbMedium1),
        durationType: DurationType.instant,
      ),
      damage: {
        if (upgradeLevel > 0)
          DamageType.psychic: (4, 25)
        else
          DamageType.fire: (2, 15),
      },
    );
    game.gameAwait(.1).then((value) => removeFromParent());

    gameEnviroment.addPhysicsComponent([temp]);
  }

  @override
  Future<void> loadAnimationSprites() async {
    if (upgradeLevel > 0) {
      entityAnimations[EntityStatus.idle] =
          await spriteAnimations.mushroomBoomerIdle2;

      entityAnimations[EntityStatus.run] =
          await spriteAnimations.mushroomBoomerRun2;

      entityAnimations[EntityStatus.dead] =
          await spriteAnimations.mushroomBoomerDead2;
    } else {
      entityAnimations[EntityStatus.idle] =
          await spriteAnimations.mushroomBoomerIdle1;

      entityAnimations[EntityStatus.run] =
          await spriteAnimations.mushroomBoomerRun1;

      entityAnimations[EntityStatus.dead] =
          await spriteAnimations.mushroomBoomerDead1;
    }
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
}

class MushroomShooter extends Enemy
    with
        MovementFunctionality,
        AimFunctionality,
        AimControlFunctionality,
        AttackFunctionality,
        SimpleShoot,
        SimpleFollowRangeAI {
  MushroomShooter({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = mushroomShooterBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    speed.baseParameter = mushroomShooterBaseSpeed;
    initialWeapons.add(WeaponType.blankProjectileWeapon);
    attackOnAnimationFinish = true;
  }

  @override
  AimPattern aimPattern = AimPattern.player;

  @override
  EnemyType enemyType = EnemyType.mushroomShooter;

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  @override
  late final double zoningDistance = randomBetween((8.0, 12.0));

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
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }
}

class MushroomSpinner extends Enemy
    with
        MovementFunctionality,
        AimFunctionality,
        TouchDamageFunctionality,
        AimControlFunctionality,
        AttackFunctionality,
        SimpleFollowAI,
        StateManagedAI {
  MushroomSpinner({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = mushroomShooterBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    speed.baseParameter = mushroomShooterBaseSpeed * .5;
    initialWeapons.add(WeaponType.blankProjectileWeapon);

    var initState = false;

    baseState = EnemyState(
      this,
      priority: 0,
      randomFunctions: [],
      stateDuration: (0, 1),
      triggerFunctions: [],
    );

    const spinDuration = 6.0;
    RotateEffect? rotateEffect;
    onDeath.add((instance) {
      rotateEffect?.removeFromParent();
      return null;
    });
    enemyStates = {
      //Walking
      0: EnemyState(
        this,
        priority: 0,
        randomFunctions: [],
        onStateStart: (duration) async {
          await toggleIdleRunAnimations(false);
          hitSinceLastSpin = false;
          if (initState) {
            await setEntityAnimation('spin_end');
          } else {
            initState = true;
          }
        },
        stateDuration: (3, 5),
        triggerFunctions: [],
      ),
      //Spinning
      1: EnemyState(
        this,
        priority: 5,
        randomFunctions: [],
        onStateEnd: () {
          endPrimaryAttacking();
          speed.baseParameter = mushroomShooterBaseSpeed * .5;
          touchDamage.damageBase.clear();
          rotateEffect?.removeFromParent();
          rotateEffect = null;
          entityAnimationsGroup.angle = 0;
        },
        stateDuration: (spinDuration, spinDuration * 1.5),
        onStateStart: (duration) async {
          await toggleIdleRunAnimations(true);
          await setEntityAnimation('spin_start').then((_) {
            startPrimaryAttacking();
            speed.baseParameter = mushroomShooterBaseSpeed * 1.5;
            touchDamage.damageBase[DamageType.psychic] = (5, 10);
            rotateEffect?.removeFromParent();
            entityAnimationsGroup.add(
              rotateEffect = RotateEffect.by(
                pi / 18,
                RepeatedEffectController(
                  SineEffectController(
                    period: 1 + (2 * rng.nextDouble()),
                  ),
                  duration.floor().clamp(1, 200),
                ),
              ),
            );
          });
        },
        triggerFunctions: [
          () => center.distanceTo(gameEnviroment.player!.center) < 10,
          () => hitSinceLastSpin || durationSincePreviousStateChange > 10,
        ],
      ),
    };
  }

  bool hitSinceLastSpin = false;

  @override
  AimPattern aimPattern = AimPattern.player;

  @override
  late EnemyState baseState;

  @override
  late Map<int, EnemyState> enemyStates;

  @override
  EnemyType enemyType = EnemyType.mushroomSpinner;

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  Future<void> loadRunIdleAnimations() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomSpinnerIdle1;

    entityAnimations[EntityStatus.run] =
        await spriteAnimations.mushroomSpinnerRun1;
  }

  Future<void> toggleIdleRunAnimations(bool isSpinning) async {
    if (isSpinning) {
      entityAnimations[EntityStatus.idle] = entityAnimations['spin']!.clone();

      entityAnimations[EntityStatus.run] = entityAnimations['spin']!.clone();
    } else {
      await loadRunIdleAnimations();
    }
    entityAnimationsGroup.resetTicker(EntityStatus.run);
    entityAnimationsGroup.resetTicker(EntityStatus.idle);
  }

  @override
  void applyDamage(DamageInstance damage) {
    hitSinceLastSpin = true;
    super.applyDamage(damage);
  }

  @override
  Future<void> loadAnimationSprites() async {
    loadRunIdleAnimations();

    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomSpinnerDead1;

    entityAnimations['spin_start'] =
        await spriteAnimations.mushroomSpinnerSpinStart1;

    entityAnimations['spin_end'] =
        await spriteAnimations.mushroomSpinnerSpinEnd1;

    entityAnimations['spin'] = await spriteAnimations.mushroomSpinnerSpin1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  void update(double dt) {
    if (entityAnimationsGroup.animations?[EntityStatus.run] ==
        entityAnimations['spin']) {}

    moveCharacter();
    super.update(dt);
  }
}

class MushroomBurrower extends Enemy
    with
        JumpFunctionality,
        MovementFunctionality,
        HopFollowAI,
        AimFunctionality,
        TouchDamageFunctionality,
        AttackFunctionality,
        AimControlFunctionality,
        StateManagedAI {
  MushroomBurrower({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = mushroomShooterBaseHeight;

    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;

    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    // speed.baseParameter = 0;

    collision.baseParameter = false;

    initialWeapons.add(WeaponType.blankProjectileWeapon);

    var initState = false;

    baseState = EnemyState(
      this,
      priority: 0,
      randomFunctions: [],
      stateDuration: (0, 0),
      triggerFunctions: [],
    );

    const groundDuration = 3.0;

    onHitByOtherEntity.add((instance) {
      timeSinceHit = 0;
      return false;
    });

    enemyStates = {
      //Out
      0: EnemyState(
        this,
        priority: 0,
        randomFunctions: [],
        onStateStart: (duration) async {
          toggleIdleRunAnimations(false);
          if (initState) {
            await setEntityAnimation('burrow_out')
                .then((value) => setEntityAnimation(EntityStatus.idle));
          } else {
            initState = true;
          }

          touchDamage.damageBase[DamageType.physical] = (10, 15);
          collision.removeKey(entityId);

          final count = 2 + (rng.nextBool() ? 0 : 2);
          currentWeapon?.attackCountIncrease.baseParameter = count;
          movementEnabled.removeKey(
            entityId,
          );
          invincible.removeKey(
            entityId,
          );

          startPrimaryAttacking();
        },
        stateDuration: (4, 5),
        triggerFunctions: [
          () => canUnBurrow,
        ],
        onStateEnd: () {},
      ),
      //In
      1: EnemyState(
        this,
        priority: 5,
        randomFunctions: [],
        stateDuration: (groundDuration, groundDuration * 1.5),
        onStateStart: (duration) {
          setEntityAnimation('burrow_in')
              .then((value) => setEntityAnimation(EntityStatus.idle));
          toggleIdleRunAnimations(true);
          touchDamage.damageBase.clear();
          collision.setIncrease(entityId, false);
          movementEnabled.setIncrease(entityId, false);
          invincible.setIncrease(entityId, true);
          endPrimaryAttacking();
        },
        triggerFunctions: [],
      ),
    };
  }

  final double unBurrowHitTime = 3;

  double timeSinceHit = 0;

  @override
  AimPattern aimPattern = AimPattern.player;

  @override
  late EnemyState baseState;

  @override
  late Map<int, EnemyState> enemyStates;

  @override
  EnemyType enemyType = EnemyType.mushroomBurrower;

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  double get burrowSpeed => 1.0;
  bool get canUnBurrow => timeSinceHit > unBurrowHitTime;

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
    // entityAnimations[EntityStatus.dead] =
    //     await spriteAnimations.mushroomBurrowerDead1;
    entityAnimations[EntityStatus.jump] =
        await spriteAnimations.mushroomBurrowerJump1;
    entityAnimations['burrow_in'] =
        await spriteAnimations.mushroomBurrowerBurrowIn1
          ..stepTime = burrowSpeed / 9;
    entityAnimations['burrow_out'] =
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
  void update(double dt) {
    moveCharacter();
    timeSinceHit += dt;

    super.update(dt);
  }
}

class MushroomBoss extends Enemy
    with
        MovementFunctionality,
        AimFunctionality,
        TouchDamageFunctionality,
        AimControlFunctionality,
        AttackFunctionality,
        StateManagedAI {
  MushroomBoss({
    required super.initialPosition,
    required super.enviroment,
    required super.upgradeLevel,
    required super.eventManagement,
  }) {
    height.baseParameter = 5;
    invincibilityDuration.baseParameter =
        mushroomBoomerBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomBossBaseMaxHealth;
    speed.baseParameter = mushroomBossBaseSpeed;
    initialWeapons.add(WeaponType.mushroomBossWeapon1);
    knockBackResistanceParameter.baseParameter = 0;
    knockBackResistanceParameter.setParameterPercentValue(entityId, -1);
    priority = entityPriority + 500;

    final AiTimerClass aiTimerConfig = (
      function: () {
        addMoveVelocity(
          (SpawnLocation.infrontOfPlayer.grabNewPosition(gameEnviroment) -
                  center)
              .normalized(),
          aiInputPriority,
        );
      },
      id: '${entityId}move',
      time: 5,
    );
    gameEnviroment.eventManagement.addAiTimer(
      aiTimerConfig,
    );
    onDeath.add((instance) {
      gameEnviroment.eventManagement.removeAiTimer(
        id: aiTimerConfig.id,
      );
      entityAnimationsGroup.animationTicker?.completed.then
          // gameEnviroment.game.gameAwait(2).then
          ((value) async {
        final area = AreaEffect(
          position: position,
          overridePriority: attackPriority,
          sourceEntity: this,
          radius: 5,
          animationComponent: SimpleStartPlayEndSpriteAnimationComponent(
            spawnAnimation: await spriteAnimations.fireOrbMedium1,
            durationType: DurationType.instant,
          ),
          damage: {
            DamageType.fire: (50, 200),
          },
        );
        gameEnviroment.addPhysicsComponent([area]);
      });
      return false;
    });

    baseState = EnemyState(
      this,
      priority: 0,
      randomFunctions: [],
      stateDuration: (0, 1),
      triggerFunctions: [],
    );

    affectsAllEntities.baseParameter = true;

    const spinDuration = 10.0;

    enemyStates = {
      //Walking
      0: EnemyState(
        this,
        priority: 0,
        randomFunctions: [],
        onStateStart: (duration) async {
          await toggleIdleRunAnimations('');
          hitSinceLastSpin = false;
        },
        stateDuration: (5, 8),
        triggerFunctions: [],
      ),
      //Spinning
      1: EnemyState(
        this,
        priority: 5,
        randomFunctions: [],
        onStateEnd: () async {
          canMove = false;
          endPrimaryAttacking();
          touchDamage.damageBase.clear();
          entityAnimationsGroup.angle = 0;
          await setEntityAnimation('spin_end');
        },
        stateDuration: (spinDuration, spinDuration * 1.5),
        onStateStart: (duration) async {
          await toggleIdleRunAnimations('spinning');
          canMove = true;
          await setEntityAnimation('spin_start');
          startPrimaryAttacking();
          touchDamage.damageBase[DamageType.fire] = (10, 15);
        },
        triggerFunctions: [],
      ),

      //eye_close_toinvince
      2: EnemyState(
        this,
        priority: 5,
        preventDoubleRandomFunction: false,
        randomEventTimeFrame: (2, 4),
        randomFunctions: [
          () async {
            final entities = <Entity>[];
            for (var i = 0; i < rng.nextInt(3) + 3; i++) {
              final runner = EnemyType.mushroomRunner.build(
                position,
                gameEnviroment,
                (healthPercentage < .1) ? 2 : 1,
                eventManagement,
              );
              runner.priority = priority - 1;
              entities.add(runner);
            }
            await gameEnviroment.addPhysicsComponent(entities);
          }
        ],
        onStateEnd: () async {
          invincible.removeKey(entityId);
          await setEntityAnimation('eye_open');
        },
        stateDuration: (spinDuration, spinDuration * 1.5),
        onStateStart: (duration) async {
          await toggleIdleRunAnimations('invincible');
          invincible.setIncrease(entityId, true);
          await setEntityAnimation('eye_close');
        },
        triggerFunctions: [],
      ),
      //passive
      4: EnemyState(
        this,
        priority: 5,
        randomFunctions: [],
        onStateStart: (duration) async {
          await toggleIdleRunAnimations('');
          hitSinceLastSpin = false;
        },
        stateDuration: (2, 4),
        triggerFunctions: [],
      ),
    };
  }

  bool canMove = false;
  bool hitSinceLastSpin = false;

  @override
  AimPattern aimPattern = AimPattern.player;

  @override
  late EnemyState baseState;

  @override
  late Map<int, EnemyState> enemyStates;

  @override
  EnemyType enemyType = EnemyType.mushroomBoss;

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.2,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

  Future<void> loadRunIdleAnimations() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.mushroomBossIdle1;
  }

  @override
  final double maxDistanceFromPlayer = double.infinity;

  ///['spinning']
  ///['invincible']
  ///none
  Future<void> toggleIdleRunAnimations(String state) async {
    switch (state) {
      case 'spinning':
        entityAnimations[EntityStatus.idle] = entityAnimations['spin']!.clone();

        break;
      case 'invincible':
        entityAnimations[EntityStatus.idle] =
            entityAnimations['eye_close_idle']!.clone();

        break;

      default:
        await loadRunIdleAnimations();
    }

    entityAnimationsGroup.resetTicker(EntityStatus.idle);
  }

  @override
  void applyDamage(DamageInstance damage) {
    hitSinceLastSpin = true;
    super.applyDamage(damage);
  }

  @override
  // TODO: implement filter
  Filter? get filter => Filter()
    ..categoryBits = enemyCategory
    ..maskBits = playerCategory +
        swordCategory +
        projectileCategory +
        sensorCategory +
        areaEffectCategory;

  @override
  final (int, int) experiencePerDrop = (10, 50);

  @override
  bool get hideShadow => true;

  @override
  Future<void> loadAnimationSprites() async {
    await loadRunIdleAnimations();

    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.mushroomBossDead1;
    entityAnimations[EntityStatus.run] =
        await spriteAnimations.mushroomBossSpin1;

    entityAnimations[EntityStatus.spawn] =
        await spriteAnimations.mushroomBossSpawn1;

    entityAnimations['spin_start'] =
        await spriteAnimations.mushroomBossSpinStart1;

    entityAnimations['spin_end'] = await spriteAnimations.mushroomBossSpinEnd1;

    entityAnimations['spin'] = await spriteAnimations.mushroomBossSpin1;

    entityAnimations['eye_close'] =
        await spriteAnimations.mushroomBossEyeClose1;
    entityAnimations['eye_close_idle'] =
        await spriteAnimations.mushroomBossEyeCloseIdle1;
    entityAnimations['eye_open'] = await spriteAnimations.mushroomBossEyeOpen1;
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    await super.onLoad();
    // startAttacking();
  }

  @override
  void update(double dt) {
    if (entityAnimationsGroup.animations?[EntityStatus.run] ==
        entityAnimations['spin']) {}
    if (canMove) {
      moveCharacter();
    }
    super.update(dt);
  }
}
