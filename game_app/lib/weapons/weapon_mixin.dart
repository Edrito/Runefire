import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/data_classes/base.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/secondary_abilities.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:recase/recase.dart';

import '../resources/functions/vector_functions.dart';
import '../resources/enums.dart';

mixin MultiWeaponCheck on Weapon {
  @override
  void attackAttempt([double holdDurationPercent = 1]) {
    if ((entityAncestor as AttackFunctionality).currentWeapon != this) return;

    super.attackAttempt(holdDurationPercent);
  }
}

mixin ReloadFunctionality on Weapon {
  final IntParameterManager maxAttacks = IntParameterManager(baseParameter: 10);

  ///How long in seconds to reload
  final DoubleParameterManager reloadTime =
      DoubleParameterManager(baseParameter: 1, minParameter: 0);

  double get percentReloaded =>
      (reloadTimer?.timer.current ?? reloadTime.parameter) /
      reloadTime.parameter;

  //Status of reloading
  int spentAttacks = 0;

  int? get remainingAttacks =>
      maxAttacks.parameter == 0 ? null : maxAttacks.parameter - spentAttacks;

  ///Timer that when completes finishes reload
  TimerComponent? reloadTimer;

  @override
  FutureOr<void> onLoad() {
    // if (this is MeleeFunctionality) {
    //   assert(
    //       maxAttacks.parameter == (this as MeleeFunctionality).attacksLength ||
    //           maxAttacks.parameter == 0);
    // }
    return super.onLoad();
  }

  @override
  void attackAttempt([double holdDurationPercent = 1]) {
    //Do not attack if reloading
    if (isReloading) {
      return;
    }

    spentAttacks++;
    super.attackAttempt(holdDurationPercent);

    //Check if needs to reload after an attack
    reloadCheck();
  }

  void stopReloading() {
    spentAttacks = 0;
    reloadTimer?.timer.stop();
    reloadTimer?.removeFromParent();
    reloadTimer = null;
    if (this is FullAutomatic) {
      var fullAuto = this as FullAutomatic;
      fullAuto.attackTimer?.timer.reset();
      fullAuto.attackTimer?.onTick();
    }

    removeReloadAnimation();
  }

  void removeReloadAnimation() {
    entityAncestor?.entityStatusWrapper
        .removeReloadAnimation(weaponId, isSecondaryWeapon);
  }

  void createReloadBar() {
    if (entityAncestor == null) return;
    entityAncestor!.entityStatusWrapper.addReloadAnimation(
        weaponId, reloadTime.parameter, reloadTimer!, isSecondaryWeapon);
  }

  void reloadCheck() {
    if (remainingAttacks != 0 || isReloading || reloadTime.parameter == 0) {
      return;
    }
    reload();
  }

  void reload() {
    if (this is MeleeFunctionality) {
      (this as MeleeFunctionality).resetToFirstSwings();
    }
    if (this is AttributeWeaponFunctionsFunctionality) {
      final attributeWeaponFunctions =
          this as AttributeWeaponFunctionsFunctionality;
      for (var attribute in attributeWeaponFunctions.onReload) {
        attribute();
      }
    }
    reloadTimer = TimerComponent(
      period: reloadTime.parameter,
      removeOnFinish: true,
      onTick: () {
        stopReloading();
      },
    )..addToParent(this);
    createReloadBar();
  }
}

mixin StaminaCostFunctionality on Weapon {
  final DoubleParameterManager weaponStaminaCost = DoubleParameterManager(
      baseParameter: 10, minParameter: 0, maxParameter: 200);

  @override
  void attackAttempt([double holdDurationPercent = 1]) {
    if (entityAncestor is StaminaFunctionality) {
      final stamina = entityAncestor as StaminaFunctionality;
      if (stamina.remainingStamina < weaponStaminaCost.parameter) return;
      stamina.modifyStamina(-weaponStaminaCost.parameter);
    }
    super.attackAttempt(holdDurationPercent);
  }
}

mixin MeleeFunctionality on Weapon {
  ///How many attacks are in the melee combo
  int get numberOfAttacks => attackHitboxPatterns.length ~/ 2;

  ///Pairs of attack patterns
  ///
  ///Start position - Start angle
  ///
  ///Finish position - Finish angle
  List<(Vector2, double)> attackHitboxPatterns = [];

  ///If melee, must be the same length as [attacksLength] or 0
  List<SpriteAnimation> attackEntitySpriteAnimations = [];

  ///Must be the same length as [attacksLength] or 0
  List<SpriteAnimation> attackHitboxSpriteAnimations = [];

  ///Must be the same length as [attacksLength] or 0
  List<SpriteAnimation> attackWeaSpriteAnimations = [];

  ///Must be the same length as [attacksLength]
  List<Vector2> attackHitboxSizes = [];

  int meleeAttacksCompletedIndex = 0;
  Vector2? currentSwingPosition;
  List<double> currentSwingAngles = [];

  @override
  bool get attacksAreActive => activeSwings.isNotEmpty;
  List<MeleeAttack> activeSwings = [];

  int get attacksLength => (attackHitboxPatterns.length / 2).ceil();

  int get currentAttackPatternIndex =>
      (meleeAttacksCompletedIndex -
          (((meleeAttacksCompletedIndex / (attacksLength)).floor()) *
              (attacksLength))) *
      2;

  @override
  FutureOr<void> onLoad() {
    if (this is ReloadFunctionality) {
      (this as ReloadFunctionality).maxAttacks.baseParameter = numberOfAttacks;
    }
    return super.onLoad();
  }

  @override
  void attack([double chargeAmount = 1]) async {
    List<Component> returnList = [];
    final currentSwingAngle = entityAncestor?.handJoint.angle ?? 0;

    List<double> temp = splitRadInCone(
        currentSwingAngle, attackCount, maxSpreadDegrees.parameter);

    for (var deltaDirection in temp) {
      currentSwingAngles.add(deltaDirection);

      returnList.add(MeleeAttack(
        initPosition: (Vector2.zero()) * distanceFromPlayer,
        initAngle: deltaDirection,
        index: currentAttackPatternIndex,
        parentWeapon: this,
      ));
    }

    entityAncestor?.addAll(returnList);
    meleeAttacksCompletedIndex++;
    super.attack(chargeAmount);
  }

  @override
  void endAttacking() {
    if (this is! ReloadFunctionality && this is! SemiAutomatic) {
      resetToFirstSwings();
    }
    super.endAttacking();
  }

  @override
  void attackAttempt([double holdDurationPercent = 1]) async {
    if (meleeAttacksCompletedIndex >= attacksLength) {
      resetToFirstSwings();
    }
    currentSwingPosition = Vector2.zero();

    if (this is SemiAutomatic) {
      holdDurationPercent =
          (this as SemiAutomatic).holdDurationPercentOfAttackRate;
    }

    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    attackOnAnimationFinish
        ? await entityAncestor?.setEntityStatus(
            EntityStatus.attack,
            attackEntitySpriteAnimations.isNotEmpty
                ? attackEntitySpriteAnimations[meleeAttacksCompletedIndex]
                : null)
        : entityAncestor?.setEntityStatus(
            EntityStatus.attack,
            attackEntitySpriteAnimations.isNotEmpty
                ? attackEntitySpriteAnimations[meleeAttacksCompletedIndex]
                : null);
    super.attackAttempt(holdDurationPercent);
  }

  void resetToFirstSwings() {
    currentSwingAngles.clear();
    currentSwingPosition = null;
    meleeAttacksCompletedIndex = 0;
  }
}

mixin SecondaryFunctionality on Weapon {
  set setSecondaryFunctionality(dynamic item) {
    if (item is Weapon) {
      _secondaryWeapon = item;
      _secondaryWeapon?.weaponAttachmentPoints = weaponAttachmentPoints;
      _secondaryWeapon?.isSecondaryWeapon = true;
      _secondaryWeapon?.weaponId = weaponId;
      assert(_secondaryWeapon is! FullAutomatic);
    } else if (item is SecondaryWeaponAbility) {
      _secondaryWeaponAbility = item;
      add(item);
    }
  }

  bool get secondaryIsWeapon => _secondaryWeapon != null;

  Weapon? _secondaryWeapon;
  SecondaryWeaponAbility? _secondaryWeaponAbility;

  @override
  void weaponSwappedTo() {
    final entityStatusWrapper = entityAncestor?.entityStatusWrapper;
    entityStatusWrapper?.showReloadAnimations(weaponId);
    super.weaponSwappedTo();
  }

  @override
  void weaponSwappedFrom() {
    final entityStatusWrapper = entityAncestor?.entityStatusWrapper;
    entityStatusWrapper?.hideReloadAnimations(weaponId);
    super.weaponSwappedFrom();
  }

  @override
  void startAltAttacking() {
    _secondaryWeapon?.startAttacking();
    _secondaryWeaponAbility?.startAbilityCheck();
  }

  @override
  void endAltAttacking() {
    _secondaryWeapon?.endAttacking();
    _secondaryWeaponAbility?.endAbility();
  }
}

mixin ProjectileFunctionality on Weapon {
  //META
  abstract ProjectileType? projectileType;
  bool allowProjectileRotation = false;

  final IntParameterManager pierce = IntParameterManager(baseParameter: 0);

  final DoubleParameterManager projectileVelocity =
      DoubleParameterManager(baseParameter: 20);

  List<Projectile> activeProjectiles = [];

  @override
  FutureOr<void> onLoad() {
    pierce.baseParameter = pierce.baseParameter
        .clamp(maxChainingTargets.parameter, double.infinity)
        .toInt();
    return super.onLoad();
  }

  @override
  void attackAttempt([double holdDurationPercent = 1]) async {
    if (this is SemiAutomatic) {
      holdDurationPercent =
          (this as SemiAutomatic).holdDurationPercentOfAttackRate;
    }
    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    additionalCountCheck();
    super.attackAttempt(holdDurationPercent);
  }

  Vector2 randomVector2() => (Vector2.random(rng) - Vector2.random(rng)) * 100;

  @override
  void attack([double chargeAmount = 1]) async {
    entityAncestor?.gameEnviroment.physicsComponent
        .addAll(generateProjectileFunction(chargeAmount));

    // entityAncestor?.handJoint.add(MoveEffect.tp(Vector2(0, -.05),
    //     EffectController(duration: .05, reverseDuration: .05)));
    entityAncestor?.handJoint.weaponSpriteAnimation?.add(RotateEffect.to(
        (entityAncestor?.handJoint.weaponSpriteAnimation?.angle ?? 0) +
            (entityAncestor!.handJoint.isFlippedHorizontally ? .01 : -.01),
        EffectController(duration: .1, reverseDuration: .1)));

    super.attack(chargeAmount);
  }

  double particleLifespan = .15;

  Component generateParticle() {
    Vector2 moveDelta = entityAncestor?.body.linearVelocity ?? Vector2.zero();
    var particleColor = Colors.orange.withOpacity(.5);
    final particle = Particle.generate(
      lifespan: particleLifespan,
      count: 10,
      generator: (i) => AcceleratedParticle(
        position: weaponTipPosition,
        speed: moveDelta +
            (randomizeVector2Delta(
                            entityAncestor?.inputAimVectors ?? Vector2.zero(),
                            .45)
                        .normalized())
                    .clone() *
                30 *
                (.5 + rng.nextDouble()),
        child: CircleParticle(
          radius: .06 * (.06 + rng.nextDouble()),
          paint: Paint()..color = particleColor,
        ),
      ),
    );

    return ParticleSystemComponent(particle: particle);
  }

  Vector2? get weaponTipPosition {
    final weaponTip =
        weaponAttachmentPoints[WeaponSpritePosition.hand]?.weaponTip;
    if (weaponTip != null) {
      return weaponTip.absolutePosition + entityAncestor!.center;
    } else {
      return ((entityAncestor!.handJoint.absolutePosition.normalized() *
              length /
              2) +
          entityAncestor!.center);
    }
  }

  List<BodyComponent> generateProjectileFunction([double chargeAmount = 1]) {
    List<BodyComponent> returnList = [];

    List<Vector2> temp = splitVector2DeltaIntoArea(
        entityAncestor?.inputAimVectors ?? Vector2.zero(),
        attackCount,
        maxSpreadDegrees.parameter);

    for (var deltaDirection in temp) {
      if (projectileType == null) continue;
      final delta = (randomizeVector2Delta(
          deltaDirection, weaponRandomnessPercent.parameter));

      final Vector2 originPosition;

      if (weaponType.attackType == AttackType.melee) {
        originPosition =
            (delta.normalized() * (distanceFromPlayer + (length / 2))) +
                entityAncestor!.center;
      } else if (weaponType.attackType == AttackType.projectile) {
        originPosition = weaponTipPosition ?? Vector2.zero();
      } else {
        originPosition = Vector2.zero();
      }

      returnList.add(projectileType!.generateProjectile(
          delta: delta,
          originPositionVar: originPosition,
          ancestorVar: this,
          chargeAmount: chargeAmount));
    }

    return returnList;
  }
}

mixin SemiAutomatic on Weapon {
  bool isAttacking = false;

  abstract SemiAutoType semiAutoType;
  bool waitForAttackRate = true;

  double get chargeLength => attackTickRate.parameter;

  @override
  double durationHeld = 0;

  TimerComponent? attackTimer;

  double get holdDurationPercentOfAttackRate =>
      semiAutoType == SemiAutoType.charge
          ? ui.clampDouble(durationHeld / chargeLength, 0, 1)
          : 1;

  @override
  void update(double dt) {
    if (isAttacking && !isReloading) {
      durationHeld += dt;
    }
    super.update(dt);
  }

  @override
  void endAttacking() {
    isAttacking = false;
    entityAncestor?.entityStatusWrapper.removeHoldDuration();
    switch (semiAutoType) {
      case SemiAutoType.release:
        if (durationHeld > chargeLength) {
          attackAttempt();
        }
        break;
      case SemiAutoType.charge:
        attackAttempt();
        break;
      default:
    }

    durationHeld = 0;
    super.endAttacking();
  }

  @override
  void startAttacking() {
    isAttacking = true;

    switch (semiAutoType) {
      case SemiAutoType.regular:
        attackAttempt();
        break;
      case SemiAutoType.release:
        entityAncestor?.entityStatusWrapper.addHoldDuration(chargeLength);
        break;
      case SemiAutoType.charge:
        entityAncestor?.entityStatusWrapper.addHoldDuration(chargeLength);
        break;
      default:
    }
  }

  @override
  void attackAttempt([double holdDurationPercent = 1]) {
    if (waitForAttackRate) {
      if (attackTimer == null) {
        attackTimer = TimerComponent(
            period: attackTickRate.parameter,
            removeOnFinish: true,
            onTick: () {
              attackTimer = null;
            });
        add(attackTimer!);
      } else {
        return;
      }
    }
    super.attackAttempt(holdDurationPercent);
  }
}

mixin FullAutomatic on Weapon {
  @override
  double get durationHeld => attackTicks * attackTickRate.parameter;

  bool stopAttacking = false;
  bool allowRapidClicking = false;
  bool instantAttack = true;

  int attackTicks = 0;
  TimerComponent? attackTimer;

  void attackTick() {
    attackAttempt();
    attackTicks++;
  }

  void attackFinishTick() {
    attackTimer?.removeFromParent();
    attackTicks = 0;
    attackTimer = null;
    stopAttacking = false;
  }

  @override
  void endAttacking() {
    stopAttacking = true;
    super.endAttacking();
  }

  @override
  void startAttacking() {
    stopAttacking = false;

    if (instantAttack) {
      if (allowRapidClicking) {
        attackTimer?.timer.reset();
        attackTick();
      } else if (attackTimer == null) {
        attackTick();
      }
    }

    attackTimer ??= TimerComponent(
      period: attackTickRate.parameter,
      repeat: true,
      onTick: () {
        if (stopAttacking) {
          attackFinishTick();
        } else {
          attackTick();
        }
      },
    )..addToParent(this);
  }
}

mixin MeleeTrailEffect on MeleeFunctionality {
  Map<MeleeAttack, (List<Vector2>, List<Vector2>)> behindEffects = {};

  final double baseBeginPercent = .4;

  @override
  void render(Canvas canvas) {
    if (attacksAreActive) {
      for (var element in activeSwings) {
        if (!behindEffects.containsKey(element)) {
          behindEffects[element] = (
            [
              newPosition(element.position, -degrees(element.angle),
                      length * baseBeginPercent)
                  .clone()
            ],
            [
              newPosition(element.position, -degrees(element.angle), length)
                  .clone()
            ]
          );
        } else {
          {
            behindEffects[element] = (
              [
                ...behindEffects[element]!.$1,
                newPosition(element.position, -degrees(element.angle),
                        length * baseBeginPercent)
                    .clone(),
              ],
              [
                ...behindEffects[element]!.$2,
                newPosition(element.position, -degrees(element.angle), length)
                    .clone(),
              ]
            );
          }
        }
      }
      behindEffects.removeWhere((key, value) => !activeSwings.contains(key));
    } else {
      behindEffects.clear();
    }

    for (var element in behindEffects.entries) {
      List<Offset> offsets = [];

      for (var i = 0; i < element.value.$1.length - 1; i++) {
        offsets.add(element.value.$1.elementAt(i).toOffset());
        offsets.add(element.value.$2.elementAt(i).toOffset());
      }
      if (offsets.isEmpty) return;

      canvas.drawVertices(
          ui.Vertices(VertexMode.triangleStrip, offsets),
          BlendMode.color,
          BasicPalette.red.paint()
            ..style = PaintingStyle.fill
            ..shader = ui.Gradient.linear(offsets.first, offsets.last,
                [Colors.transparent, Colors.yellow])
            ..strokeWidth = 0);
    }

    super.render(canvas);
  }
}

mixin AttributeWeaponFunctionsFunctionality on Weapon {
  //Event functions that are modified from attributes
  List<Function(HealthFunctionality other)> onKill = [];
  List<Function(HealthFunctionality other)> onHitProjectile = [];
  List<Function(HealthFunctionality other)> onHitMelee = [];
  List<Function()> onAttackProjectile = [];
  List<Function()> onAttackMelee = [];
  List<Function()> onAttack = [];
  List<Function()> onReload = [];
  List<Function(Weapon from, Weapon to)> onSwapWeapon = [];

  @override
  void attack([double holdDurationPercent = 1]) {
    if (this is ProjectileFunctionality) {
      for (var element in onAttackProjectile) {
        element();
      }
    } else if (this is MeleeFunctionality) {
      for (var element in onAttackMelee) {
        element();
      }
    }
    for (var element in onAttack) {
      element();
    }
    super.attack();
  }
}

String buildWeaponDescription(
    WeaponDescription weaponDescription, WeaponType weapon, int level,
    [bool isUnlocked = true]) {
  String returnString = "";

  if (!isUnlocked) return " - ";
  final builtWeapon = weapon.build(null, null, level);

  switch (weaponDescription) {
    case WeaponDescription.attackRate:
      returnString =
          "${builtWeapon.attackRateSecondComparison.toStringAsFixed(1)}/s";
      break;
    case WeaponDescription.damage:
      bool firstLoop = true;
      for (var element in builtWeapon.baseDamage.damageBase.entries) {
        if (firstLoop) {
          firstLoop = false;
        } else {
          returnString += "\n";
        }
        returnString +=
            "${element.key.name.titleCase}: ${element.value.$1.toStringAsFixed(0)} - ${element.value.$2.toStringAsFixed(0)}";
      }

      break;

    case WeaponDescription.reloadTime:
      if (builtWeapon is ReloadFunctionality) {
        returnString =
            "${builtWeapon.reloadTime.parameter.toStringAsFixed(0)} s";
      } else {
        returnString = "";
      }
      break;
    case WeaponDescription.staminaCost:
      if (builtWeapon is StaminaCostFunctionality) {
        returnString = "${builtWeapon.weaponStaminaCost}/attack";
      } else {
        returnString = "";
      }
      break;
    case WeaponDescription.maxAmmo:
      if (builtWeapon is ReloadFunctionality) {
        returnString = "${builtWeapon.maxAttacks}";
      } else {
        returnString = "";
      }
      break;
    case WeaponDescription.velocity:
      if (builtWeapon is ProjectileFunctionality) {
        returnString = "${builtWeapon.projectileVelocity.parameter.round()}m/s";
      } else {
        returnString = "";
      }
      break;
    case WeaponDescription.semiOrAuto:
      if (builtWeapon is SemiAutomatic) {
        switch (builtWeapon.semiAutoType) {
          case SemiAutoType.regular:
            returnString = "Semi-Auto";
            break;
          case SemiAutoType.release:
            returnString = "Release";
            break;
          case SemiAutoType.charge:
            returnString = "Charge";
            break;
        }
      } else if (builtWeapon is FullAutomatic) {
        returnString = "Full-Auto";
      }

      break;

    case WeaponDescription.attackCount:
      returnString = "${builtWeapon.attackCount} attack(s)";

      break;
  }

  return returnString;
}
