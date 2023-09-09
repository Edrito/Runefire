import 'dart:async';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/constants/priorities.dart';
import 'package:game_app/resources/data_classes/base.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/secondary_abilities.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:recase/recase.dart';

import '../resources/functions/custom.dart';
import '../resources/functions/functions.dart';
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
    reloadFunctions();
    reloadTimer = TimerComponent(
      period: reloadTime.parameter,
      removeOnFinish: true,
      onTick: () {
        stopReloading();
        reloadCompleteFunctions();
      },
    )..addToParent(this);
    createReloadBar();
  }

  void reloadCompleteFunctions() {
    if (entityAncestor is AttributeFunctionsFunctionality) {
      final attributeFunctions =
          entityAncestor as AttributeFunctionsFunctionality;
      for (var attribute in attributeFunctions.onReloadComplete) {
        attribute(this);
      }
    }
  }

  void reloadFunctions() {
    if (entityAncestor is AttributeFunctionsFunctionality) {
      final attributeFunctions =
          entityAncestor as AttributeFunctionsFunctionality;
      for (var attribute in attributeFunctions.onReload) {
        attribute(this);
      }
    }
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
typedef WeaponSpriteAnimationBuilder = Future<WeaponSpriteAnimation> Function();

class MeleeAttack {
  MeleeAttack(
      {required this.attackHitboxSize,
      required this.entitySpriteAnimation,
      required this.attackSpriteAnimationBuild,
      required this.chargePattern,
      this.flippedDuringAttack = false,
      this.customStartAngle = true,
      required this.attackPattern});

  final Vector2 attackHitboxSize;
  final SpriteAnimation? entitySpriteAnimation;
  WeaponSpriteAnimationBuilder? attackSpriteAnimationBuild;
  List<WeaponSpriteAnimation> latestAttackSpriteAnimation = [];

  bool customStartAngle;
  bool flippedDuringAttack;

  Future<WeaponSpriteAnimation?> buildWeaponSpriteAnimation() async {
    if (attackSpriteAnimationBuild == null) return null;
    final spriteAnimation = await attackSpriteAnimationBuild!.call();
    latestAttackSpriteAnimation.add(spriteAnimation);
    return spriteAnimation;
  }

  ///List of Patterns for single attack, each pattern is a position, angle and reletive scale of the hitbox
  List<(Vector2, double, double)> attackPattern;

  List<(Vector2, double, double)> chargePattern;
}

mixin MeleeFunctionality on Weapon {
  ///How many attacks are in the melee combo
  int get numberOfAttacks => meleeAttacks.length;

  MeleeAttack? get currentAttack =>
      meleeAttacks.isEmpty ? null : meleeAttacks[currentAttackIndex];

  final BoolParameterManager meleeAttacksCollision =
      BoolParameterManager(baseParameter: false);

  MeleeType meleeType = MeleeType.slash;

  List<MeleeAttack> meleeAttacks = [];

  Vector2? currentSwingPosition;

  @override
  bool get attacksAreActive => activeSwings.isNotEmpty;
  List<MeleeAttackHandler> activeSwings = [];

  int currentAttackIndex = 0;

  @override
  SourceAttackLocation? sourceAttackLocation =
      SourceAttackLocation.distanceFromPlayer;

  @override
  FutureOr<void> onLoad() {
    if (this is ReloadFunctionality) {
      (this as ReloadFunctionality).maxAttacks.baseParameter = numberOfAttacks;
    }
    return super.onLoad();
  }

  void meleeAttack(int? index, [double chargeAmount = 1]) {
    List<Component> returnList = [];
    final currentSwingAngle = entityAncestor?.handJoint.angle ?? 0;
    final indexUsed = (index ?? currentAttackIndex);

    List<double> temp = splitRadInCone(
        currentSwingAngle, attackCount, maxSpreadDegrees.parameter);

    for (var deltaDirection in temp) {
      final customPosition =
          generateSourcePosition(sourceAttackLocation!, null, true);
      returnList.add(MeleeAttackHandler(
        initPosition: customPosition,
        initAngle: deltaDirection,
        attachmentPoint: sourceAttackLocation != SourceAttackLocation.mouse
            ? entityAncestor
            : null,
        currentAttack: meleeAttacks[indexUsed],
        weaponAncestor: this,
      ));
    }

    entityAncestor?.enviroment.physicsComponent.addAll(returnList);
    currentAttackIndex++;
  }

  @override
  void standardAttack(
      [double holdDurationPercent = 1, bool callFunctions = true]) async {
    meleeAttack(currentAttackIndex, holdDurationPercent);
    super.standardAttack(holdDurationPercent, callFunctions);
  }

  @override
  void endAttacking() {
    if (this is! ReloadFunctionality && this is! SemiAutomatic) {
      resetToFirstSwings();
    }
    super.endAttacking();
  }

  void resetCheck() {
    if (currentAttackIndex >= numberOfAttacks) {
      resetToFirstSwings();
    }
  }

  @override
  void attackAttempt([double holdDurationPercent = 1]) async {
    resetCheck();
    currentSwingPosition = Vector2.zero();

    if (this is SemiAutomatic) {
      holdDurationPercent = (this as SemiAutomatic).holdDurationPercent;
    }

    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);
    final future = entityAncestor?.setEntityStatus(EntityStatus.attack,
        customAnimationKey:
            meleeAttacks.indexWhere((element) => element == currentAttack));
    attackOnAnimationFinish ? await future : future;
    super.attackAttempt(holdDurationPercent);
  }

  void resetToFirstSwings() {
    currentSwingPosition = null;
    currentAttackIndex = 0;
  }
}

mixin SecondaryFunctionality on Weapon {
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

  bool get secondaryIsWeapon => secondaryWeapon != null;

  Weapon? secondaryWeapon;
  SecondaryWeaponAbility? secondaryWeaponAbility;

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
    secondaryWeapon?.startAttacking();
    secondaryWeaponAbility?.startAbilityCheck();
  }

  @override
  void endAltAttacking() {
    secondaryWeapon?.endAttacking();
    secondaryWeaponAbility?.endAbility();
  }
}

mixin ProjectileFunctionality on Weapon {
  //META
  abstract ProjectileType? projectileType;
  bool allowProjectileRotation = false;

  final DoubleParameterManager projectileVelocity =
      DoubleParameterManager(baseParameter: 20);

  List<Projectile> activeProjectiles = [];

  final bool originateFromCenter = false;

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
      holdDurationPercent = (this as SemiAutomatic).holdDurationPercent;
    }
    attackOnAnimationFinish
        ? await setWeaponStatus(WeaponStatus.attack)
        : setWeaponStatus(WeaponStatus.attack);

    additionalCountCheck();
    super.attackAttempt(holdDurationPercent);
  }

  @override
  SourceAttackLocation? get sourceAttackLocation =>
      super.sourceAttackLocation ?? SourceAttackLocation.weaponTip;

  Vector2 randomVector2() => (Vector2.random(rng) - Vector2.random(rng)) * 100;

  void shootProjectile([double chargeAmount = 1]) {
    entityAncestor?.enviroment.physicsComponent
        .addAll(generateProjectileFunction(chargeAmount));
    // entityAncestor?.enviroment.add(generateParticle());

    entityAncestor?.handJoint.weaponSpriteAnimation?.add(RotateEffect.to(
        (entityAncestor?.handJoint.weaponSpriteAnimation?.angle ?? 0) +
            (entityAncestor!.handJoint.isFlippedHorizontally ? .01 : -.01),
        EffectController(duration: .1, reverseDuration: .1)));
  }

  @override
  void standardAttack(
      [double holdDurationPercent = 1, bool callFunctions = true]) async {
    shootProjectile(holdDurationPercent);
    super.standardAttack(holdDurationPercent, callFunctions);
  }

  double particleLifespan = .5;

  Component generateParticle() {
    Vector2 moveDelta = entityAncestor?.body.linearVelocity ?? Vector2.zero();
    var particleColor = Colors.blue.withOpacity(.5);
    final particle = Particle.generate(
      count: 20 + rng.nextInt(10),
      lifespan: 2,
      applyLifespanToChildren: false,
      generator: (i) => AcceleratedParticle(
        position: getWeaponTipDownBarrel(.9),
        speed: (randomizeVector2Delta(
                        entityAncestor?.entityAimAngle ?? Vector2.zero(), .3)
                    .normalized())
                .clone() *
            3 *
            (1 + rng.nextDouble()),
        child: FadeOutCircleParticle(
            radius: .05 * ((rng.nextDouble() * .9) + .1),
            paint: Paint()..color = particleColor,
            lifespan: (particleLifespan * rng.nextDouble()) + particleLifespan),
      ),
    );

    return ParticleSystemComponent(particle: particle);
  }

  Vector2 getWeaponTipDownBarrel(double percentBetweenBaseAndTip) {
    return ((weaponTipPosition! - entityAncestor!.center) * .9) +
        entityAncestor!.center;
  }

  List<BodyComponent> generateProjectileFunction([double chargeAmount = 1]) {
    List<BodyComponent> returnList = [];

    List<Vector2> temp = splitVector2DeltaIntoArea(
        entityAncestor!.entityAimAngle,
        attackCount,
        maxSpreadDegrees.parameter);

    for (var deltaDirection in temp) {
      if (projectileType == null) continue;
      final delta = (randomizeVector2Delta(
          deltaDirection, weaponRandomnessPercent.parameter));

      returnList.add(projectileType!.generateProjectile(
          delta: delta,
          originPositionVar: generateSourcePosition(sourceAttackLocation!),
          ancestorVar: this,
          chargeAmount: chargeAmount));
    }

    return returnList;
  }
}

mixin MeleeChargeReady on MeleeFunctionality, SemiAutomatic {
  MeleeAttackHandler? chargeAttackHandler;

  @override
  void startAttacking() async {
    resetCheck();

    chargeAttackHandler = MeleeAttackHandler(
      currentAttack: meleeAttacks[currentAttackIndex],
      weaponAncestor: this,
      isCharging: true,
      initAngle: 0,
      initPosition: Vector2.zero(),
    )..priority = foregroundPriority;
    entityAncestor!.enviroment.add(chargeAttackHandler!);
    // damageType = baseDamage.damageBase.keys.toList().getRandomElement();
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

  @override
  void update(double dt) {
    if (isAttacking) {}
    super.update(dt);
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
}

mixin ChargeEffect on ProjectileFunctionality, SemiAutomatic {
  SpriteAnimation? spawnAnimation;
  SpriteAnimation? chargedAnimation;
  SpriteAnimation? playAnimation;
  SpriteAnimation? endAnimation;

  SpriteAnimationComponent? chargeAnimation;

  late DamageType damageType;

  double chargeSize = .5;

  @override
  double get particleLifespan => .2;

  // Curve get holdDurationCurve => Curves.easeIn;
  // double get holdDurationPercentWithCurve =>
  //     holdDurationCurve.transform(holdDurationPercent);

  Future<void> buildAnimations() async {
    // switch (damageType) {
    //   case DamageType.physical:
    //     spawnAnimation = await buildSpriteSheet(
    //         4,
    //         'weapons/projectiles/bullets/physical_bullet_spawn.png',
    //         .02,
    //         false);
    //     playAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/physical_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(3,
    //         'weapons/projectiles/bullets/physical_bullet_end.png', .1, false);

    //     break;

    //   case DamageType.energy:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/energy_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/energy_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/energy_bullet_end.png', .1, false);

    //     break;

    //   case DamageType.fire:
    //     spawnAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/fire_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/fire_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/fire_bullet_end.png', .1, false);

    //     break;

    //   case DamageType.frost:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/frost_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/frost_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/frost_bullet_end.png', .1, false);

    //     break;

    //   case DamageType.magic:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/magic_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(
    //         4, 'weapons/projectiles/bullets/magic_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/magic_bullet_end.png', .1, false);

    //     break;

    //   case DamageType.psychic:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/psychic_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/psychic_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/psychic_bullet_end.png', .1, false);

    //     break;
    //   case DamageType.healing:
    //     spawnAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/healing_bullet_spawn.png', .02, false);
    //     playAnimation = await buildSpriteSheet(4,
    //         'weapons/projectiles/bullets/healing_bullet_play.png', .02, true);
    //     endAnimation = await buildSpriteSheet(
    //         3, 'weapons/projectiles/bullets/healing_bullet_end.png', .1, false);

    //     break;
    // }

    // spawnAnimation = await buildSpriteSheet(
    //           4,
    //           'weapons/projectiles/bullets/physical_bullet_spawn.png',
    //           .02,
    //           false);
    playAnimation = await loadSpriteAnimation(
        3, 'weapons/charge/fire_charge_play.png', .1, true);
    endAnimation = await loadSpriteAnimation(
        4, 'weapons/charge/fire_charge_end.png', .07, false);
    spawnAnimation = await loadSpriteAnimation(
        5, 'weapons/charge/fire_charge_spawn.png', .01, false);
    chargedAnimation = await loadSpriteAnimation(
        6, 'weapons/charge/fire_charge_charged.png', .05, false);
    // endAnimation = await buildSpriteSheet(3,
    //     'weapons/projectiles/bullets/physical_bullet_end.png', .1, false);
  }

  @override
  void startAttacking() async {
    damageType = baseDamage.damageBase.keys.toList().getRandomElement();
    await buildAnimations();
    spawnAnimation?.stepTime =
        attackTickRate.parameter / (spawnAnimation?.frames.length ?? 1);

    if (semiAutoType != SemiAutoType.regular) {
      chargeAnimation = SpriteAnimationComponent(
          size: Vector2.all(chargeSize),
          anchor: Anchor.center,
          animation: spawnAnimation ?? playAnimation)
        ..addToParent(
            weaponAttachmentPoints[WeaponSpritePosition.hand]!.weaponTip!);

      if (spawnAnimation == null) {
        chargeAnimation?.size = Vector2.zero();
        chargeAnimation?.add(SizeEffect.to(
            Vector2.all(chargeSize),
            EffectController(
                duration: attackTickRate.parameter, curve: Curves.bounceIn)));
      } else {
        chargeAnimation?.animationTicker?.completed
            .then((value) => chargeCompleted());
      }
    }

    super.startAttacking();
  }

  void chargeCompleted() {
    chargeAnimation?.animation = playAnimation;
    if (chargedAnimation != null) {
      chargeAnimation?.add(SpriteAnimationComponent(
        anchor: Anchor.center,
        position: Vector2.all(chargeSize / 2),
        size: Vector2.all(chargeSize * 2.5),
        animation: chargedAnimation,
      ));
    }
  }

  @override
  void update(double dt) {
    if (isAttacking) {
      addParticles(.5);
    }
    super.update(dt);
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

  Component generateChargeParticle(double percent) {
    var particleColor = damageType.color;
    final particle = Particle.generate(
      count: (1 + rng.nextInt(3) * percent).round(),
      lifespan: 2,
      applyLifespanToChildren: false,
      generator: (i) => AcceleratedParticle(
        position: weaponTipPosition! + Vector2.zero(),
        speed: ((Vector2.random() * 4) - Vector2.all(2)) * percent,
        child: FadeOutCircleParticle(
            radius: .04 * ((rng.nextDouble() * .9) + .1),
            paint: Paint()..color = particleColor,
            lifespan: (particleLifespan * rng.nextDouble()) + particleLifespan),
      ),
    );

    return ParticleSystemComponent(particle: particle);
  }

  void addParticles(double percent) {
    entityAncestor?.enviroment.add(generateChargeParticle(percent));
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

  double get holdDurationPercent => semiAutoType == SemiAutoType.regular
      ? 1
      : Curves.easeInCirc
          .transform(ui.clampDouble(durationHeld / chargeLength, 0, 1));

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
    // entityAncestor?.entityStatusWrapper.removeHoldDuration();
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
    if (semiAutoType != SemiAutoType.charge) {
      setWeaponStatus(WeaponStatus.charge);
      // entityAncestor?.setEntityStatus(EntityStatus.attack);
    }
    switch (semiAutoType) {
      case SemiAutoType.regular:
        attackAttempt();
        break;
      case SemiAutoType.release:
        // entityAncestor?.entityStatusWrapper.addHoldDuration(chargeLength);
        break;
      case SemiAutoType.charge:
        // entityAncestor?.entityStatusWrapper.addHoldDuration(chargeLength);
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
typedef OnHitDef = bool Function(DamageInstance damage);
mixin AttributeWeaponFunctionsFunctionality on Weapon {
  //Event functions that are modified from attributes
  List<Function(HealthFunctionality other)> onKill = [];
  List<OnHitDef> onHitProjectile = [];
  List<Function(Projectile projectile)> onProjectileDeath = [];
  List<OnHitDef> onHitMelee = [];
  List<OnHitDef> onHit = [];
  List<Function()> onAttackProjectile = [];
  List<Function()> onAttackMelee = [];
  List<Function()> onAttack = [];
  List<Function()> onReload = [];

  @override
  void standardAttack(
      [double holdDurationPercent = 1, bool callFunctions = true]) {
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
    super.standardAttack(holdDurationPercent, callFunctions);
  }
}

String buildWeaponDescription(
    WeaponDescription weaponDescription, WeaponType weapon, int level,
    [bool isUnlocked = true]) {
  String returnString = "";

  if (!isUnlocked) return " - ";
  final builtWeapon = weapon.buildTemp(level);

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
