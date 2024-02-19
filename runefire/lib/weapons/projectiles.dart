import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/assets/sprite_animations.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/projectile_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';

class MagicalProjectile extends SpriteBullet {
  final bool showParticles;
  MagicalProjectile(
    super.projectileConfiguration, {
    this.showParticles = true,
  }) : super(useDefaults: false) {
    final isSmallProjectile = this.isSmallProjectile;

    final bigString = isSmallProjectile ? '' : '_big';
    final name = damageType.name;

    switch (damageType) {
      case DamageType.fire:
        customPlayAnimation = loadSpriteAnimation(
          4,
          'weapons/projectiles/magic/${name}_play$bigString.png',
          .1,
          true,
        );
        customHitAnimation = loadSpriteAnimation(
          4,
          'weapons/projectiles/magic/${name}_hit.png',
          .1,
          false,
        );

        break;
      case DamageType.energy:
        customPlayAnimation = loadSpriteAnimation(
          9,
          'weapons/projectiles/magic/${name}_play$bigString.png',
          .05,
          true,
        );
        customHitAnimation = loadSpriteAnimation(
          4,
          'weapons/projectiles/magic/${name}_hit.png',
          .1,
          false,
        );

        break;
      case DamageType.magic:
        customPlayAnimation = loadSpriteAnimation(
          9,
          'weapons/projectiles/magic/${name}_play$bigString.png',
          .05,
          true,
        );
        // customHitAnimation = loadSpriteAnimation(
        //     4, 'weapons/projectiles/magic/${name}_hit.png', .1, false);

        break;
      case DamageType.psychic:
        customPlayAnimation = loadSpriteAnimation(
          isSmallProjectile ? 4 : 2,
          'weapons/projectiles/magic/${name}_play$bigString.png',
          .1,
          true,
        );
        customHitAnimation = loadSpriteAnimation(
          5,
          'weapons/projectiles/magic/${name}_hit.png',
          .1,
          false,
        );
        if (!isSmallProjectile) {
          customSpawnAnimation = loadSpriteAnimation(
            3,
            'weapons/projectiles/magic/${name}_spawn$bigString.png',
            .1,
            false,
          );
        }
        break;
      case DamageType.frost:
        customPlayAnimation = loadSpriteAnimation(
          3,
          'weapons/projectiles/magic/${name}_play$bigString.png',
          .05,
          true,
        );
        customHitAnimation = loadSpriteAnimation(
          6,
          'weapons/projectiles/magic/${name}_hit.png',
          .065,
          false,
        );
        customSpawnAnimation = loadSpriteAnimation(
          3,
          'weapons/projectiles/magic/${name}_spawn$bigString.png',
          .1,
          false,
        );
        break;
      default:
    }
  }
  late CustomParticleGenerator particleGenerator = CustomParticleGenerator(
    minSize: .02,
    maxSize: (power * .07) + .05,
    lifespan: 2,
    parentBody: body,
    frequency: 2,
    particlePosition: Vector2(.3 * size, .3 * size),
    velocity: Vector2.all(0.5),
    color: damageType.color,
    damageType: damageType,
  );

  @override
  void onRemove() {
    if (showParticles) {
      particleGenerator.removeFromParent();
    }
    super.onRemove();
  }

  @override
  void onMount() {
    if (showParticles) {
      weaponAncestor.entityAncestor?.enviroment
          .addPhysicsComponent([particleGenerator]);
    }
    super.onMount();
  }
}

class PaintBullet extends FadeOutBullet
    with StandardProjectile, PaintProjectile {
  PaintBullet(
    super.projectileConfiguration,
  ) {
    defaultLinearDamping = .3;
  }

  @override
  ProjectileType projectileType = ProjectileType.paintBullet;
}

class SpriteBullet extends Projectile
    with StandardProjectile, ProjectileSpriteLifecycle {
  Future<SpriteAnimation>? customSpawnAnimation;
  Future<SpriteAnimation>? customPlayAnimation;
  Future<SpriteAnimation>? customEndAnimation;
  Future<SpriteAnimation>? customHitAnimation;

  SpriteBullet(
    super.projectileConfiguration, {
    this.useDefaults = true,
    this.customBulletName,
    this.customSpawnAnimation,
    this.customPlayAnimation,
    this.customEndAnimation,
    this.customHitAnimation,
  });

  @override
  void bodyContact(HealthFunctionality other) {
    applyHitAnimation(other, center);

    super.bodyContact(other);
  }

  String? customBulletName;

  bool useDefaults;
  @override
  SimpleStartPlayEndSpriteAnimationComponent? animationComponent;

  Future<void> buildAnimations() async {
    late SpriteAnimation? spawnAnimation;
    late SpriteAnimation? playAnimation;
    late SpriteAnimation? endAnimation;

    spawnAnimation = await customSpawnAnimation ??
        (useDefaults
            ? await loadSpriteAnimation(
                4,
                'weapons/projectiles/bullets/${customBulletName ?? damageType.name}_bullet_spawn.png',
                .03,
                false,
              )
            : null);
    playAnimation = await customPlayAnimation ??
        (useDefaults
            ? await loadSpriteAnimation(
                4,
                'weapons/projectiles/bullets/${customBulletName ?? damageType.name}_bullet_play.png',
                .05,
                true,
              )
            : null);
    endAnimation = await customEndAnimation ??
        (useDefaults
            ? await loadSpriteAnimation(
                3,
                'weapons/projectiles/bullets/${customBulletName ?? damageType.name}_bullet_end.png',
                .1,
                false,
              )
            : null);
    hitAnimation = await customHitAnimation ??
        (useDefaults
            ? await loadSpriteAnimation(
                6,
                'weapons/projectiles/bullets/${customBulletName ?? damageType.name}_bullet_hit.png',
                .035,
                false,
              )
            : null);

    animationComponent ??= SimpleStartPlayEndSpriteAnimationComponent(
      playAnimation: playAnimation,
      spawnAnimation: spawnAnimation,
      randomizePlay: true,
      desiredWidth: size,
      endAnimation: endAnimation,
    );
  }

  @override
  Future<void> onLoad() async {
    await buildAnimations();
    super.onLoad();
  }

  @override
  SpriteAnimation? hitAnimation;

  @override
  ProjectileType projectileType = ProjectileType.spriteBullet;
}

class PaintLaser extends FadeOutBullet with LaserProjectile {
  PaintLaser(
    super.projectileConfiguration,
  );
  @override
  ProjectileType projectileType = ProjectileType.laser;
}

class FollowLaser extends FadeOutBullet with LaserProjectile {
  FollowLaser(
    super.projectileConfiguration,
  ) {
    followWeapon = true;
    allowChainingOrHoming = true;
    rememberTargets = true;
    lightningEffect = true;
  }

  @override
  bool get removeOnEndAttack => true;
  @override
  ProjectileType projectileType = ProjectileType.followLaser;
}
