import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_perpetrator.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/input_priorities.dart';

import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/resources/functions/functions.dart';

StatusEffectAttribute? statusEffectBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? victimEntity, {
  Entity? perpetratorEntity,
}) {
  switch (type) {
    case AttributeType.burn:
      return FireDamageAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.bleed:
      return BleedAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.fear:
      return FearAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.confused:
      return ConfusedStatusEffectAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.marked:
      return MarkAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.stun:
      return StunAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.empowered:
      return EmpoweredAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.chill:
      return ChillStatusEffectAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.frozen:
      return ChillStatusEffectAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.slow:
      return SlowAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.electrified:
      return ElectrifiedAttribute(
        level: level,
        victimEntity: victimEntity,
        perpetratorEntity: perpetratorEntity,
      );
    default:
      return null;
  }
}

abstract class StatusEffectAttribute extends PerpetratorAttribute {
  StatusEffectAttribute({
    required super.victimEntity,
    required super.perpetratorEntity,
    super.level,
    super.damageType,
  }) {
    statusEffectPotency = perpetratorEntity?.statusEffectsPercentIncrease
            .statusEffectPercentIncrease[statusEffect] ??
        1;
  }

  @override
  @mustCallSuper
  void mapUpgrade() {
    super.mapUpgrade();
    victimEntity?.entityStatusWrapper
        .addStatusEffect(statusEffect, upgradeLevel);
  }

  @override
  @mustCallSuper
  void unMapUpgrade() {
    super.unMapUpgrade();
    victimEntity?.entityStatusWrapper.removeStatusEffect(statusEffect);
  }

  abstract StatusEffects statusEffect;
  late double statusEffectPotency;
  @override
  AttributeType get attributeType => statusEffect.getCorrospondingAttribute;
}

class FireDamageAttribute extends StatusEffectAttribute {
  FireDamageAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.burn;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 5;

  @override
  String title = 'Fire Damage';

  @override
  String description() {
    return '';
  }

  double tickRate = .5;

  double durationPassed = 0;

  double minDamage = .1;
  double maxDamage = 1;

  void fireDamage() {
    if (victimEntity is HealthFunctionality && perpetratorEntity != null) {
      final victimHealth = victimEntity! as HealthFunctionality;
      victimHealth.hitCheck(
        attributeId,
        damageCalculations(
          perpetratorEntity!,
          victimHealth,
          {
            DamageType.fire: (
              minDamage * upgradeLevel.toDouble(),
              (maxDamage * upgradeLevel.toDouble())
            ),
          },
          statusEffect: statusEffect,
          sourceAttack: perpetratorEntity,
          damageKind: DamageKind.dot,
        ),
        false,
      );
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
    super.mapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(tickCheck);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }
}

class FearAttribute extends StatusEffectAttribute {
  FearAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.fear;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 1;

  @override
  String title = 'Fear';

  @override
  String description() {
    return '';
  }

  double durationPassed = 0;

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    if (victimEntity is MovementFunctionality && perpetratorEntity != null) {
      final move = victimEntity! as MovementFunctionality;
      move.entitiesFeared[perpetratorEntity!.entityId] = perpetratorEntity!;
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is MovementFunctionality && perpetratorEntity != null) {
      final move = victimEntity! as MovementFunctionality;
      move.entitiesFeared.remove(perpetratorEntity!.entityId);
    }
  }
}

class MarkAttribute extends StatusEffectAttribute {
  MarkAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 1;

  @override
  String title = 'Marked';

  @override
  String description() {
    return '';
  }

  double durationPassed = 0;

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity! as HealthFunctionality;
      health.isMarked.setIncrease(attributeId, true);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity! as HealthFunctionality;
      health.isMarked.setIncrease(attributeId, false);
    }

    // if (victimEntity is MovementFunctionality) {
    //   final move = victimEntity as MovementFunctionality;
    //   move.entitiesFeared.remove(perpetratorEntity.entityId);
    // }
  }

  @override
  StatusEffects statusEffect = StatusEffects.marked;
}

class EmpoweredAttribute extends StatusEffectAttribute {
  EmpoweredAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 1;

  @override
  String title = 'Empowered';

  @override
  String description() {
    return '';
  }

  bool onHitOtherEntity(DamageInstance instance) {
    instance.checkCrit(force: true);
    Future.delayed(const Duration(milliseconds: 10)).then((value) {
      removeAttribute();
    });
    return true;
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    if (victimEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = victimEntity! as AttributeCallbackFunctionality;
    attr.onHitOtherEntity.add(onHitOtherEntity);
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = victimEntity! as AttributeCallbackFunctionality;
    attr.onHitOtherEntity.remove(onHitOtherEntity);
  }

  @override
  StatusEffects statusEffect = StatusEffects.empowered;
}

class StunAttribute extends StatusEffectAttribute {
  StunAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 1;

  @override
  String title = 'Stunned';

  @override
  String description() {
    return '';
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.enableMovement.setIncrease(attributeId, false);
      attr.enableMovement.setIncrease('${attributeId}2', false);
    }
    if (victimEntity is AttackFunctionality) {
      final attack = victimEntity! as AttackFunctionality;
      attack.endPrimaryAttacking();
      attack.endSecondaryAttacking();
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.enableMovement.removeKey(attributeId);
      attr.enableMovement.removeKey('${attributeId}2');
    }
  }

  @override
  StatusEffects statusEffect = StatusEffects.frozen;
}

class ConfusedStatusEffectAttribute extends StatusEffectAttribute {
  ConfusedStatusEffectAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.confused;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 5;

  @override
  String title = 'Confused';

  @override
  String description() {
    return '';
  }

  double durationPassed = 0;

  @override
  void action() {
    if (victimEntity is MovementFunctionality) {
      final move = victimEntity! as MovementFunctionality;
      move.addMoveVelocity(Vector2.random(), attributeInputPriority);
    }
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    (victimEntity!).gameEnviroment.eventManagement.addAiTimer(
          action,
          attributeId,
          1.5,
        );
    action();
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    (victimEntity!).gameEnviroment.eventManagement.removeAiTimer(
          action,
          attributeId,
          1.5,
        );
    if (victimEntity is MovementFunctionality) {
      final move = victimEntity! as MovementFunctionality;
      move.removeMoveVelocity(attributeInputPriority);
    }
  }
}

class SlowAttribute extends StatusEffectAttribute {
  SlowAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.slow;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 5;

  @override
  String title = 'Slow';

  @override
  String description() {
    return '';
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    final amount = increasePercentOfBase(-.1, includeBase: true).toDouble();
    if (victimEntity is MovementFunctionality) {
      final move = victimEntity! as MovementFunctionality;
      move.speed.setParameterPercentValue(attributeId, amount);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is MovementFunctionality) {
      final move = victimEntity! as MovementFunctionality;
      move.speed.removeKey(attributeId);
    }
  }
}

class ChillStatusEffectAttribute extends SlowAttribute {
  ChillStatusEffectAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.chill;

  @override
  String title = 'Chill';

  double minDamage = .05;
  double maxDamage = .5;

  void slowDamage() {
    if (victimEntity is StaminaFunctionality) {
      final victimStamina = victimEntity! as StaminaFunctionality;
      victimStamina.modifyStamina(
        -randomBetween(
          (
            minDamage * upgradeLevel.toDouble(),
            (maxDamage * upgradeLevel.toDouble())
          ),
        ),
      );
    }
  }

  double tickRate = .5;

  double durationPassed = 0;

  void tickCheck(double dt) {
    if (durationPassed >= tickRate) {
      durationPassed = 0;
      slowDamage();
    }
    durationPassed += dt;
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(tickCheck);
    }

    if (upgradeLevel == maxLevel) {
      victimEntity?.addAttribute(
        AttributeType.frozen,
        isTemporary: true,
        perpetratorEntity: perpetratorEntity,
      );
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }
}

class BleedAttribute extends StatusEffectAttribute {
  BleedAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.bleed;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 5;

  @override
  String title = 'Bleed';

  double tickRate = .5;

  double durationPassed = 0;

  double minDamage = .05;
  double maxDamage = .5;

  void bleedDamage() {
    if (victimEntity is HealthFunctionality && perpetratorEntity != null) {
      final victimHealth = victimEntity! as HealthFunctionality;
      victimHealth.hitCheck(
        attributeId,
        damageCalculations(
          perpetratorEntity!,
          victimHealth,
          {
            DamageType.physical: (
              minDamage * upgradeLevel.toDouble(),
              (maxDamage * upgradeLevel.toDouble())
            ),
          },
          statusEffect: statusEffect,
          sourceAttack: perpetratorEntity,
          damageKind: DamageKind.dot,
        ),
        false,
      );
    }

    if (victimEntity is StaminaFunctionality) {
      final victimStamina = victimEntity! as StaminaFunctionality;
      victimStamina.modifyStamina(
        -randomBetween(
          (
            minDamage * upgradeLevel.toDouble(),
            (maxDamage * upgradeLevel.toDouble())
          ),
        ),
      );
    }
  }

  void tickCheck(double dt) {
    if (durationPassed >= tickRate) {
      durationPassed = 0;
      bleedDamage();
    }
    durationPassed += dt;
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(tickCheck);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }
}

class FrozenAttribute extends StatusEffectAttribute {
  FrozenAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  bool get reApplyOnAddition => false;

  @override
  StatusEffects statusEffect = StatusEffects.frozen;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 1;

  @override
  String title = 'Frozen';

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    victimEntity?.enableMovement.setIncrease(attributeId, false);
    victimEntity?.isStunned.setIncrease(attributeId, true);
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    victimEntity?.enableMovement.removeKey(attributeId);
    victimEntity?.isStunned.removeKey(attributeId);
  }
}

class ElectrifiedAttribute extends StatusEffectAttribute {
  ElectrifiedAttribute({
    required super.level,
    required super.victimEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.electrified;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int? get maxLevel => 1;

  @override
  String title = 'Electrified';

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    final amount = increasePercentOfBase(
          .1,
          includeBase: true,
          customUpgradeFactor: .5,
        ) +
        1.0;
    victimEntity?.damageTypeResistance.setDamagePercentIncrease(
      attributeId,
      DamageType.getValuesWithoutHealing
          .asNameMap()
          .map((key, value) => MapEntry(value, amount)),
    );
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    victimEntity?.damageTypeResistance.removePercentKey(attributeId);
  }
}
