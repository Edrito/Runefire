import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/enums.dart';

typedef BodyComponentFunction = List<BodyComponent> Function();

class Portal extends Weapon
    with
        ProjectileFunctionality,
        SecondaryFunctionality,
        SemiAutomatic,
        ReloadFunctionality {
  Portal.create(
    int newUpgradeLevel,
    AimFunctionality ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

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
  // TODO: implement chainingTargets
  int get chainingTargets => 5;

  @override
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  List<WeaponSpritePosition> spirtePositions = [WeaponSpritePosition.hand];

  @override
  bool allowProjectileRotation = true;

  @override
  int projectileCount = 1;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.fire: (500, 1000.0)
  };

  @override
  double baseAttackRate = 1;

  @override
  double length = 2;

  @override
  int? maxAmmo = 5;

  @override
  double maxSpreadDegrees = 270;

  @override
  int pierce = 5;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 60;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -0;

  @override
  double weaponRandomnessPercent = .2;

  @override
  double distanceFromPlayer = 0.2;

  @override
  FutureOr<void> onLoad() async {
    circle = CircleComponent(
        radius: .2, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    add(circle);
    return super.onLoad();
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;

  @override
  double reloadTime = 1;
}

class Pistol extends Weapon
    with
        FullAutomatic,
        ProjectileFunctionality,
        ReloadFunctionality,
        SecondaryFunctionality {
  Pistol.create(
    int newUpgradeLevel,
    AimFunctionality ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  bool get allowRapidClicking => true;

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  bool allowProjectileRotation = true;

  @override
  int projectileCount = 1;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (5, 10.0),
    DamageType.energy: (5, 10.0)
  };

  @override
  double baseAttackRate = 1;

  @override
  bool get isHoming => true;

  @override
  int get chainingTargets => 5;

  @override
  double length = 3;

  @override
  double maxSpreadDegrees = 40;

  @override
  int pierce = 5;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 50;

  @override
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  double tipPositionPercent = -.3;

  @override
  double weaponRandomnessPercent = .0;

  @override
  double distanceFromPlayer = .6;

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

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  int? maxAmmo = 10;

  @override
  double reloadTime = 1;
}

class Shotgun extends Weapon
    with
        ProjectileFunctionality,
        FullAutomatic,
        ReloadFunctionality,
        SecondaryFunctionality {
  Shotgun.create(
    super.newUpgradeLevel,
    super.ancestor,
  );

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

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
  double distanceFromPlayer = 0;

  @override
  bool allowProjectileRotation = false;

  @override
  int projectileCount = 4;

  @override
  List<WeaponSpritePosition> spirtePositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (10, 20.0)
  };
  @override
  double baseAttackRate = .5;

  @override
  double length = 5;

  @override
  int? maxAmmo = 5;

  @override
  double maxSpreadDegrees = 50;

  @override
  int pierce = 3;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 80;

  @override
  double reloadTime = .5;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  int get chainingTargets => 5;

  @override
  bool countIncreaseWithTime = false;
  @override
  ProjectileType? projectileType = ProjectileType.bullet;
}

class Bow extends Weapon
    with ProjectileFunctionality, SecondaryFunctionality, SemiAutomatic {
  Bow.create(
    super.newUpgradeLevel,
    super.ancestor,
  );

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  bool allowProjectileRotation = true;
  @override
  ProjectileType? projectileType = ProjectileType.arrow;
  @override
  int projectileCount = 1;

  @override
  double minDamage = 10;

  @override
  double maxDamage = 12;
  @override
  double distanceFromPlayer = .2;

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
  double baseAttackRate = .5;

  @override
  List<WeaponSpritePosition> spirtePositions = [
    WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 2;

  @override
  double maxSpreadDegrees = 40;

  @override
  int pierce = 5;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 50;

  @override
  double tipPositionPercent = 0;

  @override
  double weaponRandomnessPercent = .0;

  @override
  bool countIncreaseWithTime = false;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (50, 100.0)
  };
}

class Sword extends Weapon
    with MeleeFunctionality, SecondaryFunctionality, FullAutomatic
// ,        ReloadFunctionality
{
  Sword.create(
    int newUpgradeLevel,
    AimFunctionality ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    attackPatterns = [
      (Vector2(6, -4), 0),
      (Vector2(0, 8), 45),
      (Vector2(0, -4), 0),
      (Vector2(0, 6), 0),
      (Vector2(-6, -4), 0),
      (Vector2(0, 8), -45),
    ];
    {}

    maxAmmo = (attackPatterns.length / 2).round();

    assert(attackPatterns.length.isEven, "Must be an even number of coords");
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirtePositions.add(WeaponSpritePosition.hand);
    } else {
      spirtePositions.add(WeaponSpritePosition.back);
    }
  }

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  Future<SpriteComponent> buildSpriteComponent(
      WeaponSpritePosition position) async {
    if (position == WeaponSpritePosition.back) {
      final sprite = await Sprite.load("sword.png");

      return SpriteComponent(
        position: Vector2(.1, -.8),
        sprite: sprite,
        angle: radians(35),
        size: sprite.srcSize.scaled(length / sprite.srcSize.y) * .7,
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
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  int projectileCount = 10;

  @override
  List<WeaponSpritePosition> spirtePositions = [];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (5, 10.0)
  };
  @override
  double baseAttackRate = .2;
  @override
  bool holdAndRelease = false;

  @override
  double length = 10;

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
  double reloadTime = 1;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  bool countIncreaseWithTime = false;
  @override
  ProjectileType? projectileType;
}
