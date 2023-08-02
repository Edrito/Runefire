import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../resources/area_effects.dart';
import '../resources/functions/functions.dart';
import 'attributes_structure.dart';
import '../resources/enums.dart';

Attribute? regularAttributeBuilder(
    AttributeType type, int level, AttributeFunctionality victimEntity) {
  switch (type) {
    case AttributeType.enemyExplosion:
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

  void onKill(HealthFunctionality other) async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: other.center,
        playAnimation: await buildSpriteSheet(
            61, 'weapons/projectiles/fire_area.png', .05, true),
        radius: baseSize + increasePercentOfBase(baseSize),
        isInstant: false,
        duration: victimEntity!.durationPercentIncrease.parameter,

        ///Map<DamageType, (double, double)>
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
