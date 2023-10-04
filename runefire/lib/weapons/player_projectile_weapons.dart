// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
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
  double distanceFromPlayer = .5;

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
  double weaponScale = 1;
  @override
  late Vector2 pngSize =
      ImagesAssetsWeapons.pngSizes[ImagesAssetsWeapons.pistol]!;
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
    attackCountIncrease.baseParameter = 4;
    projectileSize = 1.2;

    increaseCloseDamage.baseParameter = true;
    closeDamageIncreaseDistanceCutoff = 6;
    attackSplitFunctions.clear();
    attackSplitFunctions[AttackSpreadType.regular] = (one, two) {
      return regularAttackSpread(one, two, 60, true);
    };
  }

  @override
  WeaponType weaponType = WeaponType.scatterBlast;

  @override
  Vector2 get tipOffset => Vector2(.5, 1);

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
  double distanceFromPlayer = .25;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double weaponScale = 1;
  @override
  late Vector2 pngSize =
      ImagesAssetsWeapons.pngSizes[ImagesAssetsWeapons.scatterVine]!;

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
    maxAttacks.baseParameter = 30;
    attackTickRate.baseParameter = .05;
    projectileVelocity.baseParameter = 30;
    attackCountIncrease.baseParameter = 20;
    pierce.baseParameter = 10;
  }
  @override
  WeaponType weaponType = WeaponType.scryshot;

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
  double distanceFromPlayer = .45;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];
  @override
  double weaponScale = 1;
  @override
  late Vector2 pngSize =
      ImagesAssetsWeapons.pngSizes[ImagesAssetsWeapons.longRifle]!;

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class ArcaneBlaster extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        FullAutomatic,
        SemiAutomatic,
        ChargeEffect,
        ChargeFullAutomatic {
  ArcaneBlaster(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (2, 4);
    maxAttacks.baseParameter = 15;
    attackTickRate.baseParameter = .2;
    attackCountIncrease.baseParameter = 1;
    weaponRandomnessPercent.baseParameter = .025;
    projectileVelocity.baseParameter = 20;
    projectileSize = .5;
    customChargeDuration = 1.5;
  }
  @override
  WeaponType weaponType = WeaponType.arcaneBlaster;

  @override
  double get attackRateDelay => 0;

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
  double weaponScale = 1;
  @override
  late Vector2 pngSize =
      ImagesAssetsWeapons.pngSizes[ImagesAssetsWeapons.arcaneBlaster]!;
  @override
  ProjectileType? projectileType = ProjectileType.blackSpriteBullet;
}

class LaserRifle extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect,
        MuzzleGlow {
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
    attackCountIncrease.baseParameter = 4;

    projectileVelocity.baseParameter = 7;

    attackOnRelease = false;
    attackOnChargeComplete = true;
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
  double weaponScale = 1;
  @override
  late Vector2 pngSize =
      ImagesAssetsWeapons.pngSizes[ImagesAssetsWeapons.prismaticBeam]!;

  @override
  ProjectileType? projectileType = ProjectileType.followLaser;

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
  double weaponScale = 1;
  @override
  late Vector2 pngSize =
      ImagesAssetsWeapons.pngSizes[ImagesAssetsWeapons.eldritchRunner]!;

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class Railspire extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  Railspire(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (30, 40);
    maxAttacks.baseParameter = 2;
    attackTickRate.baseParameter = 2;
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
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;
  @override
  double weaponScale = 1;
  @override
  late Vector2 pngSize =
      ImagesAssetsWeapons.pngSizes[ImagesAssetsWeapons.railspire]!;
}
