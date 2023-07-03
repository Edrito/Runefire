import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:game_app/entities/enemy.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/resources/visuals.dart';

import '../functions/vector_functions.dart';
import '../game/powerups.dart';
import '../resources/attributes.dart';
import '../resources/attributes_enum.dart';
import '../resources/enums.dart';
import '../weapons/weapon_class.dart';

mixin BaseAttributes {
  bool get getIsJumping =>
      this is JumpFunctionality ? (this as JumpFunctionality).isJumping : false;
  bool get getIsDashing =>
      this is DashFunctionality ? (this as DashFunctionality).isDashing : false;

  //Temporary effects
  Map<int, Powerup> currentPowerups = {};
  Map<int, Powerup> currentPowerdowns = {};

  double get damageDuration => baseDamageDuration + damageDurationIncrease;
  final double baseDamageDuration = 2;
  double damageDurationIncrease = 0;

  bool disableMovement = false;
}

mixin MovementFunctionality on Entity {
  //MOVEMENT
  abstract final double baseSpeed;
  double speedIncrease = 1;
  double get getMaxSpeed => baseSpeed * speedIncrease;
  Map<InputType, Vector2?> moveVelocities = {};

  Vector2 get moveDelta => (moveVelocities[InputType.moveJoy] ??
          moveVelocities[InputType.keyboard] ??
          moveVelocities[InputType.ai] ??
          Vector2.zero())
      .normalized();

  void moveCharacter() {
    final previousPulse = moveDelta;

    if (disableMovement || previousPulse.isZero()) {
      setEntityStatus(EntityStatus.idle);
      return;
    }

    body.applyForce(previousPulse * getMaxSpeed);

    setEntityStatus(EntityStatus.run);
  }
}

mixin AimFunctionality on Entity {
  Vector2 lastAimingPosition = Vector2.zero();

  Vector2 get aimDelta {
    if (this is HealthFunctionality && (this as HealthFunctionality).isDead) {
      return Vector2.zero();
    }

    return inputAimAngles[InputType.aimJoy] ??
        inputAimAngles[InputType.tapClick] ??
        inputAimAngles[InputType.mouseDrag] ??
        inputAimAngles[InputType.mouseMove] ??
        inputAimAngles[InputType.ai] ??
        ((this is MovementFunctionality)
            ? (this as MovementFunctionality).moveDelta
            : Vector2.zero());
  }

  Map<InputType, Vector2> inputAimAngles = {};
  Map<InputType, Vector2> inputAimPositions = {};
  late PlayerAttachmentJointComponent mouseJoint;
  late PlayerAttachmentJointComponent handJoint;

  @override
  Future<void> onLoad() {
    handJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.hand,
        anchor: Anchor.center, size: Vector2.zero());
    mouseJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.mouse,
        anchor: Anchor.center, size: Vector2.zero());
    add(handJoint);
    add(mouseJoint);
    return super.onLoad();
  }

  @override
  void flipSpriteCheck() {
    final degree = -degrees(handJoint.angle);
    if ((degree < 180 && !flipped) || (degree >= 180 && flipped)) {
      flipSprite();
    }
  }

  void handJointBehindBodyCheck() {
    final deg = degrees(radiansBetweenPoints(
      Vector2(1, 0),
      aimDelta,
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

  @override
  void update(double dt) {
    aimCharacter();
    super.update(dt);
  }

  void aimCharacter() {
    if (disableMovement) return;

    final delta = aimDelta;

    handJoint.angle = -radiansBetweenPoints(
      Vector2(0, 0.000001),
      delta,
    );
    handJointBehindBodyCheck();

    handJoint.position = delta.clone();
    lastAimingPosition = delta.clone();

    if (inputAimPositions.containsKey(InputType.mouseMove)) {
      mouseJoint.position = inputAimPositions[InputType.mouseMove]!;
    }
  }
}

mixin AttackFunctionality on AimFunctionality {
  Weapon? currentWeapon;

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
    int i = 0;
    for (var element in initialWeapons) {
      carriedWeapons[i] = element.build(this, null, 0);
      // if (carriedWeapons[i] is SecondaryFunctionality) {
      //   (carriedWeapons[i] as SecondaryFunctionality)
      //       .setSecondaryFunctionality = RapidFire(carriedWeapons[i]!, 4);
      // }
      i++;
    }
    initialWeapons.clear();
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
    currentWeapon?.weaponSwappedFrom();
    currentWeapon = weapon;
    currentWeapon?.weaponSwappedTo();
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
    int key = (carriedWeapons.entries
            .firstWhere((element) => element.value == currentWeapon)
            .key) +
        1;
    if (!carriedWeapons.containsKey(key)) {
      await setWeapon(carriedWeapons.entries.first.value);
    } else {
      await setWeapon(carriedWeapons[key]!);
    }
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
  ///+5 = 5 more stamina to use
  void modifyStamina(double amount) =>
      staminaUsed = (staminaUsed -= amount).clamp(0, maxStamina);

  /// Amount of stamina regenerated per second
  final double baseStaminaRegen = 20;
  double staminaRegenIncrease = 0;
  double get staminaRegen => baseStaminaRegen + staminaRegenIncrease;
  double get increaseRegenSpeed => ((remainingStamina / maxStamina) + .5);

  @override
  void update(double dt) {
    modifyStamina(staminaRegen * dt * increaseRegenSpeed);
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
  abstract final double baseHealth;

  double healthIncrease = 0;
  double get maxHealth => baseHealth + healthIncrease;

  double sameDamageSourceDuration = 1;

  double get remainingHealth => maxHealth - damageTaken;
  bool isDead = false;

  bool get isInvincible => invincibleTimer != null || isDead;

  double damageTaken = 0;
  double recentDamage = 0;

  //HEALTH
  TextComponent? damageText;
  Map<String, TimerComponent> hitSourceInvincibility = {};
  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;
  abstract SpriteAnimation? deathAnimation;
  abstract SpriteAnimation? damageAnimation;

  @override
  void deadStatus() {
    isDead = true;
    if (deathAnimation == null) {
      spriteAnimationComponent.add(OpacityEffect.fadeOut(
        EffectController(
          duration: 1.5,
        ),
      ));
      return;
    }
    tempAnimationPlaying = true;
    assert(!deathAnimation!.loop, "Temp animations must not loop");
    spriteAnimationComponent.animation = deathAnimation?.clone();
    super.deadStatus();
  }

  @override
  void damageStatus() {
    if (damageAnimation == null) return;
    assert(!damageAnimation!.loop, "Temp animations must not loop");
    tempAnimationPlaying = true;
    spriteAnimationComponent.animation = damageAnimation?.clone();
    spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;
    super.damageStatus();
  }

  bool takeDamage(String id, List<DamageInstance> damage) {
    setEntityStatus(EntityStatus.damage);

    final reversedController = EffectController(
      duration: .1,
      reverseDuration: .1,
    );
    spriteAnimationComponent
        .add(SizeEffect.by(Vector2.all(.5), reversedController));
    spriteAnimationComponent.add(ColorEffect(
      Colors.red,
      const Offset(0.0, 1),
      reversedController,
    ));

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
    final color = largestEntry.getColor();

    if (remainingHealth <= 0) {
      if (this is Player) {
        (this as Player).killPlayer(true);
      } else {
        setEntityStatus(EntityStatus.dead);
      }
    }
    final test = TextPaint(
        style: defaultStyle.copyWith(
      fontSize: 3,
      shadows: const [
        BoxShadow(
            color: Colors.black,
            offset: Offset(.3, .3),
            spreadRadius: 3,
            blurRadius: 3)
      ],
      color: color,
    ));
    if (damageText == null) {
      damageText = TextComponent(
        text: recentDamage.round().toString(),
        anchor: Anchor.bottomLeft,
        textRenderer: test,
        position: Vector2.random() + Vector2(1, -1),
      );
      damageText?.addAll([
        TimerComponent(
          period: 1,
          onTick: () {
            damageText?.removeFromParent();
            damageText = null;
            recentDamage = 0;
          },
        )
      ]);
      add(damageText!);
    } else {
      damageText!.text = recentDamage.round().toString();
      damageText!.children.whereType<TimerComponent>().first.timer.reset();

      damageText!.textRenderer =
          (damageText!.textRenderer as TextPaint).copyWith((p0) => p0.copyWith(
                color: color.darken(.05),
              ));

      damageText!.addAll([
        ScaleEffect.by(
          Vector2.all(1.15),
          EffectController(
            duration: .05,
            reverseDuration: .05,
          ),
        ),
      ]);
    }

    return true;
  }

  bool hit(String id, List<DamageInstance> damage) {
    if (hitSourceInvincibility.containsKey(id) ||
        isInvincible ||
        isDead ||
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

    return takeDamage(id, damage);
  }
}

mixin DodgeFunctionality on HealthFunctionality {
  //health
  double totalDamageDodged = 0;
  int dodges = 0;
  abstract final double baseDodgeChance;
  double dodgeChanceIncrease = 0;

  double get dodgeChance => (baseDodgeChance + dodgeChanceIncrease).clamp(0, 1);
  @override
  Random rng = Random();
  //HEALTH

  abstract SpriteAnimation? dodgeAnimation;

  @override
  void dodgeStatus() {
    if (dodgeAnimation == null) return;
    assert(!dodgeAnimation!.loop, "Temp animations must not loop");
    tempAnimationPlaying = true;
    spriteAnimationComponent.animation = dodgeAnimation?.clone();
    spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;
    super.dodgeStatus();
  }

  bool processDodge(List<DamageInstance> damage) {
    final random = rng.nextDouble();
    if (damage.any((element) => element.damageType == DamageType.regular) &&
        random < dodgeChance) {
      totalDamageDodged += damage
          .firstWhere((element) => element.damageType == DamageType.regular)
          .damage;

      dodges++;

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
      return true;
    } else {
      return false;
    }
  }

  @override
  bool takeDamage(String id, List<DamageInstance> damage) {
    if (processDodge(damage)) {
      return false;
    } else {
      return super.takeDamage(id, damage);
    }
  }
}

mixin TouchDamageFunctionality on ContactCallbacks, Entity {
  ///Min damage is added to min damage calculation, same with max
  Map<DamageType, (double, double)> touchDamageIncrease = {};

  //DamageType, min, max
  abstract Map<DamageType, (double, double)> touchDamageLevels;

  List<DamageInstance> get damage {
    List<DamageInstance> returnList = [];

    for (var element in touchDamageLevels.entries) {
      var min = element.value.$1;
      var max = element.value.$2;
      if (touchDamageIncrease.containsKey(element.key)) {
        min += touchDamageIncrease[element.key]?.$1 ?? 0;
        max += touchDamageIncrease[element.key]?.$2 ?? 0;
      }
      returnList.add(DamageInstance(
          damageBase: ((rng.nextDouble() * max - min) + min),
          damageType: element.key,
          duration: damageDuration));
    }

    return returnList;
  }

  List<Body> objectsHitting = [];

  double hitRate = 1;

  void damageCheck() {
    if (touchDamageLevels.isEmpty) return;

    for (var element in objectsHitting) {
      final otherReference = element.userData;
      if (otherReference is! HealthFunctionality) continue;
      if (isPlayer && otherReference is Enemy) {
        otherReference.hit(entityId, damage);
      } else if (!isPlayer && otherReference is Player) {
        otherReference.hit(entityId, damage);
      }
    }
  }

  @override
  void update(double dt) {
    damageCheck();
    super.update(dt);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (isPlayer && other is Enemy) {
      objectsHitting.add(other.body);
    } else if (!isPlayer && other is Player) {
      objectsHitting.add(other.body);
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is BodyComponent) {
      objectsHitting.remove(other.body);
    }

    super.endContact(other, contact);
  }
}

mixin DashFunctionality on StaminaFunctionality {
  abstract SpriteAnimation? dashAnimation;

  //DASH
  abstract double dashCooldown;
  TimerComponent? dashTimerCooldown;
  double dashedDistance = 0;
  bool isDashing = false;
  Vector2? dashDelta;
  double dashSpeed = 15;
  double dashDuration = .2;
  double dashStaminaCost = 50;

  @override
  void dashStatus() {
    if (!dashCheck() || dashAnimation == null) return;
    assert(!dashAnimation!.loop, "Temp animations must not loop");
    tempAnimationPlaying = true;
    spriteAnimationComponent.animation = dashAnimation?.clone();
    spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;
    super.dashStatus();
  }

  bool dashCheck() {
    if (dashTimerCooldown != null ||
        getIsJumping ||
        disableMovement ||
        dashStaminaCost > remainingStamina) {
      return false;
    }

    dashInit();
    return true;
  }

  void dashInit(
      {double? power, bool hasStaminaCost = true, bool aimAngle = false}) {
    if (hasStaminaCost) modifyStamina(-dashStaminaCost);
    if (power != null) {
      power *= 2;
    }
    power ??= 1;

    dashDistanceGoal = dashSpeed * power;
    isDashing = true;
    if (aimAngle) {
      if (this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).aimDelta;
      }
      if (dashDelta?.isZero() ?? true && this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).moveDelta;
      }
    } else {
      if (this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).moveDelta;
      }
      if (dashDelta?.isZero() ?? true && this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).aimDelta;
      }
    }

    dashDelta = dashDelta!.normalized();
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
    dashDelta = null;
    isDashing = false;
    dashedDistance = 0;
  }

  void dashMove(double dt) {
    final distance = ((dashSpeed / dashDuration) * dt);

    body.setTransform(body.position + (dashDelta! * distance), 0);
    dashedDistance += distance;
  }
}

mixin JumpFunctionality on StaminaFunctionality {
  //JUMP
  bool isJumping = false;
  bool isJumpingInvincible = false;
  double jumpDuration = .5;
  double jumpStaminaCost = 10;

  //how much of the jumpduration the character is jumping to avoid dmg
  double jumpingInvinciblePercent = .5;

  abstract SpriteAnimation? jumpAnimation;

  @override
  void jumpStatus() {
    if (!jumpCheck() || jumpAnimation == null) return;
    assert(!jumpAnimation!.loop, "Temp animations must not loop");
    tempAnimationPlaying = true;
    spriteAnimationComponent.animation = jumpAnimation?.clone();

    spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;
    super.jumpStatus();
  }

  void jump() {
    modifyStamina(-jumpStaminaCost);
    isJumping = true;
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

              return !(elapsed >= jumpDuration || controller.completed);
            })).then((_) {
      isJumping = false;
    });

    spriteWrapper.add(ScaleEffect.by(
      Vector2(1.025, 1.025),
      controller,
    ));
    spriteWrapper.add(MoveEffect.by(
      Vector2(0, -3),
      controller,
    ));
    backJoint.add(MoveEffect.by(
      Vector2(0, -3),
      controllerD,
    ));

    if (this is AimFunctionality) {
      (this as AimFunctionality).handJoint.add(MoveEffect.by(
            Vector2(0, -3),
            controllerD,
          ));
    }
  }

  bool jumpCheck() {
    if (isJumping ||
        getIsDashing ||
        disableMovement ||
        jumpStaminaCost > remainingStamina) return false;

    jump();

    return true;
  }
}

mixin AttributeFunctionality on Entity {
  Map<AttributeEnum, Attribute> currentAttributes = {};

  void loadPlayerConfig(Map<String, dynamic> config) {}
  bool initalized = false;

  ///Initial Attribtes and their initial level
  ///i.e. Max Speed : Level 3
  void initAttributes(Map<AttributeEnum, int> attributesToAdd) {
    if (initalized) return;
    for (var element in attributesToAdd.entries) {
      currentAttributes[element.key] =
          element.key.buildAttribute(element.value, this, true);
    }
    initalized = true;
  }

  void addRandomAttribute() {
    addAttribute(
        AttributeEnum.values[rng.nextInt(AttributeEnum.values.length)]);
  }

  void addAttribute(AttributeEnum attribute, [int level = 1]) {
    if (currentAttributes.containsKey(attribute)) {
      currentAttributes[attribute]?.incrementLevel(level);
    } else {
      currentAttributes[attribute] = attribute.buildAttribute(level, this);
    }
  }

  void clearAttributes() {
    for (var element in currentAttributes.entries) {
      element.value.removeAttribute();
    }
    currentAttributes.clear();
    initalized = false;
  }

  void removeAttribute(AttributeEnum attributeEnum) {
    if (currentAttributes.containsKey(attributeEnum)) {
      currentAttributes[attributeEnum]?.removeAttribute();
      currentAttributes.remove(attributeEnum);
    }
  }

  void modifyLevel(AttributeEnum attributeEnum, [int amount = 0]) {
    if (currentAttributes.containsKey(attributeEnum)) {
      var attr = currentAttributes[attributeEnum]!;
      attr.incrementLevel(amount);
    }
  }

  List<Attribute> buildAttributeSelection() {
    List<Attribute> returnList = [];

    for (var i = 0; i < 3; i++) {
      final attr =
          AttributeEnum.values[rng.nextInt(AttributeEnum.values.length)];
      if (currentAttributes.containsKey(attr)) {
        returnList.add(currentAttributes[attr]!);
      } else {
        returnList.add(attr.buildAttribute(1, this, false));
      }
    }
    return returnList;
  }
}
