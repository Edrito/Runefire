import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/resources/functions/custom_mixins.dart';
import 'package:game_app/resources/game_state_class.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/data_classes/base.dart';
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

  bool affectsAllEntities = false;

  final IntParameterManager attackCount = IntParameterManager(baseParameter: 0);

  //Invincible
  final BoolParameterManager invincible =
      BoolParameterManager(baseParameter: false);
  //Collision
  final BoolParameterManager collision =
      BoolParameterManager(baseParameter: true);
  //Duration
  final DoubleParameterManager durationPercentIncrease =
      DoubleParameterManager(baseParameter: 1);

  final DoubleParameterManager tickDamageIncrease =
      DoubleParameterManager(baseParameter: 1);

  //Movement
  final BoolParameterManager enableMovement =
      BoolParameterManager(baseParameter: true);

  //Height
  final DoubleParameterManager height =
      DoubleParameterManager(baseParameter: 1);

  ///Multiply this with area effect spells etc
  final DoubleParameterManager areaSizePercentIncrease =
      DoubleParameterManager(baseParameter: 1);

  ///Multiply this with area effect spells etc
  final DoubleParameterManager critChance =
      DoubleParameterManager(baseParameter: 1);

  final DoubleParameterManager critDamage =
      DoubleParameterManager(baseParameter: 1.5);

  final DamagePercentParameterManager damageTypePercentIncrease =
      DamagePercentParameterManager(damagePercentBase: {});

  ///1 = 100% damage
  ///0 = Take no damage
  ///2 = Take double damage
  final DamagePercentParameterManager damageTypeResistance =
      DamagePercentParameterManager(
    damagePercentBase: {},
  );

  final DoubleParameterManager areaDamagePercentIncrease =
      DoubleParameterManager(baseParameter: 1);

  final IntParameterManager maxLives = IntParameterManager(baseParameter: 1);
  int deathCount = 0;
  int get remainingLives => maxLives.parameter - deathCount;

  final DoubleParameterManager essenceSteal =
      DoubleParameterManager(baseParameter: 0, minParameter: 0);

  final StatusEffectPercentParameterManager statusEffectsPercentIncrease =
      StatusEffectPercentParameterManager(statusEffectPercentBase: {});

  final DoubleParameterManager damagePercentIncrease =
      DoubleParameterManager(baseParameter: 1);

  final DoubleParameterManager meleeDamagePercentIncrease =
      DoubleParameterManager(baseParameter: 1);

  final DoubleParameterManager projectileDamagePercentIncrease =
      DoubleParameterManager(baseParameter: 1);

  final DoubleParameterManager spellDamagePercentIncrease =
      DoubleParameterManager(baseParameter: 1);
}

mixin MovementFunctionality on Entity {
  //Speed
  final DoubleParameterManager speed =
      DoubleParameterManager(baseParameter: .1);

  Map<InputType, Vector2?> moveVelocities = {};
  Vector2 get moveDelta => (moveVelocities[InputType.moveJoy] ??
          moveVelocities[InputType.keyboard] ??
          moveVelocities[InputType.ai] ??
          Vector2.zero())
      .normalized();

  void moveFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onMove.isNotEmpty) {
      for (var element in attr.onMove) {
        element();
      }
    }
  }

  void moveCharacter() {
    final pulse = moveDelta;
    if (isDead || !enableMovement.parameter || pulse.isZero()) {
      setEntityStatus(EntityStatus.idle);
      return;
    }
    spriteFlipCheck();

    // body.setTransform(center + (pulse * speed.parameter), 0);
    body.applyForce(pulse * speed.parameter);
    gameEnviroment.test.position += pulse * speed.parameter;
    moveFunctionsCall();
    setEntityStatus(EntityStatus.run);
  }
}

mixin AimFunctionality on Entity {
  Vector2 lastAimingPosition = Vector2.zero();
  double handPositionFromBody = .1;
  bool weaponBehind = false;

  void buildDeltaFromMousePosition() {
    inputAimAngles[InputType.mouseMove] =
        (inputAimPositions[InputType.mouseMove]! -
                (playerFunctionality.player!.center -
                    enviroment.gameCamera.viewfinder.position))
            .normalized();
  }

  Vector2 get inputAimVectors {
    if (isDead) {
      return lastAimingPosition;
    }
    if (inputAimPositions.containsKey(InputType.mouseMove)) {
      buildDeltaFromMousePosition();
    }

    final returnVal = inputAimAngles[InputType.aimJoy] ??
        inputAimAngles[InputType.tapClick] ??
        inputAimAngles[InputType.mouseDrag] ??
        inputAimAngles[InputType.mouseMove] ??
        inputAimAngles[InputType.ai] ??
        ((this is MovementFunctionality)
                ? (this as MovementFunctionality).moveDelta
                : Vector2.zero())
            .normalized();
    lastAimingPosition = returnVal;
    return returnVal;
  }

  Vector2 get handJointAimDelta {
    return (handJoint.weaponTipCenter!.absolutePosition -
            handJoint.weaponBase!.absolutePosition)
        .normalized();
  }

  Map<InputType, Vector2> inputAimAngles = {};
  Map<InputType, Vector2> inputAimPositions = {};
  late PlayerAttachmentJointComponent mouseJoint;
  late PlayerAttachmentJointComponent handJoint;

  @override
  Future<void> onLoad() {
    handJoint = PlayerAttachmentJointComponent(
      WeaponSpritePosition.hand,
      anchor: Anchor.center,
      size: Vector2.zero(),
    );
    mouseJoint = PlayerAttachmentJointComponent(
      WeaponSpritePosition.mouse,
      anchor: Anchor.center,
      size: Vector2.zero(),
    );
    add(handJoint);
    add(mouseJoint);
    return super.onLoad();
  }

  @override
  void spriteFlipCheck() {
    final degree = -degrees(handJoint.angle);
    if ((degree < 180 && !flipped) || (degree >= 180 && flipped)) {
      flipSprite();
    }
  }

  void handJointBehindBodyCheck() {
    final deg = degrees(radiansBetweenPoints(
      Vector2(1, 0),
      inputAimVectors,
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
    super.flipSprite();
  }

  @override
  void update(double dt) {
    followTarget();
    super.update(dt);
  }

  Vector2 handAngleTarget = Vector2.zero();
  double aimingInterpolationAmount = .915;

  void followTarget() {
    final angle = calculateInterpolatedVector(handAngleTarget,
        handJoint.position.normalized(), aimingInterpolationAmount);
    final double distanceFactor =
        (Vector2.zero().distanceTo(mouseJoint.position) / 1)
            .clamp(1, 5)
            .toDouble();
    handJoint.position =
        angle.normalized() * handPositionFromBody * distanceFactor;

    handJoint.angle = -radiansBetweenPoints(
      Vector2(0, 1),
      handJoint.position,
    );
  }

  void aimCharacter() {
    if (!enableMovement.parameter) return;

    handAngleTarget = inputAimVectors.clone();

    handJointBehindBodyCheck();
    spriteFlipCheck();

    if (inputAimPositions.containsKey(InputType.mouseMove)) {
      mouseJoint.position = inputAimPositions[InputType.mouseMove]!;
    }
  }
}

mixin AttackFunctionality on AimFunctionality {
  Weapon? get currentWeapon => carriedWeapons[weaponIndex];
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
  bool deadStatus() {
    endAttacking();
    return super.deadStatus();
  }

  Future<void> initializeWeapons() async {
    carriedWeapons.clear();

    if (isPlayer) {
      final player = this as Player;
      final playerData = player.playerData;
      for (var i = 0; i < player.playerData.selectedWeapons.length; i++) {
        final element = playerData.selectedWeapons[i]!;
        carriedWeapons[i] = element.build(
            this,
            player.playerData.selectedSecondaries[i],
            player.playerData.unlockedWeapons[element] ?? 0);
      }
    } else {
      int i = 0;
      for (var element in initialWeapons) {
        carriedWeapons[i] = element.build(
          this,
          null,
        );
        i++;
      }
    }

    await setWeapon(currentWeapon!);
  }

  @override
  void permanentlyDisableEntity() {
    endAttacking();
    endAltAttacking();
    if (currentWeapon != null) {
      for (var element in currentWeapon!.weaponAttachmentPoints.values) {
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

  void endAttacking() {
    if (!isAttacking) return;
    isAttacking = false;
    currentWeapon?.endAttacking();
  }

  void endAltAttacking() {
    if (!isAltAttacking) return;
    isAltAttacking = false;
    currentWeapon?.endAltAttacking();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    await initializeWeapons();
  }

  Future<void> setWeapon(Weapon weapon) async {
    await handJoint.loaded.whenComplete(() => handJoint.addWeaponClass(weapon));
    await mouseJoint.loaded
        .whenComplete(() => mouseJoint.addWeaponClass(weapon));
    await backJoint.loaded.whenComplete(() => backJoint.addWeaponClass(weapon));
  }

  void startAttacking() async {
    if (isAttacking || isDead) return;
    isAttacking = true;
    currentWeapon?.startAttacking();
  }

  void startAltAttacking() async {
    if (isAltAttacking) return;
    isAltAttacking = true;
    currentWeapon?.startAltAttacking();
  }

  void swapWeapon() async {
    if (isAttacking) {
      currentWeapon?.endAttacking();
    }
    if (isAltAttacking) {
      currentWeapon?.endAltAttacking();
    }
    currentWeapon?.weaponSwappedFrom();

    incrementWeaponIndex();
    await setWeapon(currentWeapon!);

    currentWeapon?.weaponSwappedTo();

    if (isAttacking) {
      currentWeapon?.startAttacking();
    }
    if (isAltAttacking) {
      currentWeapon?.startAltAttacking();
    }
  }
}

mixin StaminaFunctionality on Entity {
  final DoubleParameterManager stamina =
      DoubleParameterManager(baseParameter: 100);
  DoubleParameterManager staminaRegen =
      DoubleParameterManager(baseParameter: 50);

  double get remainingStamina => stamina.parameter - staminaUsed;
  double staminaUsed = 0;

  ///Requires a positive value to reduce the amount of stamina used
  ///5 = 5 more stamina, -5 = 5 less stamina
  void modifyStamina(double amount) =>
      staminaUsed = (staminaUsed -= amount).clamp(0, stamina.parameter);

  /// Amount of stamina regenerated per second
  double get increaseStaminaRegenSpeed =>
      ((remainingStamina / stamina.parameter) + .5);

  @override
  void update(double dt) {
    modifyStamina(staminaRegen.parameter * dt * increaseStaminaRegenSpeed);
    super.update(dt);
  }
}

mixin HealthRegenFunctionality on HealthFunctionality {
  ///Requires a positive value to increase the amount of health
  ///5 = 5 more health, -5 = 5 less health
  void modifyHealth(double amount) =>
      damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);

  DoubleParameterManager healthRegen =
      DoubleParameterManager(baseParameter: .35);

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
  //health
  final DoubleParameterManager invincibilityDuration =
      DoubleParameterManager(baseParameter: .2);
  final DoubleParameterManager maxHealth =
      DoubleParameterManager(baseParameter: 50);

  TimerComponent? iFrameTimer;
  double sameDamageSourceDuration = .5;

  double get remainingHealth => maxHealth.parameter - damageTaken;
  double get healthPercentage => remainingHealth / maxHealth.parameter;

  @override
  bool get isInvincible => super.isInvincible || iFrameTimer != null;

  void applyEssenceSteal(DamageInstance instance) {
    final amount = essenceSteal.parameter * instance.damage;
    if (amount == 0) return;
    damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);
    addDamageText(DamageType.healing, amount);
    addDamageEffects(DamageType.healing.color);
  }

  void heal(double amount) {
    damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);
    addDamageText(DamageType.healing, amount);
    addDamageEffects(DamageType.healing.color);
  }

  double damageTaken = 0;
  double recentDamage = 0;

  //HEALTH
  TextComponent? damageText;
  Map<String, TimerComponent> hitSourceInvincibility = {};
  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;

  Vector2? baseSize;
  Vector2? baseTextSize;

  @override
  bool deadStatus() {
    isDead = true;

    permanentlyDisableEntity();
    entityStatusWrapper.removeAllAnimations();
    temporaryAnimationPlaying = true;
    final deadAnimation = entityAnimations[EntityStatus.dead];
    if (deadAnimation != null) {
      assert(!deadAnimation.loop, "Temp animations must not loop");
      spriteAnimationComponent.animation = deadAnimation.clone();
    }

    spriteAnimationComponent.add(OpacityEffect.fadeOut(
      EffectController(
          startDelay: rng.nextDouble() * 10,
          duration: 1.5,
          onMax: () => removeFromParent(),
          curve: Curves.easeIn),
    ));

    deadFunctionsCall();
    return super.deadStatus();
  }

  void deadFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onDeath.isNotEmpty) {
      for (var element in attr.onDeath) {
        element.call();
      }
    }
  }

  void addDamageText(DamageType damageType, double amount) {
    final color = damageType.color;
    const fontSize = .55;

    final textRenderer = TextPaint(
        style: defaultStyle.copyWith(
      fontSize: fontSize,
      shadows: [
        BoxShadow(
            color: Colors.black.withOpacity(.25),
            offset: const Offset(.05, .05),
            spreadRadius: .4,
            blurRadius: .75)
      ],
      color: color.brighten(.2),
    ));
    String damageString = "";
    if (amount < 1) {
      damageString = amount.toStringAsFixed(1);
    } else {
      damageString = amount.toStringAsFixed(0);
    }
    if (damageType == DamageType.healing) {
      damageString = "+ $damageString";
    }
    //TODO
    if (damageText == null) {
      damageText = TextComponent(
        text: damageString,
        anchor: Anchor.bottomLeft,
        textRenderer: textRenderer,
        priority: foregroundPriority,
        position: (Vector2.random() * .25) + Vector2(.35, .35),
      )
        ..add(TimerComponent(
          period: 2,
          onTick: () {
            damageText?.removeFromParent();
            damageText = null;
            recentDamage = 0;
          },
        ))
        ..addToParent(this);
      damageText!.add(
        MoveEffect.by(
          (Vector2.random() * .5) - Vector2.all(.25),
          EffectController(
            duration: 2,
            curve: Curves.decelerate,
          ),
        ),
      );
    } else {
      damageText!.text = damageString;
      damageText!.children.whereType<TimerComponent>().first.timer.reset();

      damageText!.textRenderer = (damageText!.textRenderer as TextPaint)
          .copyWith((p0) => p0.copyWith(
              color: p0.color!.brighten(.01),
              fontSize: (p0.fontSize! * 1.02).clamp(fontSize, fontSize * 1.1)));
      baseTextSize ??= damageText!.size;

      damageText!.add(
        ScaleEffect.to(
          baseTextSize! * (1 + (.2 * rng.nextDouble())),
          EffectController(
            duration: .05,
            curve: Curves.decelerate,
            reverseDuration: .1,
          ),
        ),
      );
    }
  }

  void onHitFunctionsCall(Entity other) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onHit.isNotEmpty) {
      for (var element in attr.onHit) {
        element(other);
      }
    }
  }

  @override
  bool damageStatus() {
    applyTempAnimation(entityAnimations[EntityStatus.damage]);

    return super.damageStatus();
  }

  void addDamageEffects(Color color) {
    final reversedController = EffectController(
      duration: .3,
      reverseDuration: .1,
    );

    baseSize ??= spriteAnimationComponent.size;

    (SizeEffect.to(
            baseSize! * (1 + (.15 * rng.nextDouble())), reversedController))
        .addToParent(spriteAnimationComponent);

    (ColorEffect(
      color,
      const Offset(0.0, 1),
      reversedController,
    )).addToParent(spriteAnimationComponent);
  }

  bool takeDamage(String id, DamageInstance damage,
      [bool applyStatusEffect = true]) {
    if (damage.damageMap.isEmpty) return false;
    MapEntry<DamageType, double> largestEntry = fetchLargestDamageType(damage);
    addDamageText(largestEntry.key, largestEntry.value);
    addDamageEffects(largestEntry.key.color);

    damage.applyResistances(this);

    setEntityStatus(EntityStatus.damage);
    applyIFrameTimer(id);
    applyDamage(damage);

    deathChecker(damage);
    applyStatusEffectChecker(damage, applyStatusEffect);
    essenceStealChecker(damage);
    onHitFunctionsCall(damage.source);
    return true;
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
    recentDamage += damage.damage;
    damageTaken.clamp(0, maxHealth.parameter);

    damageInstancesRecieved.add(damage);
  }

  ///Heal the attacker if they have the essence steal attribute
  void essenceStealChecker(DamageInstance damage) {
    bool isHealth = damage.source is HealthFunctionality;
    if (isHealth) {
      (damage.source as HealthFunctionality).applyEssenceSteal(damage);
    }
  }

  void deathChecker(DamageInstance damage) {
    if (remainingHealth <= 0 && !isDead) {
      if (this is Player) {
        gameRef.gameStateComponent.gameState.killPlayer(true, this as Player);
      } else {
        setEntityStatus(EntityStatus.dead);
      }
      callOtherWeaponOnKillFunctions(damage);
    }
  }

  void applyStatusEffectChecker(DamageInstance damage, bool applyStatusEffect) {
    if (!applyStatusEffect) return;
    if (this is! AttributeFunctionality) return;
    final attr = this as AttributeFunctionality;
    for (var element in damage.damageMap.entries) {
      DamageType damageType = element.key;

      switch (damageType) {
        case DamageType.fire:
          attr.addAttribute(
            AttributeType.burn,
            level: 1,
            duration: 3,
            perpetratorEntity: damage.source,
            damageType: DamageType.fire,
            statusEffect: StatusEffects.burn,
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
    if (other is AttributeFunctionsFunctionality) {
      for (var element in (other).onKillOtherEntity) {
        element(this);
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
  //health
  double totalDamageDodged = 0;
  int dodges = 0;

  DoubleParameterManager dodgeChance = DoubleParameterManager(
      baseParameter: .0, maxParameter: 1, minParameter: 0);

  @override
  bool dodgeStatus() {
    applyTempAnimation(entityAnimations[EntityStatus.dodge]);
    return super.dodgeStatus();
  }

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
      text: ["~", "foo", "dodge", "swish"].getRandomElement(),
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
    totalDamageDodged += damage.damageMap.entries
        .firstWhere((element) => element.key == DamageType.physical)
        .value;

    dodges++;
    applyIFrameTimer(damage.source.entityId);

    addDodgeText();
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

mixin TouchDamageFunctionality on ContactCallbacks, Entity {
  final DamageParameterManager touchDamage =
      DamageParameterManager(damageBase: {});

  DamageInstance get calculateTouchDamage =>
      damageCalculations(this, touchDamage.damageBase,
          damageSource: touchDamage);

  Map<Body, TimerComponent> objectsHitting = {};

  final DoubleParameterManager hitRate = DoubleParameterManager(
      baseParameter: 1, maxParameter: double.infinity, minParameter: 0);

  ///Time interval between damage ticks

  void damageOther(Body other) {
    final otherReference = other.userData;
    if (otherReference is! HealthFunctionality) return;
    if ((isPlayer && otherReference is Enemy) ||
        (!isPlayer && otherReference is Player)) {
      otherReference.hitCheck(entityId, calculateTouchDamage);
      touchFunctions(otherReference);
    }
  }

  void touchFunctions(HealthFunctionality other) {
    if (this is AttributeFunctionsFunctionality) {
      final attributeFunctions = this as AttributeFunctionsFunctionality;
      for (var element in attributeFunctions.onTouch) {
        element(other);
      }
    }
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (touchDamage.damageBase.isEmpty || isDead) return;
    if (other is! HealthFunctionality) return;
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
      other.hitCheck(entityId, calculateTouchDamage);
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
  //STATUS
  TimerComponent? dashTimerCooldown;
  double dashedDistance = 0;

  @override
  bool get isDashing => _isDashing;
  bool _isDashing = false;
  Vector2? dashDelta;

  @override
  bool get isInvincible =>
      super.isInvincible || (invincibleWhileDashing.parameter && isDashing);

  //DASH COOLDOWN
  final DoubleParameterManager dashCooldown =
      DoubleParameterManager(baseParameter: 2);

  final BoolParameterManager invincibleWhileDashing =
      BoolParameterManager(baseParameter: false);
  final BoolParameterManager collisionWhileDashing =
      BoolParameterManager(baseParameter: false);
  final BoolParameterManager teleportDash =
      BoolParameterManager(baseParameter: false);

  final DoubleParameterManager dashDistance =
      DoubleParameterManager(baseParameter: 5);
  final DoubleParameterManager dashDuration =
      DoubleParameterManager(baseParameter: .2, minParameter: 0);
  final DoubleParameterManager dashStaminaCost =
      DoubleParameterManager(baseParameter: 28);

  double? dashDistanceGoal;

  @override
  bool dashStatus() {
    if (!dashCheck()) return false;
    final dashAnimation = entityAnimations[EntityStatus.dash];
    dashAnimation?.stepTime =
        dashDuration.parameter / dashAnimation.frames.length * 2;
    applyTempAnimation(dashAnimation);
    return super.dashStatus();
  }

  bool dashCheck() {
    if (dashTimerCooldown != null ||
        isJumping ||
        isDead ||
        !enableMovement.parameter ||
        dashStaminaCost.parameter > remainingStamina) {
      return false;
    }

    dashInit();

    return true;
  }

  void dashInit({double? power, bool weaponSource = false}) {
    if (!weaponSource) modifyStamina(-dashStaminaCost.parameter);

    power ??= 1;

    dashDistanceGoal = dashDistance.parameter * power;
    _isDashing = true;
    if (weaponSource || teleportDash.parameter) {
      if (this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).inputAimVectors;
      }
      if (dashDelta?.isZero() ?? true && this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).moveDelta;
      }
    } else {
      if (this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).moveDelta;
      }
      if (dashDelta?.isZero() ?? true && this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).inputAimVectors;
      }
    }

    dashDelta = dashDelta!.normalized();
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

      dashBeginFunctionsCall();
    }
  }

  void dashBeginFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.dashBeginFunctions.isNotEmpty) {
      for (var element in attr.dashBeginFunctions) {
        element();
      }
    }
  }

  void dashEndFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.dashEndFunctions.isNotEmpty) {
      for (var element in attr.dashEndFunctions) {
        element();
      }
    }
  }

  void dashOngoingFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.dashOngoingFunctions.isNotEmpty) {
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
  }

  void dashMove(double dt) {
    final double distance =
        ((dashDistance.parameter / dashDuration.parameter) * dt)
            .clamp(0, dashDistance.parameter);

    body.setTransform(body.position + (dashDelta! * distance), 0);
    dashedDistance += distance;
    dashOngoingFunctionsCall();
  }
}

mixin JumpFunctionality on Entity {
  //JUMP

  @override
  bool get isJumping => _isJumping;
  bool _isJumping = false;
  bool allowJumpingInvincible = true;
  bool isJumpingInvincible = false;

  double jumpHeight = .5;

  final DoubleParameterManager jumpDuration =
      DoubleParameterManager(baseParameter: .6, minParameter: 0);
  final DoubleParameterManager jumpStaminaCost =
      DoubleParameterManager(baseParameter: 10, minParameter: 0);
  final DoubleParameterManager jumpingInvinciblePercent =
      DoubleParameterManager(
          baseParameter: .5, minParameter: 0, maxParameter: 1);

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
    final jumpAnimation = entityAnimations[EntityStatus.jump];

    jumpAnimation?.stepTime =
        jumpDuration.parameter / jumpAnimation.frames.length;
    applyTempAnimation(jumpAnimation);

    return super.jumpStatus();
  }

  void jump() {
    if (this is StaminaFunctionality) {
      (this as StaminaFunctionality).modifyStamina(-jumpStaminaCost.parameter);
    }
    _isJumping = true;
    double elapsed = 0;
    double min = (jumpDuration.parameter / 2) -
        jumpDuration.parameter * (jumpingInvinciblePercent.parameter / 2);
    double max = (jumpDuration.parameter / 2) +
        jumpDuration.parameter * (jumpingInvinciblePercent.parameter / 2);

    final controller = EffectController(
      duration: jumpDuration.parameter,
      curve: Curves.ease,
      reverseDuration: jumpDuration.parameter,
      reverseCurve: Curves.ease,
    );
    final controllerD = EffectController(
      duration: jumpDuration.parameter,
      curve: Curves.ease,
      startDelay: .1,
      reverseDuration: jumpDuration.parameter,
      reverseCurve: Curves.ease,
    );

    if (allowJumpingInvincible) {
      Future.doWhile(() =>
          Future.delayed(const Duration(milliseconds: 25)).then((value) {
            elapsed += .025;

            isJumpingInvincible = elapsed > min && elapsed < max;
            jumpOngoingFunctionsCall();

            return !(elapsed >= jumpDuration.parameter || controller.completed);
          })).then((_) {
        _isJumping = false;
        jumpEndFunctionsCall();
      });
    }

    spriteAnimationComponent.add(ScaleEffect.by(
      Vector2(1.025, 1.025),
      controller,
    ));
    spriteAnimationComponent.add(MoveEffect.by(
      Vector2(0, -jumpHeight),
      controller,
    ));
    backJoint.add(MoveEffect.by(
      Vector2(0, -jumpHeight),
      controllerD,
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
          ? (jumpStaminaCost.parameter >
              (this as StaminaFunctionality).remainingStamina)
          : false);

  bool jumpCheck() {
    if (cantJump) return false;

    jump();

    return true;
  }
}
