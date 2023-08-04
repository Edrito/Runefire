import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/area_effects.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/projectile_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/custom_mixins.dart';
import '../resources/functions/functions.dart';

class Bullet extends Projectile
    with StandardProjectile, BasicSpriteLifecycle, ProjectileSpriteLifecycle {
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
    applyHitAnimation(other, center);

    super.bodyContact(other);
  }

  @override
  bool isInstant = false;

  @override
  SpriteAnimation? spawnAnimation;

  @override
  SpriteAnimation? playAnimation;

  @override
  SpriteAnimation? endAnimation;

  @override
  Future<void> onLoad() async {
    switch (damageType) {
      case DamageType.physical:
        spawnAnimation = await buildSpriteSheet(
            4,
            'weapons/projectiles/bullets/physical_bullet_spawn.png',
            .02,
            false);
        playAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/physical_bullet_play.png', .02, true);
        endAnimation = await buildSpriteSheet(3,
            'weapons/projectiles/bullets/physical_bullet_end.png', .1, false);
        hitAnimation = await buildSpriteSheet(6,
            'weapons/projectiles/bullets/physical_bullet_hit.png', .02, false);
        break;

      case DamageType.energy:
        spawnAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/energy_bullet_spawn.png', .02, false);
        playAnimation = await buildSpriteSheet(
            4, 'weapons/projectiles/bullets/energy_bullet_play.png', .02, true);
        endAnimation = await buildSpriteSheet(
            3, 'weapons/projectiles/bullets/energy_bullet_end.png', .1, false);
        hitAnimation = await buildSpriteSheet(
            6, 'weapons/projectiles/bullets/energy_bullet_hit.png', .02, false);
        break;

      case DamageType.fire:
        spawnAnimation = await buildSpriteSheet(
            4, 'weapons/projectiles/bullets/fire_bullet_spawn.png', .02, false);
        playAnimation = await buildSpriteSheet(
            4, 'weapons/projectiles/bullets/fire_bullet_play.png', .02, true);
        endAnimation = await buildSpriteSheet(
            3, 'weapons/projectiles/bullets/fire_bullet_end.png', .1, false);
        hitAnimation = await buildSpriteSheet(
            6, 'weapons/projectiles/bullets/fire_bullet_hit.png', .02, false);
        break;

      case DamageType.frost:
        spawnAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/frost_bullet_spawn.png', .02, false);
        playAnimation = await buildSpriteSheet(
            4, 'weapons/projectiles/bullets/frost_bullet_play.png', .02, true);
        endAnimation = await buildSpriteSheet(
            3, 'weapons/projectiles/bullets/frost_bullet_end.png', .1, false);
        hitAnimation = await buildSpriteSheet(
            6, 'weapons/projectiles/bullets/frost_bullet_hit.png', .02, false);
        break;

      case DamageType.magic:
        spawnAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/magic_bullet_spawn.png', .02, false);
        playAnimation = await buildSpriteSheet(
            4, 'weapons/projectiles/bullets/magic_bullet_play.png', .02, true);
        endAnimation = await buildSpriteSheet(
            3, 'weapons/projectiles/bullets/magic_bullet_end.png', .1, false);
        hitAnimation = await buildSpriteSheet(
            6, 'weapons/projectiles/bullets/magic_bullet_hit.png', .02, false);
        break;

      case DamageType.psychic:
        spawnAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/psychic_bullet_spawn.png', .02, false);
        playAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/psychic_bullet_play.png', .02, true);
        endAnimation = await buildSpriteSheet(
            3, 'weapons/projectiles/bullets/psychic_bullet_end.png', .1, false);
        hitAnimation = await buildSpriteSheet(6,
            'weapons/projectiles/bullets/psychic_bullet_hit.png', .02, false);
        break;
      case DamageType.healing:
        spawnAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/healing_bullet_spawn.png', .02, false);
        playAnimation = await buildSpriteSheet(4,
            'weapons/projectiles/bullets/healing_bullet_play.png', .02, true);
        endAnimation = await buildSpriteSheet(
            3, 'weapons/projectiles/bullets/healing_bullet_end.png', .1, false);
        hitAnimation = await buildSpriteSheet(6,
            'weapons/projectiles/bullets/healing_bullet_hit.png', .02, false);
        break;
    }

    super.onLoad();
  }

  @override
  void killBullet([bool withEffect = false]) {
    body.setType(BodyType.static);
    if (withEffect) {
      killSprite();
    } else {
      removeFromParent();
    }
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
      playAnimation: await buildSpriteSheet(
          61, 'weapons/projectiles/fire_area.png', .05, true),
      size: 5,
      isInstant: true,
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
