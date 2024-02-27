import 'package:runefire/entities/entity_class.dart';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/physics_filter.dart';

import 'package:runefire/main.dart';

PerpetratorAttribute? perpetratorAttributeBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? victimEntity,
  Entity? perpetratorEntity,
) {
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
  PerpetratorAttribute({
    required this.perpetratorEntity,
    super.level,
    super.attributeOwnerEntity,
    super.damageType,
  });

  Entity? perpetratorEntity;
}

///Removes itself after [duration] seconds.
class TemporaryAttribute extends Attribute {
  TemporaryAttribute({
    required this.managedAttribute,
    this.duration = 4,
  });

  final Attribute managedAttribute;
  @override
  bool get reApplyOnAddition => managedAttribute.reApplyOnAddition;

  double duration;
  double timePassed = 0;

  @override
  AttributeFunctionality? get attributeOwnerEntity =>
      managedAttribute.attributeOwnerEntity;

  void applyTimer({required bool removeTimer}) {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final func = attributeOwnerEntity! as AttributeCallbackFunctionality;
      if (reApplyOnAddition) {
        resetTimer();
      }
      if (removeTimer) {
        func.onUpdate.remove(incrementTimer);
      } else {
        func.onUpdate.add(incrementTimer);
      }
    }
  }

  void incrementTimer(double dt) {
    timePassed += dt;
    if (timePassed >= duration) {
      removeUpgrade();
      attributeOwnerEntity!.removeAttribute(attributeType);
    }
  }

  void resetTimer() => timePassed = 0;

  @override
  Set<DamageType> get allowedDamageTypes => managedAttribute.allowedDamageTypes;

  @override
  void applyUpgrade() {
    applyTimer(removeTimer: false);
    managedAttribute.applyUpgrade();
  }

  @override
  AttributeType get attributeType => managedAttribute.attributeType;

  @override
  void changeLevel(int newUpgradeLevel) {
    managedAttribute.changeLevel(newUpgradeLevel);
  }

  @override
  DamageType? get damageType => managedAttribute.damageType;

  @override
  String description() {
    return managedAttribute.description();
  }

  @override
  bool get hasRandomDamageType => managedAttribute.hasRandomDamageType;

  @override
  bool get hasRandomStatusEffect => managedAttribute.hasRandomStatusEffect;

  @override
  String help() {
    return managedAttribute.help();
  }

  @override
  String get icon => managedAttribute.icon;

  @override
  bool get increaseFromBaseParameter =>
      managedAttribute.increaseFromBaseParameter;

  @override
  set increaseFromBaseParameter(bool increaseFromBaseParameter) {}

  @override
  void incrementLevel(int increment) {
    managedAttribute.incrementLevel(increment);
  }

  @override
  void mapUpgrade() {
    managedAttribute.mapUpgrade();
  }

  @override
  int? get maxLevel => managedAttribute.maxLevel;

  @override
  void reMapUpgrade() {
    resetTimer();
    managedAttribute.reMapUpgrade();
  }

  @override
  void removeUpgrade() {
    applyTimer(removeTimer: true);
    managedAttribute.removeUpgrade();
  }

  @override
  Future<Sprite> get sprite => managedAttribute.sprite;

  @override
  String get title => managedAttribute.title;

  @override
  set title(String title) {}

  @override
  void unMapUpgrade() {
    managedAttribute.unMapUpgrade();
  }
}

class PowerupItem extends BodyComponent<GameRouter> with ContactCallbacks {
  PowerupItem(this.powerup, this.originPosition);

  Vector2 originPosition;
  TemporaryAttribute powerup;
  late PolygonShape shape;
  double size = 1;
  late SpriteComponent spriteComponent;

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

    final fixtureDef = FixtureDef(
      shape,
      userData: {'type': FixtureType.body, 'object': this},
      isSensor: true,
      filter: powerupFilter,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteComponent(
      sprite: await powerup.sprite,
      size: Vector2.all(size),
      anchor: Anchor.center,
    );
    spriteComponent.add(
      MoveEffect.by(
        Vector2(0, .25),
        InfiniteEffectController(
          EffectController(
            duration: .5,
            reverseDuration: .5,
            curve: Curves.easeInOut,
            reverseCurve: Curves.easeInOut,
          ),
        ),
      ),
    );
    add(spriteComponent);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {}
}
