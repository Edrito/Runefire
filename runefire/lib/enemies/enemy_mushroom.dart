import 'dart:async';
import 'dart:async' as async;
import 'dart:math';
import 'package:flame/effects.dart';
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
    critChance.baseParameter = .5;
    maxHealth.baseParameter = 5.0 + rng.nextInt(5);
    speed.baseParameter = 1000.0 + rng.nextInt(500);
    touchDamage.damageBase[DamageType.physical] = (1, 5);
  }

  @override
  Map<ExpendableType, double> get expendableRate => {
        // ExpendableType.fearEnemiesRunes: 0.5,
        ExpendableType.healingRune: 0.1,
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

    onDeath.add((instance) {
      if (instance.damageMap.keys.contains(DamageType.fire)) {
        entityAnimationsGroup.animationTickers?[EntityStatus.dead]?.completed;
        final temp = AreaEffect(
          position: body.worldCenter,
          sourceEntity: this,
          radius: 4 * ((upgradeLevel / 2)) + 2,
          damage: {DamageType.fire: (2, 15)},
        );
        gameEnviroment.addPhysicsComponent([temp]);
      } else {
        entityAnimationsGroup.animationTickers?[EntityStatus.dead]?.completed
            .then((_) {
          final temp = AreaEffect(
            position: body.worldCenter,
            sourceEntity: this,
            radius: 4 * ((upgradeLevel / 2)) + 2,
            damage: {DamageType.fire: (2, 15)},
          );
          gameEnviroment.addPhysicsComponent([temp]);
        });
      }
      return null;
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
            setEntityAnimation('spin_end');
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
          currentWeapon?.endAttacking();
          speed.baseParameter = mushroomShooterBaseSpeed * .5;
          touchDamage.damageBase.clear();
          rotateEffect?.removeFromParent();
          rotateEffect = null;
          entityAnimationsGroup.angle = 0;
        },
        stateDuration: (spinDuration, spinDuration * 1.5),
        onStateStart: (duration) async {
          await toggleIdleRunAnimations(true);
          setEntityAnimation('spin_start').then((_) {
            currentWeapon?.startAttacking();
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

  @override
  bool get affectsAllEntities => false;

  @override
  void update(double dt) {
    if (entityAnimationsGroup.animations?[EntityStatus.run] ==
        entityAnimations['spin']) {}

    moveCharacter();
    super.update(dt);
  }

  bool hitSinceLastSpin = false;
  @override
  void applyDamage(DamageInstance damage) {
    hitSinceLastSpin = true;
    super.applyDamage(damage);
  }

  @override
  Map<ExperienceAmount, double> experienceRate = {
    ExperienceAmount.large: 0.001,
    ExperienceAmount.medium: 0.01,
    ExperienceAmount.small: 0.4,
  };

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
    speed.baseParameter = 0;

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

    const groundDuration = 2.0;
    enemyStates = {
      //Out
      0: EnemyState(
        this,
        priority: 0,
        randomFunctions: [],
        onStateStart: (duration) async {
          toggleIdleRunAnimations(false);
          if (initState) {
            body.setTransform(
              SpawnLocation.onPlayer.grabNewPosition(gameEnviroment, 1),
              angle,
            );
            await setEntityAnimation('burrow_out')
                .then((value) => setEntityAnimation(EntityStatus.idle));
          } else {
            initState = true;
          }

          touchDamage.damageBase[DamageType.physical] = (10, 15);
          collision.removeKey(entityId);

          final count = 2 + (rng.nextBool() ? 0 : 2);
          currentWeapon?.attackCountIncrease.baseParameter = count;

          currentWeapon?.startAttacking();
        },
        stateDuration: (4, 5),
        triggerFunctions: [],
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
        },
        triggerFunctions: [],
      ),
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
  EnemyType enemyType = EnemyType.mushroomBurrower;

  @override
  late EnemyState baseState;

  @override
  late Map<int, EnemyState> enemyStates;

  @override
  AimPattern aimPattern = AimPattern.player;
}
