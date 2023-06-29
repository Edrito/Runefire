import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapon_class.dart';

import '../entities/entity.dart';
import '../entities/entity_mixin.dart';
import '../functions/vector_functions.dart';
import '../resources/enums.dart';

mixin ReloadFunctionality on Weapon {
  abstract int? maxAmmo;

  ///How long in seconds to reload
  abstract double reloadTime;

  int spentAttacks = 0;

  ///Instance of reloading visual
  PositionComponent? reloadAnimation;

  int? get remainingAttacks => maxAmmo == null ? null : maxAmmo! - spentAttacks;

  ///Timer that when completes finishes reload
  TimerComponent? reloadTimer;

  @override
  FutureOr<void> onLoad() {
    if (this is MeleeFunctionality) {
      assert(maxAmmo == (this as MeleeFunctionality).attacksLength ||
          maxAmmo == null);
    }
    return super.onLoad();
  }

  @override
  void attackAttempt() {
    //Do not attack if reloading
    if (reloadTimer != null) {
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
    reloadAnimation =
        ReloadAnimation(reloadTime, entityAncestor, isSecondaryWeapon);

    entityAncestor.add(reloadAnimation!);
  }

  void reloadCheck() {
    if (remainingAttacks != 0 || reloadTimer != null || reloadTime == 0) return;
    if (removeSpriteOnAttack) {
      entityAncestor.backJoint.weaponSpriteAnimation?.opacity = 1;
      entityAncestor.handJoint.weaponSpriteAnimation?.opacity = 1;
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

  ///Must be the same length as [attacksLength]
  List<Vector2> attackHitboxSizes = [];

  int get attacksLength => (attackHitboxPatterns.length / 2).ceil();

  void melee([double chargeAmount = 1]) {
    if (attacksCompletedIndex >= attacksLength) {
      resetToFirstSwings();
    }
    currentSwingPosition = entityAncestor.handJoint.position.clone();
    currentSwingAngle = entityAncestor.handJoint.angle;

    int attackPatternIndex = (attacksCompletedIndex -
            (((attacksCompletedIndex / (attacksLength)).floor()) *
                (attacksLength))) *
        2;

    entityAncestor.setEntityStatus(
        EntityStatus.attack,
        attackEntitySpriteAnimations.isNotEmpty
            ? attackEntitySpriteAnimations[attacksCompletedIndex]
            : null);

    entityAncestor.add(MeleeAttack(
      initPosition:
          (currentSwingPosition ?? Vector2.zero()) * distanceFromPlayer,
      initAngle: currentSwingAngle,
      index: attackPatternIndex,
      parentWeapon: this,
    ));

    attacksCompletedIndex++;
  }

  int attacksCompletedIndex = 0;

  @override
  void endAttacking() {
    resetToFirstSwings();
    super.endAttacking();
  }

  @override
  void attackAttempt() {
    melee();
    super.attackAttempt();
  }

  void resetToFirstSwings() {
    currentSwingAngle = null;
    currentSwingPosition = null;
    attacksCompletedIndex = 0;
  }

  Vector2? currentSwingPosition;
  double? currentSwingAngle;
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
    _secondaryWeaponAbility?.startAttacking();
  }

  @override
  void endAltAttacking() {
    _secondaryWeapon?.endAttacking();
    _secondaryWeaponAbility?.endAttacking();
  }
}

mixin ProjectileFunctionality on Weapon {
  abstract ProjectileType? projectileType;
  abstract Sprite projectileSprite;
  abstract bool allowProjectileRotation;
  abstract int projectileCount;
  abstract double maxSpreadDegrees;
  abstract int pierce;
  abstract double projectileVelocity;
  abstract bool countIncreaseWithTime;
  int? additionalCount;

  void additionalCountCheck() {
    if (countIncreaseWithTime) {
      additionalCount = durationHeld.round();
    }
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

  Vector2 get handPosition =>
      (parents[WeaponSpritePosition.hand]!.weaponTip!.absolutePosition +
              entityAncestor.body.position)
          .clone() +
      ((entityAncestor is MovementFunctionality)
          ? (entityAncestor as MovementFunctionality).moveDelta
          : Vector2.zero());

  Vector2 get handDelta =>
      (parents[WeaponSpritePosition.hand]!.weaponTipCenter!.absolutePosition -
              entityAncestor.handJoint.absolutePosition)
          .normalized();

  void shoot([double chargeAmount = 1]) {
    additionalCountCheck();
    entityAncestor.ancestor.physicsComponent
        .addAll(generateProjectileFunction(chargeAmount));
    entityAncestor.ancestor.physicsComponent.add(generateParticle());
    entityAncestor.handJoint.add(MoveEffect.by(Vector2(0, -.05),
        EffectController(duration: .05, reverseDuration: .05)));
    entityAncestor.handJoint.add(RotateEffect.by(
        entityAncestor.handJoint.isFlippedHorizontally ? -.05 : .05,
        EffectController(duration: .1, reverseDuration: .1)));
  }

  double particleLifespan = .15;

  Component generateParticle() {
    Vector2 moveDelta = entityAncestor.body.linearVelocity;
    var particleColor = Colors.orange.withOpacity(.5);
    final particle = Particle.generate(
      lifespan: particleLifespan,
      count: 10,
      generator: (i) => AcceleratedParticle(
        position: handPosition,
        speed: moveDelta +
            (randomizeVector2Delta(handDelta, .45).normalized()).clone() *
                30 *
                (.5 + rng.nextDouble()),
        child: CircleParticle(
          radius: .2 * (.2 + rng.nextDouble()),
          paint: Paint()..color = particleColor,
        ),
      ),
    );

    return ParticleSystemComponent(particle: particle);
  }

  List<BodyComponent> generateProjectileFunction([double chargeAmount = 1]) {
    var deltaDirection = handDelta;

    List<BodyComponent> returnList = [];

    List<Vector2> temp = splitVector2DeltaInCone(deltaDirection,
        projectileCount + (additionalCount ?? 0), maxSpreadDegrees);

    for (var deltaDirection in temp) {
      if (projectileType == null) continue;
      final delta =
          (randomizeVector2Delta(deltaDirection, weaponRandomnessPercent)
                  .normalized())
              .clone();

      returnList.add(projectileType!.generateProjectile(
          delta: delta,
          originPositionVar: handPosition,
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
  final height = .5;

  final sidePadding = .5;

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

    final movingBar = RectangleComponent(size: Vector2(.2, height));
    movingBar.position = Vector2(sidePadding, height / -2);
    movingBar.add(MoveEffect.to(
        Vector2(size.x - sidePadding, movingBar.position.y),
        EffectController(duration: duration)));

    final bar = RectangleComponent(size: Vector2(size.x, .15));
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
          ? clampDouble(durationHeld / attackRate, 0, 1)
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
        if (durationHeld > attackRate) {
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
  double get durationHeld => attackTicks * attackRate;
  bool stopAttacking = false;

  int attackTicks = 0;
  TimerComponent? attackTimer;

  void attackTick() {
    attackAttempt();
    attackTicks++;
  }

  void attackFinishTick() {
    if (removeSpriteOnAttack) {
      entityAncestor.backJoint.weaponSpriteAnimation?.opacity = 1;
      entityAncestor.handJoint.weaponSpriteAnimation?.opacity = 1;
    }

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

    if (allowRapidClicking) {
      attackTimer?.timer.reset();
      attackTick();
    } else if (attackTimer == null) {
      attackTick();
    }

    attackTimer ??= TimerComponent(
      period: attackRate,
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
