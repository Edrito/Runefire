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
    projectileVelocity.baseParameter = 30;
    attackTickRate.baseParameter = .3;
    pierce.baseParameter = 2;
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
  double distanceFromPlayer = .3;

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
        return WeaponSpriteAnimation(Vector2.all(0), Vector2(-.1, 1.6),
            await buildSpriteSheet(1, 'weapons/pistol.png', 1, true),
            parentJoint: parentJoint,
            weapon: this,
            attackAnimation:
                await buildSpriteSheet(1, 'weapons/pistol.png', .1, false),
            muzzleFlash: await buildSpriteSheet(
                1, 'weapons/muzzle_flash.png', .2, false));
    }
  }

  @override
  double length = 1.356;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;
}

class Shotgun extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  Shotgun.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (5, 8);
    maxAttacks.baseParameter = 5;
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
        return WeaponSpriteAnimation(Vector2.all(1), Vector2.all(1),
            await buildSpriteSheet(6, 'weapons/pistol_idle.png', 1, true),
            parentJoint: parentJoint,
            weapon: this,
            attackAnimation: await buildSpriteSheet(
                4, 'weapons/pistol_attack.png', .1, false),
            muzzleFlash: await buildSpriteSheet(
                1, 'weapons/muzzle_flash.png', .2, false));
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 2;

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
    baseDamage.damageBase[DamageType.magic] = (50, 100);
    maxAttacks.baseParameter = 10;
    attackTickRate.baseParameter = .1;
    projectileVelocity.baseParameter = 70;
    baseAttackCount.baseParameter = 1;
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
          Vector2.all(0),
          Vector2(-.175, 2.65),
          await buildSpriteSheet(19, 'weapons/long_rifle_idle.png', .2, true),
          parentJoint: parentJoint,
          weapon: this,
          attackAnimation: await buildSpriteSheet(
              7, 'weapons/long_rifle_attack.png', .02, false),
        );
    }
  }

  @override
  update(double dt) {
    this;
    super.update(dt);
  }

  @override
  double distanceFromPlayer = .2;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 3.5;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

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
    maxAttacks.baseParameter = 22;
    attackTickRate.baseParameter = .1;
    // baseAttackCount.baseParameter = 10;
    weaponRandomnessPercent.baseParameter = .025;
    projectileVelocity.baseParameter = 40;
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
        return WeaponSpriteAnimation(Vector2.all(1), Vector2.all(1),
            await buildSpriteSheet(6, 'weapons/pistol_idle.png', 1, true),
            parentJoint: parentJoint,
            weapon: this,
            attackAnimation: await buildSpriteSheet(
                4, 'weapons/pistol_attack.png', .1, false),
            muzzleFlash: await buildSpriteSheet(
                1, 'weapons/muzzle_flash.png', .2, false));
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
  double tipPositionPercent = -.07;
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
    weaponRandomnessPercent.baseParameter = .04;
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
        return WeaponSpriteAnimation(Vector2.all(1), Vector2.all(1),
            await buildSpriteSheet(6, 'weapons/pistol_idle.png', 1, true),
            parentJoint: parentJoint,
            weapon: this,
            attackAnimation: await buildSpriteSheet(
                4, 'weapons/pistol_attack.png', .1, false),
            muzzleFlash: await buildSpriteSheet(
                1, 'weapons/muzzle_flash.png', .2, false));
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
  double tipPositionPercent = -.0;

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
        return WeaponSpriteAnimation(Vector2.all(1), Vector2.all(1),
            await buildSpriteSheet(6, 'weapons/pistol_idle.png', 1, true),
            parentJoint: parentJoint,
            weapon: this,
            attackAnimation: await buildSpriteSheet(
                4, 'weapons/pistol_attack.png', .1, false),
            muzzleFlash: await buildSpriteSheet(
                1, 'weapons/muzzle_flash.png', .2, false));
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
        return WeaponSpriteAnimation(Vector2.all(1), Vector2.all(1),
            await buildSpriteSheet(6, 'weapons/pistol_idle.png', 1, true),
            parentJoint: parentJoint,
            weapon: this,
            attackAnimation: await buildSpriteSheet(
                4, 'weapons/pistol_attack.png', .1, false),
            muzzleFlash: await buildSpriteSheet(
                1, 'weapons/muzzle_flash.png', .2, false));
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
