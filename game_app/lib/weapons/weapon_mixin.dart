import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/secondary_abilities.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapon_class.dart';

import '../entities/entity.dart';
import '../functions/vector_functions.dart';
import '../resources/enums.dart';

mixin MultiWeaponCheck on Weapon {
  @override
  void attackAttempt() {
    if ((entityAncestor as AttackFunctionality).currentWeapon != this) return;

    super.attackAttempt();
  }
}

mixin ReloadFunctionality on Weapon {
  int get maxAttacks => baseMaxAttacks + maxAttacksIncrease;
  abstract final int baseMaxAttacks;
  int maxAttacksIncrease = 0;

  ///How long in seconds to reload
  abstract final double baseReloadTime;
  double reloadTimeIncrease = 0;
  double get reloadTime =>
      (baseReloadTime - reloadTimeIncrease).clamp(0, double.infinity);

  //Status of reloading
  int spentAttacks = 0;

  PositionComponent? reloadAnimation;

  int? get remainingAttacks =>
      maxAttacks == 0 ? null : maxAttacks - spentAttacks;

  ///Timer that when completes finishes reload
  TimerComponent? reloadTimer;

  @override
  FutureOr<void> onLoad() {
    if (this is MeleeFunctionality) {
      assert(maxAttacks == (this as MeleeFunctionality).attacksLength ||
          maxAttacks == 0);
    }
    return super.onLoad();
  }

  @override
  void attackAttempt() {
    //Do not attack if reloading
    if (isReloading) {
      return;
    }

    spentAttacks++;
    super.attackAttempt();

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

    reloadAnimation?.removeFromParent();
    reloadAnimation = null;
  }

  @override
  void weaponSwappedFrom() {
    //Remove reload animation if weapon changes
    reloadAnimation?.removeFromParent();
    reloadAnimation = null;
    super.weaponSwappedFrom();
  }

  void createReloadBar() {
    if (entityAncestor == null) return;
    reloadAnimation =
        ReloadAnimation(reloadTime, entityAncestor!, isSecondaryWeapon);

    entityAncestor?.add(reloadAnimation!);
  }

  void reloadCheck() {
    if (remainingAttacks != 0 || isReloading || reloadTime == 0) return;
    reload();
  }

  void reload() {
    if (this is MeleeFunctionality) {
      (this as MeleeFunctionality).resetToFirstSwings();
    }
    createReloadBar();
    reloadTimer = TimerComponent(
      period: reloadTime,
      removeOnFinish: true,
      onTick: () {
        stopReloading();
      },
    );
    add(reloadTimer!);
  }
}

mixin MeleeFunctionality on Weapon {
  ///Pairs of attack patterns
  ///
  ///Start position - Start angle
  ///
  ///Finish position - Finish angle
  List<(Vector2, double)> attackHitboxPatterns = [];

  ///Must be the same length as [attacksLength] or 0
  List<SpriteAnimation> attackEntitySpriteAnimations = [];

  ///Must be the same length as [attacksLength] or 0
  List<SpriteAnimation> attackHitboxSpriteAnimations = [];

  ///Must be the same length as [attacksLength] or 0
  List<SpriteAnimation> attackWeaSpriteAnimations = [];

  ///Must be the same length as [attacksLength]
  List<Vector2> attackHitboxSizes = [];

  int attacksCompletedIndex = 0;
  Vector2? currentSwingPosition;
  List<double> currentSwingAngles = [];

  @override
  bool get attacksAreActive => activeSwings.isNotEmpty;
  List<MeleeAttack> activeSwings = [];

  int get attacksLength => (attackHitboxPatterns.length / 2).ceil();

  int get currentAttackPatternIndex =>
      (attacksCompletedIndex -
          (((attacksCompletedIndex / (attacksLength)).floor()) *
              (attacksLength))) *
      2;

  void melee([double chargeAmount = 1]) async {
    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    if (attacksCompletedIndex >= attacksLength) {
      resetToFirstSwings();
    }
    currentSwingPosition = Vector2.zero();
    final currentSwingAngle = entityAncestor?.handJoint.angle ?? 0;

    entityAncestor?.setEntityStatus(
        EntityStatus.attack,
        attackEntitySpriteAnimations.isNotEmpty
            ? attackEntitySpriteAnimations[attacksCompletedIndex]
            : null);

    List<Component> returnList = [];

    List<double> temp =
        splitRadInCone(currentSwingAngle, attackCount + (0 ?? 0), 360);

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
    attacksCompletedIndex++;
  }

  @override
  void endAttacking() {
    if (this is! ReloadFunctionality) {
      resetToFirstSwings();
    }
    super.endAttacking();
  }

  @override
  void attackAttempt() {
    var holdDurationPercent = 1.0;
    if (this is SemiAutomatic) {
      holdDurationPercent =
          (this as SemiAutomatic).holdDurationPercentOfAttackRate;
    }
    melee(holdDurationPercent);
    super.attackAttempt();
  }

  void resetToFirstSwings() {
    currentSwingAngles.clear();
    currentSwingPosition = null;
    attacksCompletedIndex = 0;
  }
}

mixin SecondaryFunctionality on Weapon {
  set setSecondaryFunctionality(dynamic item) {
    if (item is Weapon) {
      _secondaryWeapon = item;
      _secondaryWeapon?.parents = parents;
      _secondaryWeapon?.isSecondaryWeapon = true;

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
  void weaponSwappedFrom() {
    _secondaryWeaponAbility?.removeReloadAnimation();
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
  abstract bool allowProjectileRotation;

  abstract int basePierce;
  int get pierce => basePierce + pierceIncrease;
  int pierceIncrease = 0;

  abstract double projectileVelocity;

  List<Projectile> activeProjectiles = [];

  @override
  FutureOr<void> onLoad() {
    basePierce = basePierce.clamp(maxChainingTargets, double.infinity).toInt();
    return super.onLoad();
  }

  @override
  void attackAttempt() {
    var holdDurationPercent = 1.0;
    if (this is SemiAutomatic) {
      holdDurationPercent =
          (this as SemiAutomatic).holdDurationPercentOfAttackRate;
    }
    shoot(holdDurationPercent);
    super.attackAttempt();
  }

  Vector2 randomVector2() => (Vector2.random(rng) - Vector2.random(rng)) * 100;

  void shoot([double chargeAmount = 1]) async {
    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    additionalCountCheck();
    entityAncestor?.gameEnv.physicsComponent
        .addAll(generateProjectileFunction(chargeAmount));
    // entityAncestor?.ancestor.physicsComponent.add(generateParticle());
    entityAncestor?.handJoint.add(MoveEffect.by(Vector2(0, -.05),
        EffectController(duration: .05, reverseDuration: .05)));
    entityAncestor?.handJoint.add(RotateEffect.by(
        entityAncestor!.handJoint.isFlippedHorizontally ? -.05 : .05,
        EffectController(duration: .1, reverseDuration: .1)));
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
                            entityAncestor?.inputAimDelta ?? Vector2.zero(),
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

  Vector2 get weaponTipPosition =>
      (parents[WeaponSpritePosition.hand]!.weaponTip!.absolutePosition +
          entityAncestor!.center);

  List<BodyComponent> generateProjectileFunction([double chargeAmount = 1]) {
    List<BodyComponent> returnList = [];

    List<Vector2> temp = splitVector2DeltaIntoArea(
        entityAncestor?.handAimDelta ?? Vector2.zero(),
        attackCount,
        maxSpreadDegrees);

    for (var deltaDirection in temp) {
      if (projectileType == null) continue;
      final delta =
          (randomizeVector2Delta(deltaDirection, weaponRandomnessPercent));
      print(attackCount);

      returnList.add(projectileType!.generateProjectile(
          delta: delta,
          originPositionVar: weaponTipPosition,
          ancestorVar: this,
          chargeAmount: chargeAmount));
    }

    return returnList;
  }
}

class ReloadAnimation extends PositionComponent {
  ReloadAnimation(this.duration, this.entityAncestor, this.isSecondaryWeapon);
  double duration;
  Entity entityAncestor;
  bool isSecondaryWeapon;
  @override
  final height = .2;
  final lineHeight = .06;
  final barWidth = .05;

  final sidePadding = .1;

  @override
  FutureOr<void> onLoad() {
    final parentSize = entityAncestor.spriteWrapper.size;

    size = parentSize;

    size.y = height;

    anchor = Anchor.center;
    position.y = parentSize.y / -2;

    final timer = TimerComponent(
      period: duration,
      removeOnFinish: true,
      onTick: () {
        removeFromParent();
      },
    );

    final movingBar = RectangleComponent(size: Vector2(barWidth, height));
    movingBar.position = Vector2(sidePadding, height / -2);
    movingBar.add(MoveEffect.to(
        Vector2(size.x - sidePadding, movingBar.position.y),
        EffectController(duration: duration)));

    final bar = RectangleComponent(size: Vector2(size.x, lineHeight));
    bar.anchor = Anchor.centerLeft;

    if (isSecondaryWeapon) {
      position.y += -height * 1.5;
      movingBar.setColor(BasicPalette.green.color);
      bar.setColor(BasicPalette.green.color);
    }
    addAll([
      movingBar,
      bar,
      timer,
    ]);

    return super.onLoad();
  }
}

mixin SemiAutomatic on Weapon {
  bool isAttacking = false;

  abstract SemiAutoType semiAutoType;

  @override
  double durationHeld = 0;

  TimerComponent? attackTimer;

  double get holdDurationPercentOfAttackRate =>
      semiAutoType == SemiAutoType.charge
          ? clampDouble(durationHeld / attackTickRate, 0, 1)
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
    switch (semiAutoType) {
      case SemiAutoType.release:
        if (durationHeld > attackTickRate) {
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

    if (semiAutoType == SemiAutoType.regular) {
      attackAttempt();
    }
  }
}

mixin FullAutomatic on Weapon {
  @override
  double get durationHeld => attackTicks * attackTickRate;

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
      period: attackTickRate,
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
