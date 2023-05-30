import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
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
  double durationSinceHit = 0;
  String file;
  abstract double height;
  Map<String, double> hitSourceDuration = {};
  late Vector2 initPosition;
  abstract double invincibiltyDuration;
  abstract double maxHealth;
  abstract double maxSpeed;
  late SpriteComponent spriteComponent;

  late PositionComponent aimingAnglePosition;
  Vector2 lastAimingPosition = Vector2.zero();

  abstract Filter? filter;

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteComponent.size.x / 2;

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

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load(file);
    aimingAnglePosition =
        PositionComponent(anchor: Anchor.center, size: Vector2.zero());

    spriteComponent = SpriteComponent(
        sprite: sprite,
        priority: -200,
        size: sprite.srcSize.scaled(height / sprite.srcSize.y),
        anchor: Anchor.center);
    add(spriteComponent);
    add(aimingAnglePosition);

    aimingAnglePosition.mounted.whenComplete(
      () => aimingAnglePosition
          .addAll([CircleComponent(radius: .5, anchor: Anchor.center)]),
    );

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {}

  void moveCharacter({Vector2? delta}) {
    if (delta == null) return;
    body.applyForce(delta * maxSpeed);
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      onDeath();
    }

    aimCharacter();
    moveCharacter();

    hitSourceDuration.updateAll((key, value) => value += dt);

    hitSourceDuration.removeWhere(
      (key, value) => value > 1,
    );

    if (durationSinceHit <= invincibiltyDuration) {
      durationSinceHit += dt;
    }

    flipSpriteCheck();

    super.update(dt);
  }

  double get health => maxHealth - damageTaken;
  bool get isDead => damageTaken >= maxHealth;
  bool get isInvincible => durationSinceHit < invincibiltyDuration;
  bool flipped = false;

  void flipSpriteCheck({List<PositionComponent>? componentsToFlip}) {
    final degree = -degrees(aimingAnglePosition.angle);
    if ((degree < 180 && !flipped) || (degree >= 180 && flipped)) {
      if (componentsToFlip != null) {
        componentsToFlip.map((e) => e.flipHorizontallyAroundCenter());
      }
      spriteComponent.flipHorizontallyAroundCenter();
      aimingAnglePosition.flipHorizontallyAroundCenter();
      flipped = !flipped;
    }
  }

  bool takeDamage(String id, double damage) {
    if (hitSourceDuration.containsKey(id) || isInvincible) return false;
    final controller = EffectController(
      duration: .1,
      reverseDuration: .1,
    );
    spriteComponent.add(SizeEffect.by(Vector2.all(.5), controller));
    spriteComponent.add(ColorEffect(
      Colors.blue,
      const Offset(0.0, 1),
      controller,
    ));
    hitSourceDuration[id] = 0.0;
    damageTaken += damage;
    durationSinceHit = 0;
    return true;
  }

  Future<void> onDeath();
}
