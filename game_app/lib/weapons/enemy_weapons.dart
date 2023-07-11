import 'dart:async';

import 'package:flame/components.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class BlankMelee extends Weapon
    with
        MeleeFunctionality,
        SecondaryFunctionality,
        FullAutomatic,
        MeleeTrailEffect {
  BlankMelee.create(int? newUpgradeLevel, AimFunctionality? ancestor)
      : super(newUpgradeLevel ?? 1, ancestor);

  @override
  void attack([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, weapon: true);
    // }
    super.attack(chargeAmount);
  }

  @override
  FutureOr<void> onLoad() async {
    attackHitboxPatterns = [
      (Vector2(0.5, 0), -45),
      (Vector2(-.5, 1), 45),
      (Vector2(-.5, 1), 45),
      (Vector2(1, 0), -45),
    ];

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
    baseMaxAttacks = (attackHitboxPatterns.length / 2).round();

    attackHitboxSizes = [
      Vector2.all(length),
      Vector2.all(length),
    ];

    attackEntitySpriteAnimations.addAll([
      await buildSpriteSheet(7, 'sprites/roll.png', attackTickRate / 7, false),
      await buildSpriteSheet(7, 'sprites/roll.png', attackTickRate / 7, false)
    ]);

    return super.onLoad();
  }

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  // TODO: implement attackOnAnimationFinish
  bool get attackOnAnimationFinish => true;

  @override
  Future<WeaponSpriteAnimation?> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    return null;
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (5, 10.0)
  };

  @override
  double baseAttackTickRate = .3;

  @override
  double length = .5;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  WeaponType weaponType = WeaponType.shiv;

  @override
  bool countIncreaseWithTime = false;

  @override
  double baseWeaponRandomnessPercent = .05;

  @override
  int get baseAttackCount => 1;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => false;

  @override
  late int baseMaxAttacks;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees => 25;

  @override
  double baseMeleeStaminaCost = 0;
}
