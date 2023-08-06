import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../resources/area_effects.dart';
import '../resources/functions/functions.dart';
import 'attributes_structure.dart';
import '../resources/enums.dart';

Attribute? regularAttributeBuilder(AttributeType type, int level,
    AttributeFunctionality victimEntity, DamageType? damageType) {
  switch (type) {
    case AttributeType.fireExplosionOnKill:
      return FireExplosionEnemyDeathAttribute(
        level: level,
        victimEntity: victimEntity,
      );

    default:
      return null;
  }
}

class FireExplosionEnemyDeathAttribute extends Attribute {
  FireExplosionEnemyDeathAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.fireExplosionOnKill;

  @override
  double get factor => .25;

  // @override
  // int baseCost = 100;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 5;

  double baseSize = 3;

  void onKill(HealthFunctionality other) async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: other.center,
        randomlyFlipped: true,
        playAnimation: await buildSpriteSheet(
            16, 'effects/explosion_1_16.png', .05, false),
        size: baseSize + increasePercentOfBase(baseSize),
        isInstant: true,
        duration: victimEntity!.durationPercentIncrease.parameter,

        ///Map<DamageType, (double, double)>>>>
        damage: {DamageType.fire: (increase(true, 5), increase(true, 10))});
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
