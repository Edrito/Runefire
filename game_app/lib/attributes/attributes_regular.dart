import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../resources/area_effects.dart';
import 'attributes_structure.dart';
import '../resources/enums.dart';

Attribute? regularAttributeBuilder(
    AttributeType type, int level, AttributeFunctionality victimEntity) {
  switch (type) {
    case AttributeType.burn:
      return ExplosionEnemyDeathAttribute(
        level: level,
        victimEntity: victimEntity,
      );

    default:
      return null;
  }
}

class ExplosionEnemyDeathAttribute extends Attribute {
  ExplosionEnemyDeathAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.enemyExplosion;

  @override
  double get factor => .25;

  @override
  int baseCost = 100;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 5;

  double baseSize = .5;

  void onKill(HealthFunctionality other) {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: other.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      isInstant: false,
      duration: victimEntity!.durationPercentIncrease.parameter,
      onTick: (entity, areaId) {
        // if (entity is HealthFunctionality) {
        //   entity.hitCheck(areaId,
        //     DamageInstance(
        //         damageMap: {
        //            DamageType.fire : increase(true,5)
        //            },
        //         source: entity)
        //   );
        // }
      },
    );
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attributeFunctions = victimEntity as AttributeFunctionsFunctionality;
    attributeFunctions.onKillOtherEntity.add(onKill);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attributeFunctions = victimEntity as AttributeFunctionsFunctionality;
    attributeFunctions.onKillOtherEntity.remove(onKill);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Enemies Explode";

  @override
  String description() {
    if (remainingLevels != 1) {
      return "Something in that ammunition...";
    } else {
      return "Max Level";
    }
  }
}
