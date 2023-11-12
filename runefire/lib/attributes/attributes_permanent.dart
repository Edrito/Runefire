import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/resources/enums.dart';
import 'package:runefire/attributes/attribute_constants.dart' as constants;
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/damage_type_enum.dart';

abstract class PermanentAttribute extends Attribute {
  PermanentAttribute({required super.level, required super.victimEntity});

  abstract int baseCost;

  ///Cost of the level up, default is the next level cost
  int cost([int? level]) {
    return baseCost * (level ?? (upgradeLevel + 1));
  }
}

PermanentAttribute? permanentAttributeBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? victimEntity,
) {
  switch (type) {
    case AttributeType.speedPermanent:
      return BaseSpeedPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.attackRatePermanent:
      return AttackRatePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.areaSizePermanent:
      return AreaSizePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.areaDamageIncreasePermanent:
      return AreaDamageIncreasePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.meleeDamageIncreasePermanent:
      return MeleeDamageIncreasePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.projectileDamageIncreasePermanent:
      return ProjectileDamageIncreasePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.spellDamageIncreasePermanent:
      return SpellDamageIncreasePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.tickDamageIncreasePermanent:
      return TickDamageIncreasePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.statusEffectPotencyPermanent:
      return StatusEffectPotencyPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.maxStaminaPermanent:
      return MaxStaminaPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.maxHealthPermanent:
      return MaxHealthPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.staminaRegenPermanent:
      return StaminaRegenPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.healthRegenPermanent:
      return HealthRegenPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.experienceGainPermanent:
      return ExperienceGainPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.dodgeChanceIncreasePermanent:
      return DodgeChancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.critChancePermanent:
      return CritChancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.critDamagePermanent:
      return CritDamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.durationPermanent:
      return DurationPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.essenceStealPermanent:
      return EssenceStealPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );

    case AttributeType.damageIncreasePermanent:
      return DamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.physicalDamageIncreasePermanent:
      return PhysicalDamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.magicDamageIncreasePermanent:
      return MagicDamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.fireDamageIncreasePermanent:
      return FireDamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.psychicDamageIncreasePermanent:
      return PsychicDamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.energyDamageIncreasePermanent:
      return EnergyDamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.frostDamageIncreasePermanent:
      return FrostDamagePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.physicalResistanceIncreasePermanent:
      return PhysicalResistancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.magicResistanceIncreasePermanent:
      return MagicResistancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.fireResistanceIncreasePermanent:
      return FireResistancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.psychicResistanceIncreasePermanent:
      return PsychicResistancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.energyResistanceIncreasePermanent:
      return EnergyResistancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.frostResistanceIncreasePermanent:
      return FrostResistancePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.reloadTimePermanent:
      return ReloadTimePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.maxLivesPermanent:
      return MaxLivesPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    default:
      return null;
  }
}

class AreaSizePermanentAttribute extends PermanentAttribute {
  AreaSizePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.areaSizePermanent;

  @override
  double get factor => constants.areaSizeFactor;

  @override
  int get maxLevel => constants.areaSizeMaxLevel;

  @override
  int baseCost = constants.areaSizeBaseCost;

  @override
  bool increaseFromBaseParameter = constants.areaSizeIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.areaSizePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.areaSizePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Area Size';
}

class MeleeDamageIncreasePermanentAttribute extends PermanentAttribute {
  MeleeDamageIncreasePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.meleeDamageIncreasePermanent;

  @override
  double get factor => constants.meleeDamageIncreaseFactor;

  @override
  int get maxLevel => constants.meleeDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.meleeDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.meleeDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.meleeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.meleeDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Melee Damage';
}

class ProjectileDamageIncreasePermanentAttribute extends PermanentAttribute {
  ProjectileDamageIncreasePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.projectileDamageIncreasePermanent;

  @override
  double get factor => constants.projectileDamageIncreaseFactor;

  @override
  int get maxLevel => constants.projectileDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.projectileDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.projectileDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.projectileDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.projectileDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Gun Damage';
}

class SpellDamageIncreasePermanentAttribute extends PermanentAttribute {
  SpellDamageIncreasePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.spellDamageIncreasePermanent;

  @override
  double get factor => constants.spellDamageIncreaseFactor;

  @override
  int get maxLevel => constants.spellDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.spellDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.spellDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.spellDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.spellDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Spell Damage';
}

class TickDamageIncreasePermanentAttribute extends PermanentAttribute {
  TickDamageIncreasePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.tickDamageIncreasePermanent;

  @override
  double get factor => constants.tickDamageIncreaseFactor;

  @override
  int get maxLevel => constants.tickDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.tickDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.tickDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.tickDamageIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.tickDamageIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Tick Damage';
}

class AreaDamageIncreasePermanentAttribute extends PermanentAttribute {
  AreaDamageIncreasePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.areaDamageIncreasePermanent;

  @override
  double get factor => constants.areaDamageIncreaseFactor;

  @override
  int get maxLevel => constants.areaDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.areaDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.areaDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.areaDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.areaDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Area Damage';
}

class StatusEffectPotencyPermanentAttribute extends PermanentAttribute {
  StatusEffectPotencyPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.statusEffectPotencyPermanent;

  @override
  double get factor => constants.statusEffectPotencyFactor;

  @override
  int get maxLevel => constants.statusEffectPotencyMaxLevel;

  @override
  int baseCost = constants.statusEffectPotencyBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.statusEffectPotencyIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.statusEffectsPercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.statusEffectsPercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Effect Potency';
}

class BaseSpeedPermanentAttribute extends PermanentAttribute {
  BaseSpeedPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.speedPermanent;

  @override
  double get factor => constants.speedFactor;

  @override
  int get maxLevel => constants.speedMaxLevel;
  @override
  int baseCost = constants.speedBaseCost;

  @override
  bool increaseFromBaseParameter = constants.speedIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (victimEntity is MovementFunctionality) {
      genericAttributeIncrease(
        (victimEntity! as MovementFunctionality).speed,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is MovementFunctionality) {
      (victimEntity! as MovementFunctionality).speed.removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Move Speed';
}

class MaxStaminaPermanentAttribute extends PermanentAttribute {
  MaxStaminaPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.maxStaminaPermanent;

  @override
  double get factor => constants.maxStaminaFactor;

  @override
  int get maxLevel => constants.maxStaminaMaxLevel;

  @override
  int baseCost = constants.maxStaminaBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.maxStaminaIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (victimEntity is StaminaFunctionality) {
      genericAttributeIncrease(
        (victimEntity! as StaminaFunctionality).stamina,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is StaminaFunctionality) {
      (victimEntity! as StaminaFunctionality).stamina.removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Max Stamina';
}

class MaxHealthPermanentAttribute extends PermanentAttribute {
  MaxHealthPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.maxHealthPermanent;

  @override
  double get factor => constants.maxHealthFactor;

  @override
  int get maxLevel => constants.maxHealthMaxLevel;

  @override
  int baseCost = constants.maxHealthBaseCost;

  @override
  bool increaseFromBaseParameter = constants.maxHealthIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (victimEntity is HealthFunctionality) {
      genericAttributeIncrease(
        (victimEntity! as HealthFunctionality).maxHealth,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is HealthFunctionality) {
      (victimEntity! as HealthFunctionality).maxHealth.removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Max Health';
}

class StaminaRegenPermanentAttribute extends PermanentAttribute {
  StaminaRegenPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.staminaRegenPermanent;

  @override
  double get factor => constants.staminaRegenFactor;

  @override
  int get maxLevel => constants.staminaRegenMaxLevel;

  @override
  int baseCost = constants.staminaRegenBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.staminaRegenIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (victimEntity is StaminaFunctionality) {
      genericAttributeIncrease(
        (victimEntity! as StaminaFunctionality).staminaRegen,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is StaminaFunctionality) {
      (victimEntity! as StaminaFunctionality)
          .staminaRegen
          .removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Stamina Regen';
}

class HealthRegenPermanentAttribute extends PermanentAttribute {
  HealthRegenPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.healthRegenPermanent;

  @override
  double get factor => constants.healthRegenFactor;

  @override
  int get maxLevel => constants.healthRegenMaxLevel;

  @override
  int baseCost = constants.healthRegenBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.healthRegenIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (victimEntity is HealthRegenFunctionality) {
      genericAttributeIncrease(
        (victimEntity! as HealthRegenFunctionality).healthRegen,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is HealthRegenFunctionality) {
      (victimEntity! as HealthRegenFunctionality)
          .healthRegen
          .removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Health Regen';
}

class ExperienceGainPermanentAttribute extends PermanentAttribute {
  ExperienceGainPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.experienceGainPermanent;

  @override
  double get factor => constants.experienceGainFactor;

  @override
  int get maxLevel => constants.experienceGainMaxLevel;

  @override
  int baseCost = constants.experienceGainBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.experienceGainIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (victimEntity is ExperienceFunctionality) {
      genericAttributeIncrease(
        (victimEntity! as ExperienceFunctionality).xpIncreasePercent,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is ExperienceFunctionality) {
      (victimEntity! as ExperienceFunctionality)
          .xpIncreasePercent
          .removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'XP Gained';
}

class DodgeChancePermanentAttribute extends PermanentAttribute {
  DodgeChancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.dodgeChanceIncreasePermanent;

  @override
  double get factor => constants.dodgeChanceFactor;

  @override
  int get maxLevel => constants.dodgeChanceMaxLevel;

  @override
  int baseCost = constants.dodgeChanceBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.dodgeChanceIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (victimEntity is DodgeFunctionality) {
      genericAttributeIncrease(
        (victimEntity! as DodgeFunctionality).dodgeChance,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is DodgeFunctionality) {
      (victimEntity! as DodgeFunctionality).dodgeChance.removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Dodge Chance';
}

class CritChancePermanentAttribute extends PermanentAttribute {
  CritChancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.critChancePermanent;

  @override
  double get factor => constants.critChanceFactor;

  @override
  int get maxLevel => constants.critChanceMaxLevel;

  @override
  int baseCost = constants.critChanceBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.critChanceIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.critChance,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.critChance.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Crit Chance';
}

class CritDamagePermanentAttribute extends PermanentAttribute {
  CritDamagePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.critDamagePermanent;

  @override
  double get factor => constants.critDamageFactor;

  @override
  int get maxLevel => constants.critDamageMaxLevel;

  @override
  int baseCost = constants.critDamageBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.critDamageIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.critDamage,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.critDamage.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Crit Damage';
}

class DurationPermanentAttribute extends PermanentAttribute {
  DurationPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.durationPermanent;

  @override
  double get factor => constants.durationFactor;

  @override
  int get maxLevel => constants.durationMaxLevel;

  @override
  int baseCost = constants.durationBaseCost;

  @override
  bool increaseFromBaseParameter = constants.durationIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.durationPercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.durationPercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Effect Duration';
}

class EssenceStealPermanentAttribute extends PermanentAttribute {
  EssenceStealPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.essenceStealPermanent;

  @override
  double get factor => constants.essenceStealFactor;

  @override
  int get maxLevel => constants.essenceStealMaxLevel;

  @override
  int baseCost = constants.essenceStealBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.essenceStealIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.essenceSteal,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.essenceSteal.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Essence Steal';
}

class AttackRatePermanentAttribute extends PermanentAttribute {
  AttackRatePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.attackRatePermanent;

  @override
  double get factor => constants.attackRateFactor;

  @override
  int get maxLevel => constants.attackRateMaxLevel;

  @override
  int baseCost = constants.attackRateBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.attackRateIncreaseFromBaseParameter;

  @override
  Future<void> mapUpgrade() async {
    for (final element in victimEntity!.getAllWeaponItems(true, false)) {
      genericAttributeIncrease(
        element.attackTickRate,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  Future<void> unMapUpgrade() async {
    for (final element in victimEntity!.getAllWeaponItems(true, false)) {
      element.attackTickRate.removeKey(attributeId);
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Attack Speed';
}

class DamagePermanentAttribute extends PermanentAttribute {
  DamagePermanentAttribute({required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.damageIncreasePermanent;

  @override
  double get factor => constants.damageIncreaseFactor;

  @override
  int get maxLevel => constants.damageIncreaseMaxLevel;

  @override
  int baseCost = constants.damageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.damageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'All Damage';
}

class PhysicalDamagePermanentAttribute extends PermanentAttribute {
  PhysicalDamagePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.physicalDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.physical;

  @override
  double get factor => constants.physicalDamageIncreaseFactor;

  @override
  int get maxLevel => constants.physicalDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.physicalDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.physicalDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypePercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Physical Damage';
}

class MagicDamagePermanentAttribute extends PermanentAttribute {
  MagicDamagePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.magicDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.magic;

  @override
  double get factor => constants.magicDamageIncreaseFactor;

  @override
  int get maxLevel => constants.magicDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.magicDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.magicDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypePercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Magic Damage';
}

class FireDamagePermanentAttribute extends PermanentAttribute {
  FireDamagePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.fireDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.fire;

  @override
  double get factor => constants.fireDamageIncreaseFactor;

  @override
  int get maxLevel => constants.fireDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.fireDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.fireDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypePercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Fire Damage';
}

class PsychicDamagePermanentAttribute extends PermanentAttribute {
  PsychicDamagePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.psychicDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.psychic;

  @override
  double get factor => constants.psychicDamageIncreaseFactor;

  @override
  int get maxLevel => constants.psychicDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.psychicDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.psychicDamageIncreaseIncreaseFromBaseParameter;
  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypePercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Psychic Damage';
}

class EnergyDamagePermanentAttribute extends PermanentAttribute {
  EnergyDamagePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.energyDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.energy;

  @override
  double get factor => constants.energyDamageIncreaseFactor;

  @override
  int get maxLevel => constants.energyDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.energyDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.energyDamageIncreaseIncreaseFromBaseParameter;
  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypePercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Energy Damage';
}

class FrostDamagePermanentAttribute extends PermanentAttribute {
  FrostDamagePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.frostDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.frost;

  @override
  double get factor => constants.frostDamageIncreaseFactor;

  @override
  int get maxLevel => constants.frostDamageIncreaseMaxLevel;

  @override
  int baseCost = constants.frostDamageIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.frostDamageIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypePercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Frost Damage';
}

class PhysicalResistancePermanentAttribute extends PermanentAttribute {
  PhysicalResistancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType =
      AttributeType.physicalResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.physical;

  @override
  double get factor => constants.physicalResistanceIncreaseFactor;

  @override
  int get maxLevel => constants.physicalResistanceIncreaseMaxLevel;

  @override
  int baseCost = constants.physicalResistanceIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.physicalResistanceIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Physical Res';
}

class MagicResistancePermanentAttribute extends PermanentAttribute {
  MagicResistancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.magicResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.magic;

  @override
  double get factor => constants.magicResistanceIncreaseFactor;

  @override
  int get maxLevel => constants.magicResistanceIncreaseMaxLevel;

  @override
  int baseCost = constants.magicResistanceIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.magicResistanceIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Magic Res';
}

class FireResistancePermanentAttribute extends PermanentAttribute {
  FireResistancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.fireResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.fire;

  @override
  double get factor => constants.fireResistanceIncreaseFactor;

  @override
  int get maxLevel => constants.fireResistanceIncreaseMaxLevel;

  @override
  int baseCost = constants.fireResistanceIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.fireResistanceIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Fire Res';
}

class PsychicResistancePermanentAttribute extends PermanentAttribute {
  PsychicResistancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType =
      AttributeType.psychicResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.psychic;

  @override
  double get factor => constants.psychicResistanceIncreaseFactor;

  @override
  int get maxLevel => constants.psychicResistanceIncreaseMaxLevel;

  @override
  int baseCost = constants.psychicResistanceIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.psychicResistanceIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Psychic Res';
}

class EnergyResistancePermanentAttribute extends PermanentAttribute {
  EnergyResistancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.energyResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.energy;

  @override
  double get factor => constants.energyResistanceIncreaseFactor;

  @override
  int get maxLevel => constants.energyResistanceIncreaseMaxLevel;

  @override
  int baseCost = constants.energyResistanceIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.energyResistanceIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Energy Res';
}

class FrostResistancePermanentAttribute extends PermanentAttribute {
  FrostResistancePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });

  @override
  AttributeType attributeType = AttributeType.frostResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.frost;

  @override
  double get factor => constants.frostResistanceIncreaseFactor;

  @override
  int get maxLevel => constants.frostResistanceIncreaseMaxLevel;

  @override
  int baseCost = constants.frostResistanceIncreaseBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.frostResistanceIncreaseIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      victimEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Frost Res';
}

class ReloadTimePermanentAttribute extends PermanentAttribute {
  ReloadTimePermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.reloadTimePermanent;

  @override
  double get factor => constants.reloadTimeFactor;

  @override
  int get maxLevel => constants.reloadTimeMaxLevel;

  @override
  int baseCost = constants.reloadTimeBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.reloadTimeIncreaseFromBaseParameter;

  @override
  Future<void> mapUpgrade() async {
    for (final element in victimEntity!.getAllWeaponItems(true, false)) {
      if (element is ReloadFunctionality) {
        genericAttributeIncrease(
          element.reloadTime,
          increaseFromBaseParameter,
          false,
        );
      }
    }
  }

  @override
  Future<void> unMapUpgrade() async {
    for (final element in victimEntity!.getAllWeaponItems(true, false)) {
      if (element is ReloadFunctionality) {
        element.reloadTime.removeKey(attributeId);
      }
    }
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Attack Speed';
}

class MaxLivesPermanentAttribute extends PermanentAttribute {
  MaxLivesPermanentAttribute({
    required super.level,
    required super.victimEntity,
  });
  @override
  AttributeType attributeType = AttributeType.maxLivesPermanent;

  @override
  double get factor => constants.maxLivesFactor;

  @override
  int get maxLevel => constants.maxLivesMaxLevel;

  @override
  int baseCost = constants.maxLivesBaseCost;

  @override
  bool increaseFromBaseParameter = constants.maxLivesIncreaseFromBaseParameter;

  @override
  Future<void> mapUpgrade() async {
    victimEntity?.maxLives.setParameterFlatValue(
      attributeId,
      increase(increaseFromBaseParameter).round(),
    );
  }

  @override
  Future<void> unMapUpgrade() async {
    victimEntity?.maxLives.removeKey(attributeId);
  }

  @override
  String icon = 'attributes/topSpeed.png';

  @override
  String title = 'Max Lives';

  @override
  String description() {
    return upgradeLevel == maxLevel ? '' : (upgradeLevel + 1).toString();
  }
}
