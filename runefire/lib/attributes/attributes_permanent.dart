import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/resources/enums.dart';
import 'package:runefire/attributes/attribute_constants.dart' as constants;
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/damage_type_enum.dart';

abstract class PermanentAttribute extends Attribute {
  PermanentAttribute(
      {required super.level, required super.attributeOwnerEntity});

  abstract int baseCost;

  ///Cost of the level up, default is the next level cost
  int cost([int? level]) {
    return baseCost * (level ?? (upgradeLevel + 1));
  }
}

PermanentAttribute? permanentAttributeBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? attributeOwnerEntity,
) {
  switch (type) {
    case AttributeType.speedPermanent:
      return BaseSpeedPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.attackRatePermanent:
      return AttackRatePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.areaSizePermanent:
      return AreaSizePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.areaDamageIncreasePermanent:
      return AreaDamageIncreasePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.meleeDamageIncreasePermanent:
      return MeleeDamageIncreasePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.projectileDamageIncreasePermanent:
      return ProjectileDamageIncreasePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.spellDamageIncreasePermanent:
      return SpellDamageIncreasePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.tickDamageIncreasePermanent:
      return TickDamageIncreasePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.statusEffectPotencyPermanent:
      return StatusEffectPotencyPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.maxStaminaPermanent:
      return MaxStaminaPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.maxHealthPermanent:
      return MaxHealthPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.staminaRegenPermanent:
      return StaminaRegenPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.healthRegenPermanent:
      return HealthRegenPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.experienceGainPermanent:
      return ExperienceGainPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.dodgeChanceIncreasePermanent:
      return DodgeChancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.critChancePermanent:
      return CritChancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.critDamagePermanent:
      return CritDamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.durationPermanent:
      return DurationPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.essenceStealPermanent:
      return EssenceStealPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.damageIncreasePermanent:
      return DamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.physicalDamageIncreasePermanent:
      return PhysicalDamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.magicDamageIncreasePermanent:
      return MagicDamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.fireDamageIncreasePermanent:
      return FireDamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.psychicDamageIncreasePermanent:
      return PsychicDamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.energyDamageIncreasePermanent:
      return EnergyDamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.frostDamageIncreasePermanent:
      return FrostDamagePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.physicalResistanceIncreasePermanent:
      return PhysicalResistancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.magicResistanceIncreasePermanent:
      return MagicResistancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.fireResistanceIncreasePermanent:
      return FireResistancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.psychicResistanceIncreasePermanent:
      return PsychicResistancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.energyResistanceIncreasePermanent:
      return EnergyResistancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.frostResistanceIncreasePermanent:
      return FrostResistancePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.reloadTimePermanent:
      return ReloadTimePermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.maxLivesPermanent:
      return MaxLivesPermanentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    default:
      return null;
  }
}

class AreaSizePermanentAttribute extends PermanentAttribute {
  AreaSizePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.areaSizePermanent;

  @override
  double get upgradeFactor => constants.areaSizeFactor;

  @override
  int get maxLevel => constants.areaSizeMaxLevel;

  @override
  int baseCost = constants.areaSizeBaseCost;

  @override
  bool increaseFromBaseParameter = constants.areaSizeIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      attributeOwnerEntity?.areaSizePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.areaSizePercentIncrease.removeKey(attributeId);
  }

  @override
  String title = 'Area Size';
}

class MeleeDamageIncreasePermanentAttribute extends PermanentAttribute {
  MeleeDamageIncreasePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.meleeDamageIncreasePermanent;

  @override
  double get upgradeFactor => constants.meleeDamageIncreaseFactor;

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
      attributeOwnerEntity?.meleeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.meleeDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String title = 'Melee Damage';
}

class ProjectileDamageIncreasePermanentAttribute extends PermanentAttribute {
  ProjectileDamageIncreasePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.projectileDamageIncreasePermanent;

  @override
  double get upgradeFactor => constants.projectileDamageIncreaseFactor;

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
      attributeOwnerEntity?.projectileDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.projectileDamagePercentIncrease
        .removeKey(attributeId);
  }

  @override
  String title = 'Gun Damage';
}

class SpellDamageIncreasePermanentAttribute extends PermanentAttribute {
  SpellDamageIncreasePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.spellDamageIncreasePermanent;

  @override
  double get upgradeFactor => constants.spellDamageIncreaseFactor;

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
      attributeOwnerEntity?.spellDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.spellDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String title = 'Spell Damage';
}

class TickDamageIncreasePermanentAttribute extends PermanentAttribute {
  TickDamageIncreasePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.tickDamageIncreasePermanent;

  @override
  double get upgradeFactor => constants.tickDamageIncreaseFactor;

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
      attributeOwnerEntity?.tickDamageIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.tickDamageIncrease.removeKey(attributeId);
  }

  @override
  String title = 'Tick Damage';
}

class AreaDamageIncreasePermanentAttribute extends PermanentAttribute {
  AreaDamageIncreasePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.areaDamageIncreasePermanent;

  @override
  double get upgradeFactor => constants.areaDamageIncreaseFactor;

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
      attributeOwnerEntity?.areaDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.areaDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String title = 'Area Damage';
}

class StatusEffectPotencyPermanentAttribute extends PermanentAttribute {
  StatusEffectPotencyPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.statusEffectPotencyPermanent;

  @override
  double get upgradeFactor => constants.statusEffectPotencyFactor;

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
      attributeOwnerEntity?.statusEffectsPercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.statusEffectsPercentIncrease
        .removePercentKey(attributeId);
  }

  @override
  String title = 'Effect Potency';
}

class BaseSpeedPermanentAttribute extends PermanentAttribute {
  BaseSpeedPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.speedPermanent;

  @override
  double get upgradeFactor => constants.speedFactor;

  @override
  int get maxLevel => constants.speedMaxLevel;
  @override
  int baseCost = constants.speedBaseCost;

  @override
  bool increaseFromBaseParameter = constants.speedIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is MovementFunctionality) {
      genericAttributeIncrease(
        (attributeOwnerEntity! as MovementFunctionality).speed,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is MovementFunctionality) {
      (attributeOwnerEntity! as MovementFunctionality)
          .speed
          .removeKey(attributeId);
    }
  }

  @override
  String title = 'Move Speed';
}

class MaxStaminaPermanentAttribute extends PermanentAttribute {
  MaxStaminaPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.maxStaminaPermanent;

  @override
  double get upgradeFactor => constants.maxStaminaFactor;

  @override
  int get maxLevel => constants.maxStaminaMaxLevel;

  @override
  int baseCost = constants.maxStaminaBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.maxStaminaIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is StaminaFunctionality) {
      genericAttributeIncrease(
        (attributeOwnerEntity! as StaminaFunctionality).stamina,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is StaminaFunctionality) {
      (attributeOwnerEntity! as StaminaFunctionality)
          .stamina
          .removeKey(attributeId);
    }
  }

  @override
  String title = 'Max Stamina';
}

class MaxHealthPermanentAttribute extends PermanentAttribute {
  MaxHealthPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.maxHealthPermanent;

  @override
  double get upgradeFactor => constants.maxHealthFactor;

  @override
  int get maxLevel => constants.maxHealthMaxLevel;

  @override
  int baseCost = constants.maxHealthBaseCost;

  @override
  bool increaseFromBaseParameter = constants.maxHealthIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is HealthFunctionality) {
      genericAttributeIncrease(
        (attributeOwnerEntity! as HealthFunctionality).maxHealth,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is HealthFunctionality) {
      (attributeOwnerEntity! as HealthFunctionality)
          .maxHealth
          .removeKey(attributeId);
    }
  }

  @override
  String title = 'Max Health';
}

class StaminaRegenPermanentAttribute extends PermanentAttribute {
  StaminaRegenPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.staminaRegenPermanent;

  @override
  double get upgradeFactor => constants.staminaRegenFactor;

  @override
  int get maxLevel => constants.staminaRegenMaxLevel;

  @override
  int baseCost = constants.staminaRegenBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.staminaRegenIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is StaminaFunctionality) {
      genericAttributeIncrease(
        (attributeOwnerEntity! as StaminaFunctionality).staminaRegen,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is StaminaFunctionality) {
      (attributeOwnerEntity! as StaminaFunctionality)
          .staminaRegen
          .removeKey(attributeId);
    }
  }

  @override
  String title = 'Stamina Regen';
}

class HealthRegenPermanentAttribute extends PermanentAttribute {
  HealthRegenPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.healthRegenPermanent;

  @override
  double get upgradeFactor => constants.healthRegenFactor;

  @override
  int get maxLevel => constants.healthRegenMaxLevel;

  @override
  int baseCost = constants.healthRegenBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.healthRegenIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is HealthRegenFunctionality) {
      genericAttributeIncrease(
        (attributeOwnerEntity! as HealthRegenFunctionality).healthRegen,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is HealthRegenFunctionality) {
      (attributeOwnerEntity! as HealthRegenFunctionality)
          .healthRegen
          .removeKey(attributeId);
    }
  }

  @override
  String title = 'Health Regen';
}

class ExperienceGainPermanentAttribute extends PermanentAttribute {
  ExperienceGainPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.experienceGainPermanent;

  @override
  double get upgradeFactor => constants.experienceGainFactor;

  @override
  int get maxLevel => constants.experienceGainMaxLevel;

  @override
  int baseCost = constants.experienceGainBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.experienceGainIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is ExperienceFunctionality) {
      genericAttributeIncrease(
        (attributeOwnerEntity! as ExperienceFunctionality).xpIncreasePercent,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is ExperienceFunctionality) {
      (attributeOwnerEntity! as ExperienceFunctionality)
          .xpIncreasePercent
          .removeKey(attributeId);
    }
  }

  @override
  String title = 'XP Gained';
}

class DodgeChancePermanentAttribute extends PermanentAttribute {
  DodgeChancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.dodgeChanceIncreasePermanent;

  @override
  double get upgradeFactor => constants.dodgeChanceFactor;

  @override
  int get maxLevel => constants.dodgeChanceMaxLevel;

  @override
  int baseCost = constants.dodgeChanceBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.dodgeChanceIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is DodgeFunctionality) {
      genericAttributeIncrease(
        (attributeOwnerEntity! as DodgeFunctionality).dodgeChance,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is DodgeFunctionality) {
      (attributeOwnerEntity! as DodgeFunctionality)
          .dodgeChance
          .removeKey(attributeId);
    }
  }

  @override
  String title = 'Dodge Chance';
}

class CritChancePermanentAttribute extends PermanentAttribute {
  CritChancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.critChancePermanent;

  @override
  double get upgradeFactor => constants.critChanceFactor;

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
      attributeOwnerEntity?.critChance,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.critChance.removeKey(attributeId);
  }

  @override
  String title = 'Crit Chance';
}

class CritDamagePermanentAttribute extends PermanentAttribute {
  CritDamagePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.critDamagePermanent;

  @override
  double get upgradeFactor => constants.critDamageFactor;

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
      attributeOwnerEntity?.critDamage,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.critDamage.removeKey(attributeId);
  }

  @override
  String title = 'Crit Damage';
}

class DurationPermanentAttribute extends PermanentAttribute {
  DurationPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.durationPermanent;

  @override
  double get upgradeFactor => constants.durationFactor;

  @override
  int get maxLevel => constants.durationMaxLevel;

  @override
  int baseCost = constants.durationBaseCost;

  @override
  bool increaseFromBaseParameter = constants.durationIncreaseFromBaseParameter;

  @override
  void mapUpgrade() {
    genericAttributeIncrease(
      attributeOwnerEntity?.durationPercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.durationPercentIncrease.removeKey(attributeId);
  }

  @override
  String title = 'Effect Duration';
}

class EssenceStealPermanentAttribute extends PermanentAttribute {
  EssenceStealPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.essenceStealPermanent;

  @override
  double get upgradeFactor => constants.essenceStealFactor;

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
      attributeOwnerEntity?.essenceSteal,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.essenceSteal.removeKey(attributeId);
  }

  @override
  String title = 'Essence Steal';
}

class AttackRatePermanentAttribute extends PermanentAttribute {
  AttackRatePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.attackRatePermanent;

  @override
  double get upgradeFactor => constants.attackRateFactor;

  @override
  int get maxLevel => constants.attackRateMaxLevel;

  @override
  int baseCost = constants.attackRateBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.attackRateIncreaseFromBaseParameter;

  @override
  Future<void> mapUpgrade() async {
    for (final element
        in attributeOwnerEntity!.getAllWeaponItems(true, false)) {
      genericAttributeIncrease(
        element.attackTickRate,
        increaseFromBaseParameter,
        false,
      );
    }
  }

  @override
  Future<void> unMapUpgrade() async {
    for (final element
        in attributeOwnerEntity!.getAllWeaponItems(true, false)) {
      element.attackTickRate.removeKey(attributeId);
    }
  }

  @override
  String title = 'Attack Speed';
}

class DamagePermanentAttribute extends PermanentAttribute {
  DamagePermanentAttribute({required super.level, required super.attributeOwnerEntity});
  @override
  AttributeType attributeType = AttributeType.damageIncreasePermanent;

  @override
  double get upgradeFactor => constants.damageIncreaseFactor;

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
      attributeOwnerEntity?.damagePercentIncrease,
      increaseFromBaseParameter,
      false,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease.removeKey(attributeId);
  }

  @override
  String title = 'All Damage';
}

class PhysicalDamagePermanentAttribute extends PermanentAttribute {
  PhysicalDamagePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.physicalDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.physical;

  @override
  double get upgradeFactor => constants.physicalDamageIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeDamagePercentIncrease
        .removePercentKey(attributeId);
  }

  @override
  String title = 'Physical Damage';
}

class MagicDamagePermanentAttribute extends PermanentAttribute {
  MagicDamagePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.magicDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.magic;

  @override
  double get upgradeFactor => constants.magicDamageIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeDamagePercentIncrease
        .removePercentKey(attributeId);
  }

  @override
  String title = 'Magic Damage';
}

class FireDamagePermanentAttribute extends PermanentAttribute {
  FireDamagePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.fireDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.fire;

  @override
  double get upgradeFactor => constants.fireDamageIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeDamagePercentIncrease
        .removePercentKey(attributeId);
  }

  @override
  String title = 'Fire Damage';
}

class PsychicDamagePermanentAttribute extends PermanentAttribute {
  PsychicDamagePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.psychicDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.psychic;

  @override
  double get upgradeFactor => constants.psychicDamageIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeDamagePercentIncrease
        .removePercentKey(attributeId);
  }

  @override
  String title = 'Psychic Damage';
}

class EnergyDamagePermanentAttribute extends PermanentAttribute {
  EnergyDamagePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.energyDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.energy;

  @override
  double get upgradeFactor => constants.energyDamageIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeDamagePercentIncrease
        .removePercentKey(attributeId);
  }

  @override
  String title = 'Energy Damage';
}

class FrostDamagePermanentAttribute extends PermanentAttribute {
  FrostDamagePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.frostDamageIncreasePermanent;

  @override
  DamageType get damageType => DamageType.frost;

  @override
  double get upgradeFactor => constants.frostDamageIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeDamagePercentIncrease,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeDamagePercentIncrease
        .removePercentKey(attributeId);
  }

  @override
  String title = 'Frost Damage';
}

class PhysicalResistancePermanentAttribute extends PermanentAttribute {
  PhysicalResistancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType =
      AttributeType.physicalResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.physical;

  @override
  double get upgradeFactor => constants.physicalResistanceIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String title = 'Physical Res';
}

class MagicResistancePermanentAttribute extends PermanentAttribute {
  MagicResistancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.magicResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.magic;

  @override
  double get upgradeFactor => constants.magicResistanceIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String title = 'Magic Res';
}

class FireResistancePermanentAttribute extends PermanentAttribute {
  FireResistancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.fireResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.fire;

  @override
  double get upgradeFactor => constants.fireResistanceIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String title = 'Fire Res';
}

class PsychicResistancePermanentAttribute extends PermanentAttribute {
  PsychicResistancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType =
      AttributeType.psychicResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.psychic;

  @override
  double get upgradeFactor => constants.psychicResistanceIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String title = 'Psychic Res';
}

class EnergyResistancePermanentAttribute extends PermanentAttribute {
  EnergyResistancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.energyResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.energy;

  @override
  double get upgradeFactor => constants.energyResistanceIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String title = 'Energy Res';
}

class FrostResistancePermanentAttribute extends PermanentAttribute {
  FrostResistancePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.frostResistanceIncreasePermanent;

  @override
  DamageType get damageType => DamageType.frost;

  @override
  double get upgradeFactor => constants.frostResistanceIncreaseFactor;

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
      attributeOwnerEntity?.damageTypeResistance,
      increaseFromBaseParameter,
      false,
      damageType,
    );
  }

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
  }

  @override
  String title = 'Frost Res';
}

class ReloadTimePermanentAttribute extends PermanentAttribute {
  ReloadTimePermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.reloadTimePermanent;

  @override
  double get upgradeFactor => constants.reloadTimeFactor;

  @override
  int get maxLevel => constants.reloadTimeMaxLevel;

  @override
  int baseCost = constants.reloadTimeBaseCost;

  @override
  bool increaseFromBaseParameter =
      constants.reloadTimeIncreaseFromBaseParameter;

  @override
  Future<void> mapUpgrade() async {
    for (final element
        in attributeOwnerEntity!.getAllWeaponItems(true, false)) {
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
    for (final element
        in attributeOwnerEntity!.getAllWeaponItems(true, false)) {
      if (element is ReloadFunctionality) {
        element.reloadTime.removeKey(attributeId);
      }
    }
  }

  @override
  String title = 'Attack Speed';
}

class MaxLivesPermanentAttribute extends PermanentAttribute {
  MaxLivesPermanentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });
  @override
  AttributeType attributeType = AttributeType.maxLivesPermanent;

  @override
  double get upgradeFactor => constants.maxLivesFactor;

  @override
  int get maxLevel => constants.maxLivesMaxLevel;

  @override
  int baseCost = constants.maxLivesBaseCost;

  @override
  bool increaseFromBaseParameter = constants.maxLivesIncreaseFromBaseParameter;

  @override
  Future<void> mapUpgrade() async {
    attributeOwnerEntity?.maxLives.setParameterFlatValue(
      attributeId,
      increase(increaseFromBaseParameter).round(),
    );
  }

  @override
  Future<void> unMapUpgrade() async {
    attributeOwnerEntity?.maxLives.removeKey(attributeId);
  }

  @override
  String title = 'Max Lives';

  @override
  String description() {
    return upgradeLevel == maxLevel ? '' : (upgradeLevel + 1).toString();
  }
}
