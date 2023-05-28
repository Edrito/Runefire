import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/ranged_weapon.dart';

enum ProjectileWeaponType { pistol, shotgun }

typedef BodyComponentFunction = List<BodyComponent> Function();

extension ProjectileWeaponTypeFilename on ProjectileWeaponType {
  String getFilename() {
    switch (this) {
      case ProjectileWeaponType.pistol:
        return 'pistol.png';
      case ProjectileWeaponType.shotgun:
        return 'shotgun.png';
      default:
        return '';
    }
  }
}

class Pistol extends ProjectileWeapon {
  Pistol() : super(ProjectileWeaponType.pistol);

  late CircleComponent circle;

  @override
  double damage = 5;

  @override
  int count = 1;

  @override
  double fireRate = 5;

  @override
  bool holdAndRelease = false;

  @override
  double length = 7;

  @override
  int maxAmmo = 10;

  @override
  double maxSpreadDegrees = 1;

  @override
  int pierce = 1;

  @override
  late BodyComponent<Forge2DGame> projectile;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 100;

  @override
  bool randomPath = false;

  @override
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .25;

  @override
  double weaponVariation = 0;

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

  @override
  bool isHoming = false;

  @override
  bool allowProjectileRotation = true;

  @override
  double reloadTime = 1;
}

class Shotgun extends ProjectileWeapon {
  Shotgun()
      : super(
          ProjectileWeaponType.shotgun,
        );

  @override
  int count = 7;

  @override
  double reloadTime = 1;
  @override
  double damage = 10;
  @override
  double fireRate = 2;

  @override
  bool holdAndRelease = false;

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
  int spentAmmo = 0;

  @override
  double tipPositionPercent = .40;

  @override
  double weaponVariation = .2;

  @override
  double get distanceFromPlayer => 2;

  @override
  FutureOr<void> onLoad() async {
    projectileSprite = await Sprite.load('pellet.png');
    return super.onLoad();
  }

  @override
  bool allowProjectileRotation = false;

  @override
  bool isHoming = false;
}
