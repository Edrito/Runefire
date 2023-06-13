import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapon_class.dart';

import '../functions/vector_functions.dart';
import '../resources/enums.dart';

mixin ReloadFunctionality on Weapon {
  abstract int? maxAmmo;

  abstract double reloadTime;

  int spentAttacks = 0;

  int? get remainingAttacks => maxAmmo == null ? null : maxAmmo! - spentAttacks;
  TimerComponent? reloadTimer;
  @override
  void attackTick() {
    reloadCheck();
    if (reloadTimer == null) {
      super.attackTick();
    }
  }

  void reloadCheck() {
    if (this is MeleeFunctionality) {
      var melee = this as MeleeFunctionality;
      melee.currentSwingPosition = null;
      melee.currentSwingAngle = null;
    }

    if (remainingAttacks != 0 || reloadTimer != null || reloadTime == 0) return;
    if (removeBackSpriteOnAttack) {
      parentEntity?.backJoint.spriteComponent?.opacity = 1;
    }

    reloadTimer = TimerComponent(
      period: reloadTime,
      removeOnFinish: true,
      onTick: () {
        spentAttacks = 0;
        reloadTimer = null;
        if (stopAttacking) {
          attackFinishTick();
        }
        if (attackTimer != null) {
          attackTimer?.timer.start();
          attackTick();
        }
      },
    );
    add(reloadTimer!);
  }
}

mixin MeleeFunctionality on Weapon {
  ///An even number of pairs
  ///Next position - next angle
  ///
  ///...
  List<(Vector2, double)> attackPatterns = [];

  int get attacksLength => (attackPatterns.length / 2).ceil();

  void melee() {
    parentEntity?.add(generateMeleeSwing());
  }

  int spentAttacks = 0;
  @override
  void attackFinishTick() {
    resetToFirstSwings();

    super.attackFinishTick();
  }

  void resetToFirstSwings() {
    currentSwingAngle = null;
    currentSwingPosition = null;
    spentAttacks = 0;
  }

  Vector2? currentSwingPosition;
  double? currentSwingAngle;

  PositionComponent generateMeleeSwing() {
    if (attackTicks > attacksLength) {
      resetToFirstSwings();
    }
    currentSwingPosition ??= parentEntity?.handJoint.position.clone();
    currentSwingAngle ??= parentEntity?.handJoint.angle;
    int attackPatternIndex = (attackTicks -
            (((attackTicks / (attacksLength)).floor()) * (attacksLength))) *
        2;
    return MeleeAttack(
        (currentSwingPosition ?? Vector2.zero()) * distanceFromPlayer,
        currentSwingAngle,
        attackPatternIndex,
        this);
  }
}

mixin ProjectileFunctionality on Weapon {
  abstract ProjectileType? projectileType;
  abstract Sprite projectileSprite;
  abstract bool allowProjectileRotation;
  Vector2 randomVector2() => (Vector2.random(rng) - Vector2.random(rng)) * 100;

  Vector2 get handPosition =>
      (parents[WeaponSpritePosition.hand]!.weaponTip!.absolutePosition +
              parentEntity!.body.position)
          .clone();

  Vector2 get handDelta =>
      (parents[WeaponSpritePosition.hand]!.weaponTipCenter!.absolutePosition -
              parentEntity!.handJoint.absolutePosition)
          .normalized();

  void shoot() {
    parentEntity?.ancestor.physicsComponent
        .addAll(generateProjectileFunction());
    parentEntity?.ancestor.physicsComponent.add(generateParticle());
    parentEntity!.handJoint.add(MoveEffect.by(Vector2(0, -.05),
        EffectController(duration: .05, reverseDuration: .05)));
    parentEntity!.handJoint.add(RotateEffect.by(
        parentEntity!.handJoint.isFlippedHorizontally ? -.05 : .05,
        EffectController(duration: .1, reverseDuration: .1)));
  }

  double particleLifespan = .15;

  Component generateParticle() {
    Vector2 moveDelta = parentEntity?.body.linearVelocity ?? Vector2.zero();
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
          radius: .2,
          paint: Paint()..color = particleColor,
        ),
      ),
    );

    return ParticleSystemComponent(particle: particle);
  }

  List<BodyComponent> generateProjectileFunction() {
    var deltaDirection = handDelta;

    List<BodyComponent> returnList = [];

    List<Vector2> temp = splitVector2DeltaInCone(
        deltaDirection, count + (additionalCount ?? 0), maxSpreadDegrees);

    for (var deltaDirection in temp) {
      if (projectileType == null) continue;
      final delta =
          (randomizeVector2Delta(deltaDirection, weaponRandomnessPercent)
                  .normalized())
              .clone();

      returnList.add(projectileType!.generateProjectile(
          delta: delta,
          speed: projectileVelocity,
          originPositionVar: handPosition,
          ancestorVar: this,
          idVar: (deltaDirection.x + attackTicks).toString()));
    }

    return returnList;
  }
}
