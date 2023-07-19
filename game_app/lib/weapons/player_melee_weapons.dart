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
        FullAutomatic,
        MeleeTrailEffect,
        StaminaCostFunctionality {
  Dagger.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (2, 5);
    attackTickRate.baseParameter = .35;

    attackHitboxPatterns = [
      (Vector2(.2, 0), 0),
      (Vector2(.2, 1), 0),
      (Vector2(.25, 0), -35),
      (Vector2(-.6, 0), 35),
      (Vector2(-.2, 0), 0),
      (Vector2(-.2, .95), 0),
      (Vector2(-.25, 1), 35),
      (Vector2(.6, 0), -35),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
  }

  @override
  FutureOr<void> onLoad() async {
    for (var i = 0; i < numberOfAttacks; i++) {
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
            Vector2.zero(),
            Vector2(0, length),
            parentJoint: parentJoint,
            await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            Vector2.zero(),
            Vector2(0, length),
            parentJoint: parentJoint,
            await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  double length = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  double tipPositionPercent = 0;

  @override
  WeaponType weaponType = WeaponType.dagger;
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
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (8, 16);
    attackTickRate.baseParameter = .7;
    attackHitboxPatterns = [
      (Vector2(.2, -.5), 0),
      (Vector2(.2, 2.55), 0),
      (Vector2(-.2, -.5), 0),
      (Vector2(-.2, 2.45), 0),
      (Vector2(-0, 0), 0),
      (Vector2(-0, 0), 360),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  FutureOr<void> onLoad() async {
    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");

    for (var i = 0; i < numberOfAttacks; i++) {
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
            Vector2.zero(),
            Vector2(0, length),
            parentJoint: parentJoint,
            await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            Vector2.zero(),
            Vector2(0, length),
            parentJoint: parentJoint,
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
  double length = 3;

  @override
  double tipPositionPercent = 0;

  @override
  WeaponType weaponType = WeaponType.spear;
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
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (5, 12);
    attackTickRate.baseParameter = .5;
  }

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
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");

    for (var i = 0; i < numberOfAttacks; i++) {
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
            baseOffset,
            tipOffset,
            parentJoint: parentJoint,
            await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            baseOffset,
            tipOffset,
            parentJoint: parentJoint,
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
  double length = 2;

  @override
  double tipPositionPercent = 0;

  @override
  WeaponType weaponType = WeaponType.energySword;
}

class FlameSword extends PlayerWeapon
    with
        MeleeFunctionality,
        // ProjectileFunctionality,
        FullAutomatic,
        ReloadFunctionality,
        StaminaCostFunctionality {
  FlameSword.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    attackTickRate.baseParameter = .6;
    baseDamage.damageBase[DamageType.fire] = (20, 25);
    attackHitboxPatterns = [
      (Vector2(.0, -1.5), 360),
      (Vector2(0, 1.5), -30),
      (Vector2(.0, -1.5), 0),
      (Vector2(0, 1.5), 390),
      (Vector2(0, -1), 0),
      (Vector2(0, 1.5), -0),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
  }

  @override
  FutureOr<void> onLoad() async {
    for (var i = 0; i < numberOfAttacks; i++) {
      attackHitboxSpriteAnimations
          .add(await buildSpriteSheet(1, 'weapons/fire_sword.png', 1, true));
    }
    attackHitboxSizes = attackHitboxSpriteAnimations.fold<List<Vector2>>(
        [],
        (previousValue, element) => [
              ...previousValue,
              element.frames.first.sprite.srcSize
                  .scaledToDimension(true, length)
                  .clone()
                ..x = 1
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
  Vector2 get baseOffset => Vector2(0, .25);

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
            Vector2(5, 0),
            Vector2(0, length),
            parentJoint: parentJoint,
            await buildSpriteSheet(1, 'weapons/fire_sword.png', 1, true))
          ..position = Vector2(-.65, .67)
          ..angle = radians(-145);
      default:
        return WeaponSpriteAnimation(
            Vector2.zero(),
            Vector2(0, length),
            parentJoint: parentJoint,
            await buildSpriteSheet(1, 'weapons/fire_sword.png', 1, true));
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  double length = 2.6;

  @override
  WeaponType weaponType = WeaponType.flameSword;
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
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (20, 50);
    attackHitboxPatterns = [
      (Vector2(-.8, .25), 55),
      (Vector2(1, .35), -5),
      (Vector2(.0, -1.5), 0),
      (Vector2(0, 1.5), 0),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    attackTickRate.baseParameter = 2;

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;
  @override
  FutureOr<void> onLoad() async {
    for (var i = 0; i < numberOfAttacks; i++) {
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
            Vector2.zero(),
            Vector2(0, length),
            parentJoint: parentJoint,
            await buildSpriteSheet(1, weaponType.flameImage, 1, true))
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            Vector2.zero(),
            Vector2(0, length),
            parentJoint: parentJoint,
            await buildSpriteSheet(1, weaponType.flameImage, 1, true));
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  double length = 3;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  double tipPositionPercent = 0;

  @override
  bool get waitForAttackRate => false;

  @override
  WeaponType weaponType = WeaponType.largeSword;
}
