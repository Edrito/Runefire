import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:runefire/attributes/attributes_elemental/base.dart';
import 'package:runefire/attributes/attributes_perpetrator.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/functions.dart';
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

enum AttributeTerritory { permanent, game, statusEffect, passive }

enum AttributeType {
  //Debuffs
  burn(territory: AttributeTerritory.statusEffect),
  bleed(territory: AttributeTerritory.statusEffect),

  chill(territory: AttributeTerritory.statusEffect),
  electrified(territory: AttributeTerritory.statusEffect),
  slow(territory: AttributeTerritory.statusEffect),

  stun(territory: AttributeTerritory.statusEffect),
  confused(territory: AttributeTerritory.statusEffect),

  frozen(territory: AttributeTerritory.statusEffect),

  fear(territory: AttributeTerritory.statusEffect),
  empowered(territory: AttributeTerritory.statusEffect),
  marked(territory: AttributeTerritory.statusEffect),

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

  //Elemental

  //Fire
  fireIncreaseDamage(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.passive,
    autoAssigned: true,
    elementalRequirement: {
      DamageType.fire: .25,
    },
  ),
  chanceToBurnNeighbouringEnemies(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.passive,
    autoAssigned: true,
    elementalRequirement: {
      DamageType.fire: .5,
    },
  ),
  killFireEmpower(
    category: AttributeCategory.offence,
    territory: AttributeTerritory.passive,
    autoAssigned: true,
    elementalRequirement: {
      DamageType.fire: .75,
    },
  ),

  chanceToRevive(
    category: AttributeCategory.defence,
    territory: AttributeTerritory.passive,
    autoAssigned: true,
    elementalRequirement: {
      DamageType.fire: 1,
    },
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
    // ignore: unused_element
    this.autoAssigned = false,

    ///A higher priority means the attribute will be processed last
    this.priority = 0,
    bool Function(Entity) attributeEligibilityTest =
        defaultAttributeEligibilityTest,
    // ignore: unused_element
    Map<DamageType, double>? elementalRequirement,
  })  : _elementalRequirement = elementalRequirement,
        _attributeEligibilityTest = attributeEligibilityTest;

  final AttributeRarity rarity;
  final AttributeCategory category;
  final AttributeTerritory territory;
  final bool autoAssigned;
  final int priority;
  final AttributeEligibilityTest _attributeEligibilityTest;
  final Map<DamageType, double>? _elementalRequirement;

  List<DamageType> get elementalRequirement =>
      _elementalRequirement?.keys.toList() ?? [];

  bool get requiresElementalPower => _elementalRequirement != null;

  double elementalRequirementValue(DamageType damageType) {
    return _elementalRequirement?[damageType] ?? 0;
  }

  String get icon => 'attributes/$name';

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

  bool isEligible(Entity entity) {
    if (_elementalRequirement != null) {
      final playerElementalLevel = entity.elementalPower;

      //remade using .any
      if (_elementalRequirement!.keys.any((element) =>
          playerElementalLevel[element] == null ||
          playerElementalLevel[element]! < _elementalRequirement![element]!,)) {
        return false;
      }
    }

    return _attributeEligibilityTest(entity);
  }
}

bool teleportDashTest(Entity player) {
  return player is AttributeFunctionality &&
          player.hasAttribute(AttributeType.dashSpeedDistance) &&
          player.hasAttribute(AttributeType.dashAttackEmpower)
      //  &&
      // player.currentAttributes.containsKey(AttributeType.invincibleDashing)
      ;
}

bool standStillTest(Entity player) {
  return player is AttributeFunctionality &&
      player.hasAttribute(AttributeType.damageStandStillIncrease) &&
      player.hasAttribute(AttributeType.defenceStandStillIncrease) &&
      player.hasAttribute(AttributeType.dodgeStandStillIncrease);
}

bool sentryCombinationTest(Entity player) {
  if (player is! AttributeFunctionality) return false;
  if (player.hasAttribute(AttributeType.sentryCombination) ||
      player.hasAttribute(AttributeType.mirrorOrb)) {
    return false;
  }

  var good = 0;
  if (player.hasAttribute(AttributeType.sentryRangedAttack)) {
    good++;
  }
  if (player.hasAttribute(AttributeType.sentryGrabItems)) {
    good++;
  }
  if (player.hasAttribute(AttributeType.sentryMarkEnemy)) {
    good++;
  }
  if (player.hasAttribute(AttributeType.sentryElementalFly)) {
    good++;
  }

  return good > 2;
}

bool negativeCombinePulseTest(Entity player) {
  if (player is! AttributeFunctionality) return false;
  return !player.hasAttribute(AttributeType.combinePeriodicPulse);
}

bool playerIsReloadFunctionality(Entity player) {
  return player is ReloadFunctionality;
}

bool combinePulseTest(Entity player) {
  if (player is! AttributeFunctionality) return false;
  return player.hasAttribute(AttributeType.periodicMagicPulse) &&
      player.hasAttribute(AttributeType.periodicPush) &&
      player.hasAttribute(AttributeType.periodicStun);
}

bool playerHasMeleeWeapon(Entity player) {
  if (player is! AttackFunctionality) return false;
  return player.carriedWeapons.any((element) => element is MeleeFunctionality);
}

bool playerHasProjectileWeapon(Entity player) {
  return player
      .getAllWeaponItems(false, true)
      .any((element) => element is ProjectileFunctionality);
}

bool defaultAttributeEligibilityTest(Entity _) {
  return true;
}

typedef AttributeEligibilityTest = bool Function(Entity player);

extension AllAttributesExtension on AttributeType {
  Attribute buildAttribute(
    int level,
    AttributeFunctionality? victimEntity, {
    Entity? perpetratorEntity,
    DamageType? damageType,
    bool isTemporary = false,
    double? duration,
    bool builtForInfo = false,
  }) {
    if (isTemporary) {
      final managedAttribute = buildAttribute(
        level,
        victimEntity,
        perpetratorEntity: perpetratorEntity,
        damageType: damageType,
        builtForInfo: builtForInfo,
      );
      return TemporaryAttribute(
        managedAttribute: managedAttribute,
        duration: duration ?? 4,
      );
    }
    final permanentAttr = permanentAttributeBuilder(this, level, victimEntity);
    if (permanentAttr != null) {
      return permanentAttr;
    }

    if (victimEntity == null && !builtForInfo) {
      throw Exception('Victim entity required for $this!');
    }

    final regularAttr =
        regularAttributeBuilder(this, level, victimEntity, damageType);

    if (regularAttr != null) {
      return regularAttr;
    }
    final elementalAttr =
        damageTypeAttributeBuilder(this, level, victimEntity, damageType);

    if (elementalAttr != null) {
      return elementalAttr;
    }

    if (perpetratorEntity == null && !builtForInfo) {
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

  bool reApplyOnAddition = true;

  @override
  void removeUpgrade() {
    if (damageType != null) {
      victimEntity?.modifyElementalPower(damageType!, -elementalWeighting);
    } else if (attributeType.elementalRequirement.isNotEmpty) {
      for (final element in attributeType.elementalRequirement) {
        victimEntity?.modifyElementalPower(element, -elementalWeighting);
      }
    }

    super.removeUpgrade();
  }

  @override
  void applyUpgrade() {
    if (damageType != null) {
      victimEntity?.modifyElementalPower(damageType!, elementalWeighting);
    } else if (attributeType.elementalRequirement.isNotEmpty) {
      for (final element in attributeType.elementalRequirement) {
        victimEntity?.modifyElementalPower(element, elementalWeighting);
      }
    }

    super.applyUpgrade();
  }

  void action() {}

  bool hasRandomDamageType = false;

  bool hasRandomStatusEffect = false;

  DamageType? damageType;

  Set<DamageType> allowedDamageTypes = {};

  // bool get isTemporary => this is TemporaryAttribute;
  AttributeTerritory get attributeTerritory => attributeType.territory;

  String description() {
    final percent = ((upgradeFactor ?? 0) * 100).abs().round();

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
    return 'An increase of ${(upgradeFactor ?? 0) * 100}% of your base attribute with an additional ${(upgradeFactor ?? 0) * 100}% at max level.';
  }

  late String attributeId;

  String get icon {
    if (_iconExists()) {
      return attributeType.icon;
    } else {
      return defaultIconLocation;
    }
  }

  bool _iconExists() {
    return assetExists('assets/images/${attributeType.icon}');
  }

  Future<Sprite> get sprite {
    return Sprite.load(icon);
  }

  abstract String title;
  abstract bool increaseFromBaseParameter;
  AttributeFunctionality? victimEntity;

  int get remainingLevels => (maxLevel ?? upgradeLevel) - upgradeLevel;

  @override
  int? maxLevel = 5;

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
            ).toDouble(),
          );
        } else {
          (parameterManager as DoubleParameterManager).setParameterFlatValue(
            attributeId,
            increase(
              increaseFromBaseParameter,
              parameterManager.baseParameter,
            ).toDouble(),
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
            ).toDouble(),
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
            .increaseAllPercent(attributeId, increase(false).toDouble());

        break;

      case DamagePercentParameterManager:
        (parameterManager as DamagePercentParameterManager)
            .setDamagePercentIncrease(
          attributeId,
          {damageType!: increase(false).toDouble()},
        );

        break;

      default:
    }
  }
}
