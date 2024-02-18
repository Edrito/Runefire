import 'package:runefire/attributes/attributes_elemental/fire.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/damage_type_enum.dart';

Attribute? damageTypeAttributeBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? victimEntity,
  DamageType? damageType,
) {
  switch (type) {
    case AttributeType.chanceToBurnNeighbouringEnemies:
      return ChanceToBurnNeighbouringEnemiesAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.chanceToRevive:
      return ChanceToReviveAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.fireIncreaseDamage:
      return FireIncreaseDamageTenPercentAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    case AttributeType.killFireEmpower:
      return KillFireEmpowerAttackAttribute(
        level: level,
        victimEntity: victimEntity,
      );
    default:
      return null;
  }
}
