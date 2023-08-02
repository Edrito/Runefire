import 'package:game_app/resources/area_effects.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/projectile_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/functions.dart';

class Bullet extends Projectile with StandardProjectile {
  Bullet(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      super.power});

  @override
  double embedIntoEnemyChance = .8;

  @override
  ProjectileType projectileType = ProjectileType.bullet;

  @override
  double size = .5;

  @override
  double ttl = 2.0;
}

class Fireball extends Projectile with StandardProjectile {
  Fireball(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      super.power});

  @override
  double embedIntoEnemyChance = 0;

  @override
  ProjectileType projectileType = ProjectileType.fireball;

  @override
  double size = 1;

  @override
  double ttl = 2.0;

  @override
  void killBullet([bool withEffect = false]) async {
    weaponAncestor.entityAncestor?.gameEnviroment.physicsComponent
        .add(AreaEffect(
      sourceEntity: weaponAncestor.entityAncestor!,
      position: center,
      playAnimation: await buildSpriteSheet(
          61, 'weapons/projectiles/fire_area.png', .05, true),
      radius: 2,
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
