import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/projectile_mixin.dart';

import '../resources/enums.dart';

class Bullet extends Projectile with SingularProjectile {
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

  @override
  bool isContinuous = false;
}

class Laser extends Projectile with LaserProjectile {
  Laser(
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

  @override
  bool isContinuous = false;
}
