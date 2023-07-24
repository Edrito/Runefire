import 'package:game_app/attributes/attributes_mixin.dart';

import 'attribute_constants.dart' as constants;
import 'attributes_structure.dart';

abstract class PermanentAttribute extends Attribute {
  PermanentAttribute({required super.level, required super.victimEntity});

  abstract int baseCost;

  ///Cost of the level up, default is the next level cost
  int cost([int? level]) {
    return baseCost * (level ?? (upgradeLevel + 1));
  }
}

PermanentAttribute? permanentAttributeBuilder(
    AttributeType type, int level, AttributeFunctionality? victimEntity) {
  switch (type) {
    case AttributeType.speed:
      return SpeedPermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.attackRate:
      return AttackRatePermanentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    default:
      return null;
  }
}

class AreaSizePermanentAttribute extends PermanentAttribute {
  AreaSizePermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.areaSize;

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
    genericAttributeIncrease(victimEntity?.areaSizePercentIncrease,
        increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.areaSizePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Area Size Increase";

  @override
  String description() {
    return "Max Level";
  }
}

class MeleeDamageIncreasePermanentAttribute extends PermanentAttribute {
  MeleeDamageIncreasePermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.meleeDamageIncrease;

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
    genericAttributeIncrease(victimEntity?.meleeDamagePercentIncrease,
        increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.meleeDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Melee Damage Increase";

  @override
  String description() {
    return "Max Level";
  }
}

class ProjectileDamageIncreasePermanentAttribute extends PermanentAttribute {
  ProjectileDamageIncreasePermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.projectileDamageIncrease;

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
    genericAttributeIncrease(victimEntity?.projectileDamagePercentIncrease,
        increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.projectileDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Projectile Damage Increase";

  @override
  String description() {
    return "Max Level";
  }
}

class SpellDamageIncreasePermanentAttribute extends PermanentAttribute {
  SpellDamageIncreasePermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.spellDamageIncrease;

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
    genericAttributeIncrease(victimEntity?.spellDamagePercentIncrease,
        increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.spellDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Spell Damage Increase";

  @override
  String description() {
    return "Max Level";
  }
}

class TickDamageIncreasePermanentAttribute extends PermanentAttribute {
  TickDamageIncreasePermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.tickDamageIncrease;

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
        victimEntity?.tickDamageIncrease, increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.tickDamageIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Tick Damage Increase";

  @override
  String description() {
    return "Max Level";
  }
}

class AreaDamageIncreasePermanentAttribute extends PermanentAttribute {
  AreaDamageIncreasePermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.areaDamageIncrease;

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
    genericAttributeIncrease(victimEntity?.areaDamagePercentIncrease,
        increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.areaDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Area Damage Increase";

  @override
  String description() {
    return "Max Level";
  }
}

class StatusEffectPotencyPermanentAttribute extends PermanentAttribute {
  StatusEffectPotencyPermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.statusEffectPotency;

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
    genericAttributeIncrease(victimEntity?.statusEffectsPercentIncrease,
        increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.statusEffectsPercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Status Effect Potency Increase";

  @override
  String description() {
    return "Max Level";
  }
}

class BaseSpeedPermanentAttribute extends PermanentAttribute {
  BaseSpeedPermanentAttribute(
      {required super.level, required super.victimEntity});
  @override
  AttributeType attributeType = AttributeType.areaDamageIncrease;

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
    genericAttributeIncrease(victimEntity?.areaDamagePercentIncrease,
        increaseFromBaseParameter, false);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.areaDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Area Damage Increase";

  @override
  String description() {
    return "Max Level";
  }
}
