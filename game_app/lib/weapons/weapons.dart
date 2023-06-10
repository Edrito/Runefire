import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/enums.dart';

typedef BodyComponentFunction = List<BodyComponent> Function();

class Portal extends Weapon with ProjectileFunctionality {
  Portal.create(
    this.upgradeLevel,
    super.ancestor,
  );
  @override
  int upgradeLevel;
  @override
  List<AttackType> attackTypes = [
    AttackType.projectile,
  ];

  @override
  Future<SpriteComponent> buildSpriteComponent(
      WeaponSpritePosition position) async {
    final sprite = await Sprite.load(
      "portal.png",
    );

    return SpriteComponent(
      sprite: sprite,
      size: sprite.srcSize.scaled(length / sprite.srcSize.y),
      anchor: Anchor.topCenter,
    );
  }

  @override
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  List<WeaponSpritePosition> spirtePositions = [WeaponSpritePosition.hand];

  @override
  bool allowProjectileRotation = true;

  @override
  int count = 1;

  @override
  double minDamage = 20;

  @override
  double maxDamage = 26;

  @override
  double baseFireRate = 2;

  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = false;

  @override
  double length = 7;

  @override
  int? maxAmmo;

  @override
  double maxSpreadDegrees = 270;

  @override
  int pierce = 0;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 60;

  @override
  int chainingTargets = 0;
  @override
  ProjectileType? projectileType = ProjectileType.fireball;

  @override
  double reloadTime = 1;

  @override
  double tipPositionPercent = -0;

  @override
  double weaponRandomnessPercent = .2;

  @override
  double distanceFromPlayer = 2;

  @override
  FutureOr<void> onLoad() async {
    circle = CircleComponent(
        radius: .2, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    add(circle);
    return super.onLoad();
  }
}

class Pistol extends Weapon with ProjectileFunctionality {
  Pistol.create(
    this.upgradeLevel,
    super.ancestor,
  );

  @override
  int upgradeLevel;

  @override
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  bool allowProjectileRotation = true;

  @override
  int count = 26;

  @override
  double minDamage = 10;

  @override
  double maxDamage = 12;

  @override
  double baseFireRate = .1;
  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = false;

  @override
  double length = 7;

  @override
  double maxSpreadDegrees = 180;

  @override
  int pierce = 1;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 120;
  @override
  int chainingTargets = 0;
  @override
  ProjectileType? projectileType = ProjectileType.bullet;
  @override
  double reloadTime = 1;

  @override
  double tipPositionPercent = -.3;

  @override
  double weaponRandomnessPercent = .005;

  @override
  double distanceFromPlayer = 10;

  @override
  FutureOr<void> onLoad() async {
    circle = CircleComponent(
        radius: .2, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    add(circle);
    return super.onLoad();
  }

  @override
  List<WeaponSpritePosition> spirtePositions = [WeaponSpritePosition.hand];

  @override
  Future<SpriteComponent> buildSpriteComponent(
      WeaponSpritePosition position) async {
    final sprite = await Sprite.load("pistol.png");

    return SpriteComponent(
      sprite: sprite,
      size: sprite.srcSize.scaled(length / sprite.srcSize.y),
      anchor: Anchor.topCenter,
    );
  }
}

class Shotgun extends Weapon with ProjectileFunctionality {
  Shotgun.create(
    this.upgradeLevel,
    super.ancestor,
  );

  @override
  int upgradeLevel;

  @override
  Future<SpriteComponent> buildSpriteComponent(
      WeaponSpritePosition position) async {
    final sprite = await Sprite.load(
      "shotgun.png",
    );

    return SpriteComponent(
      sprite: sprite,
      size: sprite.srcSize.scaled(length / sprite.srcSize.y),
      anchor: Anchor.topCenter,
    );
  }

  @override
  double distanceFromPlayer = -1;
  @override
  int chainingTargets = 0;
  @override
  bool allowProjectileRotation = false;

  @override
  int count = 5;

  @override
  List<WeaponSpritePosition> spirtePositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double minDamage = 10;

  @override
  double maxDamage = 40;

  @override
  double baseFireRate = .5;

  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = false;

  @override
  double length = 20;

  @override
  int? maxAmmo = 6;

  @override
  double maxSpreadDegrees = 50;

  @override
  int pierce = 5;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 80;

  @override
  double reloadTime = 1;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  bool countIncreaseWithTime = false;
  @override
  ProjectileType? projectileType = ProjectileType.pellet;
}

class Bow extends Weapon with ProjectileFunctionality {
  Bow.create(
    this.upgradeLevel,
    super.ancestor,
  );
  @override
  int upgradeLevel;
  @override
  bool allowProjectileRotation = true;
  @override
  ProjectileType? projectileType = ProjectileType.arrow;
  @override
  int count = 1;
  @override
  int chainingTargets = 0;
  @override
  double minDamage = 10;

  @override
  double maxDamage = 12;
  @override
  double distanceFromPlayer = 2;

  @override
  Future<SpriteComponent> buildSpriteComponent(
      WeaponSpritePosition position) async {
    if (position == WeaponSpritePosition.back) {
      final sprite = await Sprite.load("portal.png");

      return SpriteComponent(
        position: Vector2(0, -5),
        sprite: sprite,
        size: sprite.srcSize.scaled(length / sprite.srcSize.y),
        anchor: Anchor.topCenter,
      );
    } else {}
    final sprite = await Sprite.load(
      "bow.png",
    );

    return SpriteComponent(
      sprite: sprite,
      size: sprite.srcSize.scaled(length / sprite.srcSize.y),
      anchor: Anchor.topCenter,
    );
  }

  @override
  double baseFireRate = .5;

  @override
  List<WeaponSpritePosition> spirtePositions = [
    WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];
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
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 50;

  @override
  double reloadTime = 0;

  @override
  double tipPositionPercent = 0;

  @override
  double weaponRandomnessPercent = .0;

  @override
  bool countIncreaseWithTime = false;

  @override
  List<AttackType> attackTypes = [
    AttackType.projectile,
  ];
}

class Sword extends Weapon with MeleeFunctionality {
  @override
  int upgradeLevel;
  Sword.create(
    this.upgradeLevel,
    super.ancestor,
  ) {
    attackPatterns = [
      (Vector2(12, -5), 0),
      (Vector2(0, 12), 45),
      (Vector2(0, -5), 0),
      (Vector2(0, 12), 0),
      (Vector2(-12, -5), 0),
      (Vector2(0, 12), -45),
    ];

    assert(attackPatterns.length.isEven, "Must be an even number of coords");
  }

  @override
  Future<SpriteComponent> buildSpriteComponent(
      WeaponSpritePosition position) async {
    if (position == WeaponSpritePosition.back) {
      final sprite = await Sprite.load("sword.png");

      return SpriteComponent(
        position: Vector2(1, -3),
        sprite: sprite,
        angle: radians(35),
        size: sprite.srcSize.scaled(length / sprite.srcSize.y) * .8,
        anchor: Anchor.center,
      );
    } else {
      final sprite = await Sprite.load("sword.png");
      final test = SpriteComponent(
        sprite: sprite,
        size: sprite.srcSize.scaled(length / sprite.srcSize.y),
        anchor: Anchor.topCenter,
      );

      return test;
    }
  }

  @override
  List<AttackType> attackTypes = [
    AttackType.melee,
  ];
  @override
  bool get removeBackSpriteOnAttack => true;

  @override
  double distanceFromPlayer = 2;
  @override
  int chainingTargets = 0;
  @override
  bool allowProjectileRotation = false;

  @override
  int count = 10;

  @override
  List<WeaponSpritePosition> spirtePositions = [WeaponSpritePosition.back];

  @override
  double minDamage = 20;

  @override
  double maxDamage = 40;
  @override
  double baseFireRate = .1;
  @override
  bool holdAndRelease = false;

  @override
  bool isHoming = false;

  @override
  double length = 15;

  @override
  int? maxAmmo;

  @override
  double maxSpreadDegrees = 270;

  @override
  int pierce = 100;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 0;

  @override
  double reloadTime = 0;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  bool countIncreaseWithTime = false;
  @override
  ProjectileType? projectileType;
}
