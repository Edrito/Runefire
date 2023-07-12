import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:game_app/resources/functions/vector_functions.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class Dagger extends PlayerWeapon
    with
        MeleeFunctionality,
        // ProjectileFunctionality,
        FullAutomatic,
        MeleeTrailEffect,
        StaminaCostFunctionality {
  Dagger.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  void attack([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, PlayerWeapon: true);
    // }
    super.attack(chargeAmount);
  }

  @override
  FutureOr<void> onLoad() async {
    attackHitboxPatterns = [
      (Vector2(.25, 0), -35),
      (Vector2(-.6, 0), 35),
      (Vector2(.2, 0), 0),
      (Vector2(.2, 1), 0),

      (Vector2(-.2, 0), 0),
      (Vector2(-.2, .95), 0),

      (Vector2(-.25, 1), 35),
      (Vector2(.6, 0), -35),
      // (Vector2(.5, 1), -45),
      // (Vector2(-.5, -.2), 60),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
    baseMaxAttacks = (attackHitboxPatterns.length / 2).round();

    for (var i = 0; i < baseMaxAttacks; i++) {
      attackHitboxSpriteAnimations
          .add(await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }

    attackHitboxSizes = attackHitboxSpriteAnimations.fold<List<Vector2>>(
        [],
        (previousValue, element) => [
              ...previousValue,
              element.frames.first.sprite.srcSize
                  .scaledToDimension(true, length)
            ]);
    return super.onLoad();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

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
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(3.7, -4.5)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true));
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
    DamageType.bleed: (7, 14)
  };
  @override
  double baseAttackTickRate = .2;

  @override
  double length = 1;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  WeaponType weaponType = WeaponType.dagger;

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
  double get baseMaxSpreadDegrees =>
      (attackCount * 25).clamp(0, 335).toDouble();

  @override
  bool allowProjectileRotation = false;

  @override
  int basePierce = 1;

  // @override
  // ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double projectileVelocity = 20;

  @override
  double baseWeaponStaminaCost = 2;
}

class Spear extends PlayerWeapon
    with
        MeleeFunctionality,
        // ProjectileFunctionality,
        FullAutomatic,
        MeleeTrailEffect,
        StaminaCostFunctionality {
  Spear.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  void attack([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, PlayerWeapon: true);
    // }
    super.attack(chargeAmount);
  }

  @override
  FutureOr<void> onLoad() async {
    attackHitboxPatterns = [
      (Vector2(.2, -.5), 0),
      (Vector2(.2, 2.55), 0),
      (Vector2(-.2, -.5), 0),
      (Vector2(-.2, 2.45), 0),
      (Vector2(-0, 0), 0),
      (Vector2(-0, 0), 360),
      // (Vector2(.5, 1), -45),
      // (Vector2(-.5, -.2), 60),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
    baseMaxAttacks = (attackHitboxPatterns.length / 2).round();

    for (var i = 0; i < baseMaxAttacks; i++) {
      attackHitboxSpriteAnimations
          .add(await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }

    attackHitboxSizes = attackHitboxSpriteAnimations.fold<List<Vector2>>(
        [],
        (previousValue, element) => [
              ...previousValue,
              element.frames.first.sprite.srcSize
                  .scaledToDimension(true, length)
            ]);
    return super.onLoad();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

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
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(3.7, -4.5)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true));
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
    DamageType.bleed: (7, 14)
  };
  @override
  double baseAttackTickRate = .6;

  @override
  double length = 3;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  WeaponType weaponType = WeaponType.spear;

  @override
  bool countIncreaseWithTime = false;

  @override
  double baseWeaponRandomnessPercent = .05;

  @override
  int get baseAttackCount => 4;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => false;

  @override
  late int baseMaxAttacks;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees =>
      (attackCount * 25).clamp(0, 335).toDouble();

  @override
  bool allowProjectileRotation = false;

  @override
  int basePierce = 1;

  // @override
  // ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double projectileVelocity = 20;

  @override
  double baseWeaponStaminaCost = 10;
}

class EnergySword extends PlayerWeapon
    with
        MeleeFunctionality,
        ProjectileFunctionality,
        SemiAutomatic,
        MeleeTrailEffect,
        StaminaCostFunctionality {
  EnergySword.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  void attack([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, PlayerWeapon: true);
    // }
    super.attack(chargeAmount);
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
  @override
  FutureOr<void> onLoad() async {
    attackHitboxPatterns = [
      (Vector2(-.2, .25), 45),
      (Vector2(1, .35), -30),
      (Vector2(.2, .25), -45),
      (Vector2(-1, .35), 30),
      (Vector2(.0, -.5), 0),
      (Vector2(0, 1), 0),

      // (Vector2(.5, 1), -45),
      // (Vector2(-.5, -.2), 60),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
    baseMaxAttacks = (attackHitboxPatterns.length / 2).round();

    for (var i = 0; i < baseMaxAttacks; i++) {
      attackHitboxSpriteAnimations
          .add(await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }

    attackHitboxSizes = attackHitboxSpriteAnimations.fold<List<Vector2>>(
        [],
        (previousValue, element) => [
              ...previousValue,
              element.frames.first.sprite.srcSize
                  .scaledToDimension(true, length)
            ]);
    return super.onLoad();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  List<BodyComponent<Forge2DGame>> generateProjectileFunction(
      [double chargeAmount = 1]) {
    if (chargeAmount != 1) return [];
    return super.generateProjectileFunction(chargeAmount);
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(3.7, -4.5)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.electric: (7, 14)
  };
  @override
  double baseAttackTickRate = .3;

  @override
  double length = 2;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  WeaponType weaponType = WeaponType.energySword;

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
  double get baseMaxSpreadDegrees =>
      (attackCount * 25).clamp(0, 335).toDouble();

  @override
  bool allowProjectileRotation = false;

  @override
  int basePierce = 1;

  // @override
  // ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double projectileVelocity = 20;

  @override
  double baseWeaponStaminaCost = 1;

  @override
  bool waitForAttackRate = true;
}

class FlameSword extends PlayerWeapon
    with
        MeleeFunctionality,
        // ProjectileFunctionality,
        FullAutomatic,
        MeleeTrailEffect,
        ReloadFunctionality,
        StaminaCostFunctionality {
  FlameSword.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  void attack([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, PlayerWeapon: true);
    // }
    super.attack(chargeAmount);
  }

  @override
  FutureOr<void> onLoad() async {
    attackHitboxPatterns = [
      (Vector2(.0, -1.5), 360),
      (Vector2(0, 1.5), -30),
      (Vector2(.0, -1.5), 0),
      (Vector2(0, 1.5), 390),
      (Vector2(0, -1), 0),
      (Vector2(0, 1.5), -0),
      // (Vector2(.5, 1), -45),
      // (Vector2(-.5, -.2), 60),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");

    for (var i = 0; i < baseMaxAttacks; i++) {
      attackHitboxSpriteAnimations
          .add(await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }

    attackHitboxSizes = attackHitboxSpriteAnimations.fold<List<Vector2>>(
        [],
        (previousValue, element) => [
              ...previousValue,
              element.frames.first.sprite.srcSize
                  .scaledToDimension(true, length)
            ]);
    return super.onLoad();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

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
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(3.7, -4.5)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true));
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
    DamageType.fire: (7, 14)
  };
  @override
  double baseAttackTickRate = .8;

  @override
  double length = 2;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  WeaponType weaponType = WeaponType.flameSword;

  @override
  bool countIncreaseWithTime = false;

  @override
  double baseWeaponRandomnessPercent = .05;

  @override
  int get baseAttackCount => 4;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => false;

  @override
  int get baseMaxAttacks => 3;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees =>
      (attackCount * 25).clamp(0, 335).toDouble();

  @override
  bool allowProjectileRotation = false;

  @override
  int basePierce = 1;

  // @override
  // ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double projectileVelocity = 20;

  @override
  double baseWeaponStaminaCost = 5;

  @override
  // TODO: implement baseReloadTime
  double get baseReloadTime => 4;
}

class LargeSword extends PlayerWeapon
    with
        MeleeFunctionality,
        SemiAutomatic,
        MeleeTrailEffect,
        StaminaCostFunctionality {
  LargeSword.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  void attack([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, PlayerWeapon: true);
    // }
    super.attack(chargeAmount);
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;
  @override
  FutureOr<void> onLoad() async {
    attackHitboxPatterns = [
      (Vector2(-.8, .25), 55),
      (Vector2(1, .35), -5),
      // (Vector2(.2, .25), -45),
      // (Vector2(-1, .35), 30),
      (Vector2(.0, -1.5), 0),
      (Vector2(0, 1.5), 0),

      // (Vector2(.5, 1), -45),
      // (Vector2(-.5, -.2), 60),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");

    for (var i = 0; i < baseMaxAttacks; i++) {
      attackHitboxSpriteAnimations
          .add(await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }

    attackHitboxSizes = attackHitboxSpriteAnimations.fold<List<Vector2>>(
        [],
        (previousValue, element) => [
              ...previousValue,
              element.frames.first.sprite.srcSize
                  .scaledToDimension(true, length)
            ]);
    return super.onLoad();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

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
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(3.7, -4.5)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (40, 120)
  };
  @override
  double baseAttackTickRate = 1.5;

  @override
  double length = 3;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  WeaponType weaponType = WeaponType.largeSword;

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
  int get baseMaxAttacks => (attackHitboxPatterns.length / 2).round();

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees =>
      (attackCount * 25).clamp(0, 335).toDouble();

  @override
  bool allowProjectileRotation = false;

  @override
  int basePierce = 1;

  // @override
  // ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double projectileVelocity = 20;

  @override
  double baseWeaponStaminaCost = 20;

  @override
  bool waitForAttackRate = true;
}
