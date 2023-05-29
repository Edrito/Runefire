import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/games.dart';

enum EntityType { player, enemy }

abstract class Entity extends BodyComponent<GameplayGame> {
  Entity({
    required this.file,
    required this.entityType,
    required Vector2 position,
  }) {
    initPosition = position;
  }

  EntityType entityType;

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

  abstract Filter? filter;

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = spriteComponent.size.x / 2;
    // shape.set([
    //   Vector2(-spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
    //   Vector2(spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
    //   Vector2(spriteComponent.size.x / 2, spriteComponent.size.y / 2),
    //   Vector2(-spriteComponent.size.x / 2, spriteComponent.size.y / 2),
    // ]);

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

  @override
  Future<void> onLoad() async {
    final sprite = await Sprite.load(file);
    spriteComponent = SpriteComponent(
        sprite: sprite,
        priority: -200,
        size: sprite.srcSize.scaled(height / sprite.srcSize.y),
        anchor: Anchor.center);
    add(spriteComponent);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {
    if (health <= 0) {
      onDeath();
    }
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

  void flipSpriteCheck() {
    if (body.linearVelocity.x > 0 && !spriteComponent.isFlippedHorizontally) {
      spriteComponent.flipHorizontallyAroundCenter();
    } else if (body.linearVelocity.x <= 0 &&
        spriteComponent.isFlippedHorizontally) {
      spriteComponent.flipHorizontallyAroundCenter();
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
