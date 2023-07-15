import 'package:game_app/resources/area_effects.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/projectile_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/enums.dart';

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
  double size = .15;

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
  void killBullet([bool withEffect = false]) {
    weaponAncestor.entityAncestor?.gameEnviroment.physicsComponent
        .add(AreaEffect(
      sourceEntity: weaponAncestor.entityAncestor!,
      position: center,
      radius: 5,
      isInstant: true,
      duration: 5,
      onTick: (entity, areaId) {
        if (entity is HealthFunctionality) {
          entity.hitCheck(areaId, [
            DamageInstance(
                damageBase: .1, damageType: DamageType.fire, source: entity)
          ]);
        }
      },
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
