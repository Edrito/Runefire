import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';

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
        return const Color.fromARGB(255, 185, 105, 0);
    }
  }
}

enum AttributeType {
  mobility,
  projectile,
  magic,
  melee,
  defence,
  offense,
  attack
}

enum AttributeEnum {
  topSpeed,
  attackRate,
}

extension AllAttributesExtension on AttributeEnum {
  Attribute buildAttribute(int level, Entity entity, [bool applyNow = true]) {
    switch (this) {
      case AttributeEnum.topSpeed:
        return TopSpeedAttribute(level, entity, applyNow);
      case AttributeEnum.attackRate:
        return AttackRateAttribute(level, entity, applyNow);
    }
  }
}

extension RarityAttributesExtension on AttributeEnum {
  AttributeRarity get rarity {
    switch (this) {
      case AttributeEnum.topSpeed:
        return AttributeRarity.standard;
      case AttributeEnum.attackRate:
        return AttributeRarity.unique;
      default:
        return AttributeRarity.standard;
    }
  }
}
