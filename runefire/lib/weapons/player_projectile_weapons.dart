// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/enums.dart';

class CrystalPistol extends PlayerWeapon
    with
        FullAutomatic,
        ProjectileFunctionality,
        ReloadFunctionality,
        MultiWeaponCheck {
  CrystalPistol(
    super.newUpgradeLevel,
    super.ancestor,
  );

  @override
  WeaponType weaponType = WeaponType.crystalPistol;

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.magic] = (
      increasePercentOfBase(7.0, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(10.0, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
    );
    maxAttacks.baseParameter =
        increasePercentOfBase(8, customUpgradeFactor: 1 / 8, includeBase: true)
            .round();
    projectileVelocity.baseParameter =
        increasePercentOfBase(20.0, customUpgradeFactor: .1, includeBase: true)
            .toDouble();
    attackTickRate.baseParameter =
        increasePercentOfBase(.3, customUpgradeFactor: -.05, includeBase: true)
            .toDouble();
    pierce.baseParameter = increasePercentOfBase(
      2,
      customUpgradeFactor: .5 / 2,
      includeBase: true,
    ).round();
    projectileRelativeSize.baseParameter = .75;

    super.mapUpgrade();
  }

  late CircleComponent circle;

  @override
  double distanceFromPlayer = .5;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.crystalPistolIdle1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .75);

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;
}

class Shotgun extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  Shotgun(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    increaseCloseDamage.baseParameter = true;
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.physical] = (
      increasePercentOfBase(2.0, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(4.5, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
    );
    attackCountIncrease.baseParameter = 4 + (isMaxLevel ? 1 : 0);
    maxAttacks.baseParameter =
        increasePercentOfBase(4, customUpgradeFactor: 1 / 8, includeBase: true)
            .round();
    projectileVelocity.baseParameter =
        increasePercentOfBase(20.0, customUpgradeFactor: .1, includeBase: true)
            .toDouble();
    attackTickRate.baseParameter =
        increasePercentOfBase(.8, customUpgradeFactor: -.05, includeBase: true)
            .toDouble();
    pierce.baseParameter = increasePercentOfBase(
      1,
      customUpgradeFactor: 1 / 2,
      includeBase: true,
    ).round();
    projectileRelativeSize.baseParameter = 1.2;

    closeDamageIncreaseAmount.baseParameter =
        increasePercentOfBase(1.5, customUpgradeFactor: .1, includeBase: true)
            .toDouble();

    attackSpreadPatterns.clear();

    attackSpreadPatterns.add((one, two) {
      return regularAttackSpread(one, two, 60, true);
    });

    closeDamageIncreaseDistanceCutoff =
        increasePercentOfBase(5.5, customUpgradeFactor: .1, includeBase: true)
            .toDouble();

    super.mapUpgrade();
  }

  @override
  Set<AttackSplitFunction> attackSpreadPatterns = {
    (double angle, int attackCount) => [angle],
  };

  @override
  WeaponType weaponType = WeaponType.scatterBlast;

  // @override
  // Vector2 get tipOffset => Vector2(.5, 1);

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.scatterVineIdle1,
            'muzzle_flash': await spriteAnimations.blackMuzzleFlash1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = -1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  ProjectileType? projectileType = ProjectileType.spriteBullet;
}

class Scryshot extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  Scryshot(
    super.newUpgradeLevel,
    super.ancestor,
  );
  @override
  WeaponType weaponType = WeaponType.scryshot;

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.magic] = (
      increasePercentOfBase(
        17.5,
        includeBase: true,
      ).toDouble(),
      increasePercentOfBase(
        35.0,
        includeBase: true,
      ).toDouble()
    );
    increaseFarDamage.baseParameter = true;

    maxAttacks.baseParameter = increasePercentOfBase(
      3,
      includeBase: true,
      customUpgradeFactor: .35 / 3,
    ).round();

    attackTickRate.baseParameter = 1;
    projectileVelocity.baseParameter = 30;
    pierce.baseParameter = increasePercentOfBase(
      3,
      includeBase: true,
      customUpgradeFactor: (2 / 5) / 3,
    ).round();
    super.mapUpgrade();
  }

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            WeaponStatus.attack: await spriteAnimations.scryshotAttack1,
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.scryshotIdle1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = .45;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];
  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

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
    super.newUpgradeLevel,
    super.ancestor,
  );
  @override
  WeaponType weaponType = WeaponType.arcaneBlaster;

  @override
  double get attackRateDelay => 0;

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.physical] = (
      increasePercentOfBase(
        1,
        includeBase: true,
      ).toDouble(),
      increasePercentOfBase(
        3,
        includeBase: true,
      ).toDouble()
    );
    maxAttacks.baseParameter = increasePercentOfBase(
      22,
      includeBase: true,
      customUpgradeFactor: 2 / 22,
    ).round();

    attackTickRate.baseParameter = increasePercentOfBase(
      .15,
      includeBase: true,
      customUpgradeFactor: -.05,
    ).toDouble();

    weaponRandomnessPercent.baseParameter = .025;
    projectileVelocity.baseParameter = 20;
    projectileRelativeSize.baseParameter = .5;
    super.mapUpgrade();
  }

  @override
  double get customChargeDuration => attackTickRate.parameter * 5;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .5);

  @override
  ProjectileType? projectileType = ProjectileType.blackSpriteBullet;
}

class PrismaticBeam extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect,
        MuzzleGlow {
  PrismaticBeam(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    attackOnRelease = false;
    attackOnChargeComplete = true;
  }
  @override
  WeaponType weaponType = WeaponType.prismaticBeam;

  @override
  double get attackRateDelay => attackTickRate.parameter / 4;

  @override
  void mapUpgrade() {
    if (upgradeLevel == 0) {
      baseDamage.damageBase[DamageType.energy] = (1, 2);
    }
    if (upgradeLevel == 1) {
      baseDamage.damageBase[DamageType.fire] = (1, 2);
    }
    if (upgradeLevel == 2) {
      baseDamage.damageBase[DamageType.frost] = (1, 2);
    }
    if (upgradeLevel == 3) {
      baseDamage.damageBase[DamageType.psychic] = (1, 2);
    }
    if (upgradeLevel == 4) {
      baseDamage.damageBase[DamageType.magic] = (1, 2);
    }

    maxAttacks.baseParameter =
        increasePercentOfBase(10, customUpgradeFactor: 1 / 5, includeBase: true)
            .round();
    attackTickRate.baseParameter = .25;
    weaponRandomnessPercent.baseParameter = .04;
    chainingTargets.baseParameter = 1;
    attackCountIncrease.baseParameter = 1 + upgradeLevel;

    projectileVelocity.baseParameter = 7;
    projectileRelativeSize.baseParameter = .1;
    super.mapUpgrade();
  }

  @override
  double? get customChargeDuration => attackTickRate.parameter * 5;

  @override
  Vector2 get tipOffset => Vector2(0, 1.42);

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.prismaticBeamIdle1,
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
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  ProjectileType? projectileType = ProjectileType.followLaser;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}

class EldritchRunner extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  EldritchRunner(
    super.newUpgradeLevel,
    super.ancestor,
  );

  @override
  void onRemove() {
    onProjectileDeath.remove(createExplosion);
    super.onRemove();
  }

  void createExplosion(Projectile projectile) {
    final area = AreaEffect(
      position: projectile.position,
      sourceEntity: entityAncestor!,
      radius:
          increasePercentOfBase(2.5, customUpgradeFactor: .1, includeBase: true)
              .toDouble(),
      damage: {
        ...baseDamage.damageBase
            .map((key, value) => MapEntry(key, (value.$1 / 3, value.$2 / 3))),
      },
      onTick: (entity, areaId) {
        if (entity is AttributeFunctionality) {
          entity.addAttribute(
            AttributeType.fear,
            perpetratorEntity: entityAncestor,
            isTemporary: true,
            level: (.5 * upgradeLevel).round(),
            damageType: DamageType.psychic,
          );
        }
      },
    );

    entityAncestor?.gameEnviroment.addPhysicsComponent([area]);
  }

  @override
  WeaponType weaponType = WeaponType.eldritchRunner;

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.psychic] = (
      increasePercentOfBase(
        15,
        includeBase: true,
      ).toDouble(),
      increasePercentOfBase(25, includeBase: true).toDouble()
    );

    maxAttacks.baseParameter =
        increasePercentOfBase(1, customUpgradeFactor: .5 / 1, includeBase: true)
            .round();

    onProjectileDeath.add(createExplosion);
    pierce.baseParameter = 1;

    attackTickRate.baseParameter = 2;
    projectileRelativeSize.baseParameter =
        increasePercentOfBase(1.5, includeBase: true).toDouble();

    super.mapUpgrade();
  }

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.eldritchRunnerIdle1,
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
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

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
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    baseDamage.damageBase[DamageType.energy] = (
      increasePercentOfBase(
        10,
        includeBase: true,
      ).toDouble(),
      increasePercentOfBase(15, includeBase: true).toDouble()
    );
    maxAttacks.baseParameter =
        increasePercentOfBase(10, includeBase: true).round();
    attackTickRate.baseParameter =
        increasePercentOfBase(1.6, customUpgradeFactor: -.05, includeBase: true)
            .toDouble();
  }
  @override
  WeaponType weaponType = WeaponType.railspire;

  @override
  double get customChargeDuration => attackTickRate.parameter * 5;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.fireMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.railspireIdle1,
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
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);
}

class ShimmerRifle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  ShimmerRifle(
    super.newUpgradeLevel,
    super.ancestor,
  );
  @override
  WeaponType weaponType = WeaponType.arcaneBlaster;

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.frost] = (
      increasePercentOfBase(
        2,
        includeBase: true,
      ).toDouble(),
      increasePercentOfBase(
        5,
        includeBase: true,
      ).toDouble()
    );
    maxAttacks.baseParameter = increasePercentOfBase(
      10,
      includeBase: true,
      customUpgradeFactor: 1 / 8,
    ).round();

    attackTickRate.baseParameter = increasePercentOfBase(
      .4,
      includeBase: true,
      customUpgradeFactor: -.05,
    ).toDouble();

    weaponRandomnessPercent.baseParameter = .01;
    projectileVelocity.baseParameter = 25;
    pierce.baseParameter = 2;
    projectileRelativeSize.baseParameter = .7;
    super.mapUpgrade();
  }

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.scryshotIdle1,
            WeaponStatus.attack: await spriteAnimations.scryshotAttack1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  // TODO: implement tipOffset
  Vector2 get tipOffset => super.tipOffset.clone()
    ..y = super.tipOffset.y * .68
    ..x = super.tipOffset.x - .2;
  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;
}

class EmberBow extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  EmberBow(
    super.newUpgradeLevel,
    super.ancestor,
  );
  @override
  WeaponType weaponType = WeaponType.arcaneBlaster;

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.fire] = (
      increasePercentOfBase(
        4,
        includeBase: true,
      ).toDouble(),
      increasePercentOfBase(
        8,
        includeBase: true,
      ).toDouble()
    );

    increaseFarDamage.baseParameter = true;

    maxAttacks.baseParameter = increasePercentOfBase(
      1,
      includeBase: true,
      customUpgradeFactor: 1,
    ).round();

    attackTickRate.baseParameter = increasePercentOfBase(
      1,
      includeBase: true,
      customUpgradeFactor: -.05,
    ).toDouble();

    weaponRandomnessPercent.baseParameter = increasePercentOfBase(
      .1,
      includeBase: true,
      customUpgradeFactor: .1 / (maxLevel ?? 1),
    ).toDouble();

    projectileVelocity.baseParameter = increasePercentOfBase(
      35,
      includeBase: true,
    ).toDouble();

    pierce.baseParameter = 3;
    projectileRelativeSize.baseParameter = .5;
    super.mapUpgrade();
  }

  @override
  double get customChargeDuration => attackTickRate.parameter * 2;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.fireMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.emberBowIdle1,
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
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .5);

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}
