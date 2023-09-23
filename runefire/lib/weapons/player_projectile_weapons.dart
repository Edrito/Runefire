// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:runefire/main.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class CrystalPistol extends PlayerWeapon
    with
        FullAutomatic,
        ProjectileFunctionality,
        ReloadFunctionality,
        MultiWeaponCheck {
  CrystalPistol(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.magic] = (7, 10);
    maxAttacks.baseParameter = 8;
    projectileVelocity.baseParameter = 20;
    attackTickRate.baseParameter = .3;
    maxHomingTargets.baseParameter = 1;
    pierce.baseParameter = 2;
    projectileSize = .75;

    tipOffset = Vector2(-.035, weaponSize - .1);
  }

  @override
  WeaponType weaponType = WeaponType.crystalPistol;
  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  late CircleComponent circle;

  @override
  double distanceFromPlayer = .0;

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
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.crystalPistolIdle1
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double weaponSize = 1.356;

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;
}

class Shotgun extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  Shotgun(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (5, 8);
    maxAttacks.baseParameter = 5;
    attackTickRate.baseParameter = .8;
    baseAttackCount.baseParameter = 4;
    projectileSize = 1.2;
    tipOffset = Vector2(0, 1.65);

    increaseCloseDamage.baseParameter = true;
    closeDamageIncreaseDistanceCutoff = 6;
  }

  @override
  WeaponType weaponType = WeaponType.scatterBlast;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.scatterVineIdle1
          },
          parentJoint: parentJoint,
          weapon: this,
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
  double weaponSize = 2;

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;
}

class LongRangeRifle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  LongRangeRifle(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.magic] = (50, 100);
    maxAttacks.baseParameter = 10;
    attackTickRate.baseParameter = .1;
    projectileVelocity.baseParameter = 30;
    baseAttackCount.baseParameter = 1;
    pierce.baseParameter = 0;
  }
  @override
  WeaponType weaponType = WeaponType.scryshot;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  Vector2 tipOffset = Vector2(-0.1, 2.225);

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            WeaponStatus.attack: await spriteAnimations.scryshotAttack1,
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.scryshotIdle1,
          },
          flashSize: 2.0,
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  update(double dt) {
    this;
    super.update(dt);
  }

  @override
  double distanceFromPlayer = -.5;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = 3.0;

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class ArcaneBlaster extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  ArcaneBlaster(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (2, 4);
    maxAttacks.baseParameter = 15;
    attackTickRate.baseParameter = .2;
    baseAttackCount.baseParameter = 1;
    weaponRandomnessPercent.baseParameter = .025;
    projectileVelocity.baseParameter = 20;
    projectileSize = .5;
    tipOffset = Vector2(0, weaponSize);
  }
  @override
  WeaponType weaponType = WeaponType.arcaneBlaster;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.blackMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.arcaneBlasterIdle1,
          },
          parentJoint: parentJoint,
          weapon: this,
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
  double weaponSize = 2;
  @override
  ProjectileType? projectileType = ProjectileType.blackSpriteBullet;
}

class LaserRifle extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  LaserRifle(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (1, 3);
    baseDamage.damageBase[DamageType.fire] = (1, 3);
    baseDamage.damageBase[DamageType.frost] = (1, 3);
    baseDamage.damageBase[DamageType.psychic] = (1, 3);
    baseDamage.damageBase[DamageType.magic] = (1, 3);
    // baseDamage.damageBase[DamageType.healing] = (1, 3);
    maxAttacks.baseParameter = 4;
    attackTickRate.baseParameter = .4;
    weaponRandomnessPercent.baseParameter = .04;
    chainingTargets.baseParameter = 1;
    baseAttackCount.baseParameter = 5;
  }
  @override
  WeaponType weaponType = WeaponType.prismaticBeam;

  @override
  double get attackRateDelay => attackTickRate.parameter / 4;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  // TODO: implement tipOffset
  Vector2 get tipOffset => Vector2(0, 1.42);

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.prismaticBeamIdle1
          },
          parentJoint: parentJoint,
          weapon: this,
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
  double weaponSize = 2;

  @override
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}

class RocketLauncher extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  RocketLauncher(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.fire] = (40, 80);
    maxAttacks.baseParameter = 1;
    attackTickRate.baseParameter = 2;
    tipOffset = Vector2(0, weaponSize);
  }
  @override
  WeaponType weaponType = WeaponType.eldritchRunner;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.eldritchRunnerIdle1
          },
          parentJoint: parentJoint,
          weapon: this,
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
  double weaponSize = 1.7;

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;

  @override
  double tipPositionPercent = -.2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class Railgun extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  Railgun(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (30, 40);
    maxAttacks.baseParameter = 2;
    attackTickRate.baseParameter = 2;
    tipOffset = Vector2(0, weaponSize);
  }
  @override
  WeaponType weaponType = WeaponType.railspire;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.fireMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.railspireIdle1
          },
          parentJoint: parentJoint,
          weapon: this,
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
  double weaponSize = 3;
}
