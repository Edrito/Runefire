import 'dart:async';

import 'package:flame/components.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/enums.dart';

class BlankProjectileWeapon extends EnemyWeapon
    with ProjectileFunctionality, SemiAutomatic {
  BlankProjectileWeapon(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (5, 8);
    attackTickRate.baseParameter = .8;

    projectileVelocity.baseParameter = 10;
  }
  @override
  WeaponType weaponType = WeaponType.scatterCaster;

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
          Vector2.all(1),
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
  double weaponSize = 2;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.2;

  @override
  void endAltAttacking() {
    // TODO: implement endAltAttacking
  }

  @override
  void startAltAttacking() {
    // TODO: implement startAltAttacking
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}
