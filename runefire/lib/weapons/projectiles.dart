import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/constants/sprite_animations.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/projectile_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/custom.dart';
import '../resources/functions/functions.dart';

class MagicalProjectile extends SpriteBullet {
  MagicalProjectile(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      DamageType? primaryDamageType,
      required super.size})
      : super(primaryDamageType: primaryDamageType, useDefaults: false) {
    bool isSmallProjectile = this.isSmallProjectile;

    String bigString = isSmallProjectile ? '' : '_big';
    String name = damageType.name;

    switch (damageType) {
      case DamageType.fire:
        customPlayAnimation = loadSpriteAnimation(4,
            'weapons/projectiles/magic/${name}_play$bigString.png', .1, true);
        customHitAnimation = loadSpriteAnimation(
            4, 'weapons/projectiles/magic/${name}_hit.png', .1, false);

        break;
      case DamageType.energy:
        customPlayAnimation = loadSpriteAnimation(9,
            'weapons/projectiles/magic/${name}_play$bigString.png', .05, true);
        customHitAnimation = loadSpriteAnimation(
            4, 'weapons/projectiles/magic/${name}_hit.png', .1, false);

        break;
      case DamageType.magic:
        customPlayAnimation = loadSpriteAnimation(9,
            'weapons/projectiles/magic/${name}_play$bigString.png', .05, true);
        // customHitAnimation = loadSpriteAnimation(
        //     4, 'weapons/projectiles/magic/${name}_hit.png', .1, false);

        break;
      case DamageType.psychic:
        customPlayAnimation = loadSpriteAnimation(isSmallProjectile ? 4 : 2,
            'weapons/projectiles/magic/${name}_play$bigString.png', .1, true);
        customHitAnimation = loadSpriteAnimation(
            5, 'weapons/projectiles/magic/${name}_hit.png', .1, false);
        if (!isSmallProjectile) {
          customSpawnAnimation = loadSpriteAnimation(
              3,
              'weapons/projectiles/magic/${name}_spawn$bigString.png',
              .1,
              false);
        }
        break;
      case DamageType.frost:
        customPlayAnimation = loadSpriteAnimation(3,
            'weapons/projectiles/magic/${name}_play$bigString.png', .05, true);
        customHitAnimation = loadSpriteAnimation(
            6, 'weapons/projectiles/magic/${name}_hit.png', .065, false);
        customSpawnAnimation = loadSpriteAnimation(3,
            'weapons/projectiles/magic/${name}_spawn$bigString.png', .1, false);
        break;
      default:
    }
  }

  late CustomParticleGenerator particleGenerator = CustomParticleGenerator(
      minSize: .05,
      maxSize: .15,
      lifespan: 2,
      parentBody: body,
      frequency: 1,
      particlePosition: Vector2(.3 * size, size),
      velocity: Vector2.all(0.5),
      color: damageType.color,
      sprites: null);

  @override
  void onRemove() {
    particleGenerator.removeFromParent();
    super.onRemove();
  }

  @override
  void onMount() {
    weaponAncestor.entityAncestor?.enviroment.physicsComponent
        .add(particleGenerator);
    super.onMount();
  }
}

class PaintBullet extends FadeOutBullet with PaintProjectile {
  PaintBullet(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      super.primaryDamageType,
      required super.size,
      super.power});

  @override
  ProjectileType projectileType = ProjectileType.paintBullet;
}

class SpriteBullet extends Bullet with ProjectileSpriteLifecycle {
  Future<SpriteAnimation>? customSpawnAnimation;
  Future<SpriteAnimation>? customPlayAnimation;
  Future<SpriteAnimation>? customEndAnimation;
  Future<SpriteAnimation>? customHitAnimation;

  SpriteBullet(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      required super.size,
      this.useDefaults = true,
      super.primaryDamageType,
      this.customSpawnAnimation,
      this.customPlayAnimation,
      this.customEndAnimation,
      this.customHitAnimation,
      super.power});
  @override
  void bodyContact(HealthFunctionality other) {
    applyHitAnimation(other, center);

    super.bodyContact(other);
  }

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
                'weapons/projectiles/bullets/${damageType.name}_bullet_spawn.png',
                .02,
                false)
            : null);
    playAnimation = await customPlayAnimation ??
        (useDefaults
            ? await loadSpriteAnimation(
                4,
                'weapons/projectiles/bullets/${damageType.name}_bullet_play.png',
                .02,
                true)
            : null);
    endAnimation = await customEndAnimation ??
        (useDefaults
            ? await loadSpriteAnimation(
                3,
                'weapons/projectiles/bullets/${damageType.name}_bullet_end.png',
                .1,
                false)
            : null);
    hitAnimation = await customHitAnimation ??
        (useDefaults
            ? await loadSpriteAnimation(
                6,
                'weapons/projectiles/bullets/${damageType.name}_bullet_hit.png',
                .02,
                false)
            : null);

    animationComponent ??= SimpleStartPlayEndSpriteAnimationComponent(
      durationType: DurationType.temporary,
      playAnimation: playAnimation,
      spawnAnimation: spawnAnimation,
      anchor: Anchor.topCenter,
      desiredWidth: (size),
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

class Laser extends Projectile with FadeOutProjectile, LaserProjectile {
  Laser(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      super.size = 1.5,
      super.power});
  @override
  ProjectileType projectileType = ProjectileType.laser;

  @override
  late final double ttl = weaponAncestor.attackTickRate.parameter * 2;

  @override
  double baseWidth = .3;

  @override
  set ttl(double val) {}
}
