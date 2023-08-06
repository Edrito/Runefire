import 'package:flutter/material.dart';
import 'package:game_app/attributes/attributes_perpetrator.dart';

import '../resources/data_classes/base.dart';
import '../resources/enums.dart';
import 'attributes_mixin.dart';
import '../entities/entity.dart';
import 'attributes_regular.dart';
import 'attributes_permanent.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../menus/cards.dart';
import '../resources/functions/custom_mixins.dart';
import 'attributes_status_effect.dart';

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
  resistance,
  damage,
  utility,
  health
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
  areaSizePermanent,
  areaDamageIncreasePermanent(category: AttributeCategory.offense),
  meleeDamageIncreasePermanent(category: AttributeCategory.offense),
  projectileDamageIncreasePermanent(category: AttributeCategory.offense),
  spellDamageIncreasePermanent(category: AttributeCategory.offense),
  tickDamageIncreasePermanent(category: AttributeCategory.offense),
  critChancePermanent(category: AttributeCategory.offense),
  critDamagePermanent(category: AttributeCategory.offense),
  attackRatePermanent(category: AttributeCategory.offense),
  damageIncreasePermanent(category: AttributeCategory.offense),
  healthRegenPermanent(category: AttributeCategory.defence),
  dodgeChanceIncreasePermanent(category: AttributeCategory.defence),
  maxHealthPermanent(category: AttributeCategory.defence),
  essenceStealPermanent(category: AttributeCategory.defence),
  maxLivesPermanent(category: AttributeCategory.defence),
  speedPermanent(category: AttributeCategory.mobility),
  maxStaminaPermanent(category: AttributeCategory.mobility),
  staminaRegenPermanent(category: AttributeCategory.mobility),
  experienceGainPermanent(category: AttributeCategory.utility),
  durationPermanent,
  reloadTimePermanent(),
  statusEffectPotencyPermanent(category: AttributeCategory.utility),
  physicalDamageIncreasePermanent(category: AttributeCategory.damage),
  magicDamageIncreasePermanent(category: AttributeCategory.damage),
  fireDamageIncreasePermanent(category: AttributeCategory.damage),
  psychicDamageIncreasePermanent(category: AttributeCategory.damage),
  energyDamageIncreasePermanent(category: AttributeCategory.damage),
  frostDamageIncreasePermanent(category: AttributeCategory.damage),
  physicalResistanceIncreasePermanent(category: AttributeCategory.resistance),
  magicResistanceIncreasePermanent(category: AttributeCategory.resistance),
  fireResistanceIncreasePermanent(category: AttributeCategory.resistance),
  psychicResistanceIncreasePermanent(category: AttributeCategory.resistance),
  energyResistanceIncreasePermanent(category: AttributeCategory.resistance),
  frostResistanceIncreasePermanent(category: AttributeCategory.resistance),

  ///Game Attributes
  fireExplosionOnKill(
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
  Attribute buildAttribute(
    int level,
    AttributeFunctionality? victimEntity, {
    Entity? perpetratorEntity,
    DamageType? damageType,
    StatusEffects? statusEffect,
    bool isTemporary = false,
    double? duration,
  }) {
    final permanentAttr = permanentAttributeBuilder(this, level, victimEntity);
    if (permanentAttr != null) return permanentAttr;
    if (victimEntity != null) {
      final regularAttr =
          regularAttributeBuilder(this, level, victimEntity, damageType);
      if (regularAttr != null) return regularAttr;

      if (perpetratorEntity != null) {
        final perpetratorAttr = perpetratorAttributeBuilder(
            this, level, victimEntity, perpetratorEntity);
        if (perpetratorAttr != null) return perpetratorAttr;

        if (statusEffect != null) {
          final statusEffectAttr = statusEffectBuilder(
            statusEffect,
            level,
            victimEntity,
            perpetratorEntity: perpetratorEntity,
            isTemporary: isTemporary,
            duration: duration,
          );
          if (statusEffectAttr != null) return statusEffectAttr;
        }
      }
    }

    switch (this) {
      case AttributeType.fireExplosionOnKill:
        return FireExplosionEnemyDeathAttribute(
          level: level,
          victimEntity: victimEntity,
        );
      default:
        return FireExplosionEnemyDeathAttribute(
          level: level,
          victimEntity: victimEntity,
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
    upgradeLevel = level;
    if (maxLevel != null) {
      upgradeLevel = upgradeLevel.clamp(0, maxLevel!);
    }
    attributeId = const Uuid().v4();
  }

  bool hasRandomDamageType = false;
  bool hasRandomStatusEffect = false;
  DamageType? damageType;
  bool get isTemporary => this is TemporaryAttribute;
  AttributeTerritory get attributeTerritory => attributeType.territory;

  String description() {
    final percent = ((factor ?? 0) * 100).abs().round();

    String current = "${upgradeLevel * percent}%";
    String next = "${(upgradeLevel + 1) * percent}%";

    return "$current${upgradeLevel == maxLevel ? "" : " ⇒ $next"}";
  }

  String help() {
    return "An increase of ${((factor ?? 0) * 100)}% of your base attribute with an additional ${((factor ?? 0) * 100)}% at max level.";
  }

  late String attributeId;
  abstract String icon;
  abstract String title;
  double? factor;
  abstract bool increaseFromBaseParameter;
  AttributeFunctionality? victimEntity;

  int get remainingLevels => (maxLevel ?? upgradeLevel) - upgradeLevel;

  @override
  int? maxLevel = 5;

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
      gameRef: gameState.gameRouter,
      onTap: onTap,
      onTapComplete: onTapComplete,
      smallCard: small,
    );
  }

  void genericAttributeIncrease(dynamic parameterManager,
      bool increaseFromBaseParameter, bool increaseParameterPercentage,
      [DamageType? damageType]) {
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

      case DamagePercentParameterManager:
        (parameterManager as DamagePercentParameterManager)
            .setDamagePercentIncrease(
                attributeId, damageType!, increase(false));

        break;

      default:
    }
  }
}
