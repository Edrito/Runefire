import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/projectiles.dart';
import 'package:game_app/game/weapon_class.dart';

enum WeaponType { melee, point, projectile }

typedef BodyComponentFunction = List<BodyComponent> Function();

// extension ProjectileWeaponTypeFilename on WeaponType {
//   String getFilename() {
//     switch (this) {
//       case ProjectileWeaponType.pistol:
//         return 'pistol.png';
//       case ProjectileWeaponType.shotgun:
//         return 'shotgun.png';
//       case ProjectileWeaponType.bow:
//         return 'bow.png';
//       default:
//         return '';
//     }
//   }
// }

class Pistol extends Weapon {
  Pistol()
      : super([
          WeaponType.projectile,
        ], "pistol.png");

  @override
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  bool allowProjectileRotation = true;

  @override
  int count = 1;

  @override
  double damage = 5;

  @override
  double fireRate = .1;

  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = false;

  @override
  double length = 7;

  @override
  int? maxAmmo = 8;

  @override
  double maxSpreadDegrees = 90;

  @override
  int pierce = 0;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 120;

  @override
  bool isChaining = false;
  @override
  ProjectileType? projectileType = ProjectileType.bullet;
  @override
  double reloadTime = 1;

  @override
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .25;

  @override
  double weaponRandomnessPercent = .005;

  @override
  double distanceFromPlayer = 2;

  @override
  FutureOr<void> onLoad() async {
    circle = CircleComponent(
        radius: .2, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    add(circle);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    circle.position = tipOfWeapon.position;
    super.update(dt);
  }
}

class Shotgun extends Weapon {
  Shotgun()
      : super([
          WeaponType.projectile,
        ], "shotgun.png");

  @override
  double distanceFromPlayer = 2;
  @override
  bool isChaining = false;
  @override
  bool allowProjectileRotation = false;

  @override
  int count = 7;

  @override
  double damage = 10;

  @override
  double fireRate = 1;

  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = true;

  @override
  double length = 12;

  @override
  int? maxAmmo = 4;

  @override
  double maxSpreadDegrees = 40;

  @override
  int pierce = 5;

  @override
  late BodyComponent<Forge2DGame> projectile;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 80;

  @override
  double reloadTime = 1;

  @override
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .40;

  @override
  double weaponRandomnessPercent = .05;

  @override
  bool countIncreaseWithTime = false;
  @override
  ProjectileType? projectileType = ProjectileType.pellet;
}

class Bow extends Weapon {
  Bow()
      : super([
          WeaponType.projectile,
        ], "bow.png");

  @override
  bool allowProjectileRotation = true;
  @override
  ProjectileType? projectileType = ProjectileType.arrow;
  @override
  int count = 1;
  @override
  bool isChaining = false;
  @override
  double damage = 20;
  @override
  double distanceFromPlayer = 2;

  @override
  double fireRate = 1;

  @override
  bool holdAndRelease = true;

  @override
  bool isHoming = false;

  @override
  double length = 7;

  @override
  int? maxAmmo = 1;

  @override
  double maxSpreadDegrees = 40;

  @override
  int pierce = 5;

  @override
  late BodyComponent<Forge2DGame> projectile;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 50;

  @override
  double reloadTime = 0;

  @override
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .5;

  @override
  double weaponRandomnessPercent = .0;

  @override
  bool countIncreaseWithTime = false;
}
