import 'package:flutter/material.dart';
import 'package:game_app/attributes/temporary_attributes.dart';

import 'attributes_mixin.dart';
import '../entities/entity.dart';
import 'attributes.dart';

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
  temporary,
  utility
}

enum AttributeTerritory { permanent, game }

enum AttributeEnum {
  //Debuffs
  burn(category: AttributeCategory.temporary),
  bleed(category: AttributeCategory.temporary),
  chill(category: AttributeCategory.temporary),
  electrified(category: AttributeCategory.temporary),
  stun(category: AttributeCategory.temporary),
  psychic(category: AttributeCategory.temporary),

  //Permanent
  speed(category: AttributeCategory.mobility),
  attackRate(category: AttributeCategory.attack),
  duration(),
  durationDamage(category: AttributeCategory.offense),
  areaSize(),
  areaDamage(category: AttributeCategory.offense),
  critChance(category: AttributeCategory.offense),
  critDamage(category: AttributeCategory.offense),
  fireDamageIncrease(category: AttributeCategory.offense),
  physicalDamageIncrease(category: AttributeCategory.offense),
  psychicDamageIncrease(category: AttributeCategory.offense),
  energyDamageIncrease(category: AttributeCategory.offense),
  frostDamageIncrease(category: AttributeCategory.offense),
  bleedDamageIncrease(category: AttributeCategory.offense),
  lifeSteal(category: AttributeCategory.offense),
  damageIncrease(category: AttributeCategory.offense),
  meleeDamageIncrease(category: AttributeCategory.melee),
  projectileDamageIncrease(category: AttributeCategory.projectile),
  dodgeChanceIncrease(category: AttributeCategory.defence),
  maxHealth(category: AttributeCategory.defence),
  maxStamina(category: AttributeCategory.mobility),
  reloadTime(category: AttributeCategory.utility),
  healthRegen(category: AttributeCategory.defence),
  staminaRegen(category: AttributeCategory.mobility),
  experienceGain(category: AttributeCategory.utility),
  statusEffectPotency(category: AttributeCategory.offense),

  ///Game Attributes
  enemyExplosion(
      rarity: AttributeRarity.unique,
      category: AttributeCategory.mobility,
      territory: AttributeTerritory.game);

  const AttributeEnum(
      {this.rarity = AttributeRarity.standard,
      this.category = AttributeCategory.utility,
      this.territory = AttributeTerritory.permanent});

  final AttributeRarity rarity;
  final AttributeCategory category;
  final AttributeTerritory territory;
}

extension AllAttributesExtension on AttributeEnum {
  Attribute buildAttribute(int level, AttributeFunctionality victimEntity,
      Entity perpetratorEntity) {
    switch (this) {
      case AttributeEnum.speed:
        return TopSpeedAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );
      case AttributeEnum.burn:
        return FireDamageAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );
      case AttributeEnum.attackRate:
        return AttackRateAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );

      case AttributeEnum.enemyExplosion:
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

enum StatusEffects { burn, bleed, chill, electrified, stun, psychic }
