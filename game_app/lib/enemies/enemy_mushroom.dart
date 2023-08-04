import 'dart:async';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/enemies/enemy_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/event_management.dart';
import 'package:game_app/resources/area_effects.dart';

import '../resources/functions/functions.dart';
import '../resources/enums.dart';
import 'enemy.dart';
import 'enemy_mushroom_constants.dart';
import 'enemy_state_mixin.dart';

class MushroomDummy extends Enemy with JumpFunctionality

// MovementFunctionality,
// DumbFollowAI,
{
  MushroomDummy({
    required super.initPosition,
    required super.enviroment,
    required super.upgradeLevel,
  }) {
    height.baseParameter = mushroomHopperBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomHopperBaseInvincibilityDuration;
    maxHealth.baseParameter = double.infinity;
  }

  @override
  (double, double) xpRate = (0.001, 0.01);

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomHopper/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] = await buildSpriteSheet(
        3, 'enemy_sprites/mushroomHopper/jump.png', .1, false);

    entityAnimations[EntityStatus.dead] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomHopper/death.png', .1, false);
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

class MushroomHopper extends Enemy
    with
        JumpFunctionality,
        MovementFunctionality,
        HopFollowAI,
        TouchDamageFunctionality {
  MushroomHopper({
    required super.initPosition,
    required super.enviroment,
    required super.upgradeLevel,
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
  (double, double) xpRate = (0.001, 0.01);

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomHopper/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] = await buildSpriteSheet(
        3, 'enemy_sprites/mushroomHopper/jump.png', .1, false);

    entityAnimations[EntityStatus.dead] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomHopper/death.png', .1, false);
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
    required super.initPosition,
    required super.enviroment,
    required super.upgradeLevel,
  }) {
    height.baseParameter = mushroomBoomerBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomBoomerBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomBoomerBaseMaxHealth;
    speed.baseParameter = mushroomBoomerBaseSpeed;

    onDeath.add(() async {
      await spriteAnimationComponent.animationTicker?.completed;
      enviroment.physicsComponent.add(AreaEffect(
          position: body.worldCenter,
          playAnimation: await buildSpriteSheet(
              61, 'weapons/projectiles/fire_area.png', .05, true),
          sourceEntity: this,
          size: 4 * ((upgradeLevel / 2)) + 2,
          damage: {DamageType.fire: (2, 15)}));
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
  (double, double) xpRate = (0.001, 0.01);

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomBoomer/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] = await buildSpriteSheet(
        3, 'enemy_sprites/mushroomBoomer/jump.png', .1, false);
    entityAnimations[EntityStatus.dash] = await buildSpriteSheet(
        7, 'enemy_sprites/mushroomBoomer/roll.png', .06, false);
    entityAnimations[EntityStatus.walk] = await buildSpriteSheet(
        8, 'enemy_sprites/mushroomBoomer/walk.png', .1, true);
    entityAnimations[EntityStatus.run] = await buildSpriteSheet(
        8, 'enemy_sprites/mushroomBoomer/run.png', .1, true);
    entityAnimations[EntityStatus.dead] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomBoomer/death.png', .1, false);
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
  MushroomShooter({
    required super.initPosition,
    required super.enviroment,
    required super.upgradeLevel,
  }) {
    height.baseParameter = mushroomShooterBaseHeight;
    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;
    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    speed.baseParameter = mushroomShooterBaseSpeed;
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  @override
  bool get affectsAllEntities => true;

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  (double, double) xpRate = (0.001, 0.01);

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomShooter/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] = await buildSpriteSheet(
        3, 'enemy_sprites/mushroomShooter/jump.png', .1, false);
    entityAnimations[EntityStatus.dash] = await buildSpriteSheet(
        7, 'enemy_sprites/mushroomShooter/roll.png', .06, false);
    entityAnimations[EntityStatus.attack] = await buildSpriteSheet(
        3, 'enemy_sprites/mushroomShooter/jump.png', .1, false);
    entityAnimations[EntityStatus.run] = await buildSpriteSheet(
        8, 'enemy_sprites/mushroomShooter/run.png', .1, true);
    entityAnimations[EntityStatus.dead] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomShooter/death.png', .1, false);
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
  MushroomSpinner({
    required super.initPosition,
    required super.enviroment,
    required super.upgradeLevel,
  }) {
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
      0: EnemyState(this, priority: 0, randomFunctions: [], onStateStart: () {
        if (initState) {
          setEntityStatus(EntityStatus.custom,
              customAnimation: entityAnimations["spin_end"]);
        } else {
          initState = true;
        }
        speed.baseParameter = .03;
        toggleIdleRunAnimations(false);
        touchDamage.damageBase.clear();
      }, stateDuration: (4, 5), triggerFunctions: []),
      //Spinning
      1: EnemyState(this,
          priority: 5,
          randomFunctions: [],
          stateDuration: (spinDuration, spinDuration * 1.5), onStateStart: () {
        setEntityStatus(EntityStatus.custom,
            customAnimation: entityAnimations["spin_start"]);
        toggleIdleRunAnimations(true);
        speed.baseParameter = .05;
        for (var i = 1; i < 4; i++) {
          Future.delayed(((spinDuration / 4) * i).seconds, () {
            final count = 3 + (rng.nextBool() ? 0 : 3);
            currentWeapon?.baseAttackCount.baseParameter = count;
            currentWeapon?.maxSpreadDegrees.baseParameter = 270;

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
  bool get affectsAllEntities => true;

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  (double, double) xpRate = (0.001, 0.01);

  Future<void> toggleIdleRunAnimations(bool isSpinning) async {
    if (isSpinning) {
      entityAnimations[EntityStatus.idle] = entityAnimations["spin"]!;

      entityAnimations[EntityStatus.run] = entityAnimations["spin"]!;
    } else {
      entityAnimations[EntityStatus.idle] = await buildSpriteSheet(
          10, 'enemy_sprites/mushroomSpinner/idle.png', .1, true);

      entityAnimations[EntityStatus.run] = await buildSpriteSheet(
          8, 'enemy_sprites/mushroomSpinner/run.png', .1, true);
    }
  }

  @override
  Future<void> loadAnimationSprites() async {
    toggleIdleRunAnimations(false);
    entityAnimations[EntityStatus.dead] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomSpinner/death.png', .1, false);
    entityAnimations["spin_start"] = await buildSpriteSheet(
        9, 'enemy_sprites/mushroomSpinner/spin_start.png', .1, false);
    entityAnimations["spin_end"] = await buildSpriteSheet(
        9, 'enemy_sprites/mushroomSpinner/spin_end.png', .1, false);
    entityAnimations["spin"] = await buildSpriteSheet(
        7, 'enemy_sprites/mushroomSpinner/spin.png', .02, true);
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
  MushroomBurrower({
    required super.initPosition,
    required super.enviroment,
    required super.upgradeLevel,
  }) {
    height.baseParameter = mushroomShooterBaseHeight;

    invincibilityDuration.baseParameter =
        mushroomShooterBaseInvincibilityDuration;

    maxHealth.baseParameter = mushroomShooterBaseMaxHealth;
    speed.baseParameter = 0;

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
          setEntityStatus(EntityStatus.custom,
                  customAnimation: entityAnimations["burrow_out"])
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
              currentWeapon?.baseAttackCount.baseParameter = count;
              currentWeapon?.maxSpreadDegrees.baseParameter = 270;

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
        setEntityStatus(EntityStatus.custom,
                customAnimation: entityAnimations["burrow_in"])
            .then((value) => setEntityStatus(EntityStatus.idle));
        toggleIdleRunAnimations(true);
        touchDamage.damageBase.clear();
        collision.setIncrease(entityId, false);
      }, triggerFunctions: []),
    };
  }

  @override
  bool get affectsAllEntities => true;

  double get burrowSpeed => 1.0;

  @override
  (double, double) xpRate = (0.001, 0.01);

  Future<void> toggleIdleRunAnimations(bool isBurrowed) async {
    if (isBurrowed) {
      entityAnimations.remove(EntityStatus.idle);
    } else {
      entityAnimations[EntityStatus.idle] = await buildSpriteSheet(
          10, 'enemy_sprites/mushroomSpinner/idle.png', .1, true);
    }
  }

  @override
  Future<void> loadAnimationSprites() async {
    toggleIdleRunAnimations(false);
    entityAnimations[EntityStatus.dead] = await buildSpriteSheet(
        10, 'enemy_sprites/mushroomBurrower/death.png', .1, false);
    entityAnimations["burrow_in"] = await buildSpriteSheet(9,
        'enemy_sprites/mushroomBurrower/burrow_in.png', burrowSpeed / 9, false);
    entityAnimations["burrow_out"] = await buildSpriteSheet(
        9,
        'enemy_sprites/mushroomBurrower/burrow_out.png',
        burrowSpeed / 9,
        false);
  }

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