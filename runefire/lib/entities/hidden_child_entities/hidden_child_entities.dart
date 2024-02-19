import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/entities/entity_mixin.dart';

class HiddenChildEntity extends ChildEntity {
  HiddenChildEntity({
    required super.initialPosition,
    required super.parentEntity,
    required super.upgradeLevel,
  });

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      userData: this,
      isAwake: false,
      linearDamping: 2,
      fixedRotation: true,
    );
    return world.createBody(bodyDef);
  }

  @override
  Future<void> loadAnimationSprites() async {}
}

class HiddenChildAimingEntity extends HiddenChildEntity
    with AimFunctionality, AttackFunctionality {
  HiddenChildAimingEntity({
    required super.initialPosition,
    required super.parentEntity,
    required super.upgradeLevel,
  });
  @override
  void update(double dt) {
    if (isLoaded) {
      body.setTransform(parentEntity.position, angle);
    }
    super.update(dt);
  }
}
