import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/animation.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:uuid/uuid.dart';

import '../entities/entity.dart';
import '../main.dart';

class AreaEffect extends BodyComponent<GameRouter> with ContactCallbacks {
  AreaEffect({
    this.spawnAnimation,
    this.playAnimation,
    this.endAnimation,
    this.isInstant = true,
    this.duration = 5,
    this.tickRate = 1,
    this.radius = 3,
    required this.onTick,
    required this.position,
    required this.sourceEntity,
    this.isSolid = false,
  }) {
    spriteAnimationComponent = SpriteAnimationComponent(
      animation: spawnAnimation,
      size: Vector2.all(radius * 2),
    );

    areaId = const Uuid().v4();
  }

  SpriteAnimation? spawnAnimation;
  SpriteAnimation? playAnimation;
  SpriteAnimation? endAnimation;
  bool isInstant;
  double duration;
  late String areaId;
  double tickRate;
  double radius;
  Function(Entity, String) onTick;
  Vector2 position;
  Entity sourceEntity;
  bool isSolid;
  late TimerComponent aliveTimer;

  late SpriteAnimationComponent spriteAnimationComponent;
  late CircleComponent circleComponent;

  Map<Entity, TimerComponent> affectedEntities = {};
  bool isKilled = false;

  @override
  Future<void> onLoad() {
    add(spriteAnimationComponent);
    if (!isInstant) {
      spriteAnimationComponent.animationTicker?.onComplete = () {
        spriteAnimationComponent.animation = playAnimation;
      };
      aliveTimer = TimerComponent(
        period: duration,
        removeOnFinish: true,
        repeat: false,
        onTick: () {
          killArea();
        },
      )..addToParent(this);
    }
    circleComponent = CircleComponent(
        radius: radius,
        anchor: Anchor.center,
        paint: BasicPalette.red.withAlpha(100).paint());
    add(circleComponent);
    return super.onLoad();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Entity) return;
    if (other == sourceEntity) return;
    if (affectedEntities.containsKey(other)) return;
    if (isInstant) {
      doOnTick(other);
    } else {
      affectedEntities[other] = TimerComponent(
          period: tickRate,
          repeat: true,
          onTick: () {
            doOnTick(other);
          })
        ..addToParent(this)
        ..onTick();
    }

    super.beginContact(other, contact);
  }

  bool aliveForOneTick = false;

  void doOnTick(Entity entity) {
    if (isKilled) return;
    onTick(entity, areaId);
  }

  void instantChecker() {
    if (!isKilled && isInstant && body.isActive) {
      if (aliveForOneTick) {
        killArea();
      }
      aliveForOneTick = true;
    }
  }

  @override
  void update(double dt) {
    instantChecker();
    super.update(dt);
  }

  void killArea() {
    isKilled = true;
    affectedEntities.clear();
    if (endAnimation != null) {
      spriteAnimationComponent.animation = endAnimation;
      spriteAnimationComponent.animationTicker?.onComplete = () {
        removeFromParent();
      };
    } else {
      circleComponent.add(OpacityEffect.fadeOut(EffectController(
        curve: Curves.easeInCubic,
        duration: 1,
        onMax: () {
          removeFromParent();
        },
      )));
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Entity) return;
    if (isInstant) return;
    affectedEntities[other]?.removeFromParent();
    affectedEntities.remove(other);

    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    priority = -100;
    late CircleShape shape;

    shape = CircleShape();
    // shape.position.setFrom(h-Vector2.all(radius / 2));
    shape.radius = radius;
    renderBody = false;
    final filter = Filter();
    filter.categoryBits = attackCategory;
    if (sourceEntity.isPlayer) {
      filter.maskBits = enemyCategory;
    } else {
      filter.maskBits = playerCategory;
    }
    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: !isSolid,
        filter: filter);
    final bodyDef = BodyDef(
      position: position,
      userData: this,
      type: BodyType.static,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
