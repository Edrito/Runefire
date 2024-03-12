import 'dart:async';

import 'package:flame/components.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/enums.dart';

class BlankProjectileWeapon extends EnemyWeapon
    with ProjectileFunctionality, FullAutomatic {
  BlankProjectileWeapon(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    baseDamage.damageBase[DamageType.physical] = (5, 8);
    attackTickRate.baseParameter = 2;
    attackCountIncrease.baseParameter = 0;
    projectileVelocity.baseParameter = 7;
    projectileRelativeSize.baseParameter = .5;
  }
  @override
  WeaponType weaponType = WeaponType.blankProjectileWeapon;

  @override
  double get weaponLength => 2;

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
          Vector2.all(1),
          weaponAnimations: {},
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  bool get originateFromCenter => true;

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  late Vector2 pngSize = Vector2.all(8);

  @override
  ProjectileType? projectileType = ProjectileType.paintBullet;

  @override
  void endAltAttacking() {}

  @override
  void startAltAttacking() {}
}

class MushroomBossWeapon1 extends EnemyWeapon
    with ProjectileFunctionality, FullAutomatic {
  MushroomBossWeapon1(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    baseDamage.damageBase[DamageType.fire] = (5, 8);
    attackTickRate.baseParameter = .2;
    attackCountIncrease.baseParameter = 10;
    projectileVelocity.baseParameter = 8;
    projectileRelativeSize.baseParameter = .75;
    projectileLifeSpan.baseParameter = 5;
  }
  @override
  WeaponType weaponType = WeaponType.mushroomBossWeapon1;

  @override
  double get weaponLength => 2;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  Set<AttackSplitFunction> get attackSpreadPatterns => {
        (ang, count) => crossAttackSpread(count: count, initialAngle: ang),
      };

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weaponAnimations: {},
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  bool get originateFromCenter => true;

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  late Vector2 pngSize = Vector2.all(8);

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

  @override
  void endAltAttacking() {}

  @override
  void startAltAttacking() {}
}
