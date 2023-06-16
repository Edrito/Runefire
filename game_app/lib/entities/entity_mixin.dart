import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/functions/custom_mixins.dart';
import 'dart:async' as async;

import '../functions/vector_functions.dart';
import '../game/powerups.dart';
import '../resources/attributes.dart';
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

  bool disableMovement = false;
}

mixin MovementFunctionality on Entity {
  //MOVEMENT
  abstract final double baseSpeed;
  double speedIncreasePercent = 1;
  double get getMaxSpeed => baseSpeed * speedIncreasePercent;
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

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }
}

mixin AimFunctionality on Entity {
  Vector2 get aimDelta => (inputAimAngles[InputType.aimJoy] ??
      inputAimAngles[InputType.tapClick] ??
      inputAimAngles[InputType.mouseDrag] ??
      inputAimAngles[InputType.mouseMove] ??
      inputAimAngles[InputType.ai] ??
      ((this is MovementFunctionality)
          ? (this as MovementFunctionality).moveDelta
          : Vector2.zero()));

  Map<InputType, Vector2> inputAimAngles = {};
  Map<InputType, Vector2> inputAimPositions = {};
  late PlayerAttachmentJointComponent mouseJoint;
  late PlayerAttachmentJointComponent handJoint;

  @override
  async.Future<void> onLoad() {
    handJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.hand,
        anchor: Anchor.center, size: Vector2.zero());
    mouseJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.mouse,
        anchor: Anchor.center, size: Vector2.zero(), priority: 0);
    add(handJoint);
    add(mouseJoint);
    return super.onLoad();
  }

  @override
  void flipSpriteCheck() {
    final degree = -degrees(handJoint.angle);
    if ((degree < 180 && !flipped) || (degree >= 180 && flipped)) {
      // if (!(handJoint.weaponClass?.attackTypes.contains(AttackType.melee) ??
      //     true)) {
      // }
      shadow3DDecorator.xShift = 250 * (flipped ? 1 : -1);
      handJoint.flipHorizontallyAroundCenter();

      spriteWrapper.flipHorizontallyAroundCenter();
      flipped = !flipped;
    }
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

  Future<void> initializeWeapons() async {
    int i = 0;
    for (var element in initialWeapons) {
      carriedWeapons[i] = element.build(this, null, 0);
      i++;
    }
    initialWeapons.clear();
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

    initializeWeapons();
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

mixin HealthFunctionality on Entity {
  //health
  abstract double baseInvincibilityDuration;
  double invincibilityDurationFlatIncrease = 0;
  double get invincibilityDuration =>
      baseInvincibilityDuration + invincibilityDurationFlatIncrease;
  TimerComponent? invincibleTimer;
  abstract final double baseHealth;

  double healthFlatIncrease = 0;
  double get getMaxHealth => baseHealth + healthFlatIncrease;

  int sameDamageSourceTimer = 1;

  double get health => getMaxHealth - damageTaken;
  bool get isDead => damageTaken >= getMaxHealth;

  double damageTaken = 0;
  double recentDamage = 0;

  //HEALTH
  CaTextComponent? damageText;
  Map<int, async.Timer> hitSourceDuration = {};
  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;
  abstract SpriteAnimation? deathAnimation;
  abstract SpriteAnimation? damageAnimation;

  Future<void> onDeath() async {
    setEntityStatus(EntityStatus.dead);
  }

  void processDamage(int id, double damage) {
    setEntityStatus(EntityStatus.damage);
    final controller = EffectController(
      duration: .1,
      reverseDuration: .1,
    );
    spriteAnimationComponent.add(SizeEffect.by(Vector2.all(.5), controller));
    spriteAnimationComponent.add(ColorEffect(
      Colors.red,
      const Offset(0.0, 1),
      controller,
    ));
    hitSourceDuration[id] =
        async.Timer(Duration(seconds: sameDamageSourceTimer), () {
      hitSourceDuration.remove(id);
    });
    if (invincibilityDuration > 0) {
      invincibleTimer = TimerComponent(
        period: invincibilityDuration,
        removeOnFinish: true,
        onTick: () => invincibleTimer = null,
      );
      add(invincibleTimer!);
    }
    damageTaken += damage;
    recentDamage += damage;
    if (health <= 0) {
      onDeath();
    }
    final test = TextPaint(
        style: TextStyle(
      fontSize: 2,
      shadows: const [
        BoxShadow(
            color: Colors.black,
            offset: Offset(.3, .3),
            spreadRadius: 3,
            blurRadius: 3)
      ],
      color: Colors.red.shade100,
    ));
    if (damageText == null) {
      damageText = CaTextComponent(
        text: recentDamage.round().toString(),
        anchor: Anchor.bottomLeft,
        textRenderer: test,
        position: Vector2.random() + Vector2(1, -1),
      );
      damageText?.addAll([
        OpacityEffect.fadeIn(EffectController(
          duration: .2,
        )),
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

      damageText!.textRenderer = (damageText!.textRenderer as TextPaint)
          .copyWith((p0) => p0.copyWith(
              color: p0.color!
                  .withBlue((p0.color!.blue * .9).round().clamp(0, 255))
                  .withGreen((p0.color!.green * .9).round().clamp(0, 255))));

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

    damageText?.addAll([
      OpacityEffect.fadeIn(EffectController(
        duration: .2,
      )),
    ]);
  }

  bool takeDamage(int id, double damage) {
    if (hitSourceDuration.containsKey(id) ||
        invincibleTimer != null ||
        isDead) {
      return false;
    }
    processDamage(id, damage);
    return true;
  }
}

mixin DashFunctionality on Entity {
  abstract SpriteAnimation? dashAnimation;

  //DASH
  abstract double dashCooldown;
  TimerComponent? dashTimerCooldown;
  double dashedDistance = 0;
  bool isDashing = false;
  Vector2? dashDelta;
  double dashSpeed = 15;
  double dashDuration = .2;

  bool dash() {
    if (dashTimerCooldown != null || getIsJumping || disableMovement) {
      return false;
    }
    isDashing = true;
    if (this is MovementFunctionality) {
      dashDelta = (this as MovementFunctionality).moveDelta;
    }
    if (dashDelta?.isZero() ?? true && this is AimFunctionality) {
      dashDelta = (this as AimFunctionality).aimDelta;
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
    return true;
  }

  @override
  void update(double dt) {
    dashCheck(dt);
    super.update(dt);
  }

  void dashCheck(double dt) {
    if (isDashing && dashDelta != null) {
      if (dashedDistance > dashSpeed) {
        dashDelta = null;
        isDashing = false;
        dashedDistance = 0;
        return;
      }

      final distance = ((dashSpeed / dashDuration) * dt);

      body.setTransform(body.position + (dashDelta! * distance), 0);
      dashedDistance += distance;
    }
  }
}

mixin JumpFunctionality on Entity {
  //JUMP
  bool isJumping = false;
  bool isJumpingInvincible = false;
  double jumpDuration = .5;

  //how much of the jumpduration the character is jumping to avoid dmg
  double jumpingInvinciblePercent = .5;

  abstract SpriteAnimation? jumpAnimation;

  bool jump() {
    if (isJumping || getIsDashing || disableMovement) return false;

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

    return true;
  }
}

mixin AttributeFunctionality on Entity {
  Map<AttributeEnum, Attribute> attributes = {};

  void loadPlayerConfig(Map<String, dynamic> config) {}

  void addAttributes(Map<AttributeEnum, int> attributesToAdd) {
    for (var element in attributesToAdd.entries) {
      final attrib = element.key.buildAttribute(element.value, this);
      attributes[element.key] = attrib;
      attrib.applyAttribute();
    }
  }

  void clearAttributes() {
    for (var element in attributes.entries) {
      element.value.removeAttribute();
    }
    attributes.clear();
  }

  void removeAttribute(AttributeEnum attributeEnum) {
    if (attributes.containsKey(attributeEnum)) {
      attributes[attributeEnum]!.removeAttribute();
      attributes.remove(attributeEnum);
    }
  }

  void modifyLevel(AttributeEnum attributeEnum, [int amount = 1]) {
    if (attributes.containsKey(attributeEnum)) {
      var attr = attributes[attributeEnum]!;
      attr.incrementLevel(amount);
    }
  }
}
