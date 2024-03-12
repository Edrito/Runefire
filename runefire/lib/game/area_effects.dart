import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/enviroment_interactables/areas.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/extensions.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/damage_type_enum.dart';

enum DurationType { instant, temporary, permanent }

class AreaEffect extends BodyComponent<GameRouter> with ContactCallbacks {
  ///Use [damage] if you want to deal damage to entities in the area
  ///Declare a custom [areaId] if you are making multiple areas and want
  ///to prevent enemies getting super spammed with deeps
  AreaEffect({
    required this.position,
    required this.sourceEntity,
    this.animationComponent,
    this.radius = 2.5,
    this.duration = 5,
    this.durationType = DurationType.instant,
    this.collisionDelay = .3,
    String? areaId,
    this.tickRate = 1,
    this.damage,
    this.onTick,
    int? overridePriority,
    this.customColor,
    this.isSolid = false,
    this.animationRandomlyFlipped = true,
  }) {
    radius *= sourceEntity.areaSizePercentIncrease.parameter;
    priority = overridePriority ?? particlePriority;

    animationComponent?.size = Vector2.all(radius * 2);
    animationComponent?.durationType = durationType;
    animationComponent?.randomlyFlipped = animationRandomlyFlipped;

    duration = applyDurationModifications(
      perpertrator: sourceEntity,
      time: duration,
    );

    this.areaId = areaId ?? const Uuid().v4();
  }

  Map<DamageType, (double, double)>? damage;
  DefaultAreaEffectColor? customColor;

  bool get hasEffect => damage != null || onTick != null;

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

  Map<Entity, double> entityTimers = {};
  bool isKilled = false;

  @override
  Future<void> onLoad() async {
    if (animationComponent == null) {
      SpriteAnimation? spawnAnimation;
      SpriteAnimation? deadAnimation;

      if (damage != null && damage!.isNotEmpty) {
        final damageType = damage!.keys.toList().random();
        switch (damageType) {
          case DamageType.fire:
            spawnAnimation = await spriteAnimations.fireOrbMedium1;

            break;
          case DamageType.energy:
            spawnAnimation = await spriteAnimations.energyOrbMedium1;

            break;
          case DamageType.psychic:
            spawnAnimation = await spriteAnimations.psychicOrbMedium1;

            break;

          case DamageType.physical:
            spawnAnimation = await spriteAnimations.physicalOrbMedium1;

          case DamageType.magic:
            spawnAnimation = await spriteAnimations.magicOrbMedium1;
          case DamageType.frost:
            spawnAnimation = await spriteAnimations.frostOrbMedium1;
          case DamageType.healing:
            spawnAnimation = await spriteAnimations.healingOrbMedium1;
        }
        animationComponent?.spawnAnimation = spawnAnimation;
      } else if (customColor != null) {
        switch (customColor!) {
          case DefaultAreaEffectColor.blue:
            spawnAnimation = await spriteAnimations.defaultBlueAreaEffect1;
            break;
          case DefaultAreaEffectColor.brown:
            spawnAnimation = await spriteAnimations.defaultBrownAreaEffect1;
          case DefaultAreaEffectColor.green:
            spawnAnimation = await spriteAnimations.defaultGreenAreaEffect1;
          case DefaultAreaEffectColor.red:
            spawnAnimation = await spriteAnimations.defaultRedAreaEffect1;
          case DefaultAreaEffectColor.spore:
            spawnAnimation = await spriteAnimations.mushroomSpore1;
            deadAnimation = await spriteAnimations.fireOrbMedium1;
        }
      }

      animationComponent = SimpleStartPlayEndSpriteAnimationComponent(
        durationType: durationType,
        spawnAnimation:
            spawnAnimation ?? await spriteAnimations.defaultBlueAreaEffect1
              ..loop = false,
        randomlyFlipped: animationRandomlyFlipped,
        endAnimation: deadAnimation,
        playAnimation: spawnAnimation == null
            ? await spriteAnimations.defaultBlueAreaEffect1
            : null,
        desiredWidth: radius * 2,
      );
    }

    animationComponent?.addToParent(this);

    return super.onLoad();
  }

  double durationPassed = 0;

  @override
  void beginContact(Object other, Contact contact) {
    final shouldCalculate = other is Entity &&
        other != sourceEntity &&
        !currentEntities.contains(other) &&
        !contact.containsFixtureType(FixtureType.sensor);

    if (!shouldCalculate) {
      return super.beginContact(other, contact);
    }
    currentEntities.add(other);
    entityTimers[other] ??= tickRate;
    super.beginContact(other, contact);
  }

  bool aliveForOneTick = false;

  void affectEnemy(Entity other) {
    if (damage != null && other is HealthFunctionality) {
      other.hitCheck(
        areaId,
        damageCalculations(
          sourceEntity,
          other,
          damage!,
          sourceAttack: this,
          damageKind: DamageKind.area,
        ),
      );
    }
    onTick?.call(other, areaId);
  }

  void calculateOnTick(double dt) {
    if (durationType == DurationType.instant) {
      for (final element in [...entityTimers.entries]) {
        if (isKilled) {
          return;
        }
        final other = element.key;

        if (currentEntities.contains(other) && element.value >= tickRate) {
          affectEnemy(other);
          entityTimers[other] = 0.0;
        }
      }
      return;
    }

    for (final element in [...entityTimers.entries]) {
      if (isKilled) {
        return;
      }
      final other = element.key;

      if (element.value >= tickRate) {
        if (currentEntities.contains(other)) {
          entityTimers[other] = 0.0;
          affectEnemy(other);
        }
      } else {
        entityTimers[other] = element.value + dt;
      }
    }
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
    calculateOnTick(dt);
    durationPassed += dt;
    if (durationPassed > duration && durationType == DurationType.temporary) {
      killArea();
    }
    super.update(dt);
  }

  Future<void> killArea() async {
    isKilled = true;
    entityTimers.clear();
    await animationComponent?.triggerEnding();
    removeFromParent();
  }

  Set<Entity> currentEntities = {};

  void onExit(Entity other) {}

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Entity) {
      return;
    }
    if (animationComponent?.durationType == DurationType.instant) {
      return;
    }
    currentEntities.remove(other);
    onExit(other);

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
      if (sourceEntity.affectsAllEntities.parameter) {
        filter.maskBits = 0xFFFF;
      } else {
        filter.maskBits = playerCategory;
      }
    }

    final fixtureDef = FixtureDef(
      shape,
      userData: {'type': FixtureType.body, 'object': this},
      isSensor: !isSolid,
      filter: filter,
    );
    final bodyDef = BodyDef(
      position: position,
      allowSleep: !hasEffect,
      userData: this,
      fixedRotation: true,
    );

    final newBody = world.createBody(bodyDef);
    if (hasEffect) {
      game.gameAwait(collisionDelay ?? 0).then((value) {
        newBody.createFixture(fixtureDef);
        collisionDelay = null;
      });
    }
    return newBody;
  }
}
