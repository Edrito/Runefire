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
  ) : super(newUpgradeLevel, ancestor);

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
  bool allowProjectileRotation = true;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (1, 2),
    DamageType.psychic: (1, 2),
    DamageType.fire: (1, 2),
  };

  @override
  double baseAttackTickRate = .2;

  @override
  int get maxChainingTargets => 0;

  @override
  double length = .5;

  @override
  int basePierce = 5;

  @override
  double projectileVelocity = 20;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.25;

  @override
  double weaponRandomnessPercent = .0;

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
  double baseReloadTime = 2;

  @override
  double baseWeaponRandomnessPercent = 0.05;

  @override
  int get baseAttackCount => 1;

  @override
  bool get baseCountIncreaseWithTime => true;

  @override
  bool get baseIsHoming => false;

  @override
  int get baseMaxAttacks => 12;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees => 30;
}

class Shotgun extends PlayerWeapon
    with ProjectileFunctionality, FullAutomatic, ReloadFunctionality {
  Shotgun.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);
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
  bool allowProjectileRotation = false;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (10, 20.0)
  };
  @override
  double baseAttackTickRate = .5;

  @override
  double length = 1;

  @override
  double baseWeaponRandomnessPercent = .05;

  @override
  int get baseAttackCount => 4;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => false;

  @override
  int baseMaxAttacks = 5;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees => 180;

  @override
  double weaponRandomnessPercent = .0;

  @override
  bool countIncreaseWithTime = false;

  @override
  double maxSpreadDegrees = 50;

  @override
  int basePierce = 4;

  @override
  double projectileVelocity = 20;

  @override
  double baseReloadTime = 1.5;

  @override
  double tipPositionPercent = -.02;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}
