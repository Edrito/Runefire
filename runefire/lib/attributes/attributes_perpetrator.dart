import '../entities/entity_class.dart';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/physics_filter.dart';

import '../main.dart';

PerpetratorAttribute? perpetratorAttributeBuilder(AttributeType type, int level,
    AttributeFunctionality victimEntity, Entity perpetratorEntity) {
  switch (type) {
    // case AttributeType.burn:
    //   return FireDamageAttribute(
    //     level: level,
    //     victimEntity: victimEntity,
    //     perpetratorEntity: perpetratorEntity,
    //   );

    default:
      return null;
  }
}

///Attribute sourced from another entitiy, for the purpose of damaging, status effects and such.
abstract class PerpetratorAttribute extends Attribute {
  PerpetratorAttribute(
      {super.level,
      super.victimEntity,
      required this.perpetratorEntity,
      super.damageType});

  Entity perpetratorEntity;
}

///Removes itself after [duration] seconds.
mixin TemporaryAttribute on Attribute {
  abstract double duration;
  double timePassed = 0;

  @override
  void reMapUpgrade() {
    resetTimer();
    super.reMapUpgrade();
  }

  void resetTimer() => timePassed = 0;
  void incrementTimer(double dt) {
    timePassed += dt;
    if (timePassed >= duration) {
      removeUpgrade();
      victimEntity!.removeAttribute(attributeType);
    }
  }

  @override
  void applyUpgrade() {
    applyTimer(false);

    super.applyUpgrade();
  }

  void applyTimer(bool removeTimer) {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final func = victimEntity as AttributeFunctionsFunctionality;
    resetTimer();
    if (removeTimer) {
      func.onUpdate.remove(incrementTimer);
    } else {
      func.onUpdate.add(incrementTimer);
    }
  }

  @override
  void removeUpgrade() {
    applyTimer(true);
    super.removeUpgrade();
  }
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
    if (other is AttributeFunctionality) {
      other.addAttribute(
        powerup.attributeType,
        level: 1,
      );
      removeFromParent();
    }
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
