import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/swings.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class PhaseDagger extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  PhaseDagger(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (2, 3);
    baseDamage.damageBase[DamageType.psychic] = (2, 3);
    attackTickRate.baseParameter = .25;
    pierce.baseParameter = 2;
    chainingTargets.baseParameter = 4;

    tipOffset = Vector2(0, weaponSize);

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2(.5, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
                })
              ..opacity = (.5 * rng.nextDouble()) + .5;
          },
          weaponTrailConfig: WeaponTrailConfig(
              color: DamageType.psychic.color.withOpacity(.5)),
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, -.5), -20, 1),
            (Vector2(0, 1.5), 30, 1),
            // (Vector2(.25, 0), -35, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(.5, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
                })
              ..opacity = (.5 * rng.nextDouble()) + .5;
          },
          weaponTrailConfig: WeaponTrailConfig(color: DamageType.psychic.color),
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(-.2, -.5), 20, 1),
            (Vector2(0, 1.5), -30, 1),
            // (Vector2(.25, 0), -35, 1),
          ]),
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
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
            })
          ..angle = radians(-15)
          ..position = Vector2(.15, -.5);
      default:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
            });
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = 0;

  @override
  double weaponSize = 1.3;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  WeaponType weaponType = WeaponType.phaseDagger;
}

class CrystalSword extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  CrystalSword(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (2, 5);
    attackTickRate.baseParameter = .55;
    pierce.baseParameter = 5;
    tipOffset = Vector2(0, weaponSize);

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2(weaponSize / 3.5, weaponSize),
          flippedDuringAttack: true,
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
                });
          },
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(-1, 0), 55, 1),
            (Vector2(2, -1), -75, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(weaponSize / 3.5, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
                });
          },
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(1, 0), -45, 1),
            (Vector2(-2, 0), 45, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(weaponSize / 3.5, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
                });
          },
          weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(0, 0), -0, 1),
            // (Vector2(.2, 1), 90, 1),
            (Vector2(0, 2), 0, 1),
          ]),
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
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
            })
          ..position = Vector2(.75, -1.75)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
            });
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  double weaponSize = 2.5;

  @override
  bool removeSpriteOnAttack = true;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back
  ];

  @override
  WeaponType weaponType = WeaponType.crystalSword;
}

class AethertideSpear extends PlayerWeapon
    with
        MeleeFunctionality,
        // ProjectileFunctionality,
        FullAutomatic,
        StaminaCostFunctionality {
  AethertideSpear(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (8, 16);
    attackTickRate.baseParameter = .8;
    tipOffset = Vector2(0, weaponSize);
    pierce.baseParameter = 100;

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2(1, weaponSize),
          weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle:
                      await spriteAnimations.aethertideSpearIdle1,
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, -.7), 0, 1),
            (Vector2(0, 6), 0, 1),
            // (Vector2(0, 1.5), -20, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(1, weaponSize),
          entitySpriteAnimation: null,
          weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle:
                      await spriteAnimations.aethertideSpearIdle1,
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(-.2, -.7), 0, 1),
            (Vector2(0, 6), 0, 1),
            // (Vector2(0, 1.5), 20, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(3, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle:
                      await spriteAnimations.aethertideSpearIdle1,
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(0, 3), 370, 1),
            (Vector2(0, -4), -10, 1),
          ]),
    ];
    pierce.baseParameter = 5;
    chainingTargets.baseParameter = 6;
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
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.aethertideSpearIdle1,
            })
          ..position = Vector2(weaponSize / 2, -weaponSize / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.aethertideSpearIdle1,
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
  double weaponSize = 3.75;

  @override
  WeaponType weaponType = WeaponType.spear;
}

class HolySword extends PlayerWeapon
    with
        MeleeFunctionality,
        ProjectileFunctionality,
        SemiAutomatic,
        StaminaCostFunctionality,
        MeleeChargeReady {
  HolySword(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (5, 12);
    attackTickRate.baseParameter = .7;
    projectileVelocity.baseParameter = 15;
    pierce.baseParameter = 6;

    tipOffset = Vector2(0, weaponSize);

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2(1, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.holySwordIdle1,
                });
          },
          chargePattern: [
            (Vector2(0, -.5), -140, .8),
            (Vector2(.2, 0), -120, 1.0),
            (Vector2(.1, 0), -100, 1.2),
          ],
          attackPattern: [
            // (Vector2(.2, 1), 0, 1),
            (Vector2(-1, .5), 140, 1),
            (Vector2(2, 0), -45, 1.1),
            // (Vector2(0, -.4), 55, 1),
            // (Vector2(.2, 1), 0, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(1, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.holySwordIdle1,
                });
          },
          chargePattern: [
            (Vector2(0, .3), -20, .8),
            (Vector2(.2, .3), -40, 1),
            (Vector2(.1, .3), -60, 1.2),
          ],
          attackPattern: [
            // (Vector2(.2, 1), 0, 1),
            (Vector2(.5, .5), -130, 1),
            (Vector2(-1.5, -.0), 45, 1),
            // (Vector2(.2, 1), 0, 1),
          ]),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
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
  List<Projectile> generateProjectileFunction([double chargeAmount = 1]) {
    if (chargeAmount < .7) return [];
    return super.generateProjectileFunction(chargeAmount)
      ..forEach((element) {
        element.size = weaponSize / 2;
      });
  }

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(baseOffset,
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.holySwordIdle1,
            })
          ..position = Vector2(weaponSize / 3, .35)
          ..angle = radians(135);
      default:
        return WeaponSpriteAnimation(baseOffset,
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.holySwordIdle1,
            });
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  ProjectileType? projectileType = ProjectileType.holyBullet;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  double weaponSize = 2;

  @override
  WeaponType weaponType = WeaponType.holySword;
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
    pierce.baseParameter = 5;
    // maxChainingTargets.baseParameter = 6;
    // baseAttackCount.baseParameter = 5;
    tipOffset = Vector2(0, weaponSize);
    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2(1, weaponSize),
          entitySpriteAnimation: null,
          weaponTrailConfig:
              WeaponTrailConfig(color: DamageType.fire.color.withOpacity(.75)),
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, 0), -360, 1),
            (Vector2(.2, 1), 0, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(1, weaponSize),
          weaponTrailConfig:
              WeaponTrailConfig(color: DamageType.fire.color.withOpacity(.75)),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
                });
          },
          flippedDuringAttack: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(-.2, 0), 360, 1),
            (Vector2(-.2, 1), 0, 1),
          ]),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    if (ancestor == null) return;
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

  // @override
  // Vector2 get baseOffset => Vector2(5, .25);

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(baseOffset,
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
            })
          ..position = Vector2(-.5, .3)
          ..angle = radians(-145);
      default:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
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
  double weaponSize = 1.6;

  @override
  WeaponType weaponType = WeaponType.flameSword;
}

class LargeSword extends PlayerWeapon
    with MeleeFunctionality, SemiAutomatic, StaminaCostFunctionality {
  LargeSword(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (12, 20);
    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2.all(1),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.largeSwordIdle1,
                });
          },
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, 0), 0, 1),
            (Vector2(.2, 1), 0, 1),
          ]),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    attackTickRate.baseParameter = 2;
    chainingTargets.baseParameter = 5;
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
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(Vector2.zero(),
            parentJoint: parentJoint,
            weapon: this,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.largeSwordIdle1,
            })
          ..position = Vector2(weaponSize / 2, -weaponSize / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.largeSwordIdle1,
            });
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  double weaponSize = 3;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  bool get waitForAttackRate => false;

  @override
  WeaponType weaponType = WeaponType.largeSword;
}

class FrostKatana extends PlayerWeapon
    with
        MeleeFunctionality,
        SemiAutomatic,
        StaminaCostFunctionality,
        MeleeChargeReady {
  FrostKatana(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.frost] = (5, 12);
    attackTickRate.baseParameter = .5;
    pierce.baseParameter = 5;

    customChargeDuration = 1;

    tipOffset = Vector2(0, weaponSize);

    onAttackMelee.add((holdDurationPercent) {
      if (entityAncestor is DashFunctionality) {
        final dash = (entityAncestor as DashFunctionality);
        if (holdDurationPercent < .6) return;
        pierce.setParameterFlatValue(weaponId, 999);
        dash.dashInit(
            power: holdDurationPercent * 2.5,
            weaponSource: true,
            triggerFunctions: false);
        Future.delayed(dash.dashDuration.parameter.seconds)
            .then((value) => pierce.removeFlatKey(weaponId));
      }
    });

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2(1, weaponSize),
          entitySpriteAnimation: null,
          weaponTrailConfig: WeaponTrailConfig(
            bottomStartFromTipPercent: .25,
          ),
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.frostKatanaIdle1,
                });
          },
          chargePattern: [
            (Vector2(-.2, -.2), -120, 1),
            (Vector2(.2, -.2), -100, 1),
            (Vector2(.2, -.4), -80, 1),
          ],
          attackPattern: [
            (Vector2(0, -.2), 140, 1),
            (Vector2(1, .2), -45, 1.1),
          ]),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
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
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(baseOffset,
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.frostKatanaIdle1,
            })
          ..position = Vector2(.6, -1.2)
          ..angle = radians(30);
      default:
        return WeaponSpriteAnimation(baseOffset,
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.frostKatanaIdle1,
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
  double weaponSize = 3;

  @override
  WeaponType weaponType = WeaponType.frostKatana;
}

class SwordOfJustice extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  SwordOfJustice(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (2, 5);
    baseDamage.damageBase[DamageType.fire] = (2, 5);
    attackTickRate.baseParameter = .4;
    pierce.baseParameter = 5;
    // maxChainingTargets.baseParameter = 3;
    tipOffset = Vector2(0, weaponSize);

    onHitMelee.add((damage) {
      if (damage.victim.healthPercentage < .2) {
        damage.damageMap.clear();
        damage.damageMap[DamageType.fire] = double.infinity;
        damage.checkCrit(true);
      }
      return false;
    });

    meleeAttacks = [
      MeleeAttack(
          attackHitboxSize: Vector2(weaponSize / 3.5, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
                });
          },
          weaponTrailConfig:
              WeaponTrailConfig(color: ApolloColorPalette.red.color),
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(0, -.5), -35, 1),
            (Vector2(0, 1.5), 0, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(weaponSize / 3.5, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
                });
          },
          weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(.2, -.25), -0, 1),
            (Vector2(0, 2), 0, 1),
          ]),
      MeleeAttack(
          attackHitboxSize: Vector2(weaponSize / 3.5, weaponSize),
          entitySpriteAnimation: null,
          attackSpriteAnimationBuild: () async {
            return WeaponSpriteAnimation(Vector2.zero(),
                weapon: this,
                parentJoint: null,
                weaponAnimations: {
                  WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
                });
          },
          weaponTrailConfig:
              WeaponTrailConfig(color: ApolloColorPalette.red.color),
          customStartAngle: true,
          chargePattern: [],
          attackPattern: [
            (Vector2(-.2, -.5), 35, 1),
            // (Vector2(.2, 1), 90, 1),
            (Vector2(0, 1.5), 0, 1),
          ]),
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
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
            })
          ..position = Vector2(.75, -1.75)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(Vector2.zero(),
            weapon: this,
            parentJoint: parentJoint,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
            });
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  double weaponSize = 3;

  @override
  bool removeSpriteOnAttack = true;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back
  ];

  @override
  WeaponType weaponType = WeaponType.swordOfJustice;
}
