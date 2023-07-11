import 'package:flutter/material.dart';
import 'package:game_app/attributes/temporary_attributes.dart';

import 'attributes_mixin.dart';
import '../entities/entity.dart';
import 'attributes.dart';

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

enum AttributeCategory {
  mobility,
  projectile,
  magic,
  melee,
  defence,
  offense,
  attack,
  temporary,
  misc
}

enum AttributeEnum {
  fireDamage(category: AttributeCategory.temporary),

  topSpeed(
      rarity: AttributeRarity.uncommon, category: AttributeCategory.mobility),
  power(category: AttributeCategory.temporary),
  attackRate(rarity: AttributeRarity.rare, category: AttributeCategory.attack),
  enemyExplosion(
      rarity: AttributeRarity.unique, category: AttributeCategory.mobility);

  const AttributeEnum(
      {this.rarity = AttributeRarity.standard,
      this.category = AttributeCategory.misc});

  final AttributeRarity rarity;
  final AttributeCategory category;
}

extension AllAttributesExtension on AttributeEnum {
  Attribute buildAttribute(int level, AttributeFunctionality victimEntity,
      Entity perpetratorEntity) {
    switch (this) {
      case AttributeEnum.topSpeed:
        return TopSpeedAttribute(
          level: level,
          victimEntity: victimEntity,
          perpetratorEntity: perpetratorEntity,
        );
      case AttributeEnum.fireDamage:
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
      case AttributeEnum.power:
        return PowerAttribute(
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
    }
  }
}

enum StatusEffects { stun, slow, burn, freeze, bleed, electric, misc }
