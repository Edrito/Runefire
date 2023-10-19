import 'dart:async';

import 'package:flame/components.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import '../entities/entity_mixin.dart';
import '../resources/enums.dart';

class BlankProjectileWeapon extends EnemyWeapon
    with ProjectileFunctionality, SemiAutomatic {
  BlankProjectileWeapon(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (5, 8);
    attackTickRate.baseParameter = .01;
    attackCountIncrease.baseParameter = 0;
    projectileVelocity.baseParameter = 10;
  }
  @override
  WeaponType weaponType = WeaponType.blankProjectileWeapon;

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
  double weaponScale = 1;
  @override
  late Vector2 pngSize = Vector2.all(8);

  @override
  ProjectileType? projectileType = ProjectileType.paintBullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;

  @override
  void endAltAttacking() {
    // TODO: implement endAltAttacking
  }

  @override
  void startAltAttacking() {
    // TODO: implement startAltAttacking
  }
}
