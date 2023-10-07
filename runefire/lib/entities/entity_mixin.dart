import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/constants/damage_values.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:flutter_animate/flutter_animate.dart'
    show NumDurationExtensions;

import '../resources/data_classes/base.dart';
import '../resources/functions/functions.dart';
import '../resources/functions/vector_functions.dart';
import '../main.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';
import '../weapons/weapon_class.dart';
import '../attributes/attributes_mixin.dart';

//when back from shower
//rework everything to the new bool system
//rework everything to the base/increase system
//rework everything to the new priority system
//break functions up as much as possible to allow for easy overriding

// final bool baseCollisionWhileDashing = false;
// List<bool> collisionWhileDashingIncrease = [];
// bool get collisionWhileDashing => boolAbilityDecipher(
//     baseCollisionWhileDashing, collisionWhileDashingIncrease);

mixin BaseAttributes on BodyComponent<GameRouter> {
  bool get isJumping => false;
  bool get isDashing => false;
  bool get isInvincible => invincible.parameter;
  bool isDead = false;
  bool get isChildEntity => this is ChildEntity;

  bool affectsAllEntities = false;

  @mustCallSuper
  void initializeChildEntityParameters(ChildEntity childEntity) {
    attackCount = childEntity.parentEntity.attackCount;
    durationPercentIncrease = childEntity.parentEntity.durationPercentIncrease;
    tickDamageIncrease = childEntity.parentEntity.tickDamageIncrease;
    areaSizePercentIncrease = childEntity.parentEntity.areaSizePercentIncrease;
    critChance = childEntity.parentEntity.critChance;
    critDamage = childEntity.parentEntity.critDamage;
    damageTypePercentIncrease =
        childEntity.parentEntity.damageTypePercentIncrease;
    damageTypeResistance = childEntity.parentEntity.damageTypeResistance;
    areaDamagePercentIncrease =
        childEntity.parentEntity.areaDamagePercentIncrease;
    maxLives = childEntity.parentEntity.attackCount;
    essenceSteal = childEntity.parentEntity.essenceSteal;
    statusEffectsPercentIncrease =
        childEntity.parentEntity.statusEffectsPercentIncrease;
    damagePercentIncrease = childEntity.parentEntity.damagePercentIncrease;
    knockBackIncreaseParameter =
        childEntity.parentEntity.knockBackIncreaseParameter;
    meleeDamagePercentIncrease =
        childEntity.parentEntity.meleeDamagePercentIncrease;
    projectileDamagePercentIncrease =
        childEntity.parentEntity.projectileDamagePercentIncrease;
    spellDamagePercentIncrease =
        childEntity.parentEntity.spellDamagePercentIncrease;
    staminaSteal = childEntity.parentEntity.staminaSteal;
  }

  @mustCallSuper
  void initializeParentParameters() {
    attackCount = IntParameterManager(baseParameter: 0);
    durationPercentIncrease = DoubleParameterManager(baseParameter: 1);
    tickDamageIncrease = DoubleParameterManager(baseParameter: 1);
    areaSizePercentIncrease = DoubleParameterManager(baseParameter: 1);
    critChance = DoubleParameterManager(
        baseParameter: 0.05, minParameter: 0, maxParameter: 1);
    critDamage = DoubleParameterManager(baseParameter: 1.4, minParameter: 1);
    damageTypePercentIncrease =
        DamagePercentParameterManager(damagePercentBase: {});
    damageTypeResistance = DamagePercentParameterManager(
      damagePercentBase: {},
    );
    areaDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    staminaSteal =
        BoolParameterManager(baseParameter: false, isFoldOfIncreases: false);
    maxLives = IntParameterManager(baseParameter: 1);
    essenceSteal = DoubleParameterManager(baseParameter: 0, minParameter: 0);
    statusEffectsPercentIncrease =
        StatusEffectPercentParameterManager(statusEffectPercentBase: {});
    damagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    knockBackIncreaseParameter = DoubleParameterManager(baseParameter: 1);
    meleeDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    projectileDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    spellDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
  }

  void forceInitializeParameters() {
    invincible = BoolParameterManager(baseParameter: false);
    enableMovement = BoolParameterManager(baseParameter: true);
  }

  void initializeParameterManagers() {
    if (isChildEntity) {
      initializeChildEntityParameters(this as ChildEntity);
    } else {
      initializeParentParameters();
    }
    forceInitializeParameters();
  }

  late final IntParameterManager attackCount;

  //Invincible
  late final BoolParameterManager invincible;

  //Collision
  late final BoolParameterManager collision =
      BoolParameterManager(baseParameter: true, isFoldOfIncreases: false);

  //Duration
  late final DoubleParameterManager durationPercentIncrease;

  late final DoubleParameterManager tickDamageIncrease;

  //Movement
  late final BoolParameterManager enableMovement;

  //Height
  final IntParameterManager height = IntParameterManager(baseParameter: 1);

  ///Multiply this with area effect spells etc
  late final DoubleParameterManager areaSizePercentIncrease;

  ///Multiply this with area effect spells etc
  late final DoubleParameterManager critChance;

  late final DoubleParameterManager critDamage;

  late final DamagePercentParameterManager damageTypePercentIncrease;

  ///1 = 100% damage
  ///0 = Take no damage
  ///2 = Take double damage
  late final DamagePercentParameterManager damageTypeResistance;

  late final DoubleParameterManager areaDamagePercentIncrease;

  late final IntParameterManager maxLives;

  int deathCount = 0;
  int get remainingLives => (maxLives.parameter - deathCount);

  late final DoubleParameterManager essenceSteal;

  late final BoolParameterManager staminaSteal;

  late final StatusEffectPercentParameterManager statusEffectsPercentIncrease;

  late final DoubleParameterManager damagePercentIncrease;

  late final DoubleParameterManager knockBackIncreaseParameter;

  late final DoubleParameterManager meleeDamagePercentIncrease;

  late final DoubleParameterManager projectileDamagePercentIncrease;

  late final DoubleParameterManager spellDamagePercentIncrease;
}

mixin MovementFunctionality on Entity {
  @override
  void initializeParentParameters() {
    speed = DoubleParameterManager(baseParameter: .1);
    super.initializeParentParameters();
  }

  bool get hasMoveVelocities => moveVelocities.isNotEmpty;

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    speed = (childEntity.parentEntity as MovementFunctionality).speed;
    super.initializeChildEntityParameters(childEntity);
  }

  Map<String, Entity> entitiesFeared = {};

  //Speed
  late final DoubleParameterManager speed;

  Map<InputType, Vector2?> moveVelocities = {};
  Vector2 get moveDelta {
    if (entitiesFeared.isNotEmpty) {
      final fearTarget = entitiesFeared.values.fold<Vector2>(Vector2.zero(),
          (previousValue, element) => previousValue + element.center);
      return (center - fearTarget).normalized();
    }

    return (moveVelocities[InputType.moveJoy] ??
            moveVelocities[InputType.general] ??
            moveVelocities[InputType.keyboard] ??
            moveVelocities[InputType.attribute] ??
            moveVelocities[InputType.ai] ??
            Vector2.zero())
        .normalized();
  }

  void moveFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onMove.isNotEmpty) {
      for (var element in attr.onMove) {
        element();
      }
    }
  }

  void moveCharacter() {
    Vector2 pulse = moveDelta;

    if (isDead || !enableMovement.parameter || pulse.isZero()) {
      setEntityStatus(EntityStatus.idle);
      return;
    }
    spriteFlipCheck();

    // body.setTransform(center + (pulse * speed.parameter), 0);
    if (isPlayer && !isChildEntity) {
      body.applyForce(pulse *
          speed.parameter *
          ((this as Player).isDisplay
              ? center.distanceTo(Vector2.zero()).clamp(0, 1)
              : 1));
    } else {
      body.applyForce(pulse * speed.parameter);
    }

    // body.linearVelocity = pulse;
    // gameEnviroment.test.position += pulse * speed.parameter;
    moveFunctionsCall();

    setEntityStatus(
        body.linearVelocity.length > 1 ? EntityStatus.run : EntityStatus.walk);
  }
}

mixin AimFunctionality on Entity {
  Vector2 lastAimingDelta = Vector2.zero();
  Vector2 lastAimingPosition = Vector2.zero();
  double handPositionFromBody = .1;
  bool weaponBehind = false;

  Vector2? get mousePositionOffPlayer {
    final returnVal = inputAimPositions.containsKey(InputType.mouse)
        ? ((inputAimPositions[InputType.mouse]! -
            (entityOffsetFromCameraCenter)))
        : null;
    return returnVal;
  }

  void buildDeltaFromMousePosition() {
    inputAimAngles[InputType.mouse] = mousePositionOffPlayer!.normalized();
  }

  Vector2? get entityAimPosition {
    if (isDead) {
      return lastAimingPosition;
    }

    final returnVal = inputAimPositions[InputType.aimJoy] ??
        inputAimPositions[InputType.mouse] ??
        // inputAimPositions[InputType.mouseDrag] ??
        inputAimPositions[InputType.primary] ??
        inputAimPositions[InputType.ai];
    if (returnVal != null) {
      lastAimingPosition = returnVal;
    }
    return returnVal;
  }

  Vector2 get entityInputsAimAngle {
    if (isDead) {
      return lastAimingDelta;
    }
    if (inputAimPositions.containsKey(InputType.mouse)) {
      buildDeltaFromMousePosition();
    }

    final returnVal = inputAimAngles[InputType.aimJoy] ??
        inputAimAngles[InputType.primary] ??
        // inputAimAngles[InputType.mouseDrag] ??
        inputAimAngles[InputType.mouse] ??
        inputAimAngles[InputType.ai] ??
        ((this is MovementFunctionality)
                ? (this as MovementFunctionality).moveDelta
                : Vector2.zero())
            .normalized();
    lastAimingDelta = returnVal;
    return returnVal;
  }

  Vector2 get handJointAimDelta {
    return handJoint.position.normalized();
  }

  Map<InputType, Vector2> inputAimAngles = {};
  Map<InputType, Vector2> inputAimPositions = {};
  late PlayerAttachmentJointComponent mouseJoint;
  late PlayerAttachmentJointComponent handJoint;
  Vector2 get handJointOffset => Vector2.zero();
  Vector2 get backJointOffset => Vector2.zero();

  @override
  Future<void> onLoad() {
    backJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.back,
        position: backJointOffset,
        anchor: Anchor.center,
        size: Vector2.zero(),
        priority: playerBackPriority);

    handJoint = PlayerAttachmentJointComponent(
      WeaponSpritePosition.hand,
      anchor: Anchor.center,
      position: handJointOffset,
      size: Vector2.zero(),
    );
    mouseJoint = PlayerAttachmentJointComponent(
      WeaponSpritePosition.mouse,
      anchor: Anchor.center,
      size: Vector2.zero(),
    );
    add(handJoint);
    add(backJoint);
    add(mouseJoint);
    return super.onLoad();
  }

  @override
  void spriteFlipCheck() {
    final degree = -degrees(handJoint.angle);
    if ((degree < 180 && !isFlipped) || (degree >= 180 && isFlipped)) {
      flipSprite();
    }
  }

  void handJointBehindBodyCheck() {
    final deg = degrees(radiansBetweenPoints(
      Vector2(1, 0),
      entityInputsAimAngle,
    ));

    if ((deg >= 0 && deg < 180 && !weaponBehind) ||
        (deg <= 360 && deg >= 180 && weaponBehind)) {
      weaponBehind = !weaponBehind;
      handJoint.priority = weaponBehind ? -1 : 1;
    }
  }

  @override
  void flipSprite() {
    handJoint.flipHorizontallyAroundCenter();
    backJoint.flipHorizontallyAroundCenter();
    super.flipSprite();
  }

  @override
  void update(double dt) {
    followTarget();
    super.update(dt);
  }

  Vector2 handAngleTarget = Vector2.zero();

  DoubleParameterManager aimingInterpolationAmount =
      DoubleParameterManager(baseParameter: .065);
  double distanceIncrease = 1;

  Vector2 previousHandJointPosWithoutOffset = Vector2.zero();

  void followTarget([bool smoothFollow = true]) {
    final previousNormal = previousHandJointPosWithoutOffset.normalized();
    final handAngleTarget = entityInputsAimAngle.normalized();
    final interpAmount = aimingInterpolationAmount.parameter;
    Vector2 angle;
    if (smoothFollow) {
      angle = (previousNormal
            ..moveToTarget(handAngleTarget,
                interpAmount * previousNormal.distanceTo(handAngleTarget)))
          .normalized();
    } else {
      angle = handAngleTarget.clone();
    }

    final mousePositionWithPlayerCenterOffset = mousePositionOffPlayer;

    if (isPlayer && mousePositionWithPlayerCenterOffset != null) {
      const distance = 5.0;
      final newDistance = (Curves.easeInOutCubic.transform(
                  (mousePositionWithPlayerCenterOffset.length / distance)
                      .clamp(0, 1)) *
              distance)
          .clamp(0, distance);
      distanceIncrease =
          lerpDouble(distanceIncrease, newDistance, interpAmount)!;
    }

    handJoint.position = (angle * handPositionFromBody * distanceIncrease);

    handJoint.angle = -radiansBetweenPoints(
      Vector2(0, 1),
      angle,
    );

    previousHandJointPosWithoutOffset.setFrom(handJoint.position);
    handJoint.position += handJointOffset;
  }

  void aimCharacter() {
    if (!enableMovement.parameter) return;

    handAngleTarget = entityInputsAimAngle.clone();

    handJointBehindBodyCheck();
    spriteFlipCheck();

    if (inputAimPositions.containsKey(InputType.mouse)) {
      mouseJoint.position = inputAimPositions[InputType.mouse]!.clone();
    }
  }
}

mixin AttackFunctionality on AimFunctionality {
  Weapon? get currentWeapon {
    // if (!weaponsInitialized) {
    //   initializeWeapons();
    // }

    return carriedWeapons[weaponIndex];
  }

  List<Function(Weapon? from, Weapon to)> onWeaponSwap = [];

  int weaponIndex = 0;
  void incrementWeaponIndex() {
    weaponIndex++;
    if (weaponIndex >= carriedWeapons.length) {
      weaponIndex = 0;
    }
  }

  Map<int, Weapon> carriedWeapons = {};
  List<WeaponType> initialWeapons = [];

  bool isAttacking = false;
  bool isAltAttacking = false;

  @override
  bool deadStatus(DamageInstance instance) {
    endPrimaryAttacking();
    return super.deadStatus(instance);
  }

  void initializeWeapons() {
    if (isPlayer && !isChildEntity && (this as Player).isDisplay) return;

    weaponsInitialized = false;

    carriedWeapons.clear();

    if (isPlayer && !isChildEntity) {
      final player = this as Player;
      final playerData = player.playerData;
      for (var i = 0; i < player.playerData.selectedWeapons.length; i++) {
        final element = playerData.selectedWeapons[i]!;
        carriedWeapons[i] =
            element.build(this, player.playerData.selectedSecondaries[i], game);
      }
    } else {
      int i = 0;
      for (var element in initialWeapons) {
        carriedWeapons[i] = element.build(this, null, game, 1);
        i++;
      }
    }

    weaponsInitialized = true;
  }

  bool weaponsInitialized = false;

  @override
  void permanentlyDisableEntity() async {
    endPrimaryAttacking();
    endSecondaryAttacking();
    final weapon = currentWeapon;
    if (weapon != null) {
      for (var element in weapon.weaponAttachmentPoints.values) {
        element.weaponSpriteAnimation?.removeFromParent();
      }
    }

    super.permanentlyDisableEntity();
  }

  @override
  void onRemove() {
    carriedWeapons.forEach((key, value) => value.removeFromParent());

    super.onRemove();
  }

  void endPrimaryAttacking() async {
    if (!isAttacking) return;
    isAttacking = false;
    currentWeapon?.endAttacking();
  }

  void endSecondaryAttacking() async {
    if (!isAltAttacking) return;
    isAltAttacking = false;
    currentWeapon?.endAltAttacking();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    initializeWeapons();
    final weapon = currentWeapon;
    if (weapon != null) {
      await setWeapon(weapon);
    }

    if (isPlayer && enviroment is GameEnviroment && !isChildEntity) {
      gameEnviroment.hud.mounted.then(
          (value) => gameEnviroment.hud.buildRemainingAmmoText(this as Player));
    }
  }

  Future<void> setWeapon(Weapon weapon) async {
    await handJoint.loaded.whenComplete(() => handJoint.addWeaponClass(weapon));
    await mouseJoint.loaded
        .whenComplete(() => mouseJoint.addWeaponClass(weapon));
    await backJoint.loaded.whenComplete(() => backJoint.addWeaponClass(weapon));
    if (enviroment is GameEnviroment && isPlayer) {
      await enviroment.loaded;
      gameEnviroment.hud.toggleStaminaColor(weapon.weaponType.attackType);
    }
  }

  void startPrimaryAttacking() async {
    if (isAttacking || isDead || isStunned) return;
    isAttacking = true;
    (currentWeapon)?.startAttacking();
  }

  void startSecondaryAttacking() async {
    if (isAltAttacking) return;
    isAltAttacking = true;
    (currentWeapon)?.startAltAttacking();
  }

  Future<void> swapWeapon() async {
    final previousWeapon = currentWeapon;
    if (isAttacking) {
      previousWeapon?.endAttacking();
    }
    if (isAltAttacking) {
      previousWeapon?.endAltAttacking();
    }
    previousWeapon?.weaponSwappedFrom();

    incrementWeaponIndex();
    final newWeapon = currentWeapon;

    await setWeapon(newWeapon!);

    newWeapon.weaponSwappedTo();

    if (onWeaponSwap.isNotEmpty) {
      for (var element in onWeaponSwap) {
        element(previousWeapon, newWeapon);
      }
    }

    if (isAttacking) {
      newWeapon.startAttacking();
    }
    if (isAltAttacking) {
      newWeapon.startAltAttacking();
    }
  }
}

mixin StaminaFunctionality on Entity {
  @override
  void initializeParentParameters() {
    stamina = DoubleParameterManager(baseParameter: 100);
    staminaRegen = DoubleParameterManager(baseParameter: 25);

    super.initializeParentParameters();
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    stamina = (childEntity.parentEntity as StaminaFunctionality).stamina;
    staminaRegen =
        (childEntity.parentEntity as StaminaFunctionality).staminaRegen;

    super.initializeChildEntityParameters(childEntity);
  }

  late final DoubleParameterManager stamina;
  late final DoubleParameterManager staminaRegen;
  bool isForbiddenMagic = false;

  double get remainingStamina => stamina.parameter - staminaUsed;
  double staminaUsed = 0;

  ///5 = 5 more stamina, -5 = 5 less stamina, to use
  void modifyStamina(double amount, [bool regen = false]) {
    if (isForbiddenMagic && this is HealthFunctionality && amount < 0) {
      final health = this as HealthFunctionality;

      health.applyDamage(DamageInstance(damageMap: {
        DamageType.magic: amount.abs(),
      }, source: this, victim: health, sourceAttack: this));
    } else {
      staminaUsed = (staminaUsed -= amount).clamp(0, stamina.parameter);
      staminaModifiedFunctions(amount);
      if (!regen &&
          isPlayer &&
          !isChildEntity &&
          enviroment is GameEnviroment) {
        gameEnviroment.hud.barFlash(BarType.staminaBar);
      }
    }
  }

  void staminaModifiedFunctions(double stamina) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onStaminaModified.isNotEmpty) {
      for (var element in attr.onStaminaModified) {
        element(stamina);
      }
    }
  }

  bool hasEnoughStamina(double cost) {
    return isForbiddenMagic && this is HealthFunctionality
        ? (this as HealthFunctionality).remainingHealth >= cost.abs()
        : remainingStamina >= cost;
  }

  /// Amount of stamina regenerated per second
  double get increaseStaminaRegenSpeed =>
      ((remainingStamina / stamina.parameter) + .5);

  @override
  void update(double dt) {
    // modifyStamina(staminaRegen.parameter * dt * increaseStaminaRegenSpeed);
    modifyStamina(
        staminaRegen.parameter * dt * increaseStaminaRegenSpeed, true);
    super.update(dt);
  }
}

mixin HealthRegenFunctionality on HealthFunctionality {
  ///Requires a positive value to increase the amount of health
  ///5 = 5 more health, -5 = 5 less health
  void modifyHealth(double amount) =>
      damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);

  @override
  void initializeParentParameters() {
    healthRegen = DoubleParameterManager(baseParameter: .35);
    // healthRegen = DoubleParameterManager(baseParameter: 1);

    super.initializeParentParameters();
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    healthRegen =
        (childEntity.parentEntity as HealthRegenFunctionality).healthRegen;

    super.initializeChildEntityParameters(childEntity);
  }

  late final DoubleParameterManager healthRegen;

  /// Amount of health regenerated per second
  double get increaseHealthRegenSpeed =>
      ((remainingHealth / maxHealth.parameter) + .5);

  @override
  void update(double dt) {
    modifyHealth(healthRegen.parameter * dt * increaseHealthRegenSpeed);

    super.update(dt);
  }
}

mixin HealthFunctionality on Entity {
  @override
  void initializeParentParameters() {
    invincibilityDuration = DoubleParameterManager(baseParameter: .2);
    maxHealth = DoubleParameterManager(baseParameter: 50, minParameter: 1);
    isMarked =
        BoolParameterManager(baseParameter: false, isFoldOfIncreases: false);
    super.initializeParentParameters();
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    invincibilityDuration =
        (childEntity.parentEntity as HealthFunctionality).invincibilityDuration;
    maxHealth = (childEntity.parentEntity as HealthFunctionality).maxHealth;
    isMarked = (childEntity.parentEntity as HealthFunctionality).isMarked;

    super.initializeChildEntityParameters(childEntity);
  }

  //health
  late final DoubleParameterManager invincibilityDuration;
  late final DoubleParameterManager maxHealth;
  late final BoolParameterManager isMarked;

  bool consumeMark() {
    bool isMarked = this.isMarked.parameter;
    if (isMarked && this is AttributeFunctionality) {
      final attr = this as AttributeFunctionality;
      attr.removeAttribute(AttributeType.marked);
    }
    return isMarked;
  }

  TimerComponent? iFrameTimer;
  double sameDamageSourceDuration = .5;

  double get remainingHealth => maxHealth.parameter - damageTaken;
  double get healthPercentage => remainingHealth / maxHealth.parameter;

  @override
  bool get isInvincible => super.isInvincible || iFrameTimer != null;

  void applyEssenceSteal(DamageInstance instance) {
    final amount = essenceSteal.parameter * instance.damage;
    if (amount == 0 || !amount.isFinite) return;
    if (staminaSteal.parameter && this is StaminaFunctionality) {
      final stamina = this as StaminaFunctionality;
      stamina.modifyStamina(amount);
    } else {
      damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);
    }
    addFloatingText(
        instance..copyWith(damageMap: {DamageType.healing: amount}));
    addDamageEffects(DamageType.healing.color);
  }

  void heal(double amount) {
    damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);
    addFloatingText(DamageInstance(
        damageMap: {DamageType.healing: amount},
        source: this,
        victim: this,
        sourceAttack: this));
    addDamageEffects(DamageType.healing.color);
  }

  double damageTaken = 0;
  double recentDamage = 0;

  //HEALTH
  Map<DamageType, TextComponent> damageTexts = {};
  Map<String, TimerComponent> hitSourceInvincibility = {};
  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;

  Vector2? baseSize;
  Vector2? baseTextSize;

  @override
  bool deadStatus(DamageInstance instance) {
    isDead = true;

    permanentlyDisableEntity();
    entityStatusWrapper.removeAllAnimations();
    temporaryAnimationPlaying = true;

    entityAnimationsGroup.add(OpacityEffect.fadeOut(
      EffectController(
          startDelay: rng.nextDouble() * .5,
          duration: 1.0,
          onMax: () => removeFromParent(),
          curve: Curves.easeIn),
    ));

    deadFunctionsCall(instance);
    return super.deadStatus(instance);
  }

  void deadFunctionsCall(DamageInstance instance) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onDeath.isNotEmpty) {
      for (var element in attr.onDeath) {
        element.call(instance);
      }
    }
  }

  void addFloatingText(DamageInstance damage, [String? customText]) {
    List<Component> newTexts = [];
    for (var element in damage.damageMap.entries) {
      final color = element.key.color;
      final fontSize = .45 * (damage.isCrit ? 1.3 : 1);

      final textRenderer = colorPalette.buildTextPaint(
          fontSize,
          ShadowStyle.lightGame,
          damage.isCrit ? Colors.red : color.brighten(.2));
      String damageString = "";

      if (customText != null) {
        damageString = customText;
      } else {
        damageString =
            !element.value.isFinite ? "X" : element.value.ceil().toString();

        if (element.key == DamageType.healing) {
          damageString = "+ $damageString";
        }
      }
      Vector2 pos = Vector2(entityAnimationsGroup.width / 3, 0);
      if (!isPlayer) {
        pos += center;
      }
      final tempText = TextComponent(
          text: damageString,
          // anchor: Anchor.center,
          textRenderer: textRenderer,
          priority: foregroundPriority,
          position: pos);

      final moveBy = ((Vector2.random() * .5) * (damage.isCrit ? 3 : 1));

      tempText.add(
        MoveEffect.by(
          Vector2(moveBy.x, -moveBy.y),
          EffectController(
            duration: 1.33,
            curve: Curves.linear,
            onMax: () {
              tempText.removeFromParent();
              damageTexts.remove(tempText);
            },
          ),
        ),
      );

      damageTexts[element.key]?.removeFromParent();
      damageTexts[element.key] = tempText;
      newTexts.add(tempText);
    }
    newTexts.shuffle();
    if (isPlayer) {
      addAll(newTexts);
    } else {
      gameEnviroment.addPhysicsComponent(newTexts, duration: .1);
    }
  }

  ///Returning true means cancel the damage
  bool onHitByOtherFunctionsCall(DamageInstance damage) {
    final attr = attributeFunctionsFunctionality;
    if (attr == null) return false;

    bool cancelDamage = false;
    if (attr.onHitByOtherEntity.isNotEmpty) {
      for (var element in attr.onHitByOtherEntity) {
        cancelDamage = cancelDamage || element(damage);
      }
    }
    if (attr.onHitByProjectile.isNotEmpty &&
        damage.sourceAttack is Projectile) {
      for (var element in attr.onHitByProjectile) {
        cancelDamage = cancelDamage || element(damage);
      }
    }
    return cancelDamage;
  }

  SizeEffect? currentScaleEffect;
  ColorEffect? currentColorEffect;

  void addDamageEffects(Color color) {
    final reversedController = EffectController(
        duration: .2,
        reverseDuration: .1,
        onMin: () {
          currentScaleEffect?.removeFromParent();
          currentColorEffect?.removeFromParent();
          currentScaleEffect = null;
          currentColorEffect = null;
        });

    baseSize ??= entityAnimationsGroup.size;

    currentScaleEffect?.controller.setToStart();
    currentColorEffect?.controller.setToStart();

    currentScaleEffect ??= SizeEffect.to(
        baseSize! * (1 + (.25 * rng.nextDouble())), reversedController)
      ..addToParent(entityAnimationsGroup);

    currentColorEffect ??= ColorEffect(
      color,
      const Offset(0.0, 1),
      reversedController,
    )..addToParent(entityAnimationsGroup);
  }

  void applyKnockback(DamageInstance damage) {
    final amount = (damage.damage / 30).clamp(0, 1);
    final impulse = damage.source.knockBackIncreaseParameter.parameter *
        amount *
        (damage.sourceWeapon?.knockBackAmount.parameter ?? 0);

    body.applyLinearImpulse(
        (center - damage.source.center).normalized() * impulse);
  }

  bool takeDamage(String id, DamageInstance damage,
      [bool applyStatusEffect = true]) {
    applyHealing(damage);
    applyIFrameTimer(id);

    if (damage.damageMap.isEmpty || onHitByOtherFunctionsCall(damage)) {
      return false;
    }
    if (damage.source is AttributeFunctionsFunctionality) {
      if ((damage.source as AttributeFunctionsFunctionality)
          .onDamageOtherEntityFunctions
          .call(damage)) return false;
    }

    MapEntry<DamageType, double> largestEntry = fetchLargestDamageType(damage);

    addFloatingText(damage);
    addDamageEffects(largestEntry.key.color);

    if (largestEntry.value.isFinite) {
      damage.applyResistances(this);
      applyStatusEffectFromDamageChecker(damage, applyStatusEffect);
      essenceStealChecker(damage);
    }
    applyCameraShake(damage);
    applyDamage(damage);
    setEntityStatus(EntityStatus.damage);
    applyKnockback(damage);
    deathChecker(damage);
    return true;
  }

  void applyCameraShake(DamageInstance? instance,
      [double amount = 2, double? duration]) {
    if (isPlayer) {
      gameEnviroment.gameCamera.viewport.add(ShakeEffect(
          EffectController(duration: duration ?? .1),
          intensity: instance != null ? (instance.isCrit ? 8 : 2) : amount));
    }
  }

  void applyIFrameTimer(String id) {
    hitSourceInvincibility[id] = TimerComponent(
        period: sameDamageSourceDuration,
        removeOnFinish: true,
        onTick: () {
          hitSourceInvincibility.remove(id);
        })
      ..addToParent(this);

    if (invincibilityDuration.parameter > 0) {
      iFrameTimer = TimerComponent(
        period: invincibilityDuration.parameter,
        removeOnFinish: true,
        onTick: () => iFrameTimer = null,
      );
      add(iFrameTimer!);
    }
  }

  List<DamageInstance> damageInstancesRecieved = [];

  MapEntry<DamageType, double> fetchLargestDamageType(DamageInstance instance) {
    MapEntry<DamageType, double> largestEntry =
        instance.damageMap.entries.first;

    for (var element in instance.damageMap.entries) {
      if (element.value > largestEntry.value) largestEntry = element;
    }
    return largestEntry;
  }

  void applyDamage(DamageInstance damage) {
    damageTaken += damage.damage;
    // recentDamage += damage.damage;
    damageTaken.clamp(0, maxHealth.parameter);
    if (isPlayer && !isChildEntity) {
      gameEnviroment.hud.barFlash(BarType.healthBar);
    }

    damageInstancesRecieved.add(damage);
  }

  void applyHealing(DamageInstance damage) {
    if (damage.damageMap.containsKey(DamageType.healing)) {
      damageTaken -= damage.damageMap[DamageType.healing]!;
      damageTaken.clamp(0, maxHealth.parameter);
      damage.damageMap.remove(DamageType.healing);
    }
  }

  void onHealFunctions(DamageInstance damage) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onHeal.isNotEmpty) {
      for (var element in attr.onHeal) {
        element(damage);
      }
    }
  }

  ///Heal the attacker if they have the essence steal attribute
  void essenceStealChecker(DamageInstance damage) {
    bool isHealth = damage.source is HealthFunctionality;
    if (isHealth) {
      (damage.source as HealthFunctionality).applyEssenceSteal(damage);
    }
  }

  void deathChecker(DamageInstance damage) {
    if ((remainingHealth <= 0 || !remainingHealth.isFinite) && !isDead) {
      if (this is Player) {
        game.gameStateComponent.gameState
            .killPlayer(GameEndState.death, this as Player, damage);
      } else {
        setEntityStatus(EntityStatus.dead, instance: damage);
      }
      callOtherWeaponOnKillFunctions(damage);
    }
  }

  void applyStatusEffectFromDamageChecker(
      DamageInstance damage, bool applyStatusEffect) {
    if (!applyStatusEffect) return;
    if (this is! AttributeFunctionality) return;
    final attr = this as AttributeFunctionality;
    for (var element in damage.damageMap.entries) {
      DamageType damageType = element.key;

      switch (damageType) {
        case DamageType.fire:
          final chance = damage.statusEffectChance?[StatusEffects.burn] ??
              defaultStatusEffectChance;

          if (chance <= rng.nextDouble()) continue;

          attr.addAttribute(
            AttributeType.burn,
            level: 1,
            duration: 3,
            perpetratorEntity: damage.source,
            damageType: DamageType.fire,
            isTemporary: true,
          );
          break;
        default:
      }
    }
  }

  void callOtherWeaponOnKillFunctions(DamageInstance damage) {
    bool weaponFunctions =
        damage.sourceWeapon is AttributeWeaponFunctionsFunctionality;
    if (weaponFunctions) {
      final weapon =
          damage.sourceWeapon as AttributeWeaponFunctionsFunctionality;

      for (var element in weapon.onKill) {
        element(this);
      }
    }
    final other = damage.source;
    final otherFunctions = other.attributeFunctionsFunctionality;
    if (otherFunctions != null) {
      for (var element in otherFunctions.onKillOtherEntity) {
        element(damage);
      }
    }
  }

  bool get canBeHit => !isInvincible && !isDead;

  bool hitCheck(String id, DamageInstance damage,
      [bool applyStatusEffect = true]) {
    if (hitSourceInvincibility.containsKey(id) || damage.damage == 0) {
      return false;
    }

    if (!canBeHit) {
      return false;
    }

    return takeDamage(id, damage, applyStatusEffect);
  }
}

mixin DodgeFunctionality on HealthFunctionality {
  int dodges = 0;

  @override
  void initializeParentParameters() {
    dodgeChance = DoubleParameterManager(
        baseParameter: .0, maxParameter: 1, minParameter: 0);
    super.initializeParentParameters();
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    dodgeChance = (childEntity.parentEntity as DodgeFunctionality).dodgeChance;

    super.initializeChildEntityParameters(childEntity);
  }

  late final DoubleParameterManager dodgeChance;

  void addDodgeText() {
    final test = TextPaint(
        style: defaultStyle.copyWith(
      fontSize: .3,
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      shadows: const [
        BoxShadow(
            color: Colors.black26,
            offset: Offset(.05, .05),
            spreadRadius: 3,
            blurRadius: 3)
      ],
      color: Colors.grey.shade100,
    ));
    final dodgeText = TextComponent(
      text: ["~", "foo", "dodge", "swish"].random(),
      anchor: Anchor.bottomLeft,
      textRenderer: test,
      position: Vector2(
          (rng.nextDouble() * .25) + .25, (-rng.nextDouble() * .25) - .5),
    );
    dodgeText.addAll([
      MoveEffect.by(
          Vector2(rng.nextDouble() * .25, -rng.nextDouble() * .25) * 2,
          EffectController(duration: 1, curve: Curves.easeIn)),
      TimerComponent(
        period: 1,
        removeOnFinish: true,
        onTick: () {
          dodgeText.removeFromParent();
        },
      )
    ]);
    add(dodgeText);
  }

  void dodge(DamageInstance damage) {
    dodgeFunctions(damage);

    dodges++;
    applyIFrameTimer(damage.source.entityId);

    addDodgeText();
  }

  void dodgeFunctions(DamageInstance damage) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onDodge.isNotEmpty) {
      for (var element in attr.onDodge) {
        element(damage);
      }
    }
  }

  bool dodgeCheck(DamageInstance damage) {
    final random = rng.nextDouble();

    if (damage.damageMap.entries
            .any((element) => element.key == DamageType.physical) &&
        random < dodgeChance.parameter) {
      dodge(damage);
      return true;
    } else {
      return false;
    }
  }

  @override
  bool takeDamage(String id, DamageInstance damage,
      [bool applyStatusEffect = true]) {
    if (dodgeCheck(damage)) {
      damage.damageMap.remove(DamageType.physical);
    }
    return super.takeDamage(id, damage, applyStatusEffect);
  }
}

mixin TouchDamageFunctionality on Entity, ContactCallbacks {
  @override
  void initializeParentParameters() {
    initTouchParameters();
    super.initializeParentParameters();
  }

  void initTouchParameters() {
    touchDamage = DamageParameterManager(damageBase: {});
    hitRate = DoubleParameterManager(
        baseParameter: 1, maxParameter: double.infinity, minParameter: 0);
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    bool parentIsTouch = childEntity.parentEntity is TouchDamageFunctionality;
    if (parentIsTouch) {
      touchDamage =
          (childEntity.parentEntity as TouchDamageFunctionality).touchDamage;
      hitRate = (childEntity.parentEntity as TouchDamageFunctionality).hitRate;
    } else {
      initTouchParameters();
    }

    super.initializeChildEntityParameters(childEntity);
  }

  late final DamageParameterManager touchDamage;

  late final DoubleParameterManager hitRate;

  DamageInstance calculateTouchDamage(
          HealthFunctionality victim, dynamic sourceAttack) =>
      damageCalculations(this, victim, touchDamage.damageBase,
          sourceAttack: sourceAttack, damageSource: touchDamage);

  Map<Body, TimerComponent> objectsHitting = {};

  ///Time interval between damage ticks

  void damageOther(Body other) {
    if (touchDamage.damageBase.isEmpty || isDead) return;
    final otherReference = other.userData;
    if (otherReference is! HealthFunctionality) return;
    if ((isPlayer && otherReference is Enemy) ||
        (!isPlayer && otherReference is Player)) {
      otherReference.hitCheck(
          entityId, calculateTouchDamage(otherReference, this));
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    bool shouldCalculate = touchDamage.damageBase.isNotEmpty &&
        !isDead &&
        other is HealthFunctionality &&
        ((contact.fixtureA.userData as Map)['type'] == FixtureType.body &&
            (contact.fixtureB.userData as Map)['type'] == FixtureType.body);
    if (shouldCalculate) {
      if (isPlayer && other is Enemy) {
        objectsHitting[other.body] = TimerComponent(
          period: hitRate.parameter,
          repeat: true,
          onTick: () {
            damageOther(other.body);
          },
        )
          ..addToParent(this)
          ..onTick();
        other.hitCheck(entityId, calculateTouchDamage(other, this));
      } else if (!isPlayer && other is Player) {
        objectsHitting[other.body] = TimerComponent(
          period: hitRate.parameter,
          repeat: true,
          onTick: () {
            damageOther(other.body);
          },
        )
          ..addToParent(this)
          ..onTick();
      }
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is BodyComponent) {
      objectsHitting[other.body]?.removeFromParent();
      objectsHitting.remove(other.body);
    }

    super.endContact(other, contact);
  }
}

mixin DashFunctionality on StaminaFunctionality {
  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    dashCooldown = (childEntity.parentEntity as DashFunctionality).dashCooldown;
    // invincibleWhileDashing =
    //     (childEntity.parentEntity as DashFunctionality).invincibleWhileDashing;
    collisionWhileDashing =
        (childEntity.parentEntity as DashFunctionality).collisionWhileDashing;
    teleportDash = (childEntity.parentEntity as DashFunctionality).teleportDash;
    dashDistance = (childEntity.parentEntity as DashFunctionality).dashDistance;
    dashDuration = (childEntity.parentEntity as DashFunctionality).dashDuration;
    dashStaminaCost =
        (childEntity.parentEntity as DashFunctionality).dashStaminaCost;

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    dashCooldown = DoubleParameterManager(baseParameter: 2);

    // invincibleWhileDashing = BoolParameterManager(baseParameter: false);
    collisionWhileDashing = BoolParameterManager(baseParameter: false);
    teleportDash =
        BoolParameterManager(baseParameter: false, isFoldOfIncreases: false);

    dashDistance = DoubleParameterManager(baseParameter: 1);
    dashDuration = DoubleParameterManager(baseParameter: .2, minParameter: 0);
    dashStaminaCost = DoubleParameterManager(baseParameter: 28);
    super.initializeParentParameters();
  }

  //DASH COOLDOWN
  late final DoubleParameterManager dashCooldown;
  // late final BoolParameterManager invincibleWhileDashing;
  late final BoolParameterManager collisionWhileDashing;
  late final BoolParameterManager teleportDash;
  late final DoubleParameterManager dashDistance;
  late final DoubleParameterManager dashDuration;
  late final DoubleParameterManager dashStaminaCost;

  //STATUS
  TimerComponent? dashTimerCooldown;
  double dashedDistance = 0;

  @override
  bool get isDashing => _isDashing;
  bool _isDashing = false;
  Vector2? dashDelta;

  @override
  bool get isInvincible => super.isInvincible || (isDashing);

  double? dashDistanceGoal;

  @override
  bool dashStatus() {
    if (!dashCheck()) return false;
    final dashAnimation = entityAnimationsGroup.animations?[EntityStatus.dash];
    entityAnimationsGroup.animations?[EntityStatus.dash]?.stepTime =
        dashDuration.parameter / (dashAnimation?.frames.length ?? 1) * 2;
    return super.dashStatus();
  }

  bool get canDash => !(dashTimerCooldown != null ||
      isJumping ||
      isDead ||
      isDashing ||
      !enableMovement.parameter ||
      !hasEnoughStamina(dashStaminaCost.parameter));

  bool dashCheck() {
    if (!canDash) {
      return false;
    }

    dashInit();

    return true;
  }

  void applyGroundAnimationDash() async {
    final attr = this as AttributeFunctionality;
    bool shouldApplyGroundAnimation = this is! AttributeFunctionality ||
        !attr.currentAttributes.keys.any((element) => [
              AttributeType.gravityDash,
              AttributeType.teleportDash,
              AttributeType.explosiveDash,
            ].contains(element));

    if (!shouldApplyGroundAnimation) return;

    applyGroundAnimation(
        await spriteAnimations.dashEffect1, false, spriteHeight * .1, true);
  }

  bool triggerFunctions = true;
  void dashInit(
      {double? power,
      bool weaponSource = false,
      bool triggerFunctions = true}) async {
    if (!weaponSource) modifyStamina(-dashStaminaCost.parameter);
    this.triggerFunctions = triggerFunctions;
    power ??= 1;

    applyGroundAnimationDash();
    dashDistanceGoal = dashDistance.parameter * power;
    _isDashing = true;
    if (weaponSource) {
      if (this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).lastAimingDelta;
      }
      if (dashDelta?.isZero() ?? true && this is MovementFunctionality) {
        dashDelta =
            (this as MovementFunctionality).moveDelta * dashDistance.parameter;
      }
    } else if (teleportDash.parameter) {
      if (this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).entityAimPosition;

        dashDistanceGoal =
            dashDelta?.length ?? (dashDistance.parameter * power);
      }
      if (dashDelta?.isZero() ?? true && this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).moveDelta;
      }
    } else {
      if (this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).moveDelta;
      }
      if (dashDelta?.isZero() ?? true && this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).entityInputsAimAngle;
      }
    }

    dashDelta = dashDelta!.normalized();
    dashDistanceGoal =
        dashDistanceGoal?.clamp(0, dashDistance.parameter * power);

    if (!weaponSource) {
      dashTimerCooldown = TimerComponent(
        period: dashCooldown.parameter,
        removeOnFinish: true,
        repeat: false,
        onTick: () {
          dashTimerCooldown?.timer.stop();
          dashTimerCooldown?.removeFromParent();
          dashTimerCooldown = null;
        },
      );

      add(dashTimerCooldown!);
      if (teleportDash.parameter) {
        teleport();
      }
      dashBeginFunctionsCall();
    }

    // body.applyLinearImpulse(dashDelta! * 1);
    // collision.setIncrease(entityId, true);
    // Future.delayed(1.seconds).then(
    //   (value) => finishDash(),
    // );
  }

  void dashBeginFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null &&
        attr.dashBeginFunctions.isNotEmpty &&
        triggerFunctions) {
      for (var element in attr.dashBeginFunctions) {
        element();
      }
    }
  }

  void dashEndFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.dashEndFunctions.isNotEmpty && triggerFunctions) {
      for (var element in attr.dashEndFunctions) {
        element();
      }
    }
  }

  void dashOngoingFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null &&
        attr.dashOngoingFunctions.isNotEmpty &&
        triggerFunctions) {
      for (var element in attr.dashOngoingFunctions) {
        element();
      }
    }
  }

  @override
  void update(double dt) {
    dashMoveCheck(dt);
    super.update(dt);
  }

  void dashMoveCheck(double dt) {
    if (isDashing && dashDelta != null) {
      if (dashedDistance > dashDistanceGoal!) {
        finishDash();
        return;
      }
      dashMove(dt);
    }
  }

  void finishDash() {
    dashEndFunctionsCall();
    dashDelta = null;
    _isDashing = false;
    dashedDistance = 0;
    // collision.removeKey(entityId);
  }

  void teleport() {
    body.setTransform(
        body.position + (dashDelta!.normalized() * dashDistanceGoal!), 0);
    finishDash();
  }

  void dashMove(double dt) {
    final double distance = ((dashDistanceGoal! / dashDuration.parameter) * dt)
        .clamp(0, dashDistanceGoal!);
    body.setTransform(body.position + (dashDelta! * distance), 0);
    dashedDistance += distance;
    dashOngoingFunctionsCall();
  }
}

mixin JumpFunctionality on Entity {
  @override
  void initializeParentParameters() {
    jumpDuration = DoubleParameterManager(baseParameter: .6, minParameter: 0);
    jumpStaminaCost =
        DoubleParameterManager(baseParameter: 10, minParameter: 0);
    jumpingInvinciblePercent = DoubleParameterManager(
        baseParameter: .5, minParameter: 0, maxParameter: 1);

    super.initializeParentParameters();
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    jumpDuration = (childEntity.parentEntity as JumpFunctionality).jumpDuration;
    jumpStaminaCost =
        (childEntity.parentEntity as JumpFunctionality).jumpStaminaCost;
    jumpingInvinciblePercent = (childEntity.parentEntity as JumpFunctionality)
        .jumpingInvinciblePercent;

    super.initializeChildEntityParameters(childEntity);
  }

  late final DoubleParameterManager jumpDuration;
  late final DoubleParameterManager jumpStaminaCost;
  late final DoubleParameterManager jumpingInvinciblePercent;

  //JUMP

  @override
  bool get isJumping => _isJumping;
  bool _isJumping = false;
  bool allowJumpingInvincible = true;
  bool isJumpingInvincible = false;

  double jumpHeight = .5;
  void jumpBeginFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.jumpBeginFunctions.isNotEmpty) {
      for (var element in attr.jumpBeginFunctions) {
        element();
      }
    }
  }

  void jumpEndFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.jumpEndFunctions.isNotEmpty) {
      for (var element in attr.jumpEndFunctions) {
        element();
      }
    }
  }

  void jumpOngoingFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.jumpOngoingFunctions.isNotEmpty) {
      for (var element in attr.jumpOngoingFunctions) {
        element();
      }
    }
  }

  @override
  bool jumpStatus() {
    if (!jumpCheck()) return false;

    final jumpAnimation = entityAnimationsGroup.animations?[EntityStatus.jump];

    entityAnimationsGroup.animations?[EntityStatus.jump]?.stepTime =
        jumpDuration.parameter / (jumpAnimation?.frames.length ?? 1);

    return super.jumpStatus();
  }

  void jump() async {
    if (this is StaminaFunctionality) {
      (this as StaminaFunctionality).modifyStamina(-jumpStaminaCost.parameter);
    }
    final jumpDurationPar = jumpDuration.parameter;

    entityAnimationsGroup.animations?[EntityStatus.jump]?.stepTime =
        jumpDurationPar /
            (entityAnimationsGroup
                    .animations![EntityStatus.jump]!.frames.length +
                1);

    applyGroundAnimation(
        await spriteAnimations.jumpEffect1, false, spriteHeight * .2);

    _isJumping = true;
    double elapsed = 0;
    double min = (jumpDurationPar / 2) -
        jumpDurationPar * (jumpingInvinciblePercent.parameter / 2);
    double max = (jumpDurationPar / 2) +
        jumpDurationPar * (jumpingInvinciblePercent.parameter / 2);

    final controller = EffectController(
      duration: jumpDurationPar * 1.5,
      curve: Curves.easeOut,
      reverseDuration: jumpDurationPar * 1,
      reverseCurve: Curves.ease,
    );
    // final controllerD = EffectController(
    //   duration: jumpDurationPar * 1.25,
    //   curve: Curves.easeOut,
    //   reverseDuration: jumpDurationPar * .75,
    //   reverseCurve: Curves.ease,
    // );

    if (allowJumpingInvincible) {
      Future.doWhile(
          () => Future.delayed(const Duration(milliseconds: 25)).then((value) {
                elapsed += .025;

                isJumpingInvincible = elapsed > min && elapsed < max;
                jumpOngoingFunctionsCall();

                return !(elapsed >= jumpDurationPar || controller.completed);
              })).then((_) {
        _isJumping = false;
        jumpEndFunctionsCall();
      });
    }

    entityAnimationsGroup.add(ScaleEffect.by(
      Vector2(1.025, 1.025),
      controller,
    ));
    entityAnimationsGroup.add(MoveEffect.by(
      Vector2(0, -jumpHeight),
      controller,
    ));
    backJoint.add(MoveEffect.by(
      Vector2(0, -jumpHeight),
      controller,
    ));

    // if (this is AimFunctionality) {
    //   (this as AimFunctionality).handJoint.add(MoveEffect.by(
    //         Vector2(0, -1),
    //         controllerD,
    //       ));
    // }
    jumpBeginFunctionsCall();
  }

  bool get cantJump =>
      isJumping ||
      isDashing ||
      !enableMovement.parameter ||
      isDead ||
      (this is StaminaFunctionality
          ? !(this as StaminaFunctionality)
              .hasEnoughStamina(jumpStaminaCost.parameter)
          : false);

  bool jumpCheck() {
    if (cantJump) return false;

    jump();

    return true;
  }
}

mixin ExpendableFunctionality on Entity {
  Expendable? currentExpendable;

  void onExpendable(Expendable expendable) {
    if (this is AttributeFunctionsFunctionality) {
      final attr = this as AttributeFunctionsFunctionality;
      for (var element in attr.onExpendableUsed) {
        element.call(expendable);
      }
    }
  }

  void pickupExpendable(Expendable groundExpendable) {
    if (this is AttributeFunctionsFunctionality) {
      final attr = this as AttributeFunctionsFunctionality;
      for (var element in attr.onItemPickup) {
        element.call(groundExpendable);
      }
    }

    if (groundExpendable.instantApply) {
      groundExpendable.applyExpendable();
      onExpendable(groundExpendable);
      return;
    }

    currentExpendable = groundExpendable;
    gameEnviroment.hud.currentExpendable = groundExpendable;
  }

  void useExpendable() {
    if (currentExpendable != null) {
      currentExpendable?.applyExpendable();
      onExpendable(currentExpendable!);
    }
    currentExpendable = null;
    if (enviroment is GameEnviroment) {
      gameEnviroment.hud.currentExpendable = null;
    }
  }
}
