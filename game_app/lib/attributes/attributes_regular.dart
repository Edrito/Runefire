import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../overlays/cards.dart';
import '../weapons/weapon_mixin.dart';
import '../resources/area_effects.dart';
import 'attributes_perpetrator.dart';
import 'attributes_structure.dart';
import '../resources/enums.dart';
import '../resources/functions/custom_mixins.dart';

class ExplosionEnemyDeathAttribute extends PerpetratorAttribute {
  ExplosionEnemyDeathAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

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
    if (victimEntity == null || perpetratorEntity == null) return;
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: other.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      isInstant: false,
      duration: victimEntity!.durationPercentIncrease.parameter,
      onTick: (entity, areaId) {
        if (entity is HealthFunctionality) {
          entity.hitCheck(areaId, [
            DamageInstance(
                damageBase: increasePercentOfBase(1),
                damageType: DamageType.fire,
                source: entity)
          ]);
        }
      },
    );
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final attributeFunctions = victimEntity as AttackFunctionality;
    for (var element in attributeFunctions.carriedWeapons.values) {
      if (element is AttributeWeaponFunctionsFunctionality) {
        element.onKill.add(onKill);
      }
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final attributeFunctions = victimEntity as AttackFunctionality;
    for (var element in attributeFunctions.carriedWeapons.values) {
      if (element is AttributeWeaponFunctionsFunctionality) {
        element.onKill.remove(onKill);
      }
    }
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
