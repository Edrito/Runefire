import 'package:flutter/material.dart';
import 'package:game_app/attributes/attributes_perpetrator.dart';

import '../resources/data_classes/base.dart';
import '../resources/enums.dart';
import 'attributes_mixin.dart';
import '../entities/entity.dart';
import 'attributes_regular.dart';
import 'attributes_permanent.dart';
import 'attributes_status_effect.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../overlays/cards.dart';
import '../resources/functions/custom_mixins.dart';

/// This file contains all the enums for the attributes.
/// It also contains the extension methods for the enums.

/// Gives the player a sense of how strong an attribute is.
enum AttributeRarity { unique, rare, uncommon, standard }

extension AttributeRarityExtension on AttributeRarity {
  Color get color {
    switch (this) {
      case AttributeRarity.standard:
        return Colors.white;
      case AttributeRarity.uncommon:
        return Colors.blue;
      case AttributeRarity.rare:
        return Colors.purple;
      case AttributeRarity.unique:
        return const Color.fromARGB(255, 252, 185, 0);
    }
  }
}

///Used to filter and categorize attributes for level selection
enum AttributeCategory {
  mobility,
  attack,
  projectile,
  melee,
  defence,
  offense,
  utility
}

enum AttributeTerritory { permanent, game, temporary }

enum AttributeType {
  //Debuffs
  burn(territory: AttributeTerritory.temporary),
  bleed(territory: AttributeTerritory.temporary),
  chill(territory: AttributeTerritory.temporary),
  electrified(territory: AttributeTerritory.temporary),
  stun(territory: AttributeTerritory.temporary),
  psychic(territory: AttributeTerritory.temporary),

  //Permanent
  areaSize,
  areaDamageIncrease(category: AttributeCategory.offense),

  meleeDamageIncrease(category: AttributeCategory.melee),
  projectileDamageIncrease(category: AttributeCategory.projectile),
  spellDamageIncrease(category: AttributeCategory.projectile),
  tickDamageIncrease(category: AttributeCategory.offense),

  statusEffectPotency(category: AttributeCategory.offense),

  speed(category: AttributeCategory.mobility),
  maxStamina(category: AttributeCategory.mobility),
  maxHealth(category: AttributeCategory.defence),
  staminaRegen(category: AttributeCategory.mobility),
  healthRegen(category: AttributeCategory.defence),
  experienceGain(category: AttributeCategory.utility),
  dodgeChanceIncrease(category: AttributeCategory.defence),
  critChance(category: AttributeCategory.offense),
  critDamage(category: AttributeCategory.offense),
  duration,
  essenceSteal(category: AttributeCategory.offense),

  attackRate(category: AttributeCategory.attack),
  damageIncrease(category: AttributeCategory.offense),

// enum DamageType { physical, magic, fire, psychic, energy, frost }
  physicalDamageIncrease(category: AttributeCategory.offense),
  magicDamageIncrease(category: AttributeCategory.offense),
  fireDamageIncrease(category: AttributeCategory.offense),
  psychicDamageIncrease(category: AttributeCategory.offense),
  energyDamageIncrease(category: AttributeCategory.offense),
  frostDamageIncrease(category: AttributeCategory.offense),

  physicalResistanceIncrease(category: AttributeCategory.offense),
  magicResistanceIncrease(category: AttributeCategory.offense),
  fireResistanceIncrease(category: AttributeCategory.offense),
  psychicResistanceIncrease(category: AttributeCategory.offense),
  energyResistanceIncrease(category: AttributeCategory.offense),
  frostResistanceIncrease(category: AttributeCategory.offense),

  reloadTime(category: AttributeCategory.utility),

  ///Game Attributes
  enemyExplosion(
      rarity: AttributeRarity.unique,
      category: AttributeCategory.mobility,
      territory: AttributeTerritory.game);

  const AttributeType(
      {this.rarity = AttributeRarity.standard,
      this.category = AttributeCategory.utility,
      this.territory = AttributeTerritory.permanent});

  final AttributeRarity rarity;
  final AttributeCategory category;
  final AttributeTerritory territory;
}

extension AllAttributesExtension on AttributeType {
  Attribute buildAttribute(int level, AttributeFunctionality? victimEntity,
      {Entity? perpetratorEntity,
      DamageType? damageType,
      StatusEffects? statusEffect}) {
    final permanentAttr = permanentAttributeBuilder(this, level, victimEntity);
    if (permanentAttr != null) return permanentAttr;
    if (victimEntity != null && perpetratorEntity != null) {
      final perpetratorAttr = perpetratorAttributeBuilder(
          this, level, victimEntity, perpetratorEntity);
      if (perpetratorAttr != null) return perpetratorAttr;
    }

    switch (this) {
      case AttributeType.burn:
        return FireDamageAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );

      case AttributeType.enemyExplosion:
        return ExplosionEnemyDeathAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );
      default:
        return ExplosionEnemyDeathAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );
    }
  }
}

///Status effect, increase in levels, abilities etc
///Different classes that are applied to an Entity that may be sourced
///from a level up, a enemy attack, a weapon, a potion etc
///The attribute is applied to the victimEntity
///The perpetratorEntity may be a source of a negitive attribute
abstract class Attribute with UpgradeFunctions {
  Attribute({int level = 0, this.victimEntity, this.damageType}) {
    upgradeLevel = level.clamp(0, maxLevel);
    attributeId = const Uuid().v4();
  }

  bool hasRandomDamageType = false;
  bool hasRandomStatusEffect = false;
  DamageType? damageType;
  bool get isTemporary => this is TemporaryAttribute;
  AttributeTerritory get attributeTerritory => attributeType.territory;

  String description();
  String help() {
    return "An increase of ${((factor ?? 0) * 100)}% of your base attribute with an additional ${((factor ?? 0) * 100)}% at max level.";
  }

  late String attributeId;
  abstract String icon;
  abstract String title;
  double? factor;
  abstract bool increaseFromBaseParameter;
  AttributeFunctionality? victimEntity;

  int get remainingLevels => maxLevel - upgradeLevel;

  @override
  int maxLevel = 5;

  double increase(bool increaseFromBaseParameter, [double? base]) =>
      increaseFromBaseParameter
          ? increasePercentOfBase(base!)
          : increaseWithoutBase();

  ///Default increase is multiplying the baseParameter by [factor]%
  ///then multiplying it again by the level of the attribute
  ///with an additional level for max level
  double increasePercentOfBase(double base) =>
      ((factor ?? 0) * base) *
      (upgradeLevel + (upgradeLevel == maxLevel ? 1 : 0));

  double increaseWithoutBase() =>
      (factor ?? 0) * (upgradeLevel + (upgradeLevel == maxLevel ? 1 : 0));

  AttributeType get attributeType;

  ///Increase or decrease the level based on the input value

  CustomCard buildWidget(
      {Function? onTap, Function? onTapComplete, bool small = false}) {
    return CustomCard(
      this,
      gameRef: gameRouter,
      onTap: onTap,
      onTapComplete: onTapComplete,
      smallCard: small,
    );
  }

  void genericAttributeIncrease(dynamic parameterManager,
      bool increaseFromBaseParameter, bool increaseParameterPercentage) {
    switch (parameterManager.runtimeType) {
      case DoubleParameterManager:
        if (increaseParameterPercentage) {
          (parameterManager as DoubleParameterManager).setParameterPercentValue(
              attributeId,
              increase(
                  increaseFromBaseParameter, parameterManager.baseParameter));
        } else {
          (parameterManager as DoubleParameterManager).setParameterFlatValue(
              attributeId,
              increase(
                  increaseFromBaseParameter, parameterManager.baseParameter));
        }
        break;
      case IntParameterManager:
        if (increaseParameterPercentage) {
          (parameterManager as IntParameterManager).setParameterPercentValue(
              attributeId,
              increase(increaseFromBaseParameter,
                  parameterManager.baseParameter.toDouble()));
        } else {
          (parameterManager as IntParameterManager).setParameterFlatValue(
              attributeId,
              increase(increaseFromBaseParameter,
                      parameterManager.baseParameter.toDouble())
                  .round());
        }
        break;
      case BoolParameterManager:
        (parameterManager as BoolParameterManager)
            .setIncrease(attributeId, true);

        break;
      case StatusEffectPercentParameterManager:
        (parameterManager as StatusEffectPercentParameterManager)
            .increaseAllPercent(attributeId, increase(false));

        break;
      default:
    }
  }
}
