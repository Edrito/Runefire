import 'dart:async';

import 'package:game_app/enemies/enemy_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/area_effects.dart';

import '../resources/functions/functions.dart';
import '../resources/enums.dart';
import 'enemy.dart';
import 'enemy_mushroom_constants.dart';

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
    entityAnimations[EntityStatus.idle] =
        await buildSpriteSheet(10, 'sprites/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] =
        await buildSpriteSheet(3, 'sprites/jump.png', .1, false);

    entityAnimations[EntityStatus.dead] =
        await buildSpriteSheet(10, 'enemy_sprites/death.png', .1, false);
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
          radius: 4 * ((upgradeLevel / 2)) + 1,
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
    entityAnimations[EntityStatus.idle] =
        await buildSpriteSheet(10, 'sprites/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] =
        await buildSpriteSheet(3, 'sprites/jump.png', .1, false);
    entityAnimations[EntityStatus.dash] =
        await buildSpriteSheet(7, 'sprites/roll.png', .06, false);
    entityAnimations[EntityStatus.walk] =
        await buildSpriteSheet(8, 'sprites/walk.png', .1, true);
    entityAnimations[EntityStatus.run] =
        await buildSpriteSheet(8, 'sprites/run.png', .1, true);
    entityAnimations[EntityStatus.dead] =
        await buildSpriteSheet(10, 'enemy_sprites/death.png', .1, false);
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
    entityAnimations[EntityStatus.idle] =
        await buildSpriteSheet(10, 'sprites/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] =
        await buildSpriteSheet(3, 'sprites/jump.png', .1, false);
    entityAnimations[EntityStatus.dash] =
        await buildSpriteSheet(7, 'sprites/roll.png', .06, false);
    entityAnimations[EntityStatus.walk] =
        await buildSpriteSheet(8, 'sprites/walk.png', .1, true);
    entityAnimations[EntityStatus.run] =
        await buildSpriteSheet(8, 'sprites/run.png', .1, true);
    entityAnimations[EntityStatus.dead] =
        await buildSpriteSheet(10, 'enemy_sprites/death.png', .1, false);
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
