// ignore_for_file: overridden_fields
import 'package:runefire/resources/damage_type_enum.dart';

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_audio/audio_pool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:runefire/attributes/attribute_constants.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/enums.dart';

class Icecicle extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  Icecicle(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    baseDamage.damageBase[DamageType.frost] = (7, 15);
    maxAttacks.baseParameter = 3;
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 5;
    primaryDamageType = DamageType.frost;
    projectileSize.baseParameter = .6;
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
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: .5);
  @override
  late Vector2 pngSize = ImagesAssetsWeapons.bookIdle.size.asVector2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}

class PowerWord extends PlayerWeapon with ReloadFunctionality, SemiAutomatic {
  PowerWord(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
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
      position: Vector2(.5, -entityAncestor!.spriteHeight / 2),
      textRenderer: colorPalette.buildTextPaint(
        .4,
        ShadowStyle.lightGame,
        Colors.white,
      ),
    );
  }

  void explodeTextComponent() {
    final text = buildTextComponent();

    text.add(
      ScaleEffect.by(
        Vector2.all(4),
        EffectController(
          onMax: () {
            Future.delayed(.2.seconds).then((value) {
              text.add(
                ScaleEffect.to(
                  Vector2.all(0),
                  EffectController(
                    onMax: text.removeFromParent,
                    curve: Curves.easeInCirc,
                    duration: .03,
                  ),
                ),
              );
            });
          },
          curve: Curves.easeOutQuart,
          duration: .1,
        ),
      ),
    );
    entityAncestor?.add(text);
  }

  void _setWord() {
    currentWord = words[rng.nextInt(words.length)];
    toggleTextComponent(true);
  }

  List<String> words = ['die.', 'stop.', 'away.', 'fall.', 'forget.'];
  String currentWord = '';
  TextComponent? textComponent;
  @override
  void reloadCompleteFunctions() {
    _setWord();

    super.reloadCompleteFunctions();
  }

  @override
  void standardAttack([
    double holdDurationPercent = 1,
    bool callFunctions = true,
  ]) {
    toggleTextComponent(false);

    GameState().playAudio(
      'sfx/magic/power_word/fall.wav',
      useAudioPool: true,
      maxPlayers: 1,
    );

    explodeTextComponent();
    final enemies = entityAncestor!.world.physicsWorld.bodies.where(
      (element) =>
          element.userData is Enemy &&
          entityAncestor!.gameEnviroment.gameCamera.visibleWorldRect
              .containsPoint(element.worldCenter) &&
          !(element.userData! as Enemy).isDead,
    );

    switch (currentWord) {
      case 'die.':
        for (final body in enemies) {
          final enemy = body.userData! as Enemy;

          enemy.hitCheck(
            weaponId,
            calculateDamage(enemy, this)..checkCrit(true),
          );
          // enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }

        break;
      case 'stop.':
        for (final body in enemies) {
          final enemy = body.userData! as Enemy;

          enemy.addAttribute(
            AttributeType.stun,
            isTemporary: true,
            duration: 4,
            perpetratorEntity: entityAncestor,
          );
          // enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }

        break;
      case 'away.':
        for (final body in enemies) {
          final enemy = body.userData! as Enemy;

          enemy.addAttribute(
            AttributeType.fear,
            isTemporary: true,
            duration: 4,
            perpetratorEntity: entityAncestor,
          );
          // enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }

        break;
      case 'fall.':
        for (final body in enemies) {
          final enemy = body.userData! as Enemy;

          enemy.addAttribute(
            AttributeType.stun,
            isTemporary: true,
            duration: 2,
            perpetratorEntity: entityAncestor,
          );
          enemy.hitCheck(weaponId, calculateDamage(enemy, this));
          // enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
        }
        break;
      case 'forget.':
        for (final body in enemies) {
          final enemy = body.userData! as Enemy;

          enemy.addAttribute(
            AttributeType.psychic,
            isTemporary: true,
            duration: 6,
            perpetratorEntity: entityAncestor,
          );
          enemy.hitCheck(weaponId, calculateDamage(enemy, this));
          // enemy.addFloatingText(DamageType.physical, -1, false, currentWord);
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
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 1);
  @override
  late Vector2 pngSize = ImagesAssetsWeapons.bookIdle.size.asVector2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class FireballMagic extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  FireballMagic(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    baseDamage.damageBase[DamageType.fire] = (3, 7);
    maxAttacks.baseParameter = 3;
    attackTickRate.baseParameter = 1;
    pierce.baseParameter = 0;
    primaryDamageType = DamageType.fire;
    projectileSize.baseParameter = .7;

    onProjectileDeath.add((projectile) {
      final area = AreaEffect(
        sourceEntity: entityAncestor!,
        position: projectile.center,
        animationRandomlyFlipped: true,
        damage: {DamageType.fire: (10, 25)},
      );
      final particleGenerator = CustomParticleGenerator(
        minSize: .05,
        maxSize: (projectile.power * .2) + .15,
        lifespan: 1,
        frequency: 10,
        particlePosition: Vector2(2, 2),
        velocity: Vector2.all(0.5),
        durationType: DurationType.instant,
        originPosition: projectile.center.clone(),
        color: DamageType.fire.color,
        damageType: DamageType.fire,
      );

      entityAncestor?.enviroment.addPhysicsComponent([area, particleGenerator]);
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
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 1);
  @override
  late Vector2 pngSize = ImagesAssetsWeapons.bookIdle.size.asVector2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;
}

class EnergyMagic extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        // FullAutomatic,
        SemiAutomatic,
        // ChargeFullAutomatic,
        ChargeEffect {
  EnergyMagic(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    chainingTargets.baseParameter = 3;
    baseDamage.damageBase[DamageType.energy] = (1, 2);
    maxAttacks.baseParameter = 20;
    attackCountIncrease.baseParameter = 1;
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 4;
    projectileVelocity.baseParameter = 5;
    primaryDamageType = DamageType.energy;
    projectileSize.baseParameter = .065;

    attackOnRelease = false;

    attackOnChargeComplete = true;
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
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  ProjectileType? projectileType = ProjectileType.followLaser;

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 1);
  @override
  late Vector2 pngSize = ImagesAssetsWeapons.bookIdle.size.asVector2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}

class PsychicMagic extends PlayerWeapon
    with ProjectileFunctionality, ReloadFunctionality, FullAutomatic {
  PsychicMagic(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    // chainingTargets.baseParameter = 3;
    maxHomingTargets.baseParameter = 1;
    baseDamage.damageBase[DamageType.psychic] = (3, 7);
    maxAttacks.baseParameter = 20;
    attackTickRate.baseParameter = .35;
    pierce.baseParameter = 5;

    primaryDamageType = DamageType.psychic;
    projectileSize.baseParameter = 1.25;
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
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 1);
  @override
  late Vector2 pngSize = ImagesAssetsWeapons.bookIdle.size.asVector2;
}

class MagicBlast extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  MagicBlast(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    baseDamage.damageBase[DamageType.magic] = (3, 7);
    maxAttacks.baseParameter = 20;
    attackTickRate.baseParameter = 1;
    pierce.baseParameter = 5;

    primaryDamageType = DamageType.magic;
    projectileSize.baseParameter = 1.25;

    attackOnRelease = false;
    attackOnChargeComplete = true;
    dragIncreaseOnHoldComplete = .08;
    movementReductionOnHoldComplete = -.3;
  }
  @override
  WeaponType weaponType = WeaponType.magicBlast;

  @override
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  ProjectileType? projectileType = ProjectileType.followLaser;

  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 1);
  @override
  late Vector2 pngSize = ImagesAssetsWeapons.bookIdle.size.asVector2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.release;
}

class MagicMissile extends PlayerWeapon
    with
        ProjectileFunctionality,
        ReloadFunctionality,
        SemiAutomatic,
        ChargeEffect {
  MagicMissile(
    super.newUpgradeLevel,
    super.ancestor,
  ) {
    baseDamage.damageBase[DamageType.magic] = (3, 7);
    maxAttacks.baseParameter = 3;
    attackTickRate.baseParameter = .5;
    pierce.baseParameter = 0;
    primaryDamageType = DamageType.psychic;
    projectileSize.baseParameter = .2;
    maxHomingTargets.baseParameter = 1;
    increaseAttackCountWhenCharged = true;
    increaseWhenFullyCharged.baseParameter = 3;

    attackSplitFunctions[AttackSpreadType.regular] =
        (angle, attackCount) => regularAttackSpread(angle, attackCount, 90);
  }
  @override
  WeaponType weaponType = WeaponType.magicMissile;

  @override
  bool get removeSpriteOnAttack => true;

  @override
  Future<WeaponSpriteAnimation> buildJointSpriteAnimationComponent(
    PlayerAttachmentJointComponent parentJoint,
  ) async {
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
  ProjectileType? projectileType = ProjectileType.paintBullet;
  @override
  DoubleParameterManager weaponScale =
      DoubleParameterManager(minParameter: 0, baseParameter: 1);
  @override
  late Vector2 pngSize = ImagesAssetsWeapons.bookIdle.size.asVector2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;
}
