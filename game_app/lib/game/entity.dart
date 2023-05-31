import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'dart:async' as async;
import 'package:game_app/game/games.dart';

import '../functions/vector_functions.dart';

enum EntityType { player, enemy }

abstract class Entity extends BodyComponent<GameplayGame> {
  Entity({
    required this.file,
    required Vector2 position,
  }) {
    initPosition = position;
  }

  abstract EntityType entityType;

  int targetsHomingEntity = 0;
  int maxTargetsHomingEntity = 5;

  double damageTaken = 0;
  String file;
  abstract double height;
  Map<String, async.Timer> hitSourceDuration = {};
  late Vector2 initPosition;
  abstract double invincibiltyDuration;
  abstract double maxHealth;
  abstract double maxSpeed;
  // late SpriteComponent spriteComponent;
  late SpriteAnimationComponent spriteAnimationComponent;

  late PositionComponent aimingAnglePosition;
  Vector2 lastAimingPosition = Vector2.zero();

  abstract Filter? filter;

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteAnimationComponent.size.x / 2;

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

  void aimCharacter({Vector2? delta}) {
    delta ??= body.linearVelocity.normalized().clone();

    aimingAnglePosition.angle = -radiansBetweenPoints(
      Vector2(0, 0.000001),
      delta,
    );
    //fix this
    aimingAnglePosition.position = delta.clone();

    lastAimingPosition = delta.clone();
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

    aimingAnglePosition =
        PositionComponent(anchor: Anchor.center, size: Vector2.zero());

    add(spriteAnimationComponent);
    add(aimingAnglePosition);
    spriteAnimationComponent.flipHorizontallyAroundCenter();

    // aimingAnglePosition.mounted.whenComplete(
    //   () => aimingAnglePosition
    //       .addAll([CircleComponent(radius: .5, anchor: Anchor.center)]),
    // );

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {}

  void moveCharacter({Vector2? delta}) {
    if (delta == null || delta.isZero()) {
      if (hitTimerSprite != null) return;
      currentAnimation.frames = idleAnimationSprites;
      spriteAnimationComponent.animation = currentAnimation;
      return;
    }
    body.applyForce(delta * maxSpeed);
    if (hitTimerSprite != null) return;

    currentAnimation.frames = runAnimationSprites;
    spriteAnimationComponent.animation = currentAnimation;
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      onDeath();
    }

    aimCharacter();
    flipSpriteCheck();

    super.update(dt);
  }

  double get health => maxHealth - damageTaken;
  bool get isDead => damageTaken >= maxHealth;
  TimerComponent? invincibleTimer;
  bool flipped = false;

  void flipSpriteCheck({List<PositionComponent>? componentsToFlip}) {
    final degree = -degrees(aimingAnglePosition.angle);
    if ((degree < 180 && !flipped) || (degree >= 180 && flipped)) {
      if (componentsToFlip != null) {
        componentsToFlip.map((e) => e.flipHorizontallyAroundCenter());
      }
      spriteAnimationComponent.flipHorizontallyAroundCenter();
      aimingAnglePosition.flipHorizontallyAroundCenter();
      flipped = !flipped;
    }
  }

  int sameDamageSourceTimer = 1;

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
      Colors.blue,
      const Offset(0.0, 1),
      controller,
    ));
    hitSourceDuration[id] =
        async.Timer(Duration(seconds: sameDamageSourceTimer), () {
      hitSourceDuration.remove(id);
    });
    damageTaken += damage;

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
    return true;
  }

  TimerComponent? hitTimerSprite;

  Future<void> onDeath();
}
