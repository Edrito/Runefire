import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:uuid/uuid.dart';

import '../entities/entity_class.dart';
import '../main.dart';
import '../resources/data_classes/base.dart';

enum DurationType { instant, temporary, permanent }

class AreaEffect extends BodyComponent<GameRouter> with ContactCallbacks {
  ///Use [damage] if you want to deal damage to entities in the area
  ///Declare a custom [areaId] if you are making multiple areas and want
  ///to prevent enemies getting super spammed with deeps
  AreaEffect({
    this.animationComponent,
    this.radius = 3,
    this.duration = 5,
    this.durationType = DurationType.instant,
    this.collisionDelay = .3,
    String? areaId,
    this.tickRate = 1,
    this.damage,
    this.onTick,
    required this.position,
    required this.sourceEntity,
    this.isSolid = false,
    this.animationRandomlyFlipped = false,
  }) {
    assert(onTick != null || damage != null);
    radius *= sourceEntity.areaSizePercentIncrease.parameter;
    priority = attackPriority;

    animationComponent?.size = Vector2.all(radius * 2);
    animationComponent?.durationType = durationType;
    animationComponent?.randomlyFlipped = animationRandomlyFlipped;

    duration *= sourceEntity.durationPercentIncrease.parameter;

    this.areaId = areaId ?? const Uuid().v4();
  }
  Map<DamageType, (double, double)>? damage;

  bool animationRandomlyFlipped;

  double radius;
  double? collisionDelay;
  final DurationType durationType;

  SimpleStartPlayEndSpriteAnimationComponent? animationComponent;

  double duration;
  late String areaId;
  double tickRate;
  Function(Entity entity, String areaId)? onTick;
  @override
  Vector2 position;
  Entity sourceEntity;
  bool isSolid;
  late TimerComponent aliveTimer;

  late CircleComponent circleComponent;

  Map<Entity, TimerComponent> affectedEntities = {};
  bool isKilled = false;

  @override
  Future<void> onLoad() async {
    if (animationComponent == null) {
      SpriteAnimation? spawnAnimation;
      Anchor anchor = Anchor.center;

      if (damage != null && damage!.isNotEmpty) {
        final damageType = damage!.keys.toList().random();
        switch (damageType) {
          case DamageType.fire:
            spawnAnimation = await spriteAnimations.fireExplosionMedium1;

            break;
          case DamageType.energy:
            spawnAnimation = await spriteAnimations.energyStrikeMedium1;

            anchor = Anchor.bottomCenter;

            break;
          case DamageType.psychic:
            spawnAnimation = await spriteAnimations.psychicStrikeMedium1;

            anchor = const Anchor(.5, .9);

            break;
          default:
            spawnAnimation = await spriteAnimations.fireExplosionMedium1;
        }
        animationComponent?.spawnAnimation = spawnAnimation;
      }

      animationComponent = SimpleStartPlayEndSpriteAnimationComponent(
        durationType: durationType,
        anchor: anchor,
        spawnAnimation:
            spawnAnimation ?? await spriteAnimations.fireExplosionMedium1,
        randomlyFlipped: animationRandomlyFlipped,
        desiredWidth: (radius * 2),
      );
    }

    animationComponent?.addToParent(this);

    if (animationComponent?.durationType == DurationType.temporary) {
      aliveTimer = TimerComponent(
        period: duration,
        removeOnFinish: true,
        repeat: false,
        onTick: () {
          killArea();
        },
      )..addToParent(this);
    }

    return super.onLoad();
  }

  @override
  void beginContact(Object other, Contact contact) {
    bool shouldCalculate = other is Entity &&
        other != sourceEntity &&
        !affectedEntities.containsKey(other);
    if (!shouldCalculate) return super.beginContact(other, contact);

    if (animationComponent?.durationType == DurationType.instant) {
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

  void doOnTick(Entity other) {
    if (isKilled) return;
    if (damage != null && other is HealthFunctionality) {
      other.takeDamage(
          areaId,
          damageCalculations(sourceEntity, other, damage!,
              sourceAttack: this, damageKind: DamageKind.area));
    }
    onTick?.call(other, areaId);
  }

  void instantChecker() {
    if (!isKilled &&
        animationComponent?.durationType == DurationType.instant &&
        body.isActive &&
        collisionDelay == null) {
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

  void killArea() async {
    isKilled = true;
    affectedEntities.clear();
    await animationComponent?.triggerEnding();
    removeFromParent();
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Entity) return;
    if (animationComponent?.durationType == DurationType.instant) return;
    affectedEntities[other]?.removeFromParent();
    affectedEntities.remove(other);

    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    // priority = 0;
    late CircleShape shape;

    shape = CircleShape();
    shape.radius = radius;
    // add(CircleComponent()
    //   ..radius = radius
    //   ..anchor = Anchor.center
    //   ..paint = (paint..color = Colors.red.withOpacity(.3)));
    renderBody = false;
    final filter = Filter();
    filter.categoryBits = areaEffectCategory;
    if (sourceEntity.isPlayer) {
      filter.maskBits = enemyCategory;
    } else {
      if (sourceEntity.affectsAllEntities) {
        filter.maskBits = 0xFFFF;
      } else {
        filter.maskBits = playerCategory;
      }
    }

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: !isSolid,
        filter: filter);
    final bodyDef = BodyDef(
      position: position,
      allowSleep: false,
      userData: this,
      type: BodyType.static,
      fixedRotation: true,
    );

    final newBody = world.createBody(bodyDef);
    Future.delayed((collisionDelay ?? 0).seconds).then((value) {
      newBody.createFixture(fixtureDef);
      collisionDelay = null;
    });
    return newBody;
  }
}
