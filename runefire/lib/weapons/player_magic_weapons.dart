// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../resources/functions/functions.dart';
import '../resources/enums.dart';

class Icecicle extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  Icecicle(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.frost] = (5, 10);
    maxAttacks.baseParameter = 20;
    attackTickRate.baseParameter = .35;
    primaryDamageType = DamageType.frost;
    projectileSize = .6;
    tipOffset = Vector2(0, weaponSize);
  }
  @override
  WeaponType weaponType = WeaponType.icecicleMagic;

  // @override
  // void mapUpgrade() {
  //   unMapUpgrade();

  //   super.mapUpgrade();
  // }

  // @override
  // void unMapUpgrade() {}

  @override
  // TODO: implement removeSpriteOnAttack
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.satanicBookIdle1,
            WeaponStatus.attack: await spriteAnimations.satanicBookAttack1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

  @override
  double weaponSize = .85;
}

class PowerWord extends PlayerWeapon with ReloadFunctionality, SemiAutomatic {
  PowerWord(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    maxAttacks.baseParameter = 1;
    reloadTime.baseParameter = 2;
    _setWord();

    critDamage.baseParameter = 2.5;
    baseDamage.damageBase[DamageType.magic] = (10, 20);
    critChance.baseParameter = 0.0;

    entityAncestor?.loaded.then((value) => toggleTextComponent(true));
  }
  @override
  WeaponType weaponType = WeaponType.powerWord;

  @override
  void weaponSwappedTo() {
    toggleTextComponent(true);

    super.weaponSwappedTo();
  }

  @override
  void weaponSwappedFrom() {
    toggleTextComponent(false);

    super.weaponSwappedFrom();
  }

  void toggleTextComponent(bool show) {
    if (show && isCurrentWeapon && !isReloading) {
      textComponent ??= buildTextComponent()
        ..scale = Vector2.all(0)
        ..add(ScaleEffect.to(Vector2.all(1), EffectController(duration: .1)))
        ..addToParent(entityAncestor!);
    } else {
      textComponent?.removeFromParent();
      textComponent = null;
    }
  }

  TextComponent buildTextComponent() {
    return TextComponent(
        text: currentWord,
        position: Vector2(.5, -entityAncestor!.height.parameter / 2),
        textRenderer:
            colorPalette.buildTextPaint(.4, ShadowStyle.light, Colors.white));
  }

  void explodeTextComponent() {
    final text = buildTextComponent();

    text.add(ScaleEffect.by(
        Vector2.all(4),
        EffectController(
            onMax: () {
              Future.delayed(.2.seconds).then((value) {
                text.add(ScaleEffect.to(
                    Vector2.all(0),
                    EffectController(
                        onMax: () {
                          text.removeFromParent();
                        },
                        curve: Curves.easeInCirc,
                        duration: .03)));
              });
            },
            curve: Curves.easeOutQuart,
            duration: .1)));
    entityAncestor?.add(text);
  }

  void _setWord() {
    currentWord = words[rng.nextInt(words.length)];
    toggleTextComponent(true);
  }

  List<String> words = ["die", "stop", "away", "kneel", "forget"];
  String currentWord = "";
  TextComponent? textComponent;
  @override
  void reloadCompleteFunctions() {
    _setWord();

    super.reloadCompleteFunctions();
  }

  @override
  void standardAttack(
      [double holdDurationPercent = 1, bool callFunctions = true]) {
    toggleTextComponent(false);
    explodeTextComponent();
    final enemies = entityAncestor!.world.physicsWorld.bodies.where((element) =>
        element.userData is Enemy &&
        entityAncestor!.gameEnviroment.gameCamera.visibleWorldRect
            .containsPoint(element.worldCenter) &&
        !(element.userData as Enemy).isDead);

    switch (currentWord) {
      case "die":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.takeDamage(
              weaponId, calculateDamage(enemy, this)..checkCrit(true));
          enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }

        break;
      case "stop":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.addAttribute(AttributeType.stun,
              isTemporary: true,
              duration: 4,
              perpetratorEntity: entityAncestor!);
          enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }

        break;
      case "away":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.addAttribute(AttributeType.fear,
              isTemporary: true,
              duration: 4,
              perpetratorEntity: entityAncestor!);
          enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }

        break;
      case "kneel":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.addAttribute(AttributeType.stun,
              isTemporary: true,
              duration: 2,
              perpetratorEntity: entityAncestor!);
          enemy.takeDamage(weaponId, calculateDamage(enemy, this));
          enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }
        break;
      case "forget":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.addAttribute(AttributeType.psychic,
              isTemporary: true,
              duration: 6,
              perpetratorEntity: entityAncestor!);
          enemy.takeDamage(weaponId, calculateDamage(enemy, this));
          enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }
        break;
      default:
    }
    super.standardAttack(holdDurationPercent, callFunctions);
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {},
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back,
    // WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = .85;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class FireballMagic extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  FireballMagic(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    baseDamage.damageBase[DamageType.fire] = (3, 7);
    maxAttacks.baseParameter = 20;
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 0;
    primaryDamageType = DamageType.fire;
    projectileSize = 1.5;
    tipOffset = Vector2(0, weaponSize);

    onProjectileDeath.add((projectile) {
      entityAncestor?.enviroment.physicsComponent.add(AreaEffect(
        sourceEntity: entityAncestor!,
        position: projectile.center,
        durationType: DurationType.instant,
        damage: {DamageType.fire: (10, 25)},
      ));
    });
  }
  @override
  WeaponType weaponType = WeaponType.fireballMagic;

  // @override
  // void mapUpgrade() {
  //   unMapUpgrade();

  //   super.mapUpgrade();
  // }

  // @override
  // void unMapUpgrade() {}

  @override
  // TODO: implement removeSpriteOnAttack
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.satanicBookIdle1,
            WeaponStatus.attack: await spriteAnimations.satanicBookAttack1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

  @override
  double weaponSize = .85;
}

class EnergyMagic extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  EnergyMagic(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    chainingTargets.baseParameter = 3;
    baseDamage.damageBase[DamageType.energy] = (1, 3);
    maxAttacks.baseParameter = 20;
    baseAttackCount.baseParameter = 3;
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 4;
    tipOffset = Vector2(0, weaponSize);

    primaryDamageType = DamageType.energy;
    projectileSize = .75;

    // onProjectileDeath.add((projectile) {
    //   entityAncestor?.enviroment.physicsComponent.add(AreaEffect(
    //     sourceEntity: entityAncestor!,
    //     position: projectile.center,
    //     durationType: DurationType.instant,
    //     damage: {DamageType.fire: (10, 25)},
    //   ));
    // });
  }
  @override
  WeaponType weaponType = WeaponType.energyMagic;

  // @override
  // void mapUpgrade() {
  //   unMapUpgrade();

  //   super.mapUpgrade();
  // }

  // @override
  // void unMapUpgrade() {}

  @override
  // TODO: implement removeSpriteOnAttack
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.satanicBookIdle1,
            WeaponStatus.attack: await spriteAnimations.satanicBookAttack1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

  @override
  double weaponSize = .85;
}

class PsychicMagic extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  PsychicMagic(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    // chainingTargets.baseParameter = 3;
    maxHomingTargets.baseParameter = 1;
    baseDamage.damageBase[DamageType.psychic] = (3, 7);
    maxAttacks.baseParameter = 20;
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 5;
    tipOffset = Vector2(0, weaponSize);

    primaryDamageType = DamageType.psychic;
    projectileSize = 1.25;

    // onProjectileDeath.add((projectile) {
    //   entityAncestor?.enviroment.physicsComponent.add(AreaEffect(
    //     sourceEntity: entityAncestor!,
    //     position: projectile.center,
    //     durationType: DurationType.instant,
    //     damage: {DamageType.fire: (10, 25)},
    //   ));
    // });
  }
  @override
  WeaponType weaponType = WeaponType.psychicMagic;

  // @override
  // void mapUpgrade() {
  //   unMapUpgrade();

  //   super.mapUpgrade();
  // }

  // @override
  // void unMapUpgrade() {}

  @override
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.satanicBookIdle1,
            WeaponStatus.attack: await spriteAnimations.satanicBookAttack1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

  @override
  double weaponSize = .85;
}

class MagicBlast extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  MagicBlast(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    // chainingTargets.baseParameter = 3;
    // maxHomingTargets.baseParameter = 1;
    baseDamage.damageBase[DamageType.magic] = (3, 7);
    maxAttacks.baseParameter = 20;
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 5;
    tipOffset = Vector2(0, weaponSize);

    primaryDamageType = DamageType.magic;
    projectileSize = 1.25;

    // onProjectileDeath.add((projectile) {
    //   entityAncestor?.enviroment.physicsComponent.add(AreaEffect(
    //     sourceEntity: entityAncestor!,
    //     position: projectile.center,
    //     durationType: DurationType.instant,
    //     damage: {DamageType.fire: (10, 25)},
    //   ));
    // });
  }
  @override
  WeaponType weaponType = WeaponType.magicBlast;

  // @override
  // void mapUpgrade() {
  //   unMapUpgrade();

  //   super.mapUpgrade();
  // }

  // @override
  // void unMapUpgrade() {}

  @override
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          weaponAnimations: {
            'muzzle_flash': await spriteAnimations.magicMuzzleFlash1,
            WeaponStatus.idle: await spriteAnimations.satanicBookIdle1,
            WeaponStatus.attack: await spriteAnimations.satanicBookAttack1,
          },
          parentJoint: parentJoint,
          weapon: this,
        );
    }
  }

  @override
  double distanceFromPlayer = 1;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    // WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];

  @override
  ProjectileType? projectileType = ProjectileType.magicProjectile;

  @override
  double weaponSize = .85;
}
