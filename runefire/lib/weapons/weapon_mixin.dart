import 'dart:async';
import 'dart:ui' as ui;
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide RotateEffect;
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/secondary_abilities.dart';
import 'package:runefire/weapons/melee_swing_manager.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:recase/recase.dart';

import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/resources/enums.dart';

mixin MultiWeaponCheck on Weapon {
  @override
  Future<void> attackAttempt([double holdDurationPercent = 1]) async {
    if ((entityAncestor! as AttackFunctionality).currentWeapon != this) {
      return;
    }

    super.attackAttempt(holdDurationPercent);
  }
}

mixin ReloadFunctionality on Weapon {
  final IntParameterManager maxAttacks = IntParameterManager(baseParameter: 10);

  ///How long in seconds to reload
  final DoubleParameterManager reloadTime =
      DoubleParameterManager(baseParameter: 1, minParameter: 0);

  ///Timer that when completes finishes reload
  TimerComponent? reloadTimer;

  //Status of reloading
  int _spentAttacks = 0;

  int get spentAttacks => _spentAttacks;

  set spentAttacks(int value) {
    _spentAttacks = value;
    if (entityAncestor is AttributeCallbackFunctionality) {
      final attributeFunctions =
          entityAncestor! as AttributeCallbackFunctionality;
      for (final attribute in attributeFunctions.onSpentAttack) {
        attribute(this);
      }
    }
  }

  double get percentReloaded =>
      (reloadTimer?.timer.current ?? reloadTime.parameter) /
      reloadTime.parameter;

  int? get remainingAttacks =>
      maxAttacks.parameter == 0 ? null : maxAttacks.parameter - spentAttacks;

  void createReloadBar() {
    if (entityAncestor == null) {
      return;
    }
    entityAncestor!.entityStatusWrapper.addReloadAnimation(
      weaponId,
      reloadTime.parameter,
      reloadTimer!,
      isSecondaryWeapon,
    );
  }

  void reload() {
    if (this is MeleeFunctionality) {
      (this as MeleeFunctionality).resetToFirstSwings();
    }
    if (this is AttributeWeaponFunctionsFunctionality) {
      final attributeWeaponFunctions =
          this as AttributeWeaponFunctionsFunctionality;
      for (final attribute in attributeWeaponFunctions.onReload) {
        attribute();
      }
    }
    reloadTimer = TimerComponent(
      period: reloadTime.parameter,
      removeOnFinish: true,
      onTick: () {
        stopReloading();
        reloadCompleteFunctions();
      },
    )..addToParent(this);
    reloadFunctions();
    createReloadBar();
  }

  void reloadCheck() {
    if (remainingAttacks != 0 || isReloading || reloadTime.parameter == 0) {
      return;
    }
    reload();
  }

  void reloadCompleteFunctions() {
    if (entityAncestor is AttributeCallbackFunctionality) {
      final attributeFunctions =
          entityAncestor! as AttributeCallbackFunctionality;
      for (final attribute in attributeFunctions.onReloadComplete) {
        attribute(this);
      }
    }
  }

  void reloadFunctions() {
    if (entityAncestor is AttributeCallbackFunctionality) {
      final attributeFunctions =
          entityAncestor! as AttributeCallbackFunctionality;
      for (final attribute in attributeFunctions.onReload) {
        attribute(this);
      }
    }
  }

  void removeReloadAnimation() {
    entityAncestor?.entityStatusWrapper
        .removeReloadAnimation(weaponId, isSecondaryWeapon);
  }

  void stopReloading() {
    spentAttacks = 0;
    reloadTimer?.timer.stop();
    reloadTimer?.removeFromParent();
    reloadTimer = null;
    if (this is FullAutomatic) {
      final fullAuto = this as FullAutomatic;
      fullAuto.attackTimer?.timer.reset();
      fullAuto.attackTimer?.onTick();
    }

    removeReloadAnimation();
  }

  @override
  Future<void> attackAttempt([double holdDurationPercent = 1]) async {
    //Do not attack if reloading
    if (isReloading) {
      return;
    }

    spentAttacks++;
    super.attackAttempt(holdDurationPercent);

    //Check if needs to reload after an attack
    reloadCheck();
  }
}

mixin StaminaCostFunctionality on Weapon {
  final DoubleParameterManager weaponStaminaCost = DoubleParameterManager(
    baseParameter: 10,
    minParameter: 0,
    maxParameter: 200,
  );

  @override
  Future<void> attackAttempt([double holdDurationPercent = 1]) async {
    if (entityAncestor is StaminaFunctionality) {
      final stamina = entityAncestor! as StaminaFunctionality;
      if (!stamina.hasEnoughStamina(weaponStaminaCost.parameter)) {
        return;
      }
      stamina.modifyStamina(-weaponStaminaCost.parameter);
    }
    super.attackAttempt(holdDurationPercent);
  }
}
typedef WeaponSpriteAnimationBuilder = Future<WeaponSpriteAnimation> Function();

class MeleeAttack {
  MeleeAttack({
    required this.attackHitboxSize,
    required this.entitySpriteAnimation,
    required this.attackSpriteAnimationBuild,
    required this.chargePattern,
    required this.attackPattern,
    this.weaponTrailConfig,
    this.meleeAttackType = MeleeType.slash,
    this.flippedDuringAttack = false,
    this.customStartAngle = true,
  });

  final SpriteAnimation? entitySpriteAnimation;

  bool customStartAngle;
  bool flippedDuringAttack;
  List<WeaponSpriteAnimation> latestAttackSpriteAnimation = [];
  MeleeType meleeAttackType;

  WeaponSpriteAnimationBuilder? attackSpriteAnimationBuild;
  WeaponTrailConfig? weaponTrailConfig;

  ///List of Patterns for single attack, each pattern is a position, angle and reletive scale of the hitbox
  List<(Vector2, double, double)> attackPattern;

  List<(Vector2, double, double)> chargePattern;

  Future<WeaponSpriteAnimation?> buildWeaponSpriteAnimation() async {
    if (attackSpriteAnimationBuild == null) {
      return null;
    }
    final spriteAnimation = await attackSpriteAnimationBuild!.call();
    latestAttackSpriteAnimation.add(spriteAnimation);
    return spriteAnimation;
  }

  ///Size, start percent, end percent
  ///Start percent = .1, end percent = .9 (example)
  final (Vector2, (double, double)) attackHitboxSize;
}

mixin MeleeFunctionality on Weapon {
  final BoolParameterManager meleeAttacksCollision =
      BoolParameterManager(baseParameter: false);

  List<MeleeAttackHandler> activeSwings = [];
  int currentAttackIndex = 0;
  List<MeleeAttack> meleeAttacks = [];
  bool resetSwingsOnEndAttacking = true;

  Vector2? currentSwingPosition;

  @override
  SourceAttackLocation? sourceAttackLocation =
      SourceAttackLocation.distanceFromPlayer;

  MeleeAttack? get currentAttack =>
      meleeAttacks.isEmpty ? null : meleeAttacks[currentAttackIndex];

  ///How many attacks are in the melee combo
  int get numberOfAttacks => meleeAttacks.length;

  void meleeAttack(int? index, [double chargeAmount = 1]) {
    final returnList = <Component>[];
    final currentSwingAngle = entityAncestor?.handJoint.angle ?? 0;
    final indexUsed = index ?? currentAttackIndex;

    final temp = attackSplitFunctions.entries.fold<List<double>>(
      [],
      (previousValue, element) => [
        ...previousValue,
        ...element.value.call(currentSwingAngle, getAttackCount(chargeAmount)),
      ],
    );

    for (final deltaDirection in temp) {
      final customPosition =
          generateGlobalPosition(sourceAttackLocation!, melee: true);
      returnList.add(
        MeleeAttackHandler(
          initPosition: customPosition,
          initAngle: deltaDirection,
          attachmentPoint: sourceAttackLocation != SourceAttackLocation.mouse
              ? entityAncestor
              : null,
          currentAttack: meleeAttacks[indexUsed],
          weaponAncestor: this,
        ),
      );
    }
    entityAncestor?.enviroment.addPhysicsComponent(returnList, priority: 5);

    currentAttackIndex++;
  }

  void resetCheck() {
    if (currentAttackIndex >= numberOfAttacks) {
      resetToFirstSwings();
    }
  }

  void resetToFirstSwings() {
    currentSwingPosition = null;
    currentAttackIndex = 0;
  }

  @override
  Future<void> attackAttempt([double holdDurationPercent = 1]) async {
    resetCheck();
    currentSwingPosition = Vector2.zero();

    if (this is SemiAutomatic) {
      holdDurationPercent = (this as SemiAutomatic).holdDurationPercent;
    }

    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    final future = entityAncestor?.setEntityAnimation(
      meleeAttacks.indexWhere((element) => element == currentAttack),
    );
    attackOnAnimationFinish ? await future : future;
    super.attackAttempt(holdDurationPercent);
  }

  @override
  bool get attacksAreActive => activeSwings.isNotEmpty;

  @override
  void endAttacking() {
    if (this is! ReloadFunctionality &&
        this is! SemiAutomatic &&
        resetSwingsOnEndAttacking) {
      resetToFirstSwings();
    }
    super.endAttacking();
  }

  @override
  FutureOr<void> onLoad() {
    if (this is ReloadFunctionality) {
      (this as ReloadFunctionality).maxAttacks.baseParameter = numberOfAttacks;
    }
    return super.onLoad();
  }

  @override
  Future<void> standardAttack([
    double holdDurationPercent = 1,
    bool callFunctions = true,
  ]) async {
    meleeAttack(currentAttackIndex, holdDurationPercent);
    super.standardAttack(holdDurationPercent, callFunctions);
  }
}

mixin SecondaryFunctionality on Weapon {
  Weapon? secondaryWeapon;
  SecondaryWeaponAbility? secondaryWeaponAbility;

  bool get secondaryIsWeapon => secondaryWeapon != null;

  set setSecondaryFunctionality(dynamic item) {
    secondaryWeapon = null;
    secondaryWeaponAbility = null;
    if (item is Weapon) {
      secondaryWeapon = item;
      secondaryWeapon?.weaponAttachmentPoints = weaponAttachmentPoints;
      secondaryWeapon?.isSecondaryWeapon = true;
      secondaryWeapon?.weaponId = weaponId;
      // assert(_secondaryWeapon is! FullAutomatic);
    } else if (item is SecondaryWeaponAbility) {
      secondaryWeaponAbility = item;
      add(item);
    }
  }

  @override
  void endAltAttacking() {
    secondaryWeapon?.endAttacking();
    secondaryWeaponAbility?.endAbility();
  }

  @override
  void startAltAttacking() {
    secondaryWeapon?.startAttacking();
    secondaryWeaponAbility?.startAbilityCheck();
  }

  @override
  void weaponSwappedFrom() {
    final entityStatusWrapper = entityAncestor?.entityStatusWrapper;
    entityStatusWrapper?.hideReloadAnimations(weaponId);
    super.weaponSwappedFrom();
  }

  @override
  void weaponSwappedTo() {
    final entityStatusWrapper = entityAncestor?.entityStatusWrapper;
    entityStatusWrapper?.showReloadAnimations(weaponId);
    super.weaponSwappedTo();
  }
}

mixin ProjectileFunctionality on Weapon {
  bool _closeDamageAddition(DamageInstance damage) {
    final projectile = damage.sourceAttack as Projectile;
    final distance = projectile.position.distanceTo(projectile.originPosition);

    var increase = closeDamageIncreaseCurve.transform(
      1 - (distance / closeDamageIncreaseDistanceCutoff).clamp(0, 1),
    );
    increase = (increase * (closeDamageIncreaseAmount - 1)) + 1;

    damage.damageMap.forEach((key, value) {
      damage.damageMap[key] = value * increase;
    });
    return true;
  }

  // ignore: unused_element
  bool _farDamageAddition(DamageInstance damage) {
    final projectile = damage.sourceAttack as Projectile;
    final distance = projectile.position.distanceTo(projectile.originPosition);

    final increase = farDamageIncreaseCurve.transform(
      1 -
          ((distance - farDamageIncreaseDistanceBegin) /
                  farDamageIncreaseDistanceCutoff)
              .clamp(0, 1),
    );

    damage.damageMap.forEach((key, value) {
      damage.damageMap[key] = value * increase * farDamageIncreaseAmount;
    });
    return true;
  }

  final BoolParameterManager increaseCloseDamage =
      BoolParameterManager(baseParameter: false);

  final BoolParameterManager increaseFarDamage =
      BoolParameterManager(baseParameter: false);

  final bool originateFromCenter = false;
  final DoubleParameterManager projectileVelocity =
      DoubleParameterManager(baseParameter: 20);

  List<Projectile> activeProjectiles = [];
  bool allowProjectileRotation = false;
  double closeDamageIncreaseAmount = 2.5;
  Curve closeDamageIncreaseCurve = Curves.easeInCubic;
  double closeDamageIncreaseDistanceCutoff = 8;
  double farDamageIncreaseAmount = 2.5;
  Curve farDamageIncreaseCurve = Curves.easeInCubic;
  double farDamageIncreaseDistanceBegin = 20;
  double farDamageIncreaseDistanceCutoff = 30;
  double particleLifespan = .5;
  DoubleParameterManager projectileSize =
      DoubleParameterManager(baseParameter: .3);
  //META
  abstract ProjectileType? projectileType;

  Projectile buildProjectile(Vector2 delta, double chargeAmount) {
    var newSize = projectileSize.parameter;

    if (this is SemiAutomatic &&
        (this as SemiAutomatic).increaseSizeWhenCharged) {
      newSize *= 1 + chargeAmount;
    }

    return projectileType!.generateProjectile(
      delta: delta,
      size: newSize,
      primaryDamageType: primaryDamageType,
      originPositionVar: generateGlobalPosition(sourceAttackLocation!),
      ancestorVar: this,
      chargeAmount: chargeAmount,
    );
  }

  List<Projectile> generateMultipleProjectileFunction([
    double chargeAmount = 1,
  ]) {
    final returnList = <Projectile>[];

    final temp = attackSplitFunctions.entries.fold<List<double>>(
      [],
      (previousValue, element) => [
        ...previousValue,
        ...element.value.call(
          entityAncestor!.handJoint.angle,
          getAttackCount(chargeAmount),
        ),
      ],
    );
    temp.shuffle();
    for (final radDirection in temp) {
      if (projectileType == null) {
        continue;
      }
      var converted = newPositionRad(Vector2(0, 0), -radDirection, 1);
      converted =
          randomizeVector2Delta(converted, weaponRandomnessPercent.parameter);

      returnList.add(buildProjectile(converted, chargeAmount));
    }

    return returnList;
  }

  Component generateParticle() {
    final particleColor =
        (primaryDamageType ?? baseDamage.damageBase.entries.first.key).color;

    final paint = Paint()..color = particleColor;
    final particle = Particle.generate(
      count: 5 + rng.nextInt(5),
      lifespan: 2,
      applyLifespanToChildren: false,
      generator: (i) => AcceleratedParticle(
        position: generateGlobalPosition(
          SourceAttackLocation.weaponTip,
          tipPercent: .8,
        ),
        speed: (entityAncestor?.body.linearVelocity ?? Vector2.zero()) +
            randomizeVector2Delta(
                  entityAncestor?.aimVector ?? Vector2.zero(),
                  .3,
                ).normalized().clone() *
                3 *
                (1 + rng.nextDouble()),
        child: FadeOutSquareParticle(
          radius: 2 / entityAncestor!.enviroment.gameCamera.viewfinder.zoom,
          // radius: 1,
          paint: paint,
          lifespan: (particleLifespan * rng.nextDouble()) + particleLifespan,
        ),
      ),
    );

    return ParticleSystemComponent(
      particle: particle,
      priority: particlePriority,
    );
  }

  Vector2 randomVector2() => (Vector2.random(rng) - Vector2.random(rng)) * 100;

  Future<void> shootProjectile([double chargeAmount = 1]) async {
    entityAncestor?.enviroment.addPhysicsComponent(
      generateMultipleProjectileFunction(chargeAmount),
      priority: 5,
      duration: .03,
    );

    entityAncestor?.enviroment.add(generateParticle());

    entityAncestor?.handJoint.weaponSpriteAnimation?.add(
      RotateEffect.to(
        (entityAncestor?.handJoint.weaponSpriteAnimation?.angle ?? 0) +
            (entityAncestor!.handJoint.isFlippedHorizontally ? .01 : -.01),
        EffectController(duration: .1, reverseDuration: .1),
      ),
    );
  }

  @override
  Future<void> attackAttempt([double holdDurationPercent = 1]) async {
    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    super.attackAttempt(holdDurationPercent);
  }

  @override
  FutureOr<void> onLoad() {
    pierce.baseParameter = pierce.baseParameter
        .clamp(chainingTargets.parameter, double.infinity)
        .toInt();

    if (increaseCloseDamage.parameter &&
        this is AttributeWeaponFunctionsFunctionality) {
      (this as AttributeWeaponFunctionsFunctionality)
          .onHitProjectile
          .add(_closeDamageAddition);
    }

    if (increaseFarDamage.parameter &&
        this is AttributeWeaponFunctionsFunctionality) {
      (this as AttributeWeaponFunctionsFunctionality)
          .onHitProjectile
          .add(_closeDamageAddition);
    }

    return super.onLoad();
  }

  @override
  SourceAttackLocation? get sourceAttackLocation =>
      super.sourceAttackLocation ?? SourceAttackLocation.weaponTip;

  @override
  Future<void> standardAttack([
    double holdDurationPercent = 1,
    bool callFunctions = true,
  ]) async {
    shootProjectile(holdDurationPercent);
    super.standardAttack(holdDurationPercent, callFunctions);
  }
}

mixin MeleeChargeReady on MeleeFunctionality, SemiAutomatic {
  MeleeAttackHandler? chargeAttackHandler;

  void buildChargeHandler() {
    final customPosition =
        generateGlobalPosition(SourceAttackLocation.body, melee: true);
    chargeAttackHandler = MeleeAttackHandler(
      currentAttack: meleeAttacks[currentAttackIndex],
      weaponAncestor: this,
      isCharging: true,
      attachmentPoint: entityAncestor,
      initAngle: 0,
      initPosition: customPosition,
    )..priority = foregroundPriority;
    entityAncestor?.enviroment.addPhysicsComponent([chargeAttackHandler!]);
  }

  void chargeCompleted() {
    // chargeAnimation?.animation = playAnimation;
    // if (chargedAnimation != null) {
    //   chargeAnimation?.add(SpriteAnimationComponent(
    //     anchor: Anchor.center,
    //     position: Vector2.all(chargeSize / 2),
    //     size: Vector2.all(chargeSize * 2.5),
    //     animation: chargedAnimation,
    //   ));
    // }
  }

  void onBodyFlip(bool isFlipped) {
    chargeAttackHandler?.activeSwings.forEach((element) {
      element.flipHorizontallyAroundCenter();
    });
  }

  @override
  void endAttacking() {
    chargeAttackHandler?.kill();
    chargeAttackHandler = null;
    // final spriteComponent = chargeAnimation;
    // if (endAnimation != null) {
    //   spriteComponent?.animation = endAnimation;
    //   spriteComponent?.animationTicker?.completed
    //       .then((value) => spriteComponent.removeFromParent());
    // } else {
    //   spriteComponent?.removeFromParent();
    // }
    super.endAttacking();
  }

  @override
  FutureOr<void> onLoad() {
    entityAncestor?.onBodyFlip.add(onBodyFlip);
    return super.onLoad();
  }

  @override
  void onRemove() {
    entityAncestor?.onBodyFlip.remove(onBodyFlip);
    super.onRemove();
  }

  @override
  Future<void> startAttacking() async {
    resetCheck();

    // if (!attacksAreActive) {

    if (attacksAreActive) {
      final activeSwing = activeSwings.firstOrNull;
      buildChargeHandler();
      await chargeAttackHandler!.loaded;
      if (chargeAttackHandler != null) {
        chargeAttackHandler!.activeSwings.first.weaponSpriteAnimation!.opacity =
            0;
      }
      await activeSwing?.removed;
      if (chargeAttackHandler != null) {
        chargeAttackHandler!.activeSwings.first.weaponSpriteAnimation!.opacity =
            1;
      }
    } else {
      buildChargeHandler();
    }

    // }

    // damageType = baseDamage.damageBase.keys.toList().random();
    // await buildAnimations();
    // spawnAnimation?.stepTime =
    //     attackTickRate.parameter / (spawnAnimation?.frames.length ?? 1);

    // if (semiAutoType != SemiAutoType.regular) {
    // chargeAnimation = SpriteAnimationComponent(
    //     size: Vector2.all(chargeSize),
    //     anchor: Anchor.center,
    //     animation: spawnAnimation ?? playAnimation)
    //   ..addToParent(
    //       weaponAttachmentPoints[WeaponSpritePosition.hand]!.weaponTip!);

    // if (spawnAnimation == null) {
    //   chargeAnimation?.size = Vector2.zero();
    //   chargeAnimation?.add(SizeEffect.to(
    //       Vector2.all(chargeSize),
    //       EffectController(
    //           duration: attackTickRate.parameter, curve: Curves.bounceIn)));
    // } else {
    // chargeAnimation?.animationTicker?.completed
    //     .then((value) => chargeCompleted());
    // }
    // }

    super.startAttacking();
  }

  @override
  void update(double dt) {
    if (isStartAttackingActive) {}
    super.update(dt);
  }
}

mixin MuzzleGlow on Weapon, ProjectileFunctionality {
  late Paint muzzlePaint;

  Paint paint() => muzzlePaint
    ..shader = ui.Gradient.radial(weaponTipPosition(1).toOffset(), .4, [
      primaryDamageType?.color ?? baseDamage.damageBase.entries.first.key.color,
      Colors.transparent,
    ], [
      0.5,
      1,
    ]);

  @override
  FutureOr<void> onLoad() {
    muzzlePaint = Paint()..blendMode = BlendMode.plus;

    return super.onLoad();
  }

  @override
  void render(ui.Canvas canvas) {
    if (isAttacking) {
      canvas.drawCircle(weaponTipPosition(1).toOffset(), .4, paint());
    }
    super.render(canvas);
  }
}

mixin ChargeEffect on ProjectileFunctionality, SemiAutomatic {
  double chargeSize = .5;
  late DamageType damageType;

  SpriteAnimationComponent? chargeAnimation;
  SpriteAnimation? chargedAnimation;
  SpriteAnimation? endAnimation;
  SpriteAnimation? playAnimation;
  SpriteAnimation? spawnAnimation;

  void addParticles(double percent) {
    entityAncestor?.enviroment.add(generateChargeParticle(percent));
  }

  Future<void> buildAnimations() async {
    playAnimation = await spriteAnimations.fireChargePlay1;
    endAnimation = await spriteAnimations.fireChargeEnd1;
    spawnAnimation = await spriteAnimations.fireChargeSpawn1;
    chargedAnimation = await spriteAnimations.fireChargeCharged1;
  }

  void chargeCompleted() {
    chargeAnimation?.animation = playAnimation;
    if (chargedAnimation != null) {
      chargeAnimation?.add(
        SpriteAnimationComponent(
          anchor: Anchor.center,
          position: Vector2.all(chargeSize / 2),
          size: Vector2.all(chargeSize * 2.5),
          animation: chargedAnimation,
        ),
      );
    }
  }

  Component generateChargeParticle(double percent) {
    final particleColor = damageType.color;
    final paint = Paint()..color = particleColor;
    final particle = Particle.generate(
      count: (1 + rng.nextInt(3) * percent).round(),
      lifespan: 2,
      applyLifespanToChildren: false,
      generator: (i) => AcceleratedParticle(
        position: weaponTipPosition(1) + Vector2.zero(),
        speed: ((Vector2.random() * 4) - Vector2.all(2)) * percent,
        child: FadeOutSquareParticle(
          radius: .04 * ((rng.nextDouble() * .9) + .1),
          paint: paint,
          lifespan: (particleLifespan * rng.nextDouble()) + particleLifespan,
        ),
      ),
    );

    return ParticleSystemComponent(particle: particle);
  }

  @override
  void endAttacking() {
    final spriteComponent = chargeAnimation;
    if (endAnimation != null) {
      spriteComponent?.animation = endAnimation;
      spriteComponent?.animationTicker?.completed
          .then((value) => spriteComponent.removeFromParent());
    } else {
      spriteComponent?.removeFromParent();
    }
    super.endAttacking();
  }

  @override
  double get particleLifespan => .2;

  @override
  Future<void> startAttacking() async {
    damageType = baseDamage.damageBase.keys.toList().random();
    await buildAnimations();
    spawnAnimation?.stepTime =
        chargeLength / (spawnAnimation?.frames.length ?? 1);
    if (semiAutoType != SemiAutoType.regular) {
      chargeAnimation = SpriteAnimationComponent(
        size: Vector2.all(chargeSize),
        anchor: Anchor.center,
        position: Vector2(0, tipOffset.y * weaponLength),
        animation: spawnAnimation ?? playAnimation,
      )..addToParent(entityAncestor!.handJoint);

      if (spawnAnimation == null) {
        chargeAnimation?.size = Vector2.zero();
        chargeAnimation?.add(
          SizeEffect.to(
            Vector2.all(chargeSize),
            EffectController(
              duration: attackTickRate.parameter,
              curve: Curves.bounceIn,
            ),
          ),
        );
      } else {
        chargeAnimation?.animationTicker?.completed
            .then((value) => chargeCompleted());
      }
    }

    super.startAttacking();
  }

  @override
  void update(double dt) {
    // if (isAttacking) {
    //   addParticles(.5);
    // }
    super.update(dt);
  }
}

mixin SemiAutomatic on Weapon {
  bool attackOnChargeComplete = false;
  bool attackOnRelease = true;
  double dragIncreaseOnHoldComplete = .0;
  bool increaseAttackCountWhenCharged = false;
  bool increaseSizeWhenCharged = true;
  IntParameterManager increaseWhenFullyCharged =
      IntParameterManager(baseParameter: 3);

  bool isStartAttackingActive = false;
  double movementReductionOnHoldComplete = 0;
  abstract SemiAutoType semiAutoType;

  TimerComponent? attackTimer;
  double? customChargeDuration;
  TimerComponent? durationHeldTimer;

  double get attackRateDelay => attackTickRate.parameter;
  double get chargeLength => customChargeDuration ?? attackTickRate.parameter;
  double get holdDurationPercent => semiAutoType == SemiAutoType.regular
      ? 1
      : Curves.easeIn
          .transform(ui.clampDouble(durationHeld / chargeLength, 0, 1));

  void applyAimReductionSpeedReduction(bool apply) {
    if (apply) {
      if (entityAncestor is AimFunctionality) {
        final aim = entityAncestor!;
        if (dragIncreaseOnHoldComplete != 0) {
          aim.aimingInterpolationAmount
              .setParameterPercentValue(weaponId, dragIncreaseOnHoldComplete);
        }
      }

      if (entityAncestor is MovementFunctionality) {
        final move = entityAncestor! as MovementFunctionality;
        if (movementReductionOnHoldComplete != 0) {
          move.speed
              .setParameterPercentValue(weaponId, dragIncreaseOnHoldComplete);
        }
      }
    } else {
      if (entityAncestor is AimFunctionality) {
        final aim = entityAncestor!;
        aim.aimingInterpolationAmount.removeKey(weaponId);
      }

      if (entityAncestor is MovementFunctionality) {
        final move = entityAncestor! as MovementFunctionality;
        if (movementReductionOnHoldComplete != 0) {
          move.speed
              .setParameterPercentValue(weaponId, dragIncreaseOnHoldComplete);
        }
      }
    }
  }

  void onHoldComplete() {
    if (attackOnChargeComplete) {
      attackAttempt();
    }
    applyAimReductionSpeedReduction(true);
  }

  @override
  Future<void> attackAttempt([double holdDurationPercent = 1]) async {
    if (attackRateDelay != 0) {
      if (attackTimer == null) {
        attackTimer = TimerComponent(
          period: attackTickRate.parameter,
          removeOnFinish: true,
          onTick: () {
            attackTimer = null;
          },
        );
        add(attackTimer!);
      } else {
        return;
      }
    }
    super.attackAttempt(holdDurationPercent);
  }

  @override
  double get durationHeld =>
      durationHeldTimer != null ? durationHeldTimer!.timer.current : 0;

  @override
  void endAttacking() {
    if (attackOnRelease) {
      switch (semiAutoType) {
        case SemiAutoType.release:
          if (durationHeld >= chargeLength) {
            attackAttempt();
          }
          break;
        case SemiAutoType.charge:
          attackAttempt(holdDurationPercent);
          break;
        default:
      }
    }

    durationHeldTimer?.removeFromParent();
    durationHeldTimer = null;
    isStartAttackingActive = false;
    applyAimReductionSpeedReduction(false);

    super.endAttacking();
  }

  @override
  void startAttacking() {
    isStartAttackingActive = true;
    switch (semiAutoType) {
      case SemiAutoType.regular:
        attackAttempt();
        break;
      default:
        setWeaponStatus(WeaponStatus.charge);
    }
    durationHeldTimer = TimerComponent(
      period: chargeLength,
      onTick: onHoldComplete,
    )..addToParent(this);

    super.startAttacking();
  }
}

mixin ChargeFullAutomatic on Weapon, FullAutomatic, SemiAutomatic {
  bool continuousAttackingStarted = false;

  @override
  void attackTick() {
    if (continuousAttackingStarted) {
      super.attackTick();
    }
  }

  @override
  void endAttacking() {
    if (attackOnRelease) {
      attackTimer?.onTick();
    }

    continuousAttackingStarted = false;
    super.endAttacking();
  }

  @override
  bool get instantAttack => false;

  @override
  void onHoldComplete() {
    if (attackOnChargeComplete) {
      attackTimer?.onTick();
    }
    continuousAttackingStarted = true;
    attackTimer?.timer.reset();
  }

  @override
  SemiAutoType get semiAutoType => SemiAutoType.charge;

  @override
  set semiAutoType(SemiAutoType semiAutoType) {}
}

mixin FullAutomatic on Weapon {
  bool allowRapidClicking = false;
  int attackTicks = 0;
  bool instantAttack = true;
  bool stopAttacking = false;

  TimerComponent? attackTimer;

  void attackFinishTick() {
    attackTimer?.removeFromParent();
    attackTicks = 0;
    attackTimer = null;
    stopAttacking = false;
  }

  void attackTick() {
    attackAttempt();
    attackTicks++;
  }

  void initTimer() {
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

  @override
  double get durationHeld => attackTicks * attackTickRate.parameter;

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

    initTimer();
    super.startAttacking();
  }
}

typedef OnHitDef = bool Function(DamageInstance damage);

mixin AttributeWeaponFunctionsFunctionality on Weapon {
  //Event functions that are modified from attributes
  List<Function(HealthFunctionality other)> onKill = [];

  List<Function(Projectile projectile)> onProjectileDeath = [];
  List<Function(Projectile projectile)> onAttackProjectile = [];
  List<Function(double holdDuration)> onAttackMelee = [];
  List<Function(double holdDuration)> onAttack = [];
  List<Function()> onReload = [];
  List<Function(Weapon weapon)> onAttackingFinish = [];
  List<OnHitDef> onHit = [];
  List<OnHitDef> onHitMelee = [];
  List<OnHitDef> onHitProjectile = [];

  @override
  void standardAttack([
    double holdDurationPercent = 1,
    bool callFunctions = true,
  ]) {
    if (this is MeleeFunctionality) {
      for (final element in onAttackMelee) {
        element(holdDurationPercent);
      }
    }
    for (final element in onAttack) {
      element(holdDurationPercent);
    }
    super.standardAttack(holdDurationPercent, callFunctions);
  }
}

String buildWeaponDescription(
  WeaponDescription weaponDescription,
  Weapon builtWeapon, [
  bool isUnlocked = true,
]) {
  var returnString = '';

  if (!isUnlocked) {
    return ' - ';
  }

  switch (weaponDescription) {
    case WeaponDescription.attackRate:
      returnString =
          '${builtWeapon.attackRateSecondComparison.toStringAsFixed(1)}/s';
      break;
    case WeaponDescription.damage:
      var firstLoop = true;
      for (final element in builtWeapon.baseDamage.damageBase.entries) {
        if (firstLoop) {
          firstLoop = false;
        } else {
          returnString += '\n';
        }
        returnString +=
            '${element.key.name.titleCase}: ${element.value.$1.toStringAsFixed(0)} - ${element.value.$2.toStringAsFixed(0)}';
      }

      break;

    case WeaponDescription.reloadTime:
      if (builtWeapon is ReloadFunctionality) {
        returnString =
            '${builtWeapon.reloadTime.parameter.toStringAsFixed(0)} s';
      } else {
        returnString = '';
      }
      break;
    case WeaponDescription.staminaCost:
      if (builtWeapon is StaminaCostFunctionality) {
        returnString = '${builtWeapon.weaponStaminaCost}/attack';
      } else {
        returnString = '';
      }
      break;
    case WeaponDescription.maxAmmo:
      if (builtWeapon is ReloadFunctionality) {
        returnString = '${builtWeapon.maxAttacks}';
      } else {
        returnString = '';
      }
      break;
    case WeaponDescription.velocity:
      if (builtWeapon is ProjectileFunctionality) {
        returnString = '${builtWeapon.projectileVelocity.parameter.round()}m/s';
      } else {
        returnString = '';
      }
      break;
    case WeaponDescription.semiOrAuto:
      if (builtWeapon is SemiAutomatic) {
        switch (builtWeapon.semiAutoType) {
          case SemiAutoType.regular:
            returnString = 'Semi-Auto';
            break;

          case SemiAutoType.release:
            returnString = 'Release';
            break;
          case SemiAutoType.charge:
            returnString = 'Charge';
            break;
        }

        if (builtWeapon is ChargeFullAutomatic) {
          returnString = 'Wind-up';
        }
      } else if (builtWeapon is FullAutomatic) {
        returnString = 'Full-Auto';
      }

      break;

    case WeaponDescription.additionalAttackCount:
      final count = builtWeapon.getAttackCount(1);
      if (count == 0) {
        returnString = '';
      } else {
        returnString = '$count attack(s)';
      }

      break;
    case WeaponDescription.description:
      returnString = '';
  }

  return returnString;
}

enum AttackSpreadType { base, regular, cross, back }

// extension AttackSpreadTypeExtension on AttackSpreadType {
//   List<double> buildAttacks(double angle, int count,
//       [double spreadDegrees = 60]) {
//     switch (this) {
//       case AttackSpreadType.regular:
//         return regularAttackSpread(angle, count, spreadDegrees);
//       case AttackSpreadType.cross:
//         return regularAttackSpread(angle, count, spreadDegrees);

//       case AttackSpreadType.back:
//         return regularAttackSpread(angle, count, spreadDegrees);
//     }
//   }
// }

List<double> regularAttackSpread(
  double angle,
  int count, [
  double spreadDegrees = 60,
  bool baseRemoved = false,
]) {
  List<double> returnList;
  if (baseRemoved || count.isEven) {
    returnList = splitRadInCone(angle, count, spreadDegrees, false);
  } else {
    returnList = splitRadInCone(angle, count + 1, spreadDegrees, true);
  }

  return returnList;
}
