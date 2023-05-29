import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/projectiles.dart';
import 'package:game_app/game/ranged_weapon.dart';

enum ProjectileWeaponType { pistol, shotgun, bow }

typedef BodyComponentFunction = List<BodyComponent> Function();

extension ProjectileWeaponTypeFilename on ProjectileWeaponType {
  String getFilename() {
    switch (this) {
      case ProjectileWeaponType.pistol:
        return 'pistol.png';
      case ProjectileWeaponType.shotgun:
        return 'shotgun.png';
      case ProjectileWeaponType.bow:
        return 'bow.png';
      default:
        return '';
    }
  }
}

class Pistol extends ProjectileWeapon {
  Pistol() : super(ProjectileWeaponType.pistol);

  late CircleComponent circle;

  @override
  bool allowProjectileRotation = true;

  @override
  int count = 1;

  @override
  double damage = 5;

  @override
  double fireRate = 10;

  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = false;

  @override
  double length = 7;

  @override
  int maxAmmo = 12;

  @override
  double maxSpreadDegrees = 270;

  @override
  int pierce = 0;

  @override
  late BodyComponent<Forge2DGame> projectile;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 80;

  @override
  bool randomPath = false;
  @override
  ProjectileType projectileType = ProjectileType.bullet;
  @override
  double reloadTime = 0;

  @override
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .25;

  @override
  double weaponRandomnessPercent = .005;

  @override
  double get distanceFromPlayer => 2;

  @override
  FutureOr<void> onLoad() async {
    projectileSprite = await Sprite.load('bullet.png');
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

class Shotgun extends ProjectileWeapon {
  Shotgun()
      : super(
          ProjectileWeaponType.shotgun,
        );

  @override
  bool allowProjectileRotation = false;

  @override
  int count = 7;

  @override
  double damage = 10;

  @override
  double fireRate = 2;

  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = true;

  @override
  double length = 12;

  @override
  int maxAmmo = 4;

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
  bool randomPath = false;

  @override
  double reloadTime = 1;

  @override
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .40;

  @override
  double weaponRandomnessPercent = .05;

  @override
  double get distanceFromPlayer => 2;

  @override
  FutureOr<void> onLoad() async {
    projectileSprite = await Sprite.load('pellet.png');
    return super.onLoad();
  }

  @override
  ProjectileType projectileType = ProjectileType.pellet;
}

class Bow extends ProjectileWeapon {
  Bow()
      : super(
          ProjectileWeaponType.bow,
        );

  @override
  bool allowProjectileRotation = true;
  @override
  ProjectileType projectileType = ProjectileType.arrow;
  @override
  int count = 1;

  @override
  double damage = 20;

  @override
  double fireRate = 5;

  @override
  bool holdAndRelease = true;

  @override
  bool isHoming = true;

  @override
  double length = 7;

  @override
  int maxAmmo = 1;

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
  bool randomPath = false;

  @override
  double reloadTime = 0;

  @override
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .5;

  @override
  double weaponRandomnessPercent = .0;

  @override
  double get distanceFromPlayer => 2;

  @override
  FutureOr<void> onLoad() async {
    projectileSprite = await Sprite.load('arrow.png');
    return super.onLoad();
  }
}
