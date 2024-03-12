import 'package:flame/components.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/projectile_mixin.dart';
import 'package:runefire/weapons/melee_swing_manager.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/entities/entity_class.dart';

import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/resources/enums.dart';

class FireIncreaseDamageTenPercentAttribute extends Attribute {
  FireIncreaseDamageTenPercentAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.fireIncreaseDamage;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Damage Increase';

  @override
  String description() => 'Increase damage by 10% if the target is alight.';

  bool addDamage(DamageInstance damage) {
    if (damage.victim is AttributeFunctionality) {
      final attr = damage.victim as AttributeFunctionality;
      if (attr.statusEffects.contains(StatusEffects.burn)) {
        damage.damageMap.updateAll((key, value) => value * 1.1);
      }
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.add(addDamage);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.remove(addDamage);
    }
    super.unMapUpgrade();
  }
}

class KillFireEmpowerAttackAttribute extends Attribute {
  KillFireEmpowerAttackAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.killFireEmpower;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Burned Empower Attack';

  @override
  String description() => 'Empower attack if the target is alight.';

  bool determineIfShouldEmpower(DamageInstance damage) {
    if (damage.victim is AttributeFunctionality) {
      final attr = damage.victim as AttributeFunctionality;
      if (attr.statusEffects.contains(StatusEffects.burn)) {
        attributeOwnerEntity!.addAttribute(
          AttributeType.empowered,
          isTemporary: true,
          duration: 10,
          perpetratorEntity: attributeOwnerEntity,
        );
      }
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(determineIfShouldEmpower);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.remove(determineIfShouldEmpower);
    }
    super.unMapUpgrade();
  }
}

class ChanceToBurnNeighbouringEnemiesAttribute extends Attribute {
  ChanceToBurnNeighbouringEnemiesAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.chanceToBurnNeighbouringEnemies;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Caustic Flames';

  @override
  String description() =>
      '25% chance to burn close enemies if the target dies while alight.';

  double distance = 5;
  double chance = .25;

  bool determineIfShouldBurnOtherEnemies(DamageInstance damage) {
    if (damage.victim is AttributeFunctionality) {
      final attr = damage.victim as AttributeFunctionality;
      if (attr.statusEffects.contains(StatusEffects.burn)) {
        final entities = getEntitiesInRadius(
          attributeOwnerEntity!,
          distance,
          attributeOwnerEntity!.gameEnviroment,
          test: (entity) => attributeOwnerEntity!.isPlayer
              ? entity is Enemy
              : entity is AttributeFunctionality,
        );
        for (final entity in entities) {
          if (rng.nextDouble() > chance) {
            continue;
          }
          if (entity is AttributeFunctionality) {
            entity.addAttribute(
              AttributeType.burn,
              isTemporary: true,
              perpetratorEntity: attributeOwnerEntity,
            );
          }
        }
      }
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(determineIfShouldBurnOtherEnemies);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.remove(determineIfShouldBurnOtherEnemies);
    }
    super.unMapUpgrade();
  }
}

class ChanceToReviveAttribute extends Attribute {
  ChanceToReviveAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.chanceToRevive;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Phoenix Rebirth';
  @override
  String description() => '50% chance to revive if killed.';

  final chance = .5;

  bool determineIfShouldDie(DamageInstance damage) {
    final shouldLive = rng.nextDouble() < chance;
    if (shouldLive) {
      void doAnimation() => spriteAnimations.pheonixRebirth1.then((value) {
            attributeOwnerEntity?.entityVisualEffectsWrapper.addBodyAnimation(
              id: attributeId,
              component: SimpleStartPlayEndSpriteAnimationComponent(
                spawnAnimation: value,
                durationType: DurationType.instant,
              ),
            );
          });
      (attributeOwnerEntity! as HealthFunctionality)
          .reviveCompleter
          .then((value) {
        doAnimation();
      });
    }
    return shouldLive;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.onPreDeath.add(determineIfShouldDie);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPreDeath.remove(determineIfShouldDie);
    }
    super.unMapUpgrade();
  }
}

class OverheatingMissileAttribute extends Attribute {
  OverheatingMissileAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.overheatingMissile;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Superheated Missiles';

  @override
  String description() =>
      'The first attack after a reload will burn the target.';

  Set<String> shouldAlight = {};
  //weaponid, damage instance id
  Map<String, String> continueToAlight = {};

  void initiateAlight(Weapon weapon) {
    shouldAlight.add(weapon.weaponId);
    continueToAlight.remove(weapon.weaponId);
    initiateWeaponFunction(weapon);
  }

  void initiateWeaponFunction(Weapon weapon) {
    if (weapon is AttributeWeaponFunctionsFunctionality) {
      if (!weapon.onHit.contains(doAlight)) {
        weapon.onHit.add(doAlight);
      }
    }
  }

  bool doAlight(DamageInstance instance) {
    if (shouldAlight.contains(instance.sourceWeapon?.weaponId)) {
      continueToAlight[instance.sourceWeapon!.weaponId] =
          instance.sourceAttackId;
      shouldAlight.remove(instance.sourceWeapon!.weaponId);
    }
    if (continueToAlight[instance.sourceWeapon?.weaponId] ==
        instance.sourceAttackId) {
      instance.statusEffectChance[StatusEffects.burn] = 1;
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onReload.add(initiateAlight);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onReload.remove(initiateAlight);
    }

    for (final element in attributeOwnerEntity?.getAllWeaponItems(true, true) ??
        const Iterable.empty()) {
      if (element is AttributeWeaponFunctionsFunctionality) {
        element.onHit.remove(doAlight);
      }
    }
    super.unMapUpgrade();
  }
}

class FireyAuraAttribute extends Attribute {
  FireyAuraAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.fireyAura;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Firey Aura';

  @override
  String description() => 'Increase damage when enemies are close by.';

  final double damageIncrease = 1.25;

  final double radius = 4;

  bool checkDistanceApplyDamageIncrease(DamageInstance other) {
    final isClose =
        other.victim.position.distanceTo(other.source.position) < radius;
    if (isClose) {
      other.damageMap.updateAll((key, value) => value * damageIncrease);
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onHitOtherEntity.add(checkDistanceApplyDamageIncrease);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onReload.remove(checkDistanceApplyDamageIncrease);
    }

    super.unMapUpgrade();
  }
}

class EssenceOfThePheonixAttribute extends Attribute {
  EssenceOfThePheonixAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.essenceOfThePheonix;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Essence of the Pheonix';

  @override
  String description() => 'All damage is converted to fire damage.';

  bool modifyDamage(DamageInstance other) {
    var totalDamage = 0.0;
    for (final element in other.damageMap.entries) {
      totalDamage += element.value;
    }
    other.damageMap.clear();
    other.damageMap[DamageType.fire] = totalDamage;
    other.statusEffectChance[StatusEffects.burn] =
        (other.statusEffectChance[StatusEffects.burn] ?? 0.0) + .25;
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onHitOtherEntity.add(modifyDamage);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onReload.remove(modifyDamage);
    }

    super.unMapUpgrade();
  }
}
