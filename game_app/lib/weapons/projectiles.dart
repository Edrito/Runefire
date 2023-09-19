import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/area_effects.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/projectile_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/custom.dart';
import '../resources/functions/functions.dart';

class PaintBullet extends FadeOutBullet with PaintProjectile {
  PaintBullet(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
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

  @override
  SimpleStartPlayEndSpriteAnimationComponent? animationComponent;

  Future<void> buildAnimations() async {
    late SpriteAnimation spawnAnimation;
    late SpriteAnimation playAnimation;
    late SpriteAnimation endAnimation;

    spawnAnimation = await customSpawnAnimation ??
        await loadSpriteAnimation(
            4,
            'weapons/projectiles/bullets/${damageType.name}_bullet_spawn.png',
            .02,
            false);
    playAnimation = await customPlayAnimation ??
        await loadSpriteAnimation(
            4,
            'weapons/projectiles/bullets/${damageType.name}_bullet_play.png',
            .02,
            true);
    endAnimation = await customEndAnimation ??
        await loadSpriteAnimation(
            3,
            'weapons/projectiles/bullets/${damageType.name}_bullet_end.png',
            .1,
            false);
    hitAnimation = await customHitAnimation ??
        await loadSpriteAnimation(
            6,
            'weapons/projectiles/bullets/${damageType.name}_bullet_hit.png',
            .02,
            false);

    animationComponent ??= SimpleStartPlayEndSpriteAnimationComponent(
      durationType: DurationType.temporary,
      playAnimation: playAnimation,
      spawnAnimation: spawnAnimation,
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

class Blast extends Bullet with ProjectileSpriteLifecycle {
  Blast(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      required super.size,
      super.power});

  @override
  ProjectileType projectileType = ProjectileType.blast;

  @override
  void bodyContact(HealthFunctionality other) {
    applyHitAnimation(other, center);

    super.bodyContact(other);
  }

  @override
  SimpleStartPlayEndSpriteAnimationComponent? animationComponent;

  @override
  Future<void> onLoad() async {
    // switch (damageType) {
    //   case DamageType.physical:
    //     spawnAnimation = await buildSpriteSheet(
    //         4,
    //         'weapons/projectiles/bullets/physical_bullet_spawn.png',
    //         .02,
    //         false);
    //     playAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/physical_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(3,
    //         'weapons/projectiles/bullets/physical_bullet_end.png', .1, false);
    //     hitAnimation = await buildSpriteSheet(6,
    //         'weapons/projectiles/bullets/physical_bullet_hit.png', .02, false);
    //     break;

    //   case DamageType.energy:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/energy_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/energy_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/energy_bullet_end.png', .1, false);
    //     hitAnimation = await buildSpriteSheet(
    //         6, 'weapons/projectiles/bullets/energy_bullet_hit.png', .02, false);
    //     break;

    //   case DamageType.fire:
    //     spawnAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/fire_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/fire_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/fire_bullet_end.png', .1, false);
    //     hitAnimation = await buildSpriteSheet(
    //         6, 'weapons/projectiles/bullets/fire_bullet_hit.png', .02, false);
    //     break;

    //   case DamageType.frost:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/frost_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/frost_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/frost_bullet_end.png', .1, false);
    //     hitAnimation = await buildSpriteSheet(
    //         6, 'weapons/projectiles/bullets/frost_bullet_hit.png', .02, false);
    //     break;

    //   case DamageType.magic:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/magic_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/magic_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/magic_bullet_end.png', .1, false);
    //     hitAnimation = await buildSpriteSheet(
    //         6, 'weapons/projectiles/bullets/magic_bullet_hit.png', .02, false);
    //     break;

    //   case DamageType.psychic:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/psychic_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/psychic_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/psychic_bullet_end.png', .1, false);
    //     hitAnimation = await buildSpriteSheet(6,
    //         'weapons/projectiles/bullets/psychic_bullet_hit.png', .02, false);
    //     break;
    //   case DamageType.healing:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/healing_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/healing_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/healing_bullet_end.png', .1, false);
    //     hitAnimation = await buildSpriteSheet(6,
    //         'weapons/projectiles/bullets/healing_bullet_hit.png', .02, false);
    //     break;
    // }

    // final spawnAnimation = await loadSpriteAnimation(
    //       4,
    //       'weapons/projectiles/bullets/physical_bullet_spawn.png',
    //       .02,
    //       false);

    final playAnimation = await loadSpriteAnimation(
        4,
        [
          'weapons/projectiles/blasts/fire_blast_play.png',
          // 'weapons/projectiles/blasts/fire_blast_play_alt.png'
        ].getRandomElement(),
        .1,
        true);
    final endAnimation = await loadSpriteAnimation(
        4, 'weapons/projectiles/blasts/fire_blast_end.png', .1, false);
    // hitAnimation = await buildSpriteSheet(6,
    // 'weapons/projectiles/bullets/physical_bullet_hit.png', .02, false);

    animationComponent ??= SimpleStartPlayEndSpriteAnimationComponent(
      // spawnAnimation:spawnAnimation,
      durationType: DurationType.temporary,
      playAnimation: playAnimation,
      desiredWidth: (size),
      endAnimation: endAnimation,
    );

    super.onLoad();
  }

  @override
  SpriteAnimation? hitAnimation;
}

class ExplosiveProjectile extends FadeOutBullet with PaintProjectile {
  ExplosiveProjectile(
      {required super.delta,
      required super.originPosition,
      super.size = 3,
      required super.weaponAncestor,
      super.power});

  @override
  ProjectileType projectileType = ProjectileType.explosiveProjectile;

  @override
  void killBullet([bool withEffect = false]) async {
    weaponAncestor.entityAncestor?.enviroment.physicsComponent.add(AreaEffect(
      sourceEntity: weaponAncestor.entityAncestor!,
      position: center,
      duration: 5,
      damage: {DamageType.fire: (50, 120)},
    ));
    super.killBullet(withEffect);
  }

  @override
  SimpleStartPlayEndSpriteAnimationComponent? animationComponent;

  @override
  SpriteAnimation? hitAnimation;
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
