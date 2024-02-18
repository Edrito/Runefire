import 'package:flame/components.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/child_entities.dart';
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
    required super.victimEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.fireIncreaseDamage;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

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
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.add(addDamage);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.remove(addDamage);
    }
    super.unMapUpgrade();
  }
}

class KillFireEmpowerAttackAttribute extends Attribute {
  KillFireEmpowerAttackAttribute({
    required super.level,
    required super.victimEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.killFireEmpower;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  bool determineIfShouldEmpower(DamageInstance damage) {
    if (damage.victim is AttributeFunctionality) {
      final attr = damage.victim as AttributeFunctionality;
      if (attr.statusEffects.contains(StatusEffects.burn)) {
        victimEntity!.addAttribute(
          AttributeType.empowered,
          isTemporary: true,
          duration: 10,
          perpetratorEntity: victimEntity,
        );
      }
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(determineIfShouldEmpower);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.remove(determineIfShouldEmpower);
    }
    super.unMapUpgrade();
  }
}

class ChanceToBurnNeighbouringEnemiesAttribute extends Attribute {
  ChanceToBurnNeighbouringEnemiesAttribute({
    required super.level,
    required super.victimEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.chanceToBurnNeighbouringEnemies;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  double distance = 5;
  double chance = .25;

  bool determineIfShouldBurnOtherEnemies(DamageInstance damage) {
    if (damage.victim is AttributeFunctionality) {
      final attr = damage.victim as AttributeFunctionality;
      if (attr.statusEffects.contains(StatusEffects.burn)) {
        final entities = getEntitiesInRadius(
          victimEntity!,
          distance,
          victimEntity!.gameEnviroment,
          test: (entity) => victimEntity!.isPlayer
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
              perpetratorEntity: victimEntity,
            );
          }
        }
      }
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(determineIfShouldBurnOtherEnemies);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.remove(determineIfShouldBurnOtherEnemies);
    }
    super.unMapUpgrade();
  }
}

class ChanceToReviveAttribute extends Attribute {
  ChanceToReviveAttribute({
    required super.level,
    required super.victimEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.chanceToRevive;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  final chance = .5;

  bool determineIfShouldDie(DamageInstance damage) {
    final shouldLive = rng.nextDouble() < chance;
    if (shouldLive) {
      print('REVIVED');
    }
    return shouldLive;
  }

  @override
  void mapUpgrade() {
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity! as HealthFunctionality;
      health.onDeath.add(determineIfShouldDie);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.remove(determineIfShouldDie);
    }
    super.unMapUpgrade();
  }
}
