import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/projectile_mixin.dart';

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
  double size = 1.5;

  @override
  double ttl = 1.0;
}

class Laser extends Projectile with LaserProjectile {
  Laser(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      super.power});

  @override
  ProjectileType projectileType = ProjectileType.laser;

  @override
  double size = 1.5;

  @override
  double ttl = 1;

  @override
  bool isContinuous = false;

  @override
  double baseWidth = 1.5;
}
