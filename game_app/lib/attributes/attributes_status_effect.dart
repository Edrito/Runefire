import 'package:game_app/attributes/attributes_perpetrator.dart';
import 'package:game_app/attributes/attributes_structure.dart';

import '../entities/entity_class.dart';
import '../entities/entity_mixin.dart';
import '../resources/data_classes/base.dart';
import '../resources/enums.dart';
import 'attributes_mixin.dart';

StatusEffectAttribute? statusEffectBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality victimEntity, {
  required Entity perpetratorEntity,
  required bool isTemporary,
  double? duration,
}) {
  switch (type) {
    case AttributeType.burn:
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

    case AttributeType.fear:
      if (isTemporary) {
        return TemporaryFear(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
          duration: duration,
        );
      } else {
        return FearAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );
      }
    case AttributeType.marked:
      if (isTemporary) {
        return TemporaryMark(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
          duration: duration,
        );
      } else {
        return MarkAttribute(
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
      final victimHealth = victimEntity as HealthFunctionality;
      victimHealth.hitCheck(
          attributeId,
          damageCalculations(
              perpetratorEntity,
              victimHealth,
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

class TemporaryFear extends FearAttribute with TemporaryAttribute {
  TemporaryFear(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity,
      double? duration}) {
    this.duration = duration ?? this.duration;
    this.duration *= perpetratorEntity.durationPercentIncrease.parameter;
  }

  @override
  double duration = 1;
}

class FearAttribute extends StatusEffectAttribute {
  FearAttribute(
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
  String title = "Fear";

  @override
  AttributeType get attributeType => AttributeType.burn;

  @override
  String description() {
    return "";
  }

  double durationPassed = 0;

  @override
  void mapUpgrade() {
    victimEntity?.entityStatusWrapper
        .addStatusEffect(StatusEffects.fear, upgradeLevel);

    if (victimEntity is MovementFunctionality) {
      final move = victimEntity as MovementFunctionality;
      move.entitiesFeared[perpetratorEntity.entityId] = perpetratorEntity;
    }
  }

  @override
  void unMapUpgrade() {
    victimEntity?.entityStatusWrapper.removeStatusEffect(StatusEffects.fear);
    if (victimEntity is MovementFunctionality) {
      final move = victimEntity as MovementFunctionality;
      move.entitiesFeared.remove(perpetratorEntity.entityId);
    }
  }

  @override
  String icon = "powerups/power.png";
}

class TemporaryMark extends MarkAttribute with TemporaryAttribute {
  TemporaryMark(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity,
      double? duration}) {
    this.duration = duration ?? this.duration;
    this.duration *= perpetratorEntity.durationPercentIncrease.parameter;
  }

  @override
  double duration = 1;
}

class MarkAttribute extends StatusEffectAttribute {
  MarkAttribute(
      {required super.level,
      required super.victimEntity,
      required super.perpetratorEntity});

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => null;

  @override
  String title = "Marked";

  @override
  AttributeType get attributeType => AttributeType.marked;

  @override
  String description() {
    return "";
  }

  double durationPassed = 0;

  @override
  void mapUpgrade() {
    victimEntity?.entityStatusWrapper.addMarkedStatus();

    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.isMarked.setIncrease(attributeId, true);
    }
  }

  @override
  void unMapUpgrade() {
    victimEntity?.entityStatusWrapper.removeMarked();
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.isMarked.setIncrease(attributeId, false);
    }

    // if (victimEntity is MovementFunctionality) {
    //   final move = victimEntity as MovementFunctionality;
    //   move.entitiesFeared.remove(perpetratorEntity.entityId);
    // }
  }

  @override
  String icon = "powerups/power.png";

  @override
  StatusEffects statusEffect = StatusEffects.marked;
}
