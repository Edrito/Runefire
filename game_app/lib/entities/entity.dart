import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/rendering.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/enemies.dart';
import 'dart:async' as async;
import 'package:game_app/game/powerups.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/main.dart';

import '../functions/custom_mixins.dart';
import '../functions/vector_functions.dart';
import '../resources/classes.dart';
import '../resources/enums.dart';

abstract class Entity extends BodyComponent<GameRouter> {
  Entity({required this.initPosition, required this.ancestor});

  abstract EntityType entityType;

  double jumpingInvinciblePercent = .5;
  bool isJumping = false;
  bool isJumpingInvincible = false;
  double jumpDuration = .5;
  Vector2 initPosition;
  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;
  Map<int, Powerup> currentPowerups = {};
  GameEnviroment ancestor;
  bool disableMovement = false;

  double damageTaken = 0;
  abstract double height;
  Map<String, async.Timer> hitSourceDuration = {};
  abstract double invincibiltyDuration;
  abstract double maxHealth;
  Weapon? currentWeapon;
  Map<int, Weapon> carriedWeapons = {};

  List<Function(int, Entity)> initialWeapons = [];

  abstract double maxSpeed;

  abstract SpriteAnimation idleAnimation;
  abstract SpriteAnimation? walkAnimation;
  abstract SpriteAnimation? runAnimation;
  abstract SpriteAnimation? deathAnimation;
  abstract SpriteAnimation? jumpAnimation;
  abstract SpriteAnimation? spawnAnimation;
  abstract SpriteAnimation? dashAnimation;
  abstract SpriteAnimation? damageAnimation;

  SpriteAnimation? animationQueue;
  EntityStatus? statusQueue;
  bool tempAnimationPlaying = false;

  late SpriteAnimationComponent spriteAnimationComponent;

  late PlayerAttachmentJointComponent mouseJoint;
  late PlayerAttachmentJointComponent handJoint;
  late PlayerAttachmentJointComponent backJoint;

  Vector2 lastAimingPosition = Vector2.zero();
  abstract Filter? filter;
  EntityStatus entityStatus = EntityStatus.spawn;

  Future<void> loadAnimationSprites();

  void tickerComplete() {
    tempAnimationPlaying = false;
    entityStatus = statusQueue ?? entityStatus;
    spriteAnimationComponent.animation = animationQueue;
  }

  void setEntityStatus(EntityStatus newEntityStatus,
      [SpriteAnimation? attackAnimation]) {
    SpriteAnimation? animation;
    if (newEntityStatus == EntityStatus.spawn) {
      animation = spawnAnimation ?? idleAnimation;
      spriteAnimationComponent = SpriteAnimationComponent(
        priority: 0,
        animation: animation,
        size: animation.frames.first.sprite.srcSize
            .scaled(height / animation.frames.first.sprite.srcSize.y),
      );
      entityStatus = newEntityStatus;
      return;
    }

    if (newEntityStatus == entityStatus &&
        [EntityStatus.run, EntityStatus.walk, EntityStatus.idle]
            .contains(newEntityStatus)) return;

    switch (newEntityStatus) {
      case EntityStatus.spawn:
        if (spawnAnimation == null) break;
        assert(!spawnAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = spawnAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.attack:
        if (attackAnimation == null) break;
        assert(!attackAnimation.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = attackAnimation.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;

      case EntityStatus.jump:
        if (!_jump() || jumpAnimation == null) break;
        assert(!jumpAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = jumpAnimation?.clone();

        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.dash:
        if (!_dash() || dashAnimation == null) break;
        assert(!dashAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = dashAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.dead:
        endAttacking();
        disableMovement = true;
        if (deathAnimation == null) {
          spriteAnimationComponent.add(OpacityEffect.fadeOut(
            EffectController(
              duration: .5,
            ),
            onComplete: () {
              removeFromParent();
            },
          ));
          break;
        }
        tempAnimationPlaying = true;
        assert(!deathAnimation!.loop, "Temp animations must not loop");
        spriteAnimationComponent.animation = deathAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;
        spriteAnimationComponent.add(OpacityEffect.fadeOut(
          EffectController(
            duration: spriteAnimationComponent.animationTicker?.totalDuration(),
          ),
          onComplete: () {
            removeFromParent();
          },
        ));

        break;
      case EntityStatus.damage:
        if (damageAnimation == null) break;
        assert(!damageAnimation!.loop, "Temp animations must not loop");
        tempAnimationPlaying = true;
        spriteAnimationComponent.animation = damageAnimation?.clone();
        spriteAnimationComponent.animationTicker?.onComplete = tickerComplete;

        break;
      case EntityStatus.idle:
        animation = idleAnimation;

        break;
      case EntityStatus.run:
        animation = runAnimation;

        break;
      case EntityStatus.walk:
        animation = walkAnimation;

        break;
      default:
        animation = idleAnimation;
    }
    animation ??= idleAnimation;

    if (tempAnimationPlaying) {
      statusQueue = newEntityStatus;
      animationQueue = animation;
    } else {
      entityStatus = newEntityStatus;
      spriteAnimationComponent.animation = animation;
    }
  }

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
        restitution: 0, friction: 0, density: 0.0, filter: filter);

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

  @override
  Future<void> onLoad() async {
    setEntityStatus(EntityStatus.spawn);
    handJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.hand,
        anchor: Anchor.center, size: Vector2.zero());
    backJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.back,
        anchor: Anchor.center, size: Vector2.zero(), priority: -1);
    mouseJoint = PlayerAttachmentJointComponent(WeaponSpritePosition.mouse,
        anchor: Anchor.center, size: Vector2.zero(), priority: 0);
    priority = 0;
    shadow3DDecorator = Shadow3DDecorator(
        base: spriteAnimationComponent.size,
        angle: 1.4,
        xShift: 250,
        yScale: 1.5,
        opacity: .5,
        blur: .5)
      ..base.y += -3
      ..base.x -= 1;

    spriteAnimationComponent.decorator = shadow3DDecorator;
    spriteWrapper = PositionComponent(
        priority: 0,
        size: spriteAnimationComponent.size,
        anchor: Anchor.center);
    spriteWrapper.flipHorizontallyAroundCenter();
    add(spriteWrapper..add(spriteAnimationComponent));
    add(backJoint);
    add(handJoint);
    add(mouseJoint);

    initializeWeapons();
    await setWeapon(carriedWeapons.entries.first.value);

    return super.onLoad();
  }

  late PositionComponent spriteWrapper;
  late Shadow3DDecorator shadow3DDecorator;

  @override
  void update(double dt) {
    moveCharacter();
    dashCheck();
    aimCharacter();
    flipSpriteCheck();

    super.update(dt);
  }

  Map<InputType, Vector2?> moveVelocities = {};

  void moveCharacter() {
    final previousPulse = moveDelta;

    if (disableMovement || previousPulse.isZero()) {
      setEntityStatus(EntityStatus.idle);
      return;
    }

    body.applyForce(previousPulse * maxSpeed);
    setEntityStatus(EntityStatus.run);
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
      shadow3DDecorator.xShift = 250 * (flipped ? 1 : -1);
      handJoint.flipHorizontallyAroundCenter();

      spriteWrapper.flipHorizontallyAroundCenter();
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
    if (hitSourceDuration.containsKey(id) ||
        invincibleTimer != null ||
        isDead) {
      return false;
    }
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
    if (invincibiltyDuration > 0) {
      invincibleTimer = TimerComponent(
        period: invincibiltyDuration,
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
    if (damageText == null) {
      damageText = CaTextComponent(
        text: recentDamage.round().toString(),
        anchor: Anchor.bottomLeft,
        textRenderer: test,
        position: (Vector2.random() * 2) - Vector2.all(1),
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
    return true;
  }

  double recentDamage = 0;
  CaTextComponent? damageText;

  Future<void> onDeath() async {
    setEntityStatus(EntityStatus.dead);
  }

  Future<void> initializeWeapons() async {
    int i = 0;
    for (var element in initialWeapons) {
      carriedWeapons[i] = element.call(0, this);
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

  bool _jump() {
    if (isJumping || isDashing || disableMovement) return false;

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
    handJoint.add(MoveEffect.by(
      Vector2(0, -3),
      controllerD,
    ));
    return true;
  }

  abstract double dashCooldown;

  TimerComponent? dashTimerCooldown;
  double dashTimerIterationLength = .01;
  double dashDuration = .08;
  bool isDashing = false;
  Vector2? dashVelocity;

  void dashCheck() {
    if (isDashing && dashVelocity != null) {
      body.applyForce(dashVelocity!);
    }
  }

  bool _dash() {
    if (dashTimerCooldown != null || isJumping || disableMovement) return false;
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
        } else if (isDashing && elapsed > dashDuration) {
          dashVelocity = null;
          isDashing = false;
        }
        elapsed += dashTimerIterationLength;
      },
    );
    final effect = RotateEffect.by(
      radians(360),
      EffectController(
        duration: dashDuration * 4,
      ),
    );
    spriteAnimationComponent.add(effect);
    add(dashTimerCooldown!);
    return true;
  }
}
