import 'dart:async';

import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_perpetrator.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/attributes/attributes_regular.dart';
import 'package:runefire/attributes/attributes_permanent.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/main.dart';
import 'package:runefire/menus/attribute_card.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/attributes/attributes_status_effect.dart';

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
        return const Color.fromARGB(255, 206, 151, 0);
    }
  }

  double get weighting {
    switch (this) {
      case AttributeRarity.standard:
        return 0.7;
      case AttributeRarity.uncommon:
        return 0.4;
      case AttributeRarity.rare:
        return 0.2;
      case AttributeRarity.unique:
        return 0.1;
    }
  }
}

///Used to filter and categorize attributes for level selection
enum AttributeCategory {
  mobility,
  defence,
  offence,
  resistance,
  elemental,
  utility,
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
  fear(territory: AttributeTerritory.temporary),
  empowered(territory: AttributeTerritory.temporary),
  marked(territory: AttributeTerritory.temporary),

  //Permanent
  areaSizePermanent,
  areaDamageIncreasePermanent(category: AttributeCategory.offence),
  meleeDamageIncreasePermanent(category: AttributeCategory.offence),
  projectileDamageIncreasePermanent(category: AttributeCategory.offence),
  spellDamageIncreasePermanent(category: AttributeCategory.offence),
  tickDamageIncreasePermanent(category: AttributeCategory.offence),
  critChancePermanent(category: AttributeCategory.offence),
  critDamagePermanent(category: AttributeCategory.offence),
  attackRatePermanent(category: AttributeCategory.offence),
  damageIncreasePermanent(category: AttributeCategory.offence),
  healthRegenPermanent(category: AttributeCategory.defence),
  dodgeChanceIncreasePermanent(category: AttributeCategory.defence),
  maxHealthPermanent(category: AttributeCategory.defence),
  essenceStealPermanent(category: AttributeCategory.defence),
  maxLivesPermanent(category: AttributeCategory.defence),
  speedPermanent(category: AttributeCategory.mobility),
  maxStaminaPermanent(category: AttributeCategory.mobility),
  staminaRegenPermanent(category: AttributeCategory.mobility),
  experienceGainPermanent(),
  durationPermanent,
  reloadTimePermanent(),
  statusEffectPotencyPermanent(),

  physicalDamageIncreasePermanent(category: AttributeCategory.elemental),
  magicDamageIncreasePermanent(category: AttributeCategory.elemental),
  fireDamageIncreasePermanent(category: AttributeCategory.elemental),
  psychicDamageIncreasePermanent(category: AttributeCategory.elemental),
  energyDamageIncreasePermanent(category: AttributeCategory.elemental),
  frostDamageIncreasePermanent(category: AttributeCategory.elemental),

  physicalResistanceIncreasePermanent(category: AttributeCategory.resistance),
  magicResistanceIncreasePermanent(category: AttributeCategory.resistance),
  fireResistanceIncreasePermanent(category: AttributeCategory.resistance),
  psychicResistanceIncreasePermanent(category: AttributeCategory.resistance),
  energyResistanceIncreasePermanent(category: AttributeCategory.resistance),
  frostResistanceIncreasePermanent(category: AttributeCategory.resistance),

  ///Game Attributes
  explosionOnKill(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  explosiveDash(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  gravityDash(
    rarity: AttributeRarity.rare,
    territory: AttributeTerritory.game,
    elementalRequirement: {
      DamageType.psychic: .4,
    },
  ),

  groundSlam(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  psychicReach(
    rarity: AttributeRarity.rare,
    territory: AttributeTerritory.game,
    attributeEligibilityTest: playerHasMeleeWeapon,
    elementalRequirement: {
      DamageType.psychic: .6,
    },
  ),

  periodicPush(
    rarity: AttributeRarity.uncommon,
    attributeEligibilityTest: negativeCombinePulseTest,
    territory: AttributeTerritory.game,
  ),

  periodicMagicPulse(
    rarity: AttributeRarity.uncommon,
    attributeEligibilityTest: negativeCombinePulseTest,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  periodicStun(
    rarity: AttributeRarity.uncommon,
    attributeEligibilityTest: negativeCombinePulseTest,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  combinePeriodicPulse(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offence,
    priority: 5,
    attributeEligibilityTest: combinePulseTest,
    territory: AttributeTerritory.game,
  ),
  increaseXpGrabRadius(
    territory: AttributeTerritory.game,
  ),
  sentryMarkEnemy(
    rarity: AttributeRarity.uncommon,
    territory: AttributeTerritory.game,
  ),
  sentryRangedAttack(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  sentryGrabItems(
    rarity: AttributeRarity.uncommon,
    territory: AttributeTerritory.game,
  ),

  sentryElementalFly(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  sentryCaptureBullet(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.defence,
    territory: AttributeTerritory.game,
  ),

  //TODO
  sentryCombination(
    rarity: AttributeRarity.unique,
    territory: AttributeTerritory.game,
    priority: 5,
    attributeEligibilityTest: sentryCombinationTest,
  ),

  mirrorOrb(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
    priority: 5,
    attributeEligibilityTest: sentryCombinationTest,
  ),

  shieldSurround(
    rarity: AttributeRarity.uncommon,
    territory: AttributeTerritory.game,
  ),

  swordSurround(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  reverseKnockback(
    rarity: AttributeRarity.rare,
    territory: AttributeTerritory.game,
    priority: 5,
  ),

  projectileSplitExplode(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
    attributeEligibilityTest: playerHasProjectileWeapon,
  ),

  dodgeStandStillIncrease(
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
  ),

  defenceStandStillIncrease(
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
    priority: 5,
  ),

  damageStandStillIncrease(
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
  ),

  //TODO
  combinationStandStillIncrease(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
    priority: 5,
    attributeEligibilityTest: standStillTest,
  ),

  // invincibleDashing(
  //   rarity: AttributeRarity.rare,
  //   category: AttributeCategory.mobility,
  //   territory: AttributeTerritory.game,
  // ),

  dashSpeedDistance(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
  ),

  dashAttackEmpower(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
    elementalRequirement: {
      DamageType.physical: .10,
    },
  ),

  teleportDash(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
    priority: 5,
    attributeEligibilityTest: teleportDashTest,
  ),

  weaponMerge(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
    elementalRequirement: {
      DamageType.physical: 1,
    },
  ),

  thorns(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.defence,
    territory: AttributeTerritory.game,
  ),

  ///Pushes spent ammunition in all directions around player
  ///(incentivizes using all ammo)
  reloadSpray(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
    attributeEligibilityTest: playerIsReloadFunctionality,
  ),

  ///Is invincible for the duration of the reload, depending on how much ammo was spent
  reloadInvincibility(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.defence,
    territory: AttributeTerritory.game,
    attributeEligibilityTest: playerIsReloadFunctionality,
  ),

  reloadPush(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
    attributeEligibilityTest: playerIsReloadFunctionality,
  ),

  ///increase attack count over time
  focus(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  chainingAttacks(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  ///Melee attacks
  ///
  // weaponCollision(
  //   rarity: AttributeRarity.uncommon,
  //   category: AttributeCategory.melee,
  //   territory: AttributeTerritory.game,
  // ),

  sonicWave(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  ///Projectile attacks
  daggerSwing(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  homingProjectiles(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  ///On Crit

  // extremeKnockbackCrit(
  //   rarity: AttributeRarity.uncommon,
  //   category: AttributeCategory.offense,
  //   territory: AttributeTerritory.game,
  // ),

  ///Player attributes
  ///
  ///
  heavyHitter(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),
  quickShot(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),
  rapidFire(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),
  bigPockets(
    territory: AttributeTerritory.game,
  ),
  secondsPlease(
    category: AttributeCategory.defence,
    territory: AttributeTerritory.game,
  ),
  primalMagic(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),
  appleADay(
    category: AttributeCategory.defence,
    territory: AttributeTerritory.game,
  ),
  // balancingTechnique(
  //   rarity: AttributeRarity.standard,
  //   category: AttributeCategory.offense,
  //   territory: AttributeTerritory.game,
  // ),
  //   chaoticChances(
  //   rarity: AttributeRarity.standard,
  //   category: AttributeCategory.offense,
  //   territory: AttributeTerritory.game,
  // ),
  critChanceDecreaseDamage(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),
  putYourBackIntoIt(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),
  agile(
    territory: AttributeTerritory.game,
  ),
  areaSizeDecreaseDamage(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),
  decreaseMaxAmmoIncreaseReloadSpeed(
    territory: AttributeTerritory.game,
  ),

  potionSeller(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  battleScars(
    category: AttributeCategory.defence,
    priority: 10,
    territory: AttributeTerritory.game,
  ),

  ///Remove stamina bar, stamina actions reduce health, increase health regen by 200%
  forbiddenMagic(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.defence,
    priority: 10,
    territory: AttributeTerritory.game,
  ),

  reduceHealthIncreaseLifeSteal(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  staminaSteal(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  splitDamage(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  rollTheDice(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  glassWand(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  ),

  slugTrail(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offence,
    territory: AttributeTerritory.game,
  );

  ///Constructor
  const AttributeType({
    this.rarity = AttributeRarity.standard,
    this.category = AttributeCategory.utility,
    this.territory = AttributeTerritory.permanent,

    ///A higher priority means the attribute will be processed last
    this.priority = 0,
    bool Function(Player) attributeEligibilityTest =
        defaultAttributeEligibilityTest,
    // ignore: unused_element
    Map<DamageType, double>? elementalRequirement,
  })  : _elementalRequirement = elementalRequirement,
        _attributeEligibilityTest = attributeEligibilityTest;

  final AttributeRarity rarity;
  final AttributeCategory category;
  final AttributeTerritory territory;
  final int priority;
  final AttributeEligibilityTest _attributeEligibilityTest;
  final Map<DamageType, double>? _elementalRequirement;

  List<DamageType> get elementalRequirement =>
      _elementalRequirement?.keys.toList() ?? [];

  bool get requiresElementalPower => _elementalRequirement != null;

  bool attributeMeetsForcedElementalRequest(
    Player player,
    DamageType? damageType,
  ) {
    //If no damage type, player has the requirment
    if (damageType == null) {
      return true;
    }
    final playerElementalLevel = player.elementalPower[damageType];

    //if the attribute does not have a requirment,
    //the player cannot meet that requirement, so [false]
    if (_elementalRequirement == null ||
        _elementalRequirement![damageType] == null ||
        playerElementalLevel == null) {
      return false;
    }

    //If the player has enough power for the attribute, return [true]
    //If the attribute has more than one elemental requirement,
    //so the forced attributes can only be a single type, return [false]
    return _elementalRequirement![damageType]! <= playerElementalLevel &&
        _elementalRequirement!.length < 2;
  }

  bool isEligible(Player player) {
    if (_elementalRequirement != null) {
      final playerElementalLevel = player.elementalPower;
      var elementalRequirementMet = true;
      for (final element in _elementalRequirement!.entries) {
        //current player power level
        final playerEntry = playerElementalLevel[element.key];
        //if player has no power or not enough power from previous loop, return [false]
        if (playerEntry == null || !elementalRequirementMet) {
          return false;
        } else {
          elementalRequirementMet =
              elementalRequirementMet && playerEntry >= element.value;
        }
      }
    }

    return _attributeEligibilityTest(player);
  }
}

bool teleportDashTest(Player player) {
  return player.currentAttributes
              .containsKey(AttributeType.dashSpeedDistance) &&
          player.currentAttributes.containsKey(AttributeType.dashAttackEmpower)
      //  &&
      // player.currentAttributes.containsKey(AttributeType.invincibleDashing)
      ;
}

bool standStillTest(Player player) {
  return player.currentAttributes
          .containsKey(AttributeType.damageStandStillIncrease) &&
      player.currentAttributes
          .containsKey(AttributeType.defenceStandStillIncrease) &&
      player.currentAttributes
          .containsKey(AttributeType.dodgeStandStillIncrease);
}

bool sentryCombinationTest(Player player) {
  if (player.currentAttributes.containsKey(AttributeType.sentryCombination) ||
      player.currentAttributes.containsKey(AttributeType.mirrorOrb)) {
    return false;
  }

  var good = 0;
  if (player.currentAttributes.containsKey(AttributeType.sentryRangedAttack)) {
    good++;
  }
  if (player.currentAttributes.containsKey(AttributeType.sentryGrabItems)) {
    good++;
  }
  if (player.currentAttributes.containsKey(AttributeType.sentryMarkEnemy)) {
    good++;
  }
  if (player.currentAttributes.containsKey(AttributeType.sentryElementalFly)) {
    good++;
  }

  return good > 2;
}

bool negativeCombinePulseTest(Player player) {
  return !player.currentAttributes
      .containsKey(AttributeType.combinePeriodicPulse);
}

bool playerIsReloadFunctionality(Player player) {
  return player is ReloadFunctionality;
}

bool combinePulseTest(Player player) {
  return player.currentAttributes
          .containsKey(AttributeType.periodicMagicPulse) &&
      player.currentAttributes.containsKey(AttributeType.periodicPush) &&
      player.currentAttributes.containsKey(AttributeType.periodicStun);
}

bool playerHasMeleeWeapon(Player player) {
  return player.carriedWeapons.entries
      .any((element) => element.value is MeleeFunctionality);
}

bool playerHasProjectileWeapon(Player player) {
  return player
      .getAllWeaponItems(false, true)
      .any((element) => element is ProjectileFunctionality);
}

bool defaultAttributeEligibilityTest(Player _) {
  return true;
}

typedef AttributeEligibilityTest = bool Function(Player player);

extension AllAttributesExtension on AttributeType {
  Attribute buildAttribute(
    int level,
    AttributeFunctionality? victimEntity, {
    Entity? perpetratorEntity,
    DamageType? damageType,
    bool isTemporary = false,
    double? duration,
  }) {
    final permanentAttr = permanentAttributeBuilder(this, level, victimEntity);
    if (permanentAttr != null) {
      return permanentAttr;
    }

    if (victimEntity == null) {
      throw Exception('Victim entity required for $this!');
    }

    final regularAttr =
        regularAttributeBuilder(this, level, victimEntity, damageType);

    if (regularAttr != null) {
      return regularAttr;
    }

    if (perpetratorEntity == null) {
      throw Exception('Perpetrator entity required for $this!');
    }

    final perpetratorAttr = perpetratorAttributeBuilder(
      this,
      level,
      victimEntity,
      perpetratorEntity,
    );

    if (perpetratorAttr != null) {
      return perpetratorAttr;
    }

    final statusEffectAttr = statusEffectBuilder(
      this,
      level,
      victimEntity,
      perpetratorEntity: perpetratorEntity,
      isTemporary: isTemporary,
      duration: duration,
    );

    if (statusEffectAttr != null) {
      return statusEffectAttr;
    }

    throw Exception('Attribute not found - $this');
  }
}

///Status effect, increase in levels, abilities etc
///Different classes that are applied to an Entity that may be sourced
///from a level up, a enemy attack, a weapon, a potion etc
///The attribute is applied to the victimEntity
///The perpetratorEntity may be a source of a negitive attribute
abstract class Attribute extends UpgradeFunctions {
  Attribute({int level = 0, this.victimEntity, this.damageType}) {
    upgradeLevel = level;
    if (maxLevel != null) {
      upgradeLevel = upgradeLevel.clamp(0, maxLevel!);
    }
    attributeId = const Uuid().v4();
  }

  void removeAttribute() {
    victimEntity?.removeAttribute(attributeType);
  }

  double get elementalWeighting => .025;

  @override
  void removeUpgrade() {
    if (damageType != null) {
      victimEntity?.modifyElementalPower(damageType!, -elementalWeighting);
    }

    super.removeUpgrade();
  }

  @override
  void applyUpgrade() {
    if (damageType != null) {
      victimEntity?.modifyElementalPower(damageType!, elementalWeighting);
    }
    super.applyUpgrade();
  }

  void action() {}

  bool hasRandomDamageType = false;

  bool hasRandomStatusEffect = false;

  DamageType? damageType;

  Set<DamageType> allowedDamageTypes = {};

  bool get isTemporary => this is TemporaryAttribute;
  AttributeTerritory get attributeTerritory => attributeType.territory;

  String description() {
    final percent = ((factor ?? 0) * 100).abs().round();

    final current = '${upgradeLevel * percent}%';
    final next = '${(upgradeLevel + 1) * percent}%';

    return "$current${upgradeLevel == maxLevel ? "" : " > $next"}";
  }

  void applyActionToWeapons(
    Function(Weapon weapon) function,
    bool includeSecondaries,
    bool includeAdditionalPrimaries,
  ) {
    final weapons = victimEntity?.getAllWeaponItems(
      includeSecondaries,
      includeAdditionalPrimaries,
    );
    if (weapons == null) {
      return;
    }

    for (final element in weapons) {
      function(element);
    }
  }

  String help() {
    return 'An increase of ${(factor ?? 0) * 100}% of your base attribute with an additional ${(factor ?? 0) * 100}% at max level.';
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

  void genericAttributeIncrease(
    dynamic parameterManager,
    bool increaseFromBaseParameter,
    bool increaseParameterPercentage, [
    DamageType? damageType,
  ]) {
    switch (parameterManager.runtimeType) {
      case DoubleParameterManager:
        if (increaseParameterPercentage) {
          (parameterManager as DoubleParameterManager).setParameterPercentValue(
            attributeId,
            increase(
              increaseFromBaseParameter,
              parameterManager.baseParameter,
            ),
          );
        } else {
          (parameterManager as DoubleParameterManager).setParameterFlatValue(
            attributeId,
            increase(
              increaseFromBaseParameter,
              parameterManager.baseParameter,
            ),
          );
        }
        break;
      case IntParameterManager:
        if (increaseParameterPercentage) {
          (parameterManager as IntParameterManager).setParameterPercentValue(
            attributeId,
            increase(
              increaseFromBaseParameter,
              parameterManager.baseParameter.toDouble(),
            ),
          );
        } else {
          (parameterManager as IntParameterManager).setParameterFlatValue(
            attributeId,
            increase(
              increaseFromBaseParameter,
              parameterManager.baseParameter.toDouble(),
            ).round(),
          );
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
          attributeId,
          {damageType!: increase(false)},
        );

        break;

      default:
    }
  }
}
