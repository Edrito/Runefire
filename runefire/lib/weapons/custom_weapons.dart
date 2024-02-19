import 'dart:async';

import 'package:flame/components.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

class DefaultGun extends Weapon with ProjectileFunctionality {
  DefaultGun(
    super.newUpgradeLevel,
    super.entityAncestor,
  );

  @override
  double distanceFromPlayer = 0;

  @override
  Vector2 pngSize = Vector2(0, 0);

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 0);

  @override
  WeaponType weaponType = WeaponType.blankGun;

  @override
  FutureOr<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) {
    return WeaponSpriteAnimation(
      Vector2.zero(),
      weaponAnimations: {},
      weapon: this,
      parentJoint: parentJoint,
    );
  }

  @override
  double get durationHeld => 0;

  @override
  ProjectileType? projectileType = ProjectileType.followLaser;
}

class DefaultMagic extends Weapon {
  DefaultMagic(super.newUpgradeLevel, super.entityAncestor);

  @override
  double distanceFromPlayer = 0;

  @override
  Vector2 pngSize = Vector2(0, 0);

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 0);

  @override
  WeaponType weaponType = WeaponType.blankMagic;

  @override
  FutureOr<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) {
    return WeaponSpriteAnimation(
      Vector2.zero(),
      weaponAnimations: {},
      weapon: this,
      parentJoint: parentJoint,
    );
  }

  @override
  double get durationHeld => 0;
}

class DefaultMelee extends Weapon {
  DefaultMelee(super.newUpgradeLevel, super.entityAncestor);

  @override
  double distanceFromPlayer = 0;

  @override
  Vector2 pngSize = Vector2(0, 0);

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 0);

  @override
  WeaponType weaponType = WeaponType.blankMelee;

  @override
  FutureOr<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) {
    return WeaponSpriteAnimation(
      Vector2.zero(),
      weaponAnimations: {},
      weapon: this,
      parentJoint: parentJoint,
    );
  }

  @override
  double get durationHeld => 0;
}

class HiddenArcingWeapon extends Weapon
    with ProjectileFunctionality, SemiAutomatic {
  HiddenArcingWeapon(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    attackOnRelease = false;
    attackOnChargeComplete = true;
  }

  @override
  double distanceFromPlayer = 0;

  @override
  late Vector2 pngSize = Vector2(0, 0);

  @override
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 0);

  @override
  WeaponType weaponType = WeaponType.hiddenArcingWeapon;

  @override
  double get attackRateDelay => attackTickRate.parameter / 4;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {},
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double? get customChargeDuration => 0;

  @override
  void mapUpgrade() {
    // attackTickRate.baseParameter = .25;
    // weaponRandomnessPercent.baseParameter = .04;
    // chainingTargets.baseParameter = 1;
    // attackCountIncrease.baseParameter = 1 + upgradeLevel;

    // projectileVelocity.baseParameter = 7;
    // projectileRelativeSize.baseParameter = .1;
    super.mapUpgrade();
  }

  @override
  Vector2 get tipOffset => Vector2(0, 1.42);
}
