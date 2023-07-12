import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:game_app/entities/enemy.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/functions/functions.dart';
import '../resources/functions/vector_functions.dart';
import '../main.dart';
import '../attributes/attributes_enum.dart';
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
  bool isDead = false;

  final bool baseIsInvincible = false;
  List<bool> isInvincibleIncrease = [];
  bool get isInvincible =>
      boolAbilityDecipher(baseIsInvincible, isInvincibleIncrease) || isDead;

  double get damageDuration => baseDamageDuration + damageDurationIncrease;
  final double baseDamageDuration = 2;
  double damageDurationIncrease = 0;

  final bool baseEnableMovement = true;
  List<bool> enableMovementIncrease = [];
  bool get enableMovement =>
      boolAbilityDecipher(baseEnableMovement, enableMovementIncrease);

  int additionalCountIncrease = 0;
}

mixin MovementFunctionality on Entity {
  //MOVEMENT
  abstract final double baseSpeed;
  double speedIncrease = 0;
  double get getMaxSpeed => baseSpeed + speedIncrease;

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
    final previousPulse = moveDelta;

    if (isDead || !enableMovement || previousPulse.isZero()) {
      setEntityStatus(EntityStatus.idle);
      return;
    }
    spriteFlipCheck();

    body.applyForce(previousPulse * getMaxSpeed);
    moveFunctionsCall();
    setEntityStatus(EntityStatus.run);
  }
}

mixin AimFunctionality on Entity {
  Vector2 lastAimingPosition = Vector2.zero();
  double handPositionFromBody = .1;

  Vector2 get inputAimVectors {
    if (isDead) {
      return lastAimingPosition;
    }
    return inputAimAngles[InputType.aimJoy] ??
        inputAimAngles[InputType.tapClick] ??
        inputAimAngles[InputType.mouseDrag] ??
        inputAimAngles[InputType.mouseMove] ??
        inputAimAngles[InputType.ai] ??
        ((this is MovementFunctionality)
                ? (this as MovementFunctionality).moveDelta
                : Vector2.zero())
            .normalized();
  }

  Vector2 get handJointAimDelta {
    return (handJoint.weaponTipCenter!.absolutePosition -
            handJoint.weaponBase!.absolutePosition)
        .normalized();
  }

  // Vector2 get aimDelta {
  //   return (inputAimVectors - center).normalized();
  // }

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

  bool weaponBehind = false;

  @override
  void flipSprite() {
    handJoint.flipHorizontallyAroundCenter();
    super.flipSprite();
  }

  void aimCharacter() {
    if (!enableMovement) return;

    final delta = inputAimVectors;

    handJoint.angle = -radiansBetweenPoints(
      Vector2(0, 1),
      delta,
    );
    handJointBehindBodyCheck();
    spriteFlipCheck();

    handJoint.position = delta.clone() * handPositionFromBody;
    lastAimingPosition = delta.clone();

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
  void deadStatus() {
    endAttacking();
    super.deadStatus();
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

    setWeapon(currentWeapon!);
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
    await setWeapon(carriedWeapons.entries.first.value);
  }

  Future<void> setWeapon(Weapon weapon) async {
    await handJoint.loaded.whenComplete(() => handJoint.addWeaponClass(weapon));
    await mouseJoint.loaded
        .whenComplete(() => mouseJoint.addWeaponClass(weapon));
    await backJoint.loaded.whenComplete(() => backJoint.addWeaponClass(weapon));
  }

  void startAttacking() async {
    if (isAttacking) return;
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
  abstract final double baseStamina;
  double staminaIncrease = 0;
  double get maxStamina => baseStamina + staminaIncrease;
  double get remainingStamina => maxStamina - staminaUsed;
  double staminaUsed = 0;

  ///Requires a positive value to reduce the amount of stamina used
  ///5 = 5 more stamina, -5 = 5 less stamina
  void modifyStamina(double amount) =>
      staminaUsed = (staminaUsed -= amount).clamp(0, maxStamina);

  /// Amount of stamina regenerated per second
  final double baseStaminaRegen = 50;
  double staminaRegenIncrease = 0;
  double get staminaRegen => baseStaminaRegen + staminaRegenIncrease;
  double get increaseStaminaRegenSpeed =>
      ((remainingStamina / maxStamina) + .5);

  @override
  void update(double dt) {
    modifyStamina(staminaRegen * dt * increaseStaminaRegenSpeed);
    super.update(dt);
  }
}

mixin HealthRegenFunctionality on HealthFunctionality {
  ///Requires a positive value to increase the amount of health
  ///5 = 5 more health, -5 = 5 less health
  void modifyHealth(double amount) =>
      damageTaken = (damageTaken -= amount).clamp(0, maxHealth);

  /// Amount of health regenerated per second
  final double baseHealthRegen = .35;
  double healthRegenIncrease = 0;
  double get healthRegen => baseHealthRegen + healthRegenIncrease;
  double get increaseHealthRegenSpeed => ((remainingHealth / maxHealth) + .5);

  @override
  void update(double dt) {
    modifyHealth(healthRegen * dt * increaseHealthRegenSpeed);

    super.update(dt);
  }
}

mixin HealthFunctionality on Entity {
  //health
  abstract final double baseInvincibilityDuration;
  double invincibilityDurationIncrease = 0;
  double get invincibilityDuration =>
      baseInvincibilityDuration + invincibilityDurationIncrease;

  TimerComponent? invincibleTimer;

  double sameDamageSourceDuration = .5;

  abstract final double baseHealth;
  double healthIncrease = 0;
  double get maxHealth => baseHealth + healthIncrease;
  double get remainingHealth => maxHealth - damageTaken;
  double get healthPercentage => remainingHealth / maxHealth;

  @override
  bool get isInvincible => super.isInvincible || invincibleTimer != null;

  double damageTaken = 0;
  double recentDamage = 0;

  //HEALTH
  TextComponent? damageText;
  Map<String, TimerComponent> hitSourceInvincibility = {};
  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;

  abstract SpriteAnimation? deathAnimation;
  abstract SpriteAnimation? damageAnimation;
  Vector2? baseSize;
  Vector2? baseTextSize;

  @override
  void deadStatus() {
    isDead = true;

    permanentlyDisableEntity();
    entityStatusWrapper.removeAllAnimations();
    tempAnimationPlaying = true;
    assert(!deathAnimation!.loop, "Temp animations must not loop");
    spriteAnimationComponent.animation = deathAnimation?.clone();

    spriteAnimationComponent.add(OpacityEffect.fadeOut(
      EffectController(
          startDelay: rng.nextDouble() * 10,
          duration: 1.5,
          onMax: () => removeFromParent(),
          curve: Curves.easeIn),
    ));

    deadFunctionsCall();
    super.deadStatus();
  }

  void deadFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onDeath.isNotEmpty) {
      for (var element in attr.onDeath) {
        element();
      }
    }
  }

  void buildDamageText(DamageInstance instance) {
    final color = instance.getColor();
    const fontSize = .55;

    final test = TextPaint(
        style: defaultStyle.copyWith(
      fontSize: fontSize,
      shadows: const [
        BoxShadow(
            color: Colors.black,
            offset: Offset(.07, .07),
            spreadRadius: .5,
            blurRadius: .5)
      ],
      color: color,
    ));
    String damageString = "";
    if (recentDamage < 1) {
      damageString = recentDamage.toStringAsFixed(1);
    } else {
      damageString = recentDamage.toStringAsFixed(0);
    }
    if (damageText == null) {
      damageText = TextComponent(
        text: damageString,
        anchor: Anchor.bottomLeft,
        textRenderer: test,
        priority: playerOverlayPriority,
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
  void damageStatus() {
    applyTempAnimation(damageAnimation);

    super.damageStatus();
  }

  void addDamageEffects(Color color) {
    final reversedController = EffectController(
      duration: .15,
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

  bool takeDamage(String id, List<DamageInstance> damage,
      [bool applyStatusEffect = true]) {
    if (damage.isEmpty) return false;

    setEntityStatus(EntityStatus.damage);

    if (invincibilityDuration > 0) {
      invincibleTimer = TimerComponent(
        period: invincibilityDuration,
        removeOnFinish: true,
        onTick: () => invincibleTimer = null,
      );
      add(invincibleTimer!);
    }

    DamageInstance largestEntry = damage.first;

    for (var element in damage) {
      damageTaken += element.damage;
      recentDamage += element.damage;
      if (element.damage > largestEntry.damage) largestEntry = element;
    }
    damageTaken.clamp(0, maxHealth);

    if (remainingHealth <= 0) {
      if (this is Player) {
        (this as Player).killPlayer(true);
      } else {
        setEntityStatus(EntityStatus.dead);
      }
      callOtherWeaponOnKillFunctions(damage);
    }
    if (applyStatusEffect) {
      this.applyStatusEffect(damage);
    }
    buildDamageText(largestEntry);
    addDamageEffects(largestEntry.getColor());
    onHitFunctionsCall(damage.first.source);
    return true;
  }

  void applyStatusEffect(List<DamageInstance> damage) {
    if (this is! AttributeFunctionality) return;
    final attr = this as AttributeFunctionality;
    for (var element in damage) {
      DamageType damageType = element.damageType;

      //TODO finish this
      switch (damageType) {
        case DamageType.fire:
          attr.addAttributeEnum(AttributeEnum.fireDamage,
              perpetratorEntity: element.source);
          break;
        default:
          attr.addAttributeEnum(AttributeEnum.fireDamage,
              perpetratorEntity: element.source);
      }
    }
  }

  void callOtherWeaponOnKillFunctions(List<DamageInstance> damage) {
    final weaponFunctions = damage
        .where((element) =>
            element.sourceWeapon is AttributeWeaponFunctionsFunctionality)
        .toList();
    if (weaponFunctions.isNotEmpty) {
      final weapon = weaponFunctions.first.sourceWeapon
          as AttributeWeaponFunctionsFunctionality;

      for (var element in weapon.onKill) {
        element(this);
      }
    }
  }

  bool hitCheck(String id, List<DamageInstance> damage,
      [bool applyStatusEffect = true]) {
    if (hitSourceInvincibility.containsKey(id) ||
        isInvincible ||
        (damage.fold<double>(0,
                (previousValue, element) => previousValue += element.damage)) ==
            0 ||
        damage.isEmpty) {
      return false;
    }

    hitSourceInvincibility[id] = TimerComponent(
        period: sameDamageSourceDuration,
        removeOnFinish: true,
        onTick: () {
          hitSourceInvincibility.remove(id);
        })
      ..addToParent(this);

    return takeDamage(id, damage, applyStatusEffect);
  }
}

mixin DodgeFunctionality on HealthFunctionality {
  //health
  double totalDamageDodged = 0;
  int dodges = 0;

  abstract final double baseDodgeChance;
  double dodgeChanceIncrease = 0;
  double get dodgeChance => (baseDodgeChance + dodgeChanceIncrease).clamp(0, 1);

  //HEALTH
  abstract SpriteAnimation? dodgeAnimation;

  @override
  void dodgeStatus() {
    applyTempAnimation(dodgeAnimation);

    super.dodgeStatus();
  }

  void addDodgeText() {
    final test = TextPaint(
        style: TextStyle(
      fontSize: 3,
      fontFamily: "HeroSpeak",
      fontWeight: FontWeight.bold,
      fontStyle: FontStyle.italic,
      shadows: const [
        BoxShadow(
            color: Colors.black26,
            offset: Offset(.3, .3),
            spreadRadius: 3,
            blurRadius: 3)
      ],
      color: Colors.grey.shade100,
    ));
    final dodgeText = TextComponent(
      text: "~",
      anchor: Anchor.bottomLeft,
      textRenderer: test,
      position: Vector2.random() + Vector2(1, -1),
    );
    dodgeText.addAll([
      MoveEffect.by(body.linearVelocity.normalized() * -3,
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

  void dodge(List<DamageInstance> damage) {
    totalDamageDodged += damage
        .firstWhere((element) => element.damageType == DamageType.regular)
        .damage;

    dodges++;

    addDodgeText();
  }

  bool dodgeCheck(List<DamageInstance> damage) {
    final random = rng.nextDouble();

    if (damage.any((element) => element.damageType == DamageType.regular) &&
        random < dodgeChance) {
      dodge(damage);
      return true;
    } else {
      return false;
    }
  }

  @override
  bool takeDamage(String id, List<DamageInstance> damage,
      [bool applyStatusEffect = true]) {
    List<DamageInstance> filtedDamage = [];
    for (var element in damage) {
      if (dodgeCheck([element])) {
        continue;
      } else {
        filtedDamage.add(element);
      }
    }
    return super.takeDamage(id, filtedDamage, applyStatusEffect);
  }
}

mixin TouchDamageFunctionality on ContactCallbacks, Entity {
  //Touch Damage

  ///Min damage is added to min damage calculation, same with max
  Map<DamageType, (double, double)> touchDamageIncrease = {};

  //DamageType, min, max
  abstract Map<DamageType, (double, double)> baseTouchDamage;

  List<DamageInstance> get damage => damageCalculations(
      baseTouchDamage, touchDamageIncrease, damageDuration, this, null);

  Map<Body, TimerComponent> objectsHitting = {};

  ///Time interval between damage ticks
  double get hitRate =>
      (baseHitRate - hitRateIncrease).clamp(0, double.infinity);
  final double baseHitRate = 1;
  double hitRateIncrease = 0;

  void damageOther(Body other) {
    final otherReference = other.userData;
    if (otherReference is! HealthFunctionality) return;
    if ((isPlayer && otherReference is Enemy) ||
        (!isPlayer && otherReference is Player)) {
      otherReference.hitCheck(entityId, damage);
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
    if (baseTouchDamage.isEmpty || isDead) return;
    if (other is! HealthFunctionality) return;
    if (isPlayer && other is Enemy) {
      objectsHitting[other.body] = TimerComponent(
        period: hitRate,
        repeat: true,
        onTick: () {
          damageOther(other.body);
        },
      )
        ..addToParent(this)
        ..onTick();
      other.hitCheck(entityId, damage);
    } else if (!isPlayer && other is Player) {
      objectsHitting[other.body] = TimerComponent(
        period: hitRate,
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
  abstract SpriteAnimation? dashAnimation;
  double dashedDistance = 0;

  @override
  bool get isDashing => _isDashing;

  bool _isDashing = false;
  Vector2? dashDelta;

  @override
  bool get isInvincible =>
      super.isInvincible || (invincibleWhileDashing && isDashing);

  //DASH
  double get dashCooldown =>
      (baseDashCooldown - dashCooldownIncrease + dashDuration)
          .clamp(0, double.infinity);
  abstract double baseDashCooldown;
  double dashCooldownIncrease = 0;

  final bool baseInvincibleWhileDashing = false;
  List<bool> invincibleWhileDashingIncrease = [];
  bool get invincibleWhileDashing => boolAbilityDecipher(
      baseInvincibleWhileDashing, invincibleWhileDashingIncrease);

  final bool baseCollisionWhileDashing = false;
  List<bool> collisionWhileDashingIncrease = [];
  bool get collisionWhileDashing => boolAbilityDecipher(
      baseCollisionWhileDashing, collisionWhileDashingIncrease);

  final bool baseTeleportDash = false;
  List<bool> teleportDashIncrease = [];
  bool get teleportDash =>
      boolAbilityDecipher(baseTeleportDash, teleportDashIncrease);

  abstract double baseDashDistance;
  double get dashDistance => baseDashDistance + dashDistanceIncrease;
  double dashDistanceIncrease = 0;

  final double baseDashDuration = .2;
  double get dashDuration =>
      (baseDashDuration - dashDurationIncrease).clamp(0, double.infinity);
  double dashDurationIncrease = 0;

  double baseDashStaminaCost = 28;
  double get dashStaminaCost => baseDashStaminaCost - dashStaminaCostIncrease;
  double dashStaminaCostIncrease = 0;

  @override
  void dashStatus() {
    if (!dashCheck()) return;
    dashAnimation?.stepTime = dashDuration / dashAnimation!.frames.length * 2;
    applyTempAnimation(dashAnimation);

    super.dashStatus();
  }

  bool dashCheck() {
    if (dashTimerCooldown != null ||
        isJumping ||
        isDead ||
        !enableMovement ||
        dashStaminaCost > remainingStamina) {
      return false;
    }

    dashInit();

    return true;
  }

  void dashInit({double? power, bool weaponSource = false}) {
    if (!weaponSource) modifyStamina(-dashStaminaCost);
    if (power != null) {
      power *= 2;
    }
    power ??= 1;

    dashDistanceGoal = dashDistance * power;
    _isDashing = true;
    if (weaponSource || teleportDash) {
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
        period: dashCooldown,
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

  double? dashDistanceGoal;

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
        ((dashDistance / dashDuration) * dt).clamp(0, dashDistance);

    body.setTransform(body.position + (dashDelta! * distance), 0);
    dashedDistance += distance;
    dashOngoingFunctionsCall();
  }
}

mixin JumpFunctionality on StaminaFunctionality {
  //JUMP

  @override
  bool get isJumping => _isJumping;
  bool _isJumping = false;

  bool isJumpingInvincible = false;

  final double baseJumpDuration = .6;
  double get jumpDuration =>
      (baseJumpDuration - jumpDurationIncrease).clamp(0, double.infinity);
  double jumpDurationIncrease = 0;

  double baseJumpStaminaCost = 10;
  double get jumpStaminaCost => baseJumpStaminaCost - jumpStaminaCostIncrease;
  double jumpStaminaCostIncrease = 0;

  //how much of the jumpduration the character is jumping to avoid dmg

  double baseJumpingInvinciblePercent = .5;
  double get jumpingInvinciblePercent =>
      (baseJumpingInvinciblePercent + jumpingInvinciblePercentIncrease)
          .clamp(0, 1);
  double jumpingInvinciblePercentIncrease = 0;

  abstract SpriteAnimation? jumpAnimation;

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
  void jumpStatus() {
    if (!jumpCheck()) return;
    jumpAnimation?.stepTime = jumpDuration / jumpAnimation!.frames.length;
    applyTempAnimation(jumpAnimation);

    super.jumpStatus();
  }

  void jump() {
    modifyStamina(-jumpStaminaCost);
    _isJumping = true;
    double elapsed = 0;
    double min =
        (jumpDuration / 2) - jumpDuration * (jumpingInvinciblePercent / 2);
    double max =
        (jumpDuration / 2) + jumpDuration * (jumpingInvinciblePercent / 2);

    final controller = EffectController(
      duration: jumpDuration,
      curve: Curves.ease,
      reverseDuration: jumpDuration,
      reverseCurve: Curves.ease,
    );
    final controllerD = EffectController(
      duration: jumpDuration,
      curve: Curves.ease,
      startDelay: .1,
      reverseDuration: jumpDuration,
      reverseCurve: Curves.ease,
    );

    Future.doWhile(
        () => Future.delayed(const Duration(milliseconds: 25)).then((value) {
              elapsed += .025;

              isJumpingInvincible = elapsed > min && elapsed < max;
              jumpOngoingFunctionsCall();

              return !(elapsed >= jumpDuration || controller.completed);
            })).then((_) {
      _isJumping = false;
      jumpEndFunctionsCall();
    });

    spriteWrapper.add(ScaleEffect.by(
      Vector2(1.025, 1.025),
      controller,
    ));
    spriteWrapper.add(MoveEffect.by(
      Vector2(0, -1),
      controller,
    ));
    backJoint.add(MoveEffect.by(
      Vector2(0, -1),
      controllerD,
    ));

    if (this is AimFunctionality) {
      (this as AimFunctionality).handJoint.add(MoveEffect.by(
            Vector2(0, -1),
            controllerD,
          ));
    }
    jumpBeginFunctionsCall();
  }

  bool jumpCheck() {
    if (isJumping ||
        isDashing ||
        !enableMovement ||
        isDead ||
        jumpStaminaCost > remainingStamina) return false;

    jump();

    return true;
  }
}
