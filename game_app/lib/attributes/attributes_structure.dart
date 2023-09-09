import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game_app/attributes/attributes_perpetrator.dart';
import 'package:game_app/player/player.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/data_classes/base.dart';
import '../resources/enums.dart';
import 'attributes_mixin.dart';
import '../entities/entity_class.dart';
import 'attributes_regular.dart';
import 'attributes_permanent.dart';
import 'package:uuid/uuid.dart';

import '../main.dart';
import '../menus/cards.dart';
import '../resources/functions/custom.dart';
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
  fear(territory: AttributeTerritory.temporary),
  empowered(territory: AttributeTerritory.temporary),
  marked(territory: AttributeTerritory.temporary),

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
  explosionOnKill(
      rarity: AttributeRarity.uncommon,
      category: AttributeCategory.attack,
      territory: AttributeTerritory.game),

  explosiveDash(
      rarity: AttributeRarity.uncommon,
      category: AttributeCategory.offense,
      territory: AttributeTerritory.game),

  gravityWell(
      rarity: AttributeRarity.rare,
      category: AttributeCategory.utility,
      territory: AttributeTerritory.game),

  groundSlam(
      rarity: AttributeRarity.uncommon,
      category: AttributeCategory.offense,
      territory: AttributeTerritory.game),

  psychicReach(
      rarity: AttributeRarity.rare,
      category: AttributeCategory.utility,
      territory: AttributeTerritory.game,
      attributeEligibilityTest: playerHasMeleeWeapon),

  periodicPush(
      rarity: AttributeRarity.uncommon,
      category: AttributeCategory.utility,
      attributeEligibilityTest: negativeCombinePulseTest,
      territory: AttributeTerritory.game),

  periodicMagicPulse(
      rarity: AttributeRarity.uncommon,
      attributeEligibilityTest: negativeCombinePulseTest,
      category: AttributeCategory.offense,
      territory: AttributeTerritory.game),

  periodicStun(
      rarity: AttributeRarity.uncommon,
      attributeEligibilityTest: negativeCombinePulseTest,
      category: AttributeCategory.offense,
      territory: AttributeTerritory.game),

  combinePeriodicPulse(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offense,
    priority: 5,
    attributeEligibilityTest: combinePulseTest,
    territory: AttributeTerritory.game,
  ),
  increaseXpGrabRadius(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
  ),
  sentryMarkEnemy(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
  ),
  sentryRangedAttack(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.attack,
    territory: AttributeTerritory.game,
  ),

  sentryGrabItems(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
  ),

  sentryElementalFly(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.attack,
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
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
    priority: 5,
    attributeEligibilityTest: sentryCombinationTest,
  ),

  mirrorOrb(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
    priority: 5,
    attributeEligibilityTest: sentryCombinationTest,
  ),

  shieldSurround(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
  ),

  swordSurround(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),

  reverseKnockback(
      rarity: AttributeRarity.rare,
      category: AttributeCategory.utility,
      territory: AttributeTerritory.game,
      priority: 5),

  projectileSplitExplode(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
    attributeEligibilityTest: playerHasProjectileWeapon,
  ),

  dodgeStandStillIncrease(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
  ),

  defenceStandStillIncrease(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
    priority: 5,
  ),

  damageStandStillIncrease(
    rarity: AttributeRarity.standard,
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

  invincibleDashing(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
  ),

  dashSpeedDistance(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.mobility,
    territory: AttributeTerritory.game,
  ),

  dashAttackEmpower(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),

  teleportDash(
      rarity: AttributeRarity.unique,
      category: AttributeCategory.mobility,
      territory: AttributeTerritory.game,
      priority: 5,
      attributeEligibilityTest: teleportDashTest),

  weaponMerge(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
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
      category: AttributeCategory.offense,
      territory: AttributeTerritory.game,
      attributeEligibilityTest: playerIsReloadFunctionality),

  ///Is invincible for the duration of the reload, depending on how much ammo was spent
  reloadInvincibility(
      rarity: AttributeRarity.uncommon,
      category: AttributeCategory.defence,
      territory: AttributeTerritory.game,
      attributeEligibilityTest: playerIsReloadFunctionality),

  reloadPush(
      rarity: AttributeRarity.uncommon,
      category: AttributeCategory.offense,
      territory: AttributeTerritory.game,
      attributeEligibilityTest: playerIsReloadFunctionality),

  ///increase attack count over time
  focus(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),

  chainingAttacks(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.offense,
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
    category: AttributeCategory.melee,
    territory: AttributeTerritory.game,
  ),

  ///Projectile attacks
  daggerSwing(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.projectile,
    territory: AttributeTerritory.game,
  ),

  homingProjectiles(
    rarity: AttributeRarity.rare,
    category: AttributeCategory.projectile,
    territory: AttributeTerritory.game,
  ),

  ///On Crit

  extremeKnockbackCrit(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),

  ///Player attributes
  ///
  ///
  heavyHitter(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  quickShot(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  rapidFire(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),

  bigPockets(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
  ),
  secondsPlease(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.defence,
    territory: AttributeTerritory.game,
  ),
  primalInstincts(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  appleADay(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.defence,
    territory: AttributeTerritory.game,
  ),
  flattenDamage(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  critDamageDecreaseDamage(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  putYourWeightIntoIt(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  agile(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
  ),
  areaSizeDecreaseDamage(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  decreaseMaxAmmoDecreaseReloadSpeed(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.utility,
    territory: AttributeTerritory.game,
  ),
  potionSeller(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  battleScars(
    rarity: AttributeRarity.standard,
    category: AttributeCategory.defence,
    priority: 10,
    territory: AttributeTerritory.game,
  ),

  ///Remove stamina bar, stamina actions reduce health, increase health regen by 200%
  forbiddenMagic(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.defence,
    priority: 10,
    territory: AttributeTerritory.game,
  ),
  reduceHealthIncreaseLifeSteal(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  staminaSteal(
    rarity: AttributeRarity.uncommon,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  splitDamage(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  rollTheDice(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),
  glassWand(
    rarity: AttributeRarity.unique,
    category: AttributeCategory.offense,
    territory: AttributeTerritory.game,
  ),

  slugTrail(
      rarity: AttributeRarity.uncommon,
      category: AttributeCategory.offense,
      territory: AttributeTerritory.game);

  ///Constructor
  const AttributeType(
      {this.rarity = AttributeRarity.standard,
      this.category = AttributeCategory.utility,
      this.territory = AttributeTerritory.permanent,
      // ignore: unused_element
      ///A higher priority means the attribute will be processed last
      this.priority = 0,
      // ignore: unused_element
      this.attributeEligibilityTest = defaultAttributeEligibilityTest});

  final AttributeRarity rarity;
  final AttributeCategory category;
  final AttributeTerritory territory;
  final int priority;
  final AttributeEligibilityTest attributeEligibilityTest;
}

bool teleportDashTest(Player player) {
  return player.currentAttributes
          .containsKey(AttributeType.dashSpeedDistance) &&
      player.currentAttributes.containsKey(AttributeType.dashAttackEmpower) &&
      player.currentAttributes.containsKey(AttributeType.invincibleDashing);
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

  int good = 0;
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

bool defaultAttributeEligibilityTest(Player player) {
  return true;
}

typedef AttributeEligibilityTest = bool Function(Player player);

extension AllAttributesExtension on AttributeType {
  Attribute buildAttribute(
    int level,
    AttributeFunctionality? victimEntity, {
    Entity? perpetratorEntity,
    DamageType? damageType,
    // StatusEffects? statusEffect,
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

        final statusEffectAttr = statusEffectBuilder(
          this,
          level,
          victimEntity,
          perpetratorEntity: perpetratorEntity,
          isTemporary: isTemporary,
          duration: duration,
        );
        if (statusEffectAttr != null) return statusEffectAttr;
      }
    }

    switch (this) {
      case AttributeType.explosionOnKill:
        return ExplosionOnKillAttribute(
          level: level,
          victimEntity: victimEntity,
        );
      default:
        return PeriodicPushAttribute(
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

  void removeAttribute() {
    victimEntity?.removeAttribute(attributeType);
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

    String current = "${upgradeLevel * percent}%";
    String next = "${(upgradeLevel + 1) * percent}%";

    return "$current${upgradeLevel == maxLevel ? "" : " > $next"}";
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
      {Function(DamageType? damageType)? onTap,
      Function? onTapComplete,
      bool small = false}) {
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
                attributeId, {damageType!: increase(false)});

        break;

      default:
    }
  }
}
