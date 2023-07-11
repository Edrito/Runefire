import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/attributes/attributes.dart';
import 'package:game_app/attributes/attributes_enum.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/constants/physics_filter.dart';

import '../main.dart';

abstract class TemporaryAttribute extends Attribute {
  TemporaryAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  abstract double duration;
  TimerComponent? currentTimer;
  abstract int uniqueId;

  @override
  void reMapUpgrade() {
    currentTimer?.timer.reset();
    super.reMapUpgrade();
  }

  @override
  void applyUpgrade() {
    currentTimer?.timer.reset();
    currentTimer ??= TimerComponent(
        period: duration,
        onTick: () {
          removeUpgrade();
          victimEntity.removeAttribute(attributeEnum);
        },
        removeOnFinish: true)
      ..addToParent(victimEntity);
    if (!isApplied) {
      mapUpgrade();
      isApplied = true;
    }
  }

  @override
  void removeUpgrade() {
    if (isApplied) {
      currentTimer?.removeFromParent();
      currentTimer = null;
      unMapUpgrade();
      isApplied = false;
    }
  }
}

class PowerAttribute extends TemporaryAttribute {
  @override
  double duration = 1;

  @override
  int uniqueId = 0;

  double healthIncrease = 20;
  double damageIncrease = .5;

  Effect? colorEffect;

  @override
  String title = "Strength and POWER";

  PowerAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  // TODO: implement attributeEnum
  AttributeEnum get attributeEnum => AttributeEnum.power;

  @override
  String description() {
    // TODO: implement description
    return "aaa";
  }

  @override
  void mapUpgrade() {
    // TODO: implement mapAttribute
  }

  @override
  void unMapUpgrade() {
    // TODO: implement unmapAttribute
  }

  @override
  String icon = "powerups/power.png";
}

class FireDamageAttribute extends TemporaryAttribute {
  @override
  double duration = 4;

  @override
  int uniqueId = 0;

  @override
  String title = "Fire Damage";

  FireDamageAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  AttributeEnum get attributeEnum => AttributeEnum.power;

  @override
  String description() {
    // TODO: implement description
    return "aaa";
  }

  double tickRate = .5;

  double durationPassed = 0;

  double minDamage = 1;
  double maxDamage = 1;

  void fireDamage() {
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.hitCheck(
          uniqueId.toString(),
          [
            DamageInstance(
                // damageBase:
                //     ((maxDamage + minDamage) - (minDamage * rng.nextDouble())),
                damageBase: 1 * upgradeLevel.toDouble(),
                source: perpetratorEntity!,
                damageType: DamageType.fire)
          ],
          false);
    }
  }

  void tickCheck(double dt) {
    if (durationPassed >= tickRate) {
      durationPassed = 0;
      fireDamage();
    }
    durationPassed += dt;
  }

  @override
  void mapUpgrade() {
    victimEntity.entityStatusWrapper.addStatusEffect(
        duration, StatusEffects.burn, currentTimer!, upgradeLevel);

    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.onUpdate.add(tickCheck);
    }
  }

  @override
  void unMapUpgrade() {
    victimEntity.entityStatusWrapper.removeStatusEffect(StatusEffects.burn);

    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }

  @override
  String icon = "powerups/power.png";
}

class PowerupItem extends BodyComponent<GameRouter> with ContactCallbacks {
  PowerupItem(this.powerup, this.originPosition);

  TemporaryAttribute powerup;
  late SpriteComponent spriteComponent;
  double size = 1;
  Vector2 originPosition;

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteComponent(
        sprite: await Sprite.load(powerup.icon),
        size: Vector2.all(size),
        anchor: Anchor.center);
    spriteComponent.add(MoveEffect.by(
        Vector2(0, .25),
        InfiniteEffectController(EffectController(
          duration: .5,
          reverseDuration: .5,
          curve: Curves.easeInOut,
          reverseCurve: Curves.easeInOut,
        ))));
    add(spriteComponent);
    return super.onLoad();
  }

  late PolygonShape shape;

  @override
  void render(Canvas canvas) {}

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! AttributeFunctionality) return;
    other.addAttributeEnum(powerup.attributeEnum);
    removeFromParent();
    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    shape = PolygonShape();
    shape.set([
      Vector2(-spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, spriteComponent.size.y / 2),
      Vector2(-spriteComponent.size.x / 2, spriteComponent.size.y / 2),
    ]);

    final powerupFilter = Filter()
      ..maskBits = playerCategory
      ..categoryBits = powerupCategory;

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0,
        isSensor: true,
        filter: powerupFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.static,
      bullet: false,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
