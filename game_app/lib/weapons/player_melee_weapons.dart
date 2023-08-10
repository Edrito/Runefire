import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class Dagger extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  Dagger(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (2, 5);
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 5;
    maxChainingTargets.baseParameter = 6;

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2.all(1),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await loadSpriteAnimation(
                      1, weaponType.flameImage, 1, true),
                });
          },
          customStartAngle: false,
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, 0), 90, 1),
            (Vector2(.2, 1), 90, 1),
            (Vector2(.25, 0), -35, 1),
          ])
    ];

    spirteComponentPositions.add(WeaponSpritePosition.back);
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
        return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            })
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            });
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
        StaminaCostFunctionality {
  Spear(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (8, 16);
    attackTickRate.baseParameter = .7;

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2.all(1),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await loadSpriteAnimation(
                      1, weaponType.flameImage, 1, true),
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, 0), 0, 1),
            (Vector2(.2, 1), 0, 1),
            (Vector2(.25, 0), -35, 1),
            (Vector2(-.6, 0), 35, 1),
            (Vector2(-.2, 0), 0, 1),
            (Vector2(-.2, .95), 0, 1),
            (Vector2(-.25, 1), 35, 1),
            (Vector2(.6, 0), -35, 1),
          ])
    ];
    pierce.baseParameter = 5;
    maxChainingTargets.baseParameter = 6;
    spirteComponentPositions.add(WeaponSpritePosition.back);
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
        return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            })
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            });
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
        StaminaCostFunctionality,
        MeleeChargeReady {
  EnergySword(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (5, 12);
    attackTickRate.baseParameter = .5;

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2.all(1),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await loadSpriteAnimation(
                      1, weaponType.flameImage, 1, true),
                });
          },
          chargePattern: [
            (Vector2(-.2, -.5), 35, 1),
            (Vector2(.2, -.5), 30, 1),
          ],
          attackPattern: [
            // (Vector2(.2, 1), 0, 1),
            (Vector2(.25, 0), -35, 1),
            (Vector2(.2, 1), 0, 1),
            // (Vector2(.2, 1), 0, 1),
          ])
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  void standardAttack([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, PlayerWeapon: true);
    // }
    super.standardAttack(chargeAmount);
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

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
        return WeaponSpriteAnimation(baseOffset, tipOffset,
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            })
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            baseOffset,
            weapon: this,
            tipOffset,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            });
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
        FullAutomatic,
        ReloadFunctionality,
        StaminaCostFunctionality {
  FlameSword(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    attackTickRate.baseParameter = .6;
    baseDamage.damageBase[DamageType.fire] = (20, 25);
    pierce.baseParameter = 2;
    maxChainingTargets.baseParameter = 6;
    baseAttackCount.baseParameter = 5;
    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2.all(1),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await loadSpriteAnimation(
                      1, weaponType.flameImage, 1, true),
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, 0), -360, 1),
            (Vector2(.2, 1), 0, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2.all(1),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await loadSpriteAnimation(
                      1, weaponType.flameImage, 1, true),
                });
          },
          flippedDuringAttack: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, 0), 360, 1),
            (Vector2(.2, 1), 0, 1),
            // (Vector2(.2, 0), 360, 1),
          ]),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    if (ancestor == null) return;
    // additionalWeapons['initWeapon1'] =
    //     WeaponType.spear.build(ancestor, null, gameState.gameRouter);
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
  Vector2 get baseOffset => Vector2(5, .25);

  @override
  // TODO: implement tipOffset
  Vector2 get tipOffset => Vector2(0, length);

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(baseOffset, tipOffset,
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await loadSpriteAnimation(
                  1, 'weapons/fire_sword.png', 1, true),
            })
          ..position = Vector2(-.65, .67)
          ..angle = radians(-145);
      default:
        return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await loadSpriteAnimation(
                  1, 'weapons/fire_sword.png', 1, true),
            });
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

  @override
  ProjectileType? projectileType = ProjectileType.blast;
}

class LargeSword extends PlayerWeapon
    with MeleeFunctionality, SemiAutomatic, StaminaCostFunctionality {
  LargeSword(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.fire] = (20, 50);
    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2.all(1),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await loadSpriteAnimation(
                      1, weaponType.flameImage, 1, true),
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, 0), 0, 1),
            (Vector2(.2, 1), 0, 1),
            (Vector2(.25, 0), -35, 1),
            (Vector2(-.6, 0), 35, 1),
            (Vector2(-.2, 0), 0, 1),
            (Vector2(-.2, .95), 0, 1),
            (Vector2(-.25, 1), 35, 1),
            (Vector2(.6, 0), -35, 1),
          ])
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    attackTickRate.baseParameter = 2;
    maxChainingTargets.baseParameter = 5;
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;
  @override
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
        return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
            parentJoint: parentJoint,
            weapon: this,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            })
          ..position = Vector2(length / 2, -length / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(Vector2.zero(), Vector2(0, length),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle:
                  await loadSpriteAnimation(1, weaponType.flameImage, 1, true),
            });
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
  bool get waitForAttackRate => false;

  @override
  WeaponType weaponType = WeaponType.largeSword;
}
