import 'package:flame/components.dart';
import 'package:forge2d/src/dynamics/body.dart';
import 'package:forge2d/src/dynamics/filter.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/weapons/weapon_class.dart';

class GodEntity extends Entity with BaseAttributes {
  GodEntity({required super.eventManagement, required super.enviroment})
      : super(
          initialPosition: Vector2.all(666),
        ) {
    affectsAllEntities = true;
  }
  @override
  EntityType entityType = EntityType.npc;

  @override
  Body createBody() {
    final body = super.createBody();
    for (var element in [...body.fixtures]) {
      body.destroyFixture(element);
    }
    return body;
  }

  @override
  Filter? filter;

  @override
  Future<void> loadAnimationSprites() async {}
}
