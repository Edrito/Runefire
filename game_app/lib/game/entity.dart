import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/enemies.dart';
import 'dart:async' as async;
import 'package:game_app/game/main_game.dart';
import 'package:game_app/game/powerups.dart';
import 'package:game_app/game/weapons/weapon_class.dart';
import 'package:game_app/main.dart';

import '../functions/custom_mixins.dart';
import '../functions/vector_functions.dart';

enum EntityType { player, enemy }

abstract class Entity extends BodyComponent<GameRouter> {
  Entity(
      {required this.file,
      required this.initPosition,
      required this.id,
      required this.ancestor});

  abstract EntityType entityType;

  double jumpingInvinciblePercent = .5;
  bool isJumping = false;
  bool isJumpingInvincible = false;
  double jumpDuration = .5;
  Vector2 initPosition;
  String id;
  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;
  Map<int, Powerup> currentPowerups = {};
  MainGame ancestor;

  double damageTaken = 0;
  String file;
  abstract double height;
  Map<String, async.Timer> hitSourceDuration = {};
  abstract double invincibiltyDuration;
  abstract double maxHealth;
  Weapon? currentWeapon;
  Map<int, Weapon> carriedWeapons = {};

  List<Function> initialWeapons = [];

  abstract double maxSpeed;
  // late SpriteComponent spriteComponent;
  late SpriteAnimationComponent spriteAnimationComponent;

  late PlayerAttachmentJointComponent mouseJoint;
  late PlayerAttachmentJointComponent handJoint;
  late PlayerAttachmentJointComponent backJoint;

  Vector2 lastAimingPosition = Vector2.zero();
  abstract Filter? filter;

  @override
  void onRemove() {
    if (this is Enemy) {
      carriedWeapons.forEach((key, value) => value.removeFromParent());
    }
    if (!gameRef.router.currentRoute.maintainState) {
      super.onRemove();
    }
  }

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteAnimationComponent.size.x / 2;
    renderBody = false;
    final fixtureDef = FixtureDef(shape,
        restitution: 0, friction: 0, density: 0.02, filter: filter);

    final bodyDef = BodyDef(
      userData: this,
      position: initPosition,
      type: BodyType.dynamic,
      linearDamping: 12,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  void aimCharacter() {
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

  double animationSpeed = .2;
  List<SpriteAnimationFrame> runAnimationSprites = [];
  List<SpriteAnimationFrame> idleAnimationSprites = [];
  late Sprite hitSprite;
  late SpriteAnimation currentAnimation;
  @override
  Future<void> onLoad() async {
    runAnimationSprites = [
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_run_anim_f0.png"),
          animationSpeed),
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_run_anim_f1.png"),
          animationSpeed),
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_run_anim_f2.png"),
          animationSpeed),
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_run_anim_f3.png"),
          animationSpeed),
    ];
    idleAnimationSprites = [
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_idle_anim_f0.png"),
          animationSpeed),
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_idle_anim_f1.png"),
          animationSpeed),
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_idle_anim_f2.png"),
          animationSpeed),
      SpriteAnimationFrame(
          await Sprite.load("characters/wizzard_f_idle_anim_f3.png"),
          animationSpeed),
    ];
    hitSprite = await Sprite.load("characters/wizzard_f_hit_anim_f0.png");
    currentAnimation = SpriteAnimation(idleAnimationSprites, loop: true);

    spriteAnimationComponent = SpriteAnimationComponent(
        animation: currentAnimation,
        priority: -200,
        size: currentAnimation.frames.first.sprite.srcSize
            .scaled(height / currentAnimation.frames.first.sprite.srcSize.y),
        anchor: Anchor.center);

    handJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.hand,
        anchor: Anchor.center, size: Vector2.zero());
    backJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.back,
        anchor: Anchor.center, size: Vector2.zero(), priority: -250);
    mouseJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.mouse,
        anchor: Anchor.center, size: Vector2.zero(), priority: -250);

    spriteAnimationComponent.flipHorizontallyAroundCenter();
    add(spriteAnimationComponent);
    add(backJoint);
    add(handJoint);
    add(mouseJoint);

    initializeWeapons();
    await setWeapon(carriedWeapons.entries.first.value);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      onDeath();
    }
    moveCharacter();
    dashCheck();
    aimCharacter();
    flipSpriteCheck();

    super.update(dt);
  }

  Map<InputType, Vector2?> moveVelocities = {};

  void moveCharacter() {
    final previousPulse = moveDelta;

    if (previousPulse.isZero()) {
      if (hitTimerSprite != null) return;
      currentAnimation.frames = idleAnimationSprites;
      spriteAnimationComponent.animation = currentAnimation;
      return;
    }

    body.applyForce(previousPulse * maxSpeed);

    if (hitTimerSprite != null) return;
    currentAnimation.frames = runAnimationSprites;
    spriteAnimationComponent.animation = currentAnimation;
  }

  double get health => maxHealth - damageTaken;
  bool get isDead => damageTaken >= maxHealth;
  TimerComponent? invincibleTimer;
  bool flipped = false;

  void flipSpriteCheck() {
    final degree = -degrees(handJoint.angle);
    if ((degree < 180 && !flipped) || (degree >= 180 && flipped)) {
      // if (!(handJoint.weaponClass?.attackTypes.contains(AttackType.melee) ??
      //     true)) {
      // }
      handJoint.flipHorizontallyAroundCenter();

      spriteAnimationComponent.flipHorizontallyAroundCenter();
      flipped = !flipped;
    }
  }

  int sameDamageSourceTimer = 1;

  Vector2 get moveDelta => (moveVelocities[InputType.moveJoy] ??
          moveVelocities[InputType.keyboard] ??
          moveVelocities[InputType.ai] ??
          Vector2.zero())
      .normalized();
  Vector2 get aimDelta => (inputAimAngles[InputType.aimJoy] ??
      inputAimAngles[InputType.tapClick] ??
      inputAimAngles[InputType.mouseDrag] ??
      inputAimAngles[InputType.mouseMove] ??
      moveDelta);

  Map<InputType, Vector2> inputAimAngles = {};
  Map<InputType, Vector2> inputAimPositions = {};

  bool takeDamage(String id, double damage) {
    if (hitSourceDuration.containsKey(id) || invincibleTimer != null) {
      return false;
    }
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
    if (invincibiltyDuration > 0) {
      invincibleTimer = TimerComponent(
        period: invincibiltyDuration,
        removeOnFinish: true,
        onTick: () => invincibleTimer = null,
      );
      add(invincibleTimer!);
    }
    spriteAnimationComponent.animation =
        SpriteAnimation([SpriteAnimationFrame(hitSprite, 1)]);
    hitTimerSprite = TimerComponent(
      period: .1,
      onTick: () => hitTimerSprite = null,
    );
    add(hitTimerSprite!);
    damageTaken += damage;
    final test = TextPaint(
        style: TextStyle(
      fontSize: 5,
      shadows: const [
        BoxShadow(
            color: Colors.black,
            offset: Offset(.3, .3),
            spreadRadius: 3,
            blurRadius: 3)
      ],
      color: Colors.red.shade100,
    ));

    final damageText = CaTextComponent(
      text: damage.round().toString(),
      anchor: Anchor.bottomLeft,
      textRenderer: test,
      position: (Vector2.random() * 2) - Vector2.all(1),
    );

    damageText.addAll([
      OpacityEffect.fadeIn(EffectController(
        duration: .2,
      )),
      MoveEffect.by(
        Vector2(0, -5),
        EffectController(
          duration: 1,
        ),
        onComplete: () {
          damageText.add(OpacityEffect.fadeOut(EffectController(
            duration: .2,
            onMax: () => damageText.removeFromParent(),
          )));

          damageText.removeFromParent();
        },
      ),
    ]);
    add(damageText);
    return true;
  }

  TimerComponent? hitTimerSprite;

  Future<void> onDeath();

  Future<void> initializeWeapons() async {
    int i = 0;
    for (var element in initialWeapons) {
      carriedWeapons[i] = element.call(this);
      i++;
    }
    initialWeapons.clear();
  }

  bool isAttacking = false;

  void endAttacking() {
    isAttacking = false;
    currentWeapon?.endAttacking();
  }

  Future<void> setWeapon(Weapon weapon) async {
    await handJoint.loaded.whenComplete(() => handJoint.addWeaponClass(weapon));
    await mouseJoint.loaded
        .whenComplete(() => mouseJoint.addWeaponClass(weapon));
    await backJoint.loaded.whenComplete(() => backJoint.addWeaponClass(weapon));
    currentWeapon = weapon;
  }

  void startAttacking() async {
    isAttacking = true;
    currentWeapon?.startAttacking();
  }

  void swapWeapon() async {
    if (isAttacking) {
      currentWeapon?.endAttacking();
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
  }

  void jump() {
    if (isJumping) return;

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
    Future.doWhile(
        () => Future.delayed(const Duration(milliseconds: 25)).then((value) {
              elapsed += .025;

              isJumpingInvincible = elapsed > min && elapsed < max;

              return !(elapsed >= jumpDuration || controller.completed);
            })).then((_) {
      isJumping = false;
    });

    spriteAnimationComponent.add(ScaleEffect.by(
      Vector2(1.035, 1.035),
      controller,
    ));
    spriteAnimationComponent.add(MoveEffect.by(
      Vector2(0, -1.9),
      controller,
    ));
    backJoint.add(MoveEffect.by(
      Vector2(0, -1.9),
      controller,
    ));
    handJoint.add(MoveEffect.by(
      Vector2(0, -1.9),
      controller,
    ));
  }

  abstract double dashCooldown;

  TimerComponent? dashTimerCooldown;
  double dashTimerIterationLength = .01;
  bool isDashing = false;
  Vector2? dashVelocity;

  void dashCheck() {
    if (isDashing && dashVelocity != null) {
      body.applyForce(dashVelocity!);
    }
  }

  void dash() {
    if (dashTimerCooldown != null) return;
    isDashing = true;
    double elapsed = 0;
    dashVelocity = moveDelta;
    if (dashVelocity?.isZero() ?? true) {
      dashVelocity = aimDelta;
    }
    dashVelocity = dashVelocity!.normalized() * 5000;
    dashTimerCooldown = TimerComponent(
      period: dashTimerIterationLength,
      removeOnFinish: true,
      repeat: true,
      onTick: () {
        if (elapsed > dashCooldown) {
          dashTimerCooldown?.timer.stop();
          dashTimerCooldown?.removeFromParent();
          dashTimerCooldown = null;
        } else if (isDashing && elapsed > .07) {
          dashVelocity = null;
          isDashing = false;
        }
        elapsed += dashTimerIterationLength;
      },
    );

    add(dashTimerCooldown!);
  }
}
