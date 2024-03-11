import 'dart:async';
import 'dart:math';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flame_forge2d/forge2d_game.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/melee_swing_manager.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/enums.dart';

class CrystalSword extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  CrystalSword(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    // onHitMelee.add((damage) {
    //   entityAncestor?.gameEnviroment.addPhysicsComponent([
    //     SummonedChildEntity(
    //       initialPosition: damage.victim.position,
    //       parentEntity: entityAncestor!,
    //       damageBase: {DamageType.psychic: (1, 2)},
    //       upgradeLevel: upgradeLevel,
    //     ),
    //   ]);
    //   return false;
    // });

    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .9)
        ),
        flippedDuringAttack: true,
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(-1, 0), 55, 1),
          (Vector2(2, -1), -75, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .9)
        ),
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(1, 0), -45, 1),
          (Vector2(-2, 0), 45, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .9)
        ),
        entitySpriteAnimation: null,
        meleeAttackType: MeleeType.stab,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
            },
          );
        },
        weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
        chargePattern: [],
        attackPattern: [
          (Vector2(0, 0), -0, 1),
          // (Vector2(.2, 1), 90, 1),
          (Vector2(0, 2), 0, 1),
        ],
      ),
    ];
    removeSpriteOnAttack.add(WeaponSpritePosition.back);
    removeSpriteOnAttack.add(WeaponSpritePosition.hand);
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: 2 / 3);

  @override
  WeaponType weaponType = WeaponType.crystalSword;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
          },
        )
          ..position = Vector2(.75, -.75)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.physical] = (
      increasePercentOfBase(2, customUpgradeFactor: .2, includeBase: true)
          .toDouble(),
      increasePercentOfBase(5, customUpgradeFactor: .2, includeBase: true)
          .toDouble()
    );
    attackTickRate.baseParameter = increasePercentOfBase(
      .6,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      4,
      customUpgradeFactor: 1 / 4,
      includeBase: true,
    ).round();
    super.mapUpgrade();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class PhaseDagger extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  PhaseDagger(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(.5, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        meleeAttackType: MeleeType.stab,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
            },
          )..opacity = (.5 * rng.nextDouble()) + .5;
        },
        weaponTrailConfig: WeaponTrailConfig(
          color: DamageType.psychic.color.withOpacity(.5),
        ),
        chargePattern: [],
        attackPattern: [
          (Vector2(.5, -.5), -5, 1),
          (Vector2(0, 1.5), 5, 1),
          // (Vector2(.25, 0), -35, 1)  ,
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(.5, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        meleeAttackType: MeleeType.stab,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
            },
          )..opacity = (.5 * rng.nextDouble()) + .5;
        },
        weaponTrailConfig: WeaponTrailConfig(color: DamageType.psychic.color),
        chargePattern: [],
        attackPattern: [
          (Vector2(-.5, -.5), 5, 1),
          (Vector2(0, 1.5), -5, 1),
          // (Vector2(.25, 0), -35, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(.5, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
            },
          )..opacity = (.5 * rng.nextDouble()) + .5;
        },
        weaponTrailConfig: WeaponTrailConfig(color: DamageType.psychic.color),
        chargePattern: [],
        attackPattern: [
          (Vector2(-1.5, .5), 25, 1),
          (Vector2(3, .5), -55, 1),
          // (Vector2(.25, 0), -35, 1),
        ],
      ),
    ];

    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  WeaponType weaponType = WeaponType.phaseDagger;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
          },
        )
          ..angle = radians(-15)
          ..position = Vector2(.15, -.5);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.phaseDaggerIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.physical] = (
      increasePercentOfBase(1, customUpgradeFactor: .2, includeBase: true)
          .toDouble(),
      increasePercentOfBase(3, customUpgradeFactor: .2, includeBase: true)
          .toDouble()
    );
    baseDamage.damageBase[DamageType.psychic] =
        baseDamage.damageBase[DamageType.physical]!;

    attackTickRate.baseParameter =
        increasePercentOfBase(.3, customUpgradeFactor: -.05, includeBase: true)
            .toDouble();

    pierce.baseParameter =
        increasePercentOfBase(2, customUpgradeFactor: .5 / 2, includeBase: true)
            .round();
    chainingTargets.baseParameter =
        increasePercentOfBase(1, customUpgradeFactor: 1, includeBase: true)
            .round();

    weaponStaminaCost.baseParameter =
        increasePercentOfBase(10, customUpgradeFactor: -0.05, includeBase: true)
            .toDouble();

    super.mapUpgrade();
  }

  @override
  Set<WeaponSpritePosition> get removeSpriteOnAttack => {
        WeaponSpritePosition.back,
      };

  @override
  set setSecondaryFunctionality(dynamic item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class AethertideSpear extends PlayerWeapon
    with
        MeleeFunctionality,
        FullAutomatic,
        StaminaCostFunctionality,
        ProjectileFunctionality {
  AethertideSpear(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .9)),
        weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
        meleeAttackType: MeleeType.stab,
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.aethertideSpearIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(.2, -.7), 0, 1),
          (Vector2(0, 6), 0, 1),
          // (Vector2(0, 1.5), -20, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        meleeAttackType: MeleeType.stab,
        weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.aethertideSpearIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(-.2, -.7), 0, 1),
          (Vector2(0, 6), 0, 1),
          // (Vector2(0, 1.5), 20, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(3, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.aethertideSpearIdle1,
            },
          );
        },
        onAttack: () {
          if (entityAncestor is DashFunctionality) {
            final dash = entityAncestor! as DashFunctionality;
            pierce.setParameterFlatValue(weaponId, 999);
            dash.beginDash(
              power: -1,
              weaponSource: true,
              triggerFunctions: false,
            );
            entityAncestor?.game
                .gameAwait(dash.dashDuration.parameter)
                .then((value) => pierce.removeFlatKey(weaponId));
          }
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(0, 3), 370, 1),
          (Vector2(0, -4), -10, 1),
        ],
      ),
    ];

    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = .2;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .5);

  @override
  WeaponType weaponType = WeaponType.aethertideSpear;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.aethertideSpearIdle1,
          },
        )
          ..position = Vector2(weaponLength / 2, -weaponLength / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.aethertideSpearIdle1,
          },
        );
    }
  }

  @override
  DamageType? get primaryDamageType => DamageType.magic;

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.magic] = (
      increasePercentOfBase(8, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(14, customUpgradeFactor: .1, includeBase: true)
          .toDouble()
    );

    attackTickRate.baseParameter = increasePercentOfBase(
      .8,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      4,
      customUpgradeFactor: 1 / 4,
      includeBase: true,
    ).round();
    weaponStaminaCost.baseParameter =
        increasePercentOfBase(20, customUpgradeFactor: -0.05, includeBase: true)
            .toDouble();

    super.mapUpgrade();
  }

  @override
  Set<WeaponSpritePosition> get removeSpriteOnAttack => {
        WeaponSpritePosition.back,
      };

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

  @override
  Future<void> shootProjectile(AttackConfiguration attackConfiguration) async {
    if (upgradeLevel < 3) {
      return;
    }
    return super.shootProjectile(
      attackConfiguration,
    );
  }

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;
}

class SanctifiedEdge extends PlayerWeapon
    with
        MeleeFunctionality,
        ProjectileFunctionality,
        SemiAutomatic,
        MeleeChargeReady,
        ChargeEffect,
        StaminaCostFunctionality {
  SanctifiedEdge(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            idleOnly: true,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.sanctifiedEdgeIdle1,
            },
          );
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
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.sanctifiedEdgeIdle1,
            },
          );
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
        ],
      ),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
    projectileRelativeSize.baseParameter = .5;
  }

  @override
  double distanceFromPlayer = .2;

  @override
  // TODO: implement tipOffset
  Vector2 get tipOffset => Vector2(0, weaponLength / 4);

  @override
  ProjectileType? projectileType = ProjectileType.holyBullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .5);

  @override
  WeaponType weaponType = WeaponType.sanctifiedEdge;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          baseOffset,
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.sanctifiedEdgeIdle1,
          },
        )
          ..position = Vector2(weaponLength / 3, .35)
          ..angle = radians(135);
      default:
        return WeaponSpriteAnimation(
          baseOffset,
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.sanctifiedEdgeIdle1,
          },
        );
    }
  }

  @override
  Future<void> shootProjectile(
    AttackConfiguration attackConfiguration,
  ) async {
    if (attackConfiguration.holdDurationPercent < .75) {
      return;
    }
    return super.shootProjectile(
      attackConfiguration,
    );
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.energy] = (
      increasePercentOfBase(4, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(10, customUpgradeFactor: .1, includeBase: true)
          .toDouble()
    );

    attackTickRate.baseParameter = increasePercentOfBase(
      .7,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();

    pierce.baseParameter = increasePercentOfBase(
      5,
      customUpgradeFactor: 1 / 4,
      includeBase: true,
    ).round();

    weaponStaminaCost.baseParameter =
        increasePercentOfBase(12, customUpgradeFactor: -0.05, includeBase: true)
            .toDouble();

    projectileRelativeSize.baseParameter = 1.5;
    super.mapUpgrade();
  }

  @override
  Set<WeaponSpritePosition> get removeSpriteOnAttack => {
        WeaponSpritePosition.back,
      };

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

  @override
  void unMapUpgrade() {}
}

class FlameSword extends PlayerWeapon
    with
        MeleeFunctionality,
        FullAutomatic,
        ReloadFunctionality,
        StaminaCostFunctionality {
  FlameSword(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    // maxChainingTargets.baseParameter = 6;
    // baseAttackCount.baseParameter = 5;
    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        weaponTrailConfig:
            WeaponTrailConfig(color: DamageType.fire.color.withOpacity(.75)),
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(.2, 0), -360, 1),
          (Vector2(.2, 1), 0, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .9)),
        weaponTrailConfig:
            WeaponTrailConfig(color: DamageType.fire.color.withOpacity(.75)),
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
            },
          );
        },
        flippedDuringAttack: true,
        chargePattern: [],
        attackPattern: [
          (Vector2(-.2, 0), 360, 1),
          (Vector2(-.2, 1), 0, 1),
        ],
      ),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = .2;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .5);

  @override
  WeaponType weaponType = WeaponType.fireSword;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          baseOffset,
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
          },
        )
          ..position = Vector2(-.6, .6)
          ..angle = radians(-145);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.fireSwordIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.fire] = (
      increasePercentOfBase(20, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(25, customUpgradeFactor: .1, includeBase: true)
          .toDouble()
    );
    attackTickRate.baseParameter = increasePercentOfBase(
      .6,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      5,
      customUpgradeFactor: 1 / 4,
      includeBase: true,
    ).round();
    weaponStaminaCost.baseParameter =
        increasePercentOfBase(25, customUpgradeFactor: -0.05, includeBase: true)
            .toDouble();

    super.mapUpgrade();
  }

  @override
  Set<WeaponSpritePosition> get removeSpriteOnAttack => {
        WeaponSpritePosition.back,
      };

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class LargeSword extends PlayerWeapon
    with
        MeleeFunctionality,
        SemiAutomatic,
        MeleeChargeReady,
        StaminaCostFunctionality {
  LargeSword(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .75)),
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.largeSwordIdle1,
            },
          );
        },
        chargePattern: [
          (Vector2(0, .3), -20, .8),
          (Vector2(.2, .3), -40, 1),
          (Vector2(.1, .3), -60, 1.2),
        ],
        attackPattern: [
          (Vector2(0, -.2), 140, 1),
          (Vector2(1, .2), -45, 1.1),
        ],
      ),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = .2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  void meleeAttack(
    int? index, {
    required AttackConfiguration attackConfiguration,
    double? angle,
    bool forceCrit = false,
  }) {
    if (attackConfiguration.holdDurationPercent < .6) {
      return;
    }

    super.meleeAttack(
      index,
      forceCrit: forceCrit,
      attackConfiguration: attackConfiguration,
    );
  }

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  WeaponType weaponType = WeaponType.largeSword;

  @override
  double get attackRateDelay => 0;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          parentJoint: parentJoint,
          weapon: this,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.largeSwordIdle1,
          },
        )
          ..position = Vector2(weaponLength / 2, -weaponLength / 2)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.largeSwordIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.physical] = (
      increasePercentOfBase(25, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(45, customUpgradeFactor: .1, includeBase: true)
          .toDouble()
    );
    attackTickRate.baseParameter = increasePercentOfBase(
      2,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      10,
      customUpgradeFactor: 1 / 4,
      includeBase: true,
    ).round();
    weaponStaminaCost.baseParameter =
        increasePercentOfBase(35, customUpgradeFactor: -0.05, includeBase: true)
            .toDouble();

    super.mapUpgrade();
  }

  @override
  Set<WeaponSpritePosition> get removeSpriteOnAttack => {
        WeaponSpritePosition.back,
      };

  @override
  @override
  set setSecondaryFunctionality(dynamic item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class FrostKatana extends PlayerWeapon
    with
        MeleeFunctionality,
        SemiAutomatic,
        MeleeChargeReady,
        StaminaCostFunctionality {
  FrostKatana(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    onAttackMelee.add((attackConfiguration, weapon) {
      if (entityAncestor is DashFunctionality) {
        final dash = entityAncestor! as DashFunctionality;
        if (attackConfiguration.holdDurationPercent < .6) {
          return;
        }
        pierce.setParameterFlatValue(weaponId, 999);
        dash.beginDash(
          power: attackConfiguration.holdDurationPercent * 2.5,
          weaponSource: true,
          triggerFunctions: false,
        );
        entityAncestor?.game
            .gameAwait(dash.dashDuration.parameter)
            .then((value) => pierce.removeFlatKey(weaponId));
      }
    });

    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (() => Vector2(1, weaponLength), (.1, .9)),
        entitySpriteAnimation: null,
        weaponTrailConfig: WeaponTrailConfig(
          bottomStartFromTipPercent: .25,
        ),
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.frostKatanaIdle1,
            },
          );
        },
        chargePattern: [
          (Vector2(-.2, -.2), -120, 1),
          (Vector2(.2, -.2), -100, 1),
          (Vector2(.2, -.4), -80, 1),
        ],
        attackPattern: [
          (Vector2(0, -.2), 140, 1),
          (Vector2(1, .2), -45, 1.1),
        ],
      ),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = .2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .5);

  @override
  WeaponType weaponType = WeaponType.frostKatana;

  @override
  double get attackRateDelay => attackTickRate.parameter / 4;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          baseOffset,
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.frostKatanaIdle1,
          },
        )
          ..position = Vector2(.6, -1.2)
          ..angle = radians(30);
      default:
        return WeaponSpriteAnimation(
          baseOffset,
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.frostKatanaIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    customChargeDuration = 1;

    baseDamage.damageBase[DamageType.frost] = (
      increasePercentOfBase(5, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(15, customUpgradeFactor: .1, includeBase: true)
          .toDouble()
    );
    attackTickRate.baseParameter = increasePercentOfBase(
      .5,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      5,
      customUpgradeFactor: 1 / 4,
      includeBase: true,
    ).round();
    weaponStaminaCost.baseParameter =
        increasePercentOfBase(35, customUpgradeFactor: -0.05, includeBase: true)
            .toDouble();

    super.mapUpgrade();
  }

  @override
  Set<WeaponSpritePosition> get removeSpriteOnAttack => {
        WeaponSpritePosition.back,
      };

  @override
  set setSecondaryFunctionality(dynamic item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class SwordOfJustice extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  SwordOfJustice(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    // maxChainingTargets.baseParameter = 3;

    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .9)
        ),
        entitySpriteAnimation: null,
        meleeAttackType: MeleeType.stab,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
            },
          );
        },
        weaponTrailConfig:
            WeaponTrailConfig(color: ApolloColorPalette.red.color),
        chargePattern: [],
        attackPattern: [
          (Vector2(0, -.5), -35, 1),
          (Vector2(0, 1.5), 0, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .9)
        ),
        meleeAttackType: MeleeType.stab,
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
            },
          );
        },
        weaponTrailConfig: WeaponTrailConfig(disableTrail: true),
        chargePattern: [],
        attackPattern: [
          (Vector2(.2, -.25), -0, 1),
          (Vector2(0, 2), 0, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .9)
        ),
        entitySpriteAnimation: null,
        meleeAttackType: MeleeType.stab,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
            },
          );
        },
        weaponTrailConfig:
            WeaponTrailConfig(color: ApolloColorPalette.red.color),
        chargePattern: [],
        attackPattern: [
          (Vector2(-.2, -.5), 35, 1),
          // (Vector2(.2, 1), 90, 1),
          (Vector2(0, 1.5), 0, 1),
        ],
      ),
    ];

    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back
  ];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: .5);

  @override
  WeaponType weaponType = WeaponType.swordOfJustice;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
          },
        )
          ..position = Vector2(.75, -1.75)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.swordOfJusticeIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    onHitMelee.add((damage) {
      if (damage.victim.healthPercentage <
          increasePercentOfBase(
            .1,
            customUpgradeFactor: .15,
            includeBase: true,
          ).toDouble()) {
        damage.damageMap.clear();
        damage.damageMap[DamageType.fire] = double.infinity;
        damage.checkCrit(force: true);
      }
      return false;
    });

    baseDamage.damageBase[DamageType.physical] = (
      increasePercentOfBase(2, customUpgradeFactor: .1, includeBase: true)
          .toDouble(),
      increasePercentOfBase(5, customUpgradeFactor: .1, includeBase: true)
          .toDouble()
    );

    baseDamage.damageBase[DamageType.fire] =
        baseDamage.damageBase[DamageType.physical]!;

    attackTickRate.baseParameter = increasePercentOfBase(
      .4,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      5,
      customUpgradeFactor: 1 / 4,
      includeBase: true,
    ).round();
    weaponStaminaCost.baseParameter =
        increasePercentOfBase(15, customUpgradeFactor: -0.05, includeBase: true)
            .toDouble();

    super.mapUpgrade();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class TuiCamai extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  TuiCamai(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    onHitMelee.add((damage) {
      entityAncestor?.gameEnviroment.addPhysicsComponent([
        SummonedChildEntity(
          initialPosition: damage.victim.position,
          parentEntity: entityAncestor!,
          damageBase: {DamageType.psychic: (1, 2)},
          upgradeLevel: upgradeLevel,
        ),
      ]);
      return false;
    });

    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .8)
        ),
        flippedDuringAttack: true,
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(0, -1), -210, 1),
          (Vector2(0, 1), 30, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .8)
        ),
        flippedDuringAttack: true,
        entitySpriteAnimation: spriteAnimations.playerCharacterOneDash1,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(0, -1), 210, 1),
          (Vector2(0, 1), -30, 1),
        ],
      ),
    ];
    removeSpriteOnAttack.add(WeaponSpritePosition.back);
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.back,
  ];

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: 2 / 3);

  @override
  WeaponType weaponType = WeaponType.tuiCamai;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
          },
        )
          ..position = Vector2(.75, -.75)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.psychic] = (
      increasePercentOfBase(1, customUpgradeFactor: .2, includeBase: true)
          .toDouble(),
      increasePercentOfBase(2, customUpgradeFactor: .2, includeBase: true)
          .toDouble()
    );
    attackTickRate.baseParameter = increasePercentOfBase(
      .8,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      1,
      customUpgradeFactor: 1,
      includeBase: true,
    ).round();
    super.mapUpgrade();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class SwordKladenets extends PlayerWeapon
    with FullAutomatic, StaminaCostFunctionality {
  SwordKladenets(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    removeSpriteOnAttack.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  ChildEntity? _swordEntity;

  @override
  void startAttacking() {
    _swordEntity = SummonedSwordEntityTest(
      parentEntity: entityAncestor!,
      upgradeLevel: upgradeLevel,
      initialPosition: entityAncestor!.center,
    );

    entityAncestor?.gameEnviroment.addPhysicsComponent([_swordEntity!]);
    super.startAttacking();
  }

  @override
  void endAttacking() {
    _swordEntity?.removeFromParent();
    super.endAttacking();
  }

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(baseParameter: 2 / 3);

  @override
  WeaponType weaponType = WeaponType.swordKladenets;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
          },
        )
          ..position = Vector2(.75, -.75)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.crystalSwordIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.psychic] = (
      increasePercentOfBase(1, customUpgradeFactor: .2, includeBase: true)
          .toDouble(),
      increasePercentOfBase(2, customUpgradeFactor: .2, includeBase: true)
          .toDouble()
    );
    attackTickRate.baseParameter = increasePercentOfBase(
      .8,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      1,
      customUpgradeFactor: 1,
      includeBase: true,
    ).round();
    super.mapUpgrade();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}

class MindStaff extends PlayerWeapon
    with MeleeFunctionality, FullAutomatic, StaminaCostFunctionality {
  MindStaff(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    meleeAttacks = [
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .8)
        ),
        flippedDuringAttack: true,
        entitySpriteAnimation: null,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.mindStaffIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(0, -1.4), -360, 1),
          (Vector2(0, 0), 0, 1),
        ],
      ),
      MeleeAttack(
        attackHitboxSizeBuild: (
          () => Vector2(weaponLength / 3.5, weaponLength),
          (.1, .8)
        ),
        entitySpriteAnimation: null,
        flippedDuringAttack: true,
        attackSpriteAnimationBuild: () async {
          return WeaponSpriteAnimation(
            Vector2.zero(),
            weapon: this,
            parentJoint: null,
            weaponAnimations: {
              WeaponStatus.idle: await spriteAnimations.mindStaffIdle1,
            },
          );
        },
        chargePattern: [],
        attackPattern: [
          (Vector2(0, -1.6), 360, 1),
          (Vector2(0, 0), 0, 1),
        ],
      ),
    ];
    removeSpriteOnAttack.add(WeaponSpritePosition.back);
    spirteComponentPositions.add(WeaponSpritePosition.back);
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.back,
  ];

  @override
  DoubleParameterManager weaponScale = DoubleParameterManager(baseParameter: 1);

  @override
  WeaponType weaponType = WeaponType.mindStaff;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.mindStaffIdle1,
          },
        )
          ..position = Vector2(.75, -.75)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
          Vector2.zero(),
          weapon: this,
          parentJoint: parentJoint,
          weaponAnimations: {
            WeaponStatus.idle: await spriteAnimations.mindStaffIdle1,
          },
        );
    }
  }

  @override
  void mapUpgrade() {
    baseDamage.damageBase[DamageType.psychic] = (
      increasePercentOfBase(1, customUpgradeFactor: .2, includeBase: true)
          .toDouble(),
      increasePercentOfBase(2, customUpgradeFactor: .2, includeBase: true)
          .toDouble()
    );
    attackTickRate.baseParameter = increasePercentOfBase(
      .8,
      customUpgradeFactor: -.05,
      includeBase: true,
    ).toDouble();
    pierce.baseParameter = increasePercentOfBase(
      1,
      customUpgradeFactor: 1,
      includeBase: true,
    ).round();
    super.mapUpgrade();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }
}
