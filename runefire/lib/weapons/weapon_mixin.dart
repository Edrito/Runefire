import 'dart:async';
import 'dart:math';
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
  Future<void> attackAttempt(AttackConfiguration attackConfiguration) async {
    if ((entityAncestor! as AttackFunctionality).currentWeapon != this) {
      return;
    }

    super.attackAttempt(attackConfiguration);
  }
}

mixin ReloadFunctionality on Weapon {
  //Status of reloading
  int _spentAttacks = 0;

  final IntParameterManager maxAttacks = IntParameterManager(baseParameter: 10);

  ///How long in seconds to reload
  final DoubleParameterManager reloadTime =
      DoubleParameterManager(baseParameter: 1);

  ///Timer that when completes finishes reload
  TimerComponent? reloadTimer;

  double get percentReloaded =>
      (reloadTimer?.timer.current ?? reloadTime.parameter) /
      reloadTime.parameter;

  int? get remainingAttacks =>
      maxAttacks.parameter == 0 ? null : maxAttacks.parameter - spentAttacks;

  int get spentAttacks => _spentAttacks;

  void createReloadBar() {
    if (entityAncestor == null) {
      return;
    }
    entityAncestor!.entityVisualEffectsWrapper.addReloadAnimation(
      weaponId,
      reloadTime.parameter,
      reloadTimer!,
      isSecondaryWeapon,
    );
  }

  void reload({bool instant = false}) {
    if (this is MeleeFunctionality) {
      (this as MeleeFunctionality).resetToFirstSwing();
    }

    if (instant) {
      reloadFunctions();
      stopReloading();
    } else {
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

    for (final attribute
        in attributeWeaponFunctionsFunctionality?.onReload ?? <Function()>[]) {
      attribute();
    }
  }

  void removeReloadAnimation() {
    entityAncestor?.entityVisualEffectsWrapper
        .removeReloadAnimation(weaponId, isSecondaryWeapon);
  }

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
  Future<void> attackAttempt(AttackConfiguration attackConfiguration) async {
    if (!attackConfiguration.useAmmo) {
      super.attackAttempt(attackConfiguration);
      return;
    }

    //Do not attack if reloading
    if (isReloading) {
      return;
    }

    spentAttacks++;
    super.attackAttempt(attackConfiguration);

    //Check if needs to reload after an attack
    reloadCheck();
  }
}

mixin StaminaCostFunctionality on Weapon {
  final DoubleParameterManager weaponStaminaCost = DoubleParameterManager(
    baseParameter: 10,
    maxParameter: 200,
  );

  @override
  Future<void> attackAttempt(AttackConfiguration attackConfiguration) async {
    if (entityAncestor is StaminaFunctionality) {
      final stamina = entityAncestor! as StaminaFunctionality;
      if (!stamina.hasEnoughStamina(weaponStaminaCost.parameter)) {
        return;
      }
      stamina.modifyStamina(-weaponStaminaCost.parameter);
    }
    super.attackAttempt(attackConfiguration);
  }
}
typedef WeaponSpriteAnimationBuilder = Future<WeaponSpriteAnimation> Function();

class MeleeAttack {
  MeleeAttack({
    required this.attackHitboxSizeBuild,
    required this.entitySpriteAnimation,
    required this.attackSpriteAnimationBuild,
    required this.chargePattern,
    required this.attackPattern,
    this.onAttack,
    this.weaponTrailConfig,
    this.meleeAttackType = MeleeType.slash,
    this.flippedDuringAttack = false,
    this.customStartAngle = true,
  });

  final Future<SpriteAnimation>? entitySpriteAnimation;

  bool customStartAngle;
  bool flippedDuringAttack;
  List<WeaponSpriteAnimation> latestAttackSpriteAnimation = [];
  MeleeType meleeAttackType;

  WeaponSpriteAnimationBuilder? attackSpriteAnimationBuild;
  WeaponTrailConfig? weaponTrailConfig;

  Function()? onAttack;

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
  final (Vector2 Function(), (double, double)) attackHitboxSizeBuild;
}

mixin MeleeFunctionality on Weapon {
  final BoolParameterManager meleeAttacksCollision = BoolParameterManager(
    baseParameter: false,
    frequencyDeterminesTruth: false,
  );

  List<MeleeAttackHandler> activeSwings = [];
  int _currentAttackIndex = 0;
  set currentAttackIndex(int value) {
    _currentAttackIndex = value;
  }

  int get currentAttackIndex {
    if (_currentAttackIndex > meleeAttacks.length - 1) {
      resetToFirstSwing();
    }
    return _currentAttackIndex;
  }

  void resetToFirstSwing() {
    _currentAttackIndex = 0;
    currentSwingPosition = null;
  }

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

  void meleeAttack(
    int? index, {
    required AttackConfiguration attackConfiguration,
    double? angle,
    bool forceCrit = false,
  }) {
    final returnList = <Component>[];
    final currentSwingAngle = angle ?? entityAncestor?.handJoint.angle ?? 0;
    final indexUsed = index ?? currentAttackIndex;

    final temp =
        (attackConfiguration.customAttackSpreadPattern ?? attackSpreadPatterns)
            .fold<List<double>>(
      [],
      (previousValue, element) => [
        ...previousValue,
        ...element.call(
          currentSwingAngle,
          getAttackCount(attackConfiguration.holdDurationPercent),
        ),
      ],
    );

    for (final deltaDirection in temp) {
      final customPosition = attackConfiguration.customAttackPosition ??
          generateGlobalPosition(
            attackConfiguration.customAttackLocation ?? sourceAttackLocation!,
            melee: true,
          );

      returnList.add(
        MeleeAttackHandler(
          initPosition: customPosition,
          initAngle: deltaDirection,
          forceCrit: forceCrit,
          attachmentPoint: sourceAttackLocation != SourceAttackLocation.mouse
              ? entityAncestor
              : null,
          currentAttack: meleeAttacks[indexUsed]..onAttack?.call(),
          weaponAncestor: this,
        ),
      );
    }
    entityAncestor?.enviroment.addPhysicsComponent(returnList, priority: 5);

    currentAttackIndex++;
  }

  @override
  Future<void> attackAttempt(AttackConfiguration attackConfiguration) async {
    currentSwingPosition = Vector2.zero();

    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    final future = entityAncestor?.setEntityAnimation(
      meleeAttacks.indexWhere((element) => element == currentAttack),
    );
    if (attackOnAnimationFinish) {
      await future;
    }
    if (this is SemiAutomatic) {
      super.attackAttempt(
        attackConfiguration.copyWith(
          holdDurationPercent: (this as SemiAutomatic).holdDurationPercent,
        ),
      );
    } else {
      super.attackAttempt(attackConfiguration);
    }
  }

  @override
  bool get attacksAreActive => activeSwings.isNotEmpty;

  @override
  void endAttacking() {
    if (this is! ReloadFunctionality &&
        this is! SemiAutomatic &&
        resetSwingsOnEndAttacking) {
      resetToFirstSwing();
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
  Future<void> standardAttack(
    AttackConfiguration attackConfiguration,
  ) async {
    meleeAttack(
      currentAttackIndex,
      attackConfiguration: attackConfiguration,
    );
    super.standardAttack(
      attackConfiguration,
    );
  }
}

mixin SecondaryFunctionality on Weapon {
  Weapon? secondaryWeapon;
  SecondaryWeaponAbility? secondaryWeaponAbility;

  bool get secondaryIsWeapon => secondaryWeapon != null;

  set setSecondaryFunctionality(dynamic item) {
    secondaryWeapon?.removeFromParent();
    secondaryWeaponAbility?.removeFromParent();
    secondaryWeapon = null;
    secondaryWeaponAbility = null;
    if (item is Weapon) {
      secondaryWeapon = item;
      secondaryWeapon?.weaponAttachmentPoints = weaponAttachmentPoints;
      secondaryWeapon?.isSecondaryWeapon = true;
      secondaryWeapon?.weaponId = weaponId;
      secondaryWeapon?.addToParent(this);
      secondaryWeapon?.parentWeapon = this;
      // assert(_secondaryWeapon is! FullAutomatic);
    } else if (item is SecondaryWeaponAbility) {
      secondaryWeaponAbility = item;
      add(item);
    }
  }

  @override
  void endAltAttacking() {
    secondaryWeapon?.endAttacking();
    if (secondaryWeaponAbility?.endAbilityOnSecondaryRelease ?? false) {
      secondaryWeaponAbility?.endAbility();
    }
  }

  @override
  void startAltAttacking() {
    secondaryWeapon?.startAttacking();
    secondaryWeaponAbility?.startAbilityCheck();
  }

  @override
  void weaponSwappedFrom() {
    final entityStatusWrapper = entityAncestor?.entityVisualEffectsWrapper;
    entityStatusWrapper?.hideReloadAnimations(weaponId);
    super.weaponSwappedFrom();
  }

  @override
  void weaponSwappedTo() {
    final entityStatusWrapper = entityAncestor?.entityVisualEffectsWrapper;
    entityStatusWrapper?.showReloadAnimations(weaponId);
    super.weaponSwappedTo();
  }
}

mixin ProjectileFunctionality on Weapon {
  final BoolParameterManager increaseCloseDamage = BoolParameterManager(
    baseParameter: false,
    frequencyDeterminesTruth: false,
  );

  final BoolParameterManager increaseFarDamage = BoolParameterManager(
    baseParameter: false,
    frequencyDeterminesTruth: false,
  );

  final bool originateFromCenter = false;
  final DoubleParameterManager projectileVelocity =
      DoubleParameterManager(baseParameter: 20);

  List<Projectile> activeProjectiles = [];
  bool allowProjectileRotation = false;
  DoubleParameterManager closeDamageIncreaseAmount =
      DoubleParameterManager(baseParameter: 1.5);

  Curve closeDamageIncreaseCurve = Curves.easeInCubic;
  double closeDamageIncreaseDistanceCutoff = 8;
  double farDamageIncreaseAmount = 2.5;
  Curve farDamageIncreaseCurve = Curves.easeInCubic;
  double farDamageIncreaseDistanceBegin = 20;
  double farDamageIncreaseDistanceCutoff = 30;
  double particleLifespan = .5;
  DoubleParameterManager projectileLifeSpan =
      DoubleParameterManager(baseParameter: 2);

  DoubleParameterManager projectileRelativeSize =
      DoubleParameterManager(baseParameter: 1);

  //META
  abstract ProjectileType? projectileType;

  double get particleAddSpeed => 0.02;

  Projectile buildProjectile(
    Vector2 delta,
    AttackConfiguration attackConfiguration,
  ) {
    var newSize = projectileRelativeSize.parameter;

    if (this is SemiAutomatic &&
        (this as SemiAutomatic).increaseSizeWhenCharged) {
      newSize *= 1 + attackConfiguration.holdDurationPercent;
    }
    if (weaponLength != 0 && weaponLength.isFinite) {
      newSize *= weaponLength / 3;
    }
    return projectileType!.generateProjectile(
      ProjectileConfiguration(
        delta: delta,
        originPosition: attackConfiguration.customAttackPosition ??
            generateGlobalPosition(
              attackConfiguration.customAttackLocation ?? sourceAttackLocation!,
            ),
        weaponAncestor: this,
        size: newSize,
        parentWeaponAttackingStopped: attackConfiguration.isAltAttack
            ? weaponSecondaryAttackingCompleter
            : weaponPrimaryAttackingCompleter,
        power: attackConfiguration.holdDurationPercent,
        primaryDamageType: primaryDamageType,
      ),
    );
  }

  List<Projectile> generateMultipleProjectileFunction(
    AttackConfiguration attackConfiguration,
  ) {
    final returnList = <Projectile>[];

    final temp =
        (attackConfiguration.customAttackSpreadPattern ?? attackSpreadPatterns)
            .fold<List<double>>(
      [],
      (previousValue, element) => [
        ...previousValue,
        ...element.call(
          entityAncestor!.handJoint.angle,
          getAttackCount(attackConfiguration.holdDurationPercent),
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
      returnList.add(
        buildProjectile(
          converted,
          attackConfiguration,
        ),
      );
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

  Future<void> shootProjectile(
    AttackConfiguration attackConfiguration,
  ) async {
    entityAncestor?.enviroment.addPhysicsComponent(
      generateMultipleProjectileFunction(
        attackConfiguration,
      ),
      priority: 5,
      duration: particleAddSpeed,
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
  Future<void> attackAttempt(AttackConfiguration attackConfiguration) async {
    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    super.attackAttempt(attackConfiguration);
  }

  @override
  FutureOr<void> onLoad() {
    pierce.baseParameter = pierce.baseParameter
        .clamp(chainingTargets.parameter, double.infinity)
        .toInt();

    if (increaseCloseDamage.parameter) {
      attributeWeaponFunctionsFunctionality?.onHitProjectile
          .add(_closeDamageAddition);
    }

    if (increaseFarDamage.parameter) {
      attributeWeaponFunctionsFunctionality?.onHitProjectile
          .add(_closeDamageAddition);
    }

    return super.onLoad();
  }

  @override
  SourceAttackLocation? get sourceAttackLocation =>
      super.sourceAttackLocation ?? SourceAttackLocation.weaponTip;

  @override
  Future<void> standardAttack(
    AttackConfiguration attackConfiguration,
  ) async {
    shootProjectile(
      attackConfiguration,
    );
    super.standardAttack(
      attackConfiguration,
    );
  }

  bool _closeDamageAddition(DamageInstance damage) {
    final projectile = damage.sourceAttack as Projectile;
    final distance = projectile.position.distanceTo(projectile.originPosition);

    var increase = closeDamageIncreaseCurve.transform(
      1 - (distance / closeDamageIncreaseDistanceCutoff).clamp(0, 1),
    );
    increase = (increase * closeDamageIncreaseAmount.parameter) + 1;

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
    chargeAttackHandler?.kill();
    chargeAttackHandler = null;
    super.onRemove();
  }

  @override
  Future<void> startAttacking() async {
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
  void onRemove() {
    chargeAnimation?.removeFromParent();
    super.onRemove();
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

  @override
  void weaponSwappedFrom() {
    chargeAnimation?.removeFromParent();
    super.weaponSwappedFrom();
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
      attackAttempt(const AttackConfiguration());
    }
    applyAimReductionSpeedReduction(true);
  }

  @override
  Future<void> attackAttempt(AttackConfiguration attackConfiguration) async {
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
    super.attackAttempt(attackConfiguration);
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
            attackAttempt(const AttackConfiguration());
          }
          break;
        case SemiAutoType.charge:
          attackAttempt(
            AttackConfiguration(holdDurationPercent: holdDurationPercent),
          );
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
        attackAttempt(const AttackConfiguration());
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
    attackAttempt(const AttackConfiguration());
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
  List<Function(AttackConfiguration attackConfiguration, Weapon weapon)>
      onAttackMelee = [];
  List<Function(AttackConfiguration attackConfiguration, Weapon weapon)>
      onAttackMagic = [];
  List<Function(AttackConfiguration attackConfiguration, Weapon weapon)>
      onAttack = [];
  List<Function(Weapon weapon)> onReload = [];
  List<Function(Weapon weapon)> onAttackingFinish = [];
  List<Function(Weapon weapon)> onSwappedTo = [];
  List<Function(Weapon weapon)> onSwappedFrom = [];
  List<OnHitDef> onDamage = [];
  List<OnHitDef> onDamageMagic = [];
  List<OnHitDef> onDamageMelee = [];
  List<OnHitDef> onDamageProjectile = [];
  List<OnHitDef> onHit = [];
  List<OnHitDef> onHitMagic = [];
  List<OnHitDef> onHitMelee = [];
  List<OnHitDef> onHitProjectile = [];

  @override
  void standardAttack(AttackConfiguration attackConfiguration) {
    if (this is MeleeFunctionality) {
      for (final element in onAttackMelee) {
        element(attackConfiguration, this);
      }
    }
    for (final element in onAttack) {
      element(attackConfiguration, this);
    }
    super.standardAttack(
      attackConfiguration,
    );
  }

  @override
  void weaponSwappedFrom() {
    for (final attribute in onSwappedFrom) {
      attribute(this);
    }
    super.weaponSwappedFrom();
  }

  @override
  void weaponSwappedTo() {
    for (final attribute in onSwappedTo) {
      attribute(this);
    }
    super.weaponSwappedTo();
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
    case WeaponDescription.pierce:
      returnString =
          '${builtWeapon.pierceParameter.toStringAsFixed(0)} enemies';

      break;
    case WeaponDescription.staminaCost:
      if (builtWeapon is StaminaCostFunctionality) {
        returnString = '${builtWeapon.weaponStaminaCost.baseParameter}/attack';
      } else {
        returnString = '';
      }
      break;
    case WeaponDescription.maxAmmo:
      if (builtWeapon is ReloadFunctionality) {
        returnString = '${builtWeapon.maxAttacks.baseParameter}';
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

List<double> crossAttackSpread({
  double? initialAngle,
  int count = 4,
}) {
  final returnList = <double>[];
  final angle = pi * 2 / count;
  for (var i = 0; i < count; i++) {
    returnList.add((angle * i) + (initialAngle ?? 0));
  }
  return returnList;
}

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
