// ignore_for_file: overridden_fields

import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

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
      // case WeaponSpritePosition.back:
      //   return WeaponSpriteAnimation(
      //     Vector2.all(0),
      //     Vector2(-.175, 2.65),
      //     weaponAnimations: {
      //       WeaponStatus.idle:
      //           await loadSpriteAnimation(1, 'weapons/book_idle.png', .2, true),
      //     },
      //     parentJoint: parentJoint,
      //     weapon: this,
      //   );
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
                await loadSpriteAnimation(1, 'weapons/book_idle.png', .2, true),
            WeaponStatus.attack:
                await loadSpriteAnimation(1, 'weapons/book_fire.png', 2, false),
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
  ProjectileType? projectileType = ProjectileType.spriteBullet;

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
      textComponent ??= TextComponent(
          text: currentWord,
          position: Vector2(1, -entityAncestor!.height.parameter),
          textRenderer:
              colorPalette.buildTextPaint(1, ShadowStyle.light, Colors.white))
        ..addToParent(entityAncestor!);
    } else {
      textComponent?.removeFromParent();
      textComponent = null;
    }
  }

  void _setWord() {
    currentWord = words[rng.nextInt(words.length)];
    toggleTextComponent(true);
  }

  List<String> words = ["die", "stop", "away", "kneel"];
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

    final enemies = entityAncestor!.world.bodies.where((element) =>
        element.userData is Enemy &&
        entityAncestor!.gameEnviroment.gameCamera.visibleWorldRect
            .containsPoint(element.worldCenter) &&
        !(element.userData as Enemy).isDead);

    switch (currentWord) {
      case "die":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.takeDamage(
              weaponId,
              DamageInstance(
                damageMap: {DamageType.magic: double.infinity},
                source: entityAncestor!,
                victim: enemy,
                sourceAttack: this,
              ));
        }

        break;
      case "stop":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.addAttribute(AttributeType.stun,
              isTemporary: true,
              duration: 3,
              perpetratorEntity: entityAncestor!);
        }

        break;
      case "away":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.addAttribute(AttributeType.fear,
              isTemporary: true,
              duration: 3,
              perpetratorEntity: entityAncestor!);
        }

        break;
      case "kneel":
        for (final body in enemies) {
          final enemy = body.userData as Enemy;

          enemy.addAttribute(AttributeType.stun,
              isTemporary: true,
              duration: 1.5,
              perpetratorEntity: entityAncestor!);
          enemy.takeDamage(
              weaponId,
              DamageInstance(damageMap: {
                DamageType.magic: 15,
              }, source: entityAncestor!, victim: enemy, sourceAttack: this));
        }
        break;
      default:
    }
    super.standardAttack(holdDurationPercent, callFunctions);
  }

  @override
  // TODO: implement removeSpriteOnAttack
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      // case WeaponSpritePosition.back:
      //   return WeaponSpriteAnimation(
      //     Vector2.all(0),
      //     Vector2(-.175, 2.65),
      //     weaponAnimations: {
      //       WeaponStatus.idle:
      //           await loadSpriteAnimation(1, 'weapons/book_idle.png', .2, true),
      //     },
      //     parentJoint: parentJoint,
      //     weapon: this,
      //   );
      default:
        return WeaponSpriteAnimation(
          Vector2.all(0),
          Vector2(-.175, 2.65),
          weaponAnimations: {
            // WeaponStatus.attack: await loadSpriteAnimation(
            //     7, 'weapons/long_rifle_attack.png', .02, false),
            // 'muzzle_flash': await loadSpriteAnimation(
            //     1, 'weapons/muzzle_flash.png', .2, false),
            // WeaponStatus.idle:
            //     await loadSpriteAnimation(1, 'weapons/book_idle.png', .2, true),
            // WeaponStatus.attack:
            //     await loadSpriteAnimation(1, 'weapons/book_fire.png', 2, false),
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
    // WeaponSpritePosition.hand,
  ];

  @override
  double weaponSize = .85;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}
