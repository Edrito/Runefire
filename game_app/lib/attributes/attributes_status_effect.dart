import 'package:game_app/attributes/attributes_perpetrator.dart';
import 'package:game_app/attributes/attributes_structure.dart';

import '../entities/entity_mixin.dart';
import '../resources/data_classes/base.dart';
import '../resources/enums.dart';
import 'attributes_mixin.dart';

abstract class StatusEffectAttribute extends PerpetratorAttribute {
  StatusEffectAttribute(
      {super.level,
      super.victimEntity,
      super.perpetratorEntity,
      super.damageType}) {
    duration *= victimEntity!.durationPercentIncrease.parameter;
    statusEffectPotency = victimEntity?.statusEffectsPercentIncrease
            .statusEffectPercentIncrease[statusEffect] ??
        1;
  }

  abstract double duration;
  abstract StatusEffects statusEffect;
  late double statusEffectPotency;
}

class FireDamageAttribute extends StatusEffectAttribute
    with TemporaryAttribute {
  FireDamageAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.burn;

  @override
  double duration = 4;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int uniqueId = 0;

  @override
  String title = "Fire Damage";

  @override
  AttributeType get attributeType => AttributeType.burn;

  @override
  String description() {
    return "";
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
          damageCalculations(perpetratorEntity!,
              {DamageType.fire: (1.0, (1 * upgradeLevel.toDouble()))},
              damageKind: DamageKind.dot),
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
    victimEntity?.entityStatusWrapper
        .addStatusEffect(StatusEffects.burn, upgradeLevel);

    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.onUpdate.add(tickCheck);
    }
  }

  @override
  void unMapUpgrade() {
    victimEntity?.entityStatusWrapper.removeStatusEffect(StatusEffects.burn);

    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }

  @override
  String icon = "powerups/power.png";
}
