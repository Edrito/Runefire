import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_perpetrator.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/input_priorities.dart';

import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/visuals.dart';

StatusEffectAttribute? statusEffectBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? attributeOwnerEntity, {
  Entity? perpetratorEntity,
}) {
  switch (type) {
    case AttributeType.burn:
      return FireDamageAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.bleed:
      return BleedAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.fear:
      return FearAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.confused:
      return ConfusedStatusEffectAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.marked:
      return MarkAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.stun:
      return StunAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );
    case AttributeType.empowered:
      return EmpoweredAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.chill:
      return ChillStatusEffectAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.frozen:
      return FrozenAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.slow:
      return SlowAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );

    case AttributeType.electrified:
      return ElectrifiedAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        perpetratorEntity: perpetratorEntity,
      );
    default:
      return null;
  }
}

abstract class StatusEffectAttribute extends PerpetratorAttribute {
  StatusEffectAttribute({
    required super.attributeOwnerEntity,
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
    attributeOwnerEntity?.entityVisualEffectsWrapper
        .addStatusEffect(statusEffect, upgradeLevel);
  }

  @override
  @mustCallSuper
  void unMapUpgrade() {
    super.unMapUpgrade();
    attributeOwnerEntity?.entityVisualEffectsWrapper
        .removeStatusEffect(statusEffect);
  }

  abstract StatusEffects statusEffect;
  late double statusEffectPotency;
  @override
  AttributeType get attributeType => statusEffect.getCorrospondingAttribute;
}

class FireDamageAttribute extends StatusEffectAttribute {
  FireDamageAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    if (attributeOwnerEntity is HealthFunctionality &&
        perpetratorEntity != null) {
      final victimHealth = attributeOwnerEntity! as HealthFunctionality;
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
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(tickCheck);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }
}

class FearAttribute extends StatusEffectAttribute {
  FearAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    if (attributeOwnerEntity is MovementFunctionality &&
        perpetratorEntity != null) {
      final move = attributeOwnerEntity! as MovementFunctionality;
      move.entitiesFeared[perpetratorEntity!.entityId] = perpetratorEntity!;
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (attributeOwnerEntity is MovementFunctionality &&
        perpetratorEntity != null) {
      final move = attributeOwnerEntity! as MovementFunctionality;
      move.entitiesFeared.remove(perpetratorEntity!.entityId);
    }
  }
}

class MarkAttribute extends StatusEffectAttribute {
  MarkAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.isMarked.setIncrease(attributeId, true);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.isMarked.setIncrease(attributeId, false);
    }

    // if (attributeOwnerEntity is MovementFunctionality) {
    //   final move = attributeOwnerEntity as MovementFunctionality;
    //   move.entitiesFeared.remove(perpetratorEntity.entityId);
    // }
  }

  @override
  StatusEffects statusEffect = StatusEffects.marked;
}

class EmpoweredAttribute extends StatusEffectAttribute {
  EmpoweredAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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

    attributeOwnerEntity?.addTemporaryUpdateFunction((dt) {
      removeAttribute();
    });

    return true;
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onHitOtherEntity.add(onHitOtherEntity);
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onHitOtherEntity.remove(onHitOtherEntity);
  }

  @override
  StatusEffects statusEffect = StatusEffects.empowered;
}

class StunAttribute extends StatusEffectAttribute {
  StunAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.isStunned.setIncrease(attributeId, true);
    }
    if (attributeOwnerEntity is AttackFunctionality) {
      final attack = attributeOwnerEntity! as AttackFunctionality;
      attack.endPrimaryAttacking();
      attack.endSecondaryAttacking();
    }
    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.isStunned.removeKey(attributeId);
    }
    super.unMapUpgrade();
  }

  @override
  StatusEffects statusEffect = StatusEffects.stun;
}

class ConfusedStatusEffectAttribute extends StatusEffectAttribute {
  ConfusedStatusEffectAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    if (attributeOwnerEntity is MovementFunctionality) {
      final move = attributeOwnerEntity! as MovementFunctionality;
      move.addMoveVelocity(Vector2.random(), attributeInputPriority);
    }
    if (attributeOwnerEntity is AimFunctionality) {
      final aim = attributeOwnerEntity! as AimFunctionality;
      final aimTarget = (aim.closeSensorBodies.toList()
            ..sort((a, b) => rng.nextInt(3) - 1))
          .firstOrNull;
      aim.addAimAngle(
        aimTarget == null
            ? Vector2.random()
            : (aim.center - aimTarget.center).normalized(),
        attributeInputPriority,
      );
    }
  }

  @override
  void mapUpgrade() {
    super.mapUpgrade();
    attributeOwnerEntity?.affectsAllEntities.setIncrease(attributeId, true);
    (attributeOwnerEntity!).gameEnviroment.eventManagement.addAiTimer(
      (
        function: action,
        id: attributeId,
        time: 1.5,
      ),
    );
    action();
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    (attributeOwnerEntity!).gameEnviroment.eventManagement.removeAiTimer(
          id: attributeId,
        );
    attributeOwnerEntity?.affectsAllEntities.removeKey(attributeId);
    if (attributeOwnerEntity is MovementFunctionality) {
      final move = attributeOwnerEntity! as MovementFunctionality;
      move.removeMoveVelocity(attributeInputPriority);
    }
    if (attributeOwnerEntity is AimFunctionality) {
      final aim = attributeOwnerEntity! as AimFunctionality;
      aim.removeAimAngle(attributeInputPriority);
    }
  }
}

class SlowAttribute extends StatusEffectAttribute {
  SlowAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    final amount = increasePercentOfBase(-.15, includeBase: true).toDouble();
    if (attributeOwnerEntity is MovementFunctionality) {
      final move = attributeOwnerEntity! as MovementFunctionality;
      move.speed.setParameterPercentValue(attributeId, amount);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (attributeOwnerEntity is MovementFunctionality) {
      final move = attributeOwnerEntity! as MovementFunctionality;
      move.speed.removeKey(attributeId);
    }
  }
}

class ChillStatusEffectAttribute extends SlowAttribute {
  ChillStatusEffectAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    required super.perpetratorEntity,
  });

  @override
  StatusEffects statusEffect = StatusEffects.chill;

  @override
  String title = 'Chill';

  double minDamage = .05;
  double maxDamage = .5;

  void slowDamage() {
    if (attributeOwnerEntity is StaminaFunctionality) {
      final victimStamina = attributeOwnerEntity! as StaminaFunctionality;
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
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(tickCheck);
    }

    if (upgradeLevel == maxLevel) {
      attributeOwnerEntity?.addAttribute(
        AttributeType.frozen,
        isTemporary: true,
        perpetratorEntity: perpetratorEntity,
      );
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }
}

class BleedAttribute extends StatusEffectAttribute {
  BleedAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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

  double stunChance = .2;

  void bleedDamage() {
    if (attributeOwnerEntity is HealthFunctionality &&
        perpetratorEntity != null) {
      final victimHealth = attributeOwnerEntity! as HealthFunctionality;
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

    if (attributeOwnerEntity?.hasAttribute(AttributeType.bleedStunAttribute) ??
        false) {
      if (rng.nextDouble() < stunChance) {
        attributeOwnerEntity?.addAttribute(
          AttributeType.stun,
          isTemporary: true,
          perpetratorEntity: perpetratorEntity,
        );
      }
    }

    if (attributeOwnerEntity is StaminaFunctionality) {
      final victimStamina = attributeOwnerEntity! as StaminaFunctionality;
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
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(tickCheck);
    }
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(tickCheck);
    }
  }
}

class FrozenAttribute extends StatusEffectAttribute {
  FrozenAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
  ColorEffect? colorEffect;
  @override
  void mapUpgrade() {
    attributeOwnerEntity?.movementEnabled.setIncrease(attributeId, false);
    attributeOwnerEntity?.isStunned.setIncrease(attributeId, true);
    final infiniteController = InfiniteEffectController(
      EffectController(
        duration: .1,
      ),
    );
    attributeOwnerEntity?.entityAnimationsGroup.add(
      colorEffect = ColorEffect(
        ApolloColorPalette.paleBlue.color,
        opacityFrom: .3,
        opacityTo: .5,
        infiniteController,
      ),
    );
    attributeOwnerEntity?.animationPaused.setIncrease(attributeId, true);

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    attributeOwnerEntity?.animationPaused.removeKey(attributeId);
    attributeOwnerEntity?.movementEnabled.removeKey(attributeId);
    attributeOwnerEntity?.isStunned.removeKey(attributeId);
    colorEffect?.removeFromParent();
  }
}

class ElectrifiedAttribute extends StatusEffectAttribute {
  ElectrifiedAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    attributeOwnerEntity?.damageTypeResistance.setDamagePercentIncrease(
      attributeId,
      DamageType.getValuesWithoutHealing
          .asNameMap()
          .map((key, value) => MapEntry(value, amount)),
    );
  }

  @override
  void unMapUpgrade() {
    super.unMapUpgrade();
    attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
  }
}
