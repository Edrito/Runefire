import 'package:game_app/attributes/attributes_perpetrator.dart';
import 'package:game_app/attributes/attributes_structure.dart';

import '../entities/entity.dart';
import '../entities/entity_mixin.dart';
import '../resources/data_classes/base.dart';
import '../resources/enums.dart';
import 'attributes_mixin.dart';

StatusEffectAttribute? statusEffectBuilder(
  StatusEffects type,
  int level,
  AttributeFunctionality victimEntity, {
  required Entity perpetratorEntity,
  required bool isTemporary,
  double? duration,
}) {
  switch (type) {
    case StatusEffects.burn:
      if (isTemporary) {
        return TemporaryFireDamage(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
          duration: duration,
        );
      } else {
        return FireDamageAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );
      }

    default:
      return null;
  }
}

abstract class StatusEffectAttribute extends PerpetratorAttribute {
  StatusEffectAttribute(
      {super.level,
      required super.victimEntity,
      required super.perpetratorEntity,
      super.damageType}) {
    statusEffectPotency = perpetratorEntity.statusEffectsPercentIncrease
            .statusEffectPercentIncrease[statusEffect] ??
        1;
  }

  abstract StatusEffects statusEffect;
  late double statusEffectPotency;
}

class TemporaryFireDamage extends FireDamageAttribute with TemporaryAttribute {
  TemporaryFireDamage(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity,
      double? duration}) {
    this.duration = duration ?? this.duration;
    this.duration *= perpetratorEntity.durationPercentIncrease.parameter;
    print('hereeee');
  }

  @override
  double duration = 4;
}

class FireDamageAttribute extends StatusEffectAttribute {
  FireDamageAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  StatusEffects statusEffect = StatusEffects.burn;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => null;

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

  double minDamage = .1;
  double maxDamage = 1;

  void fireDamage() {
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.hitCheck(
          attributeId,
          damageCalculations(
              perpetratorEntity,
              {
                DamageType.fire: (
                  minDamage * upgradeLevel.toDouble(),
                  (maxDamage * upgradeLevel.toDouble())
                )
              },
              statusEffect: statusEffect,
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
