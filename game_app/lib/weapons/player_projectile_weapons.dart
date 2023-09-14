// ignore_for_file: overridden_fields

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
  Pistol(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.magic] = (7, 10);
    maxAttacks.baseParameter = 8;
    projectileVelocity.baseParameter = 30;
    attackTickRate.baseParameter = .3;
    maxHomingTargets.baseParameter = 1;
    pierce.baseParameter = 2;
  }

  @override
  WeaponType weaponType = WeaponType.crystalPistol;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  late CircleComponent circle;

  @override
  double distanceFromPlayer = .0;

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
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          Vector2(-.1, 1.6),
          weaponAnimations: {
            'muzzle_flash': await loadSpriteAnimation(
                1, 'weapons/muzzle_flash.png', .2, false),
            WeaponStatus.idle:
                await loadSpriteAnimation(1, 'weapons/pistol.png', 1, true)
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double weaponSize = 1.356;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;
}

class Shotgun extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  Shotgun(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.physical] = (5, 8);
    maxAttacks.baseParameter = 5;
    attackTickRate.baseParameter = .8;
    baseAttackCount.baseParameter = 4;
  }
  @override
  WeaponType weaponType = WeaponType.scatterBlast;

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
          Vector2.zero(),
          Vector2(0, 1.65),
          weaponAnimations: {
            // WeaponStatus.attack: await loadSpriteAnimation(
            //     4, 'weapons/pistol_attack.png', .1, false),
            // 'muzzle_flash': await loadSpriteAnimation(
            //     1, 'weapons/muzzle_flash.png', .2, false),
            WeaponStatus.idle: await loadSpriteAnimation(
                1, 'weapons/scatter_vine.png', 1, true)
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = 2;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;
}

class LongRangeRifle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  LongRangeRifle(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.magic] = (50, 100);
    maxAttacks.baseParameter = 10;
    attackTickRate.baseParameter = .1;
    projectileVelocity.baseParameter = 30;
    baseAttackCount.baseParameter = 1;
    pierce.baseParameter = 0;
  }
  @override
  WeaponType weaponType = WeaponType.scryshot;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  Vector2 tipOffset = Vector2(-0.1, 2.225);

  @override
  void unMapUpgrade() {}

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          tipOffset,
          weaponAnimations: {
            WeaponStatus.attack: await loadSpriteAnimation(
                6, 'weapons/long_rifle_attack.png', .02, false),
            'muzzle_flash': await loadSpriteAnimation(
                5, 'weapons/projectiles/magic_muzzle_flash.png', .07, false),
            WeaponStatus.idle: await loadSpriteAnimation(
                19, 'weapons/long_rifle_idle.png', .2, true)
          },
          flashSize: 2.0,
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  update(double dt) {
    this;
    super.update(dt);
  }

  @override
  double distanceFromPlayer = -.5;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = 3.0;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class AssaultRifle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  AssaultRifle(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.fire] = (1, 3);
    maxAttacks.baseParameter = 22;
    attackTickRate.baseParameter = .1;
    // baseAttackCount.baseParameter = 10;
    weaponRandomnessPercent.baseParameter = .025;
    projectileVelocity.baseParameter = 40;
  }
  @override
  WeaponType weaponType = WeaponType.arcaneBlaster;

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
          Vector2.all(0),
          Vector2(-.175, 2.65),
          weaponAnimations: {
            // WeaponStatus.attack: await loadSpriteAnimation(
            //     6, 'weapons/long_rifle_attack.png', .02, false),
            'muzzle_flash': await loadSpriteAnimation(
                5, 'weapons/projectiles/fire_muzzle_flash.png', .03, false),
            WeaponStatus.idle: await loadSpriteAnimation(
                1, 'weapons/arcane_blaster.png', .2, true)
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = 1.4;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;
}

class LaserRifle extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  LaserRifle(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (1, 3);
    baseDamage.damageBase[DamageType.fire] = (1, 3);
    baseDamage.damageBase[DamageType.frost] = (1, 3);
    baseDamage.damageBase[DamageType.psychic] = (1, 3);
    baseDamage.damageBase[DamageType.magic] = (1, 3);
    baseDamage.damageBase[DamageType.healing] = (1, 3);
    maxAttacks.baseParameter = 12;
    attackTickRate.baseParameter = .4;
    waitForAttackRate = false;
    weaponRandomnessPercent.baseParameter = .04;
    maxChainingTargets.baseParameter = 4;
    baseAttackCount.baseParameter = 5;
  }
  @override
  WeaponType weaponType = WeaponType.prismaticBeam;

  @override
  void mapUpgrade() {
    unMapUpgrade();

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {}

  @override
  // TODO: implement tipOffset
  Vector2 get tipOffset => Vector2(0, 1.42);

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          tipOffset,
          weaponAnimations: {
            // WeaponStatus.attack: await loadSpriteAnimation(
            //     6, 'weapons/long_rifle_attack.png', .02, false),
            // 'muzzle_flash': await buildSpriteSheet(
            //     5, 'weapons/projectiles/fire_muzzle_flash.png', .1, false),
            WeaponStatus.idle: await loadSpriteAnimation(
                1, 'weapons/prismatic_beam.png', .2, true)
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = 2;

  @override
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}

class RocketLauncher extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, SemiAutomatic {
  RocketLauncher(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.fire] = (40, 80);
    maxAttacks.baseParameter = 1;
    attackTickRate.baseParameter = 2;
  }
  @override
  WeaponType weaponType = WeaponType.eldritchRunner;

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
          Vector2.all(0),
          Vector2(-.175, 2.65),
          weaponAnimations: {
            // WeaponStatus.attack: await loadSpriteAnimation(
            //     7, 'weapons/long_rifle_attack.png', .02, false),
            // 'muzzle_flash': await loadSpriteAnimation(
            //     1, 'weapons/muzzle_flash.png', .2, false),
            WeaponStatus.idle: await loadSpriteAnimation(
                1, 'weapons/eldritch_runner.png', .2, true)
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = 1.7;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class Railgun extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  Railgun(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.energy] = (30, 40);
    maxAttacks.baseParameter = 2;
    attackTickRate.baseParameter = 2;
  }
  @override
  WeaponType weaponType = WeaponType.railspire;

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
          Vector2.all(0),
          Vector2(-.175, 2.65),
          weaponAnimations: {
            // WeaponStatus.attack: await loadSpriteAnimation(
            //     7, 'weapons/long_rifle_attack.png', .02, false),
            'muzzle_flash': await loadSpriteAnimation(
                1, 'weapons/muzzle_flash.png', .2, false),
            WeaponStatus.idle:
                await loadSpriteAnimation(1, 'weapons/railspire.png', .2, true)
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  double tipPositionPercent = -.02;

  @override
  ProjectileType? projectileType = ProjectileType.laser;

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;

  @override
  double weaponSize = 3;
}
