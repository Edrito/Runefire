import 'dart:async';

import 'package:flame/components.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class Pistol extends PlayerWeapon
    with
        FullAutomatic,
        ProjectileFunctionality,
        ReloadFunctionality,
        MultiWeaponCheck {
  Pistol.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (7, 10);
    maxAttacks.baseParameter = 8;
    attackTickRate.baseParameter = .3;
  }

  @override
  WeaponType weaponType = WeaponType.pistol;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  late CircleComponent circle;

  @override
  double distanceFromPlayer = .2;

  @override
  FutureOr<void> onLoad() async {
    // circle = CircleComponent(
    //     radius: .2, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    // add(circle);
    return super.onLoad();
  }

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand
  ];

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }
  }

  @override
  double length = .7;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.2;
}

class Shotgun extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  Shotgun.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (5, 8);
    maxAttacks.baseParameter = 4;
    attackTickRate.baseParameter = .8;
    baseAttackCount.baseParameter = 4;
  }
  @override
  WeaponType weaponType = WeaponType.shotgun;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          parentJoint: parentJoint,
          idleAnimation:
              await buildSpriteSheet(1, weaponType.flameImage, 1, true),
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 1.2;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.2;
}

class LongRangeRifle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  LongRangeRifle.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (10, 30);
    maxAttacks.baseParameter = 4;
    attackTickRate.baseParameter = .8;
    pierce.baseParameter = 5;
  }
  @override
  WeaponType weaponType = WeaponType.longRangeRifle;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          parentJoint: parentJoint,
          idleAnimation:
              await buildSpriteSheet(1, weaponType.flameImage, 1, true),
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 1.2;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class AssaultRifle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  AssaultRifle.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (1, 3);
    maxAttacks.baseParameter = 26;
    attackTickRate.baseParameter = .1;
  }
  @override
  WeaponType weaponType = WeaponType.assaultRifle;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          parentJoint: parentJoint,
          idleAnimation:
              await buildSpriteSheet(1, weaponType.flameImage, 1, true),
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 1.4;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.2;
}

class LaserRifle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  LaserRifle.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (5, 12);
    maxAttacks.baseParameter = 12;
    attackTickRate.baseParameter = .4;
    waitForAttackRate = false;
  }
  @override
  WeaponType weaponType = WeaponType.laserRifle;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          parentJoint: parentJoint,
          idleAnimation:
              await buildSpriteSheet(1, weaponType.flameImage, 1, true),
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 1.4;

  @override
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  double tipPositionPercent = -.2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}

class RocketLauncher extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  RocketLauncher.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.fire] = (40, 80);
    maxAttacks.baseParameter = 1;
    attackTickRate.baseParameter = 2;
  }
  @override
  WeaponType weaponType = WeaponType.rocketLauncher;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          parentJoint: parentJoint,
          idleAnimation:
              await buildSpriteSheet(1, weaponType.flameImage, 1, true),
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 1.7;

  @override
  ProjectileType? projectileType = ProjectileType.fireball;

  @override
  double tipPositionPercent = -.2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class Railgun extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  Railgun.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (30, 40);
    maxAttacks.baseParameter = 2;
    attackTickRate.baseParameter = 2;
  }
  @override
  WeaponType weaponType = WeaponType.railgun;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          parentJoint: parentJoint,
          idleAnimation:
              await buildSpriteSheet(1, weaponType.flameImage, 1, true),
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double tipPositionPercent = -.02;

  @override
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;

  @override
  double length = 3;
}
