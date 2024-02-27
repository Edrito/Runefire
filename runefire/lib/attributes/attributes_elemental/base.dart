import 'package:runefire/attributes/attributes_elemental/fire.dart';
import 'package:runefire/attributes/attributes_elemental/energy.dart';
import 'package:runefire/attributes/attributes_elemental/frost.dart';
import 'package:runefire/attributes/attributes_elemental/magic.dart';
import 'package:runefire/attributes/attributes_elemental/physical.dart';
import 'package:runefire/attributes/attributes_elemental/psychic.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_regular.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/damage_type_enum.dart';

Attribute? damageTypeAttributeBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? attributeOwnerEntity,
  DamageType? damageType,
) {
  switch (type) {
    case AttributeType.chanceToBurnNeighbouringEnemies:
      return ChanceToBurnNeighbouringEnemiesAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.chanceToRevive:
      return ChanceToReviveAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.fireIncreaseDamage:
      return FireIncreaseDamageTenPercentAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.killFireEmpower:
      return KillFireEmpowerAttackAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.overheatingMissile:
      return OverheatingMissileAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.fireyAura:
      return FireyAuraAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.essenceOfThePheonix:
      return EssenceOfThePheonixAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    //Energy
    case AttributeType.energySpeedBoost:
      return EnergySpeedBoostAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.energyArcAura:
      return EnergyArcAuraAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.reducedEffectDurations:
      return ReducedEffectDurationsAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.instantReflex:
      return InstantReflexAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.staticDischarge:
      return StaticDischargeAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.hyperActivity:
      return HyperActivityAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.crossTribute:
      return CrossTributeAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.randomDashing:
      return RandomDashingAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.energeticAffinity:
      return EnergeticAffinityAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.reflectDamage:
      return ReflectDamageAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    //Psychic
    case AttributeType.psychicReflection:
      return PsychicReflectionAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.onHitEnemyConfused:
      return OnHitEnemyConfusedAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.hoverJump:
      return HoverJumpAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.gravityDash:
      return GravityDashAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.defensivePulse:
      return DefensivePulseAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );
    case AttributeType.singuarity:
      return SingularityAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.psychicReach:
      return PsychicReachAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.strengthOfTheStars:
      return StrengthOfTheStarsAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    //Physical

    case AttributeType.dodgeChancePhysicalIncrease:
      return DodgeChancePhysicalIncreaseAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.critChancePhysicalIncrease:
      return CritChancePhysicalIncreaseAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.bloodPool:
      return BloodPoolAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.bleedStunAttribute:
      return BleedStunAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.dashAttackEmpower:
      return DashAttackEmpowerAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.bleedingCrits:
      return BleedingCritsAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.bleedChanceIncrease:
      return BleedChanceIncreaseAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.weaponMerge:
      return WeaponMergeAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.physicalProwess:
      return PhysicalProwessAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    //frost

    case AttributeType.frostDamageIncreaseChillChance:
      return FrostDamageIncreaseChillChanceAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.slowCloseEnemies:
      return SlowCloseEnemiesAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.explodeFrozenEnemies:
      return ExplodeFrozenEnemiesAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.expendableFreezesNearbyEnemy:
      return ExpendableFreezesNearbyEnemyAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.meleeAttackFrozenEnemyShove:
      return MeleeAttackFrozenEnemyShoveAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.oneWithTheCold:
      return OneWithTheColdAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    //magic
    case AttributeType.doubleCast:
      return DoubleCastAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.staminaUseHeal:
      return StaminaUseHealAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    default:
      return null;
  }
}
