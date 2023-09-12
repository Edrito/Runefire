import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/area_effects.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/projectile_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/custom.dart';
import '../resources/functions/functions.dart';

class Bullet extends Projectile
    with
        StandardProjectile,
        //  ProjectileSpriteLifecycle
//  ,
        CanvasTrail {
  Bullet(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      required this.size,
      super.power});

  @override
  double embedIntoEnemyChance = .8;

  @override
  ProjectileType projectileType = ProjectileType.bullet;

  @override
  double size;

  @override
  double ttl = 1.5;

  @override
  void bodyContact(HealthFunctionality other) {
    // applyHitAnimation(other, center);

    super.bodyContact(other);
  }

  @override
  SimpleStartPlayEndSpriteAnimationComponent? animationComponent;

  @override
  Future<void> onLoad() async {
    late SpriteAnimation spawnAnimation;
    late SpriteAnimation playAnimation;
    late SpriteAnimation endAnimation;

    switch (damageType) {
      case DamageType.physical:
        spawnAnimation = await loadSpriteAnimation(
            4,
            'weapons/projectiles/bullets/physical_bullet_spawn.png',
            .02,
            false);
        playAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/physical_bullet_play.png', .02, true);
        endAnimation = await loadSpriteAnimation(3,
            'weapons/projectiles/bullets/physical_bullet_end.png', .1, false);
        hitAnimation = await loadSpriteAnimation(6,
            'weapons/projectiles/bullets/physical_bullet_hit.png', .02, false);
        break;

      case DamageType.energy:
        spawnAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/energy_bullet_spawn.png', .02, false);
        playAnimation = await loadSpriteAnimation(
            4, 'weapons/projectiles/bullets/energy_bullet_play.png', .02, true);
        endAnimation = await loadSpriteAnimation(
            3, 'weapons/projectiles/bullets/energy_bullet_end.png', .1, false);
        hitAnimation = await loadSpriteAnimation(
            6, 'weapons/projectiles/bullets/energy_bullet_hit.png', .02, false);
        break;

      case DamageType.fire:
        spawnAnimation = await loadSpriteAnimation(
            4, 'weapons/projectiles/bullets/fire_bullet_spawn.png', .02, false);
        playAnimation = await loadSpriteAnimation(
            4, 'weapons/projectiles/bullets/fire_bullet_play.png', .02, true);
        endAnimation = await loadSpriteAnimation(
            3, 'weapons/projectiles/bullets/fire_bullet_end.png', .1, false);
        hitAnimation = await loadSpriteAnimation(
            6, 'weapons/projectiles/bullets/fire_bullet_hit.png', .02, false);
        break;

      case DamageType.frost:
        spawnAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/frost_bullet_spawn.png', .02, false);
        playAnimation = await loadSpriteAnimation(
            4, 'weapons/projectiles/bullets/frost_bullet_play.png', .02, true);
        endAnimation = await loadSpriteAnimation(
            3, 'weapons/projectiles/bullets/frost_bullet_end.png', .1, false);
        hitAnimation = await loadSpriteAnimation(
            6, 'weapons/projectiles/bullets/frost_bullet_hit.png', .02, false);
        break;

      case DamageType.magic:
        spawnAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/magic_bullet_spawn.png', .02, false);
        playAnimation = await loadSpriteAnimation(
            4, 'weapons/projectiles/bullets/magic_bullet_play.png', .02, true);
        endAnimation = await loadSpriteAnimation(
            3, 'weapons/projectiles/bullets/magic_bullet_end.png', .1, false);
        hitAnimation = await loadSpriteAnimation(
            6, 'weapons/projectiles/bullets/magic_bullet_hit.png', .02, false);
        break;

      case DamageType.psychic:
        spawnAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/psychic_bullet_spawn.png', .02, false);
        playAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/psychic_bullet_play.png', .02, true);
        endAnimation = await loadSpriteAnimation(
            3, 'weapons/projectiles/bullets/psychic_bullet_end.png', .1, false);
        hitAnimation = await loadSpriteAnimation(6,
            'weapons/projectiles/bullets/psychic_bullet_hit.png', .02, false);
        break;
      case DamageType.healing:
        spawnAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/healing_bullet_spawn.png', .02, false);
        playAnimation = await loadSpriteAnimation(4,
            'weapons/projectiles/bullets/healing_bullet_play.png', .02, true);
        endAnimation = await loadSpriteAnimation(
            3, 'weapons/projectiles/bullets/healing_bullet_end.png', .1, false);
        hitAnimation = await loadSpriteAnimation(6,
            'weapons/projectiles/bullets/healing_bullet_hit.png', .02, false);
        break;
    }

    animationComponent ??= SimpleStartPlayEndSpriteAnimationComponent(
      // spawnAnimation:spawnAnimation,
      durationType: DurationType.temporary,
      playAnimation: playAnimation,
      spawnAnimation: spawnAnimation,
      size: Vector2.all(size),
      endAnimation: endAnimation,
    );

    super.onLoad();
  }

  @override
  void killBullet([bool withEffect = false]) async {
    if (!world.isLocked) {
      body.setType(BodyType.static);
    }
    if (withEffect) {
      await animationComponent?.triggerEnding();
      removeFromParent();
    } else {
      removeFromParent();
    }
    callBulletKillFunctions();
  }

  @override
  SpriteAnimation? hitAnimation;
}

class Blast extends Projectile
    with StandardProjectile, ProjectileSpriteLifecycle {
  Blast(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      required this.size,
      super.power});

  @override
  double embedIntoEnemyChance = .8;

  @override
  ProjectileType projectileType = ProjectileType.bullet;

  @override
  double size;

  @override
  double ttl = 1.5;

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
      size: Vector2.all(size),
      endAnimation: endAnimation,
    );

    super.onLoad();
  }

  @override
  void killBullet([bool withEffect = false]) {
    if (!world.isLocked) {
      body.setType(BodyType.static);
    }
    if (withEffect) {
      animationComponent?.triggerEnding();
    } else {
      removeFromParent();
    }
    callBulletKillFunctions();
  }

  @override
  SpriteAnimation? hitAnimation;
}

class ExplosiveProjectile extends Projectile with StandardProjectile {
  ExplosiveProjectile(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      super.power});

  @override
  double embedIntoEnemyChance = 0;

  @override
  ProjectileType projectileType = ProjectileType.fireball;

  @override
  double size = 3;

  @override
  double ttl = 2.0;

  @override
  void killBullet([bool withEffect = false]) async {
    weaponAncestor.entityAncestor?.enviroment.physicsComponent.add(AreaEffect(
      sourceEntity: weaponAncestor.entityAncestor!,
      position: center,
      animationComponent: SimpleStartPlayEndSpriteAnimationComponent(
          playAnimation: await loadSpriteAnimation(
              16, 'effects/explosion_1_16.png', .1, true),
          spawnAnimation: await loadSpriteAnimation(
              16, 'effects/explosion_1_16.png', .1, false),
          durationType: DurationType.instant),
      duration: 5,
      damage: {DamageType.fire: (50, 120)},
    ));
    super.killBullet(withEffect);
  }
}

class Laser extends Projectile with LaserProjectile {
  Laser(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      super.power}) {
    ttl = weaponAncestor.attackTickRate.parameter * 2;
  }

  @override
  ProjectileType projectileType = ProjectileType.laser;

  @override
  double size = 1.5;

  @override
  double ttl = 0;

  @override
  double baseWidth = .3;
}
