import 'dart:math';

import 'package:flame/components.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/custom_weapons.dart';
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

class FrostDamageIncreaseChillChanceAttribute extends Attribute {
  FrostDamageIncreaseChillChanceAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.frostDamageIncreaseChillChance;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  bool modifyStatusEffect(DamageInstance damage) {
    if ((damage.damageMap[DamageType.frost] ?? 0) > 0) {
      damage.statusEffectChance[StatusEffects.chill] =
          (damage.statusEffectChance[StatusEffects.chill] ?? 0) + .15;
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.add(modifyStatusEffect);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.remove(modifyStatusEffect);
    }
    super.unMapUpgrade();
  }
}

class SlowCloseEnemiesAttribute extends Attribute {
  SlowCloseEnemiesAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.slowCloseEnemies;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  Set<MovementFunctionality> currentlySlowedEntities = {};

  void onUpdate(double dt) {
    final newEntities = <MovementFunctionality>{};
    attributeOwnerEntity?.closeSensorBodies.forEach((element) {
      if (attributeOwnerEntity?.isPlayer ?? false) {
        if (element is Enemy && element is MovementFunctionality) {
          final parameter = (closeBodiesSensorRadius -
                  element.center.distanceTo(attributeOwnerEntity!.center)) /
              closeBodiesSensorRadius;
          (element as MovementFunctionality).speed.setParameterPercentValue(
                attributeId,
                -parameter.clamp(0, .75).abs().toDouble(),
              );
          newEntities.add(element as MovementFunctionality);
        }
      } else {
        if (element is Player) {
          final parameter = (closeBodiesSensorRadius -
                  element.center.distanceTo(attributeOwnerEntity!.center)) /
              closeBodiesSensorRadius;
          element.speed.setParameterPercentValue(
            attributeId,
            -parameter.clamp(0, .75).abs().toDouble(),
          );
          newEntities.add(element);
        }
      }
    });

    for (final element in currentlySlowedEntities) {
      if (newEntities
          .any((elementD) => elementD.entityId == element.entityId)) {
        continue;
      }
      element.speed.removeKey(attributeId);
    }

    currentlySlowedEntities = {...newEntities};
  }

  @override
  void mapUpgrade() {
    // attributeOwnerEntity?.onBodySensorContact.add(newEntity);

    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(onUpdate);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    // attributeOwnerEntity?.onBodySensorContact.remove(newEntity);
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(onUpdate);
    }
    super.unMapUpgrade();
  }
}

class ExplodeFrozenEnemiesAttribute extends Attribute {
  ExplodeFrozenEnemiesAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.explodeFrozenEnemies;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  void onKill(DamageInstance damage) {
    final enemy = damage.victim;

    if (enemy.statusEffects.contains(StatusEffects.frozen)) {
      iceShardsGun.standardAttack(
        AttackConfiguration(
          customAttackPosition: enemy.center,
          customAttackSpreadPattern: {
            (double angle, int count) {
              return crossAttackSpread(
                count: count + 6,
                initialAngle: pi * rng.nextDouble(),
              );
            }
          },
        ),
      );
    }
  }

  late ExplodeEnemiesIceShardsGun iceShardsGun;

  @override
  void mapUpgrade() {
    // attributeOwnerEntity?.onBodySensorContact.add(newEntity);
    if (attributeOwnerEntity is AimFunctionality &&
        attributeOwnerEntity is AttributeCallbackFunctionality) {
      iceShardsGun = ExplodeEnemiesIceShardsGun(
        0,
        attributeOwnerEntity! as AimFunctionality,
      );
      attributeOwnerEntity?.add(iceShardsGun);
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(onKill);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.remove(onKill);
      iceShardsGun.removeFromParent();
    }
    super.unMapUpgrade();
  }
}

class ExpendableFreezesNearbyEnemyAttribute extends Attribute {
  ExpendableFreezesNearbyEnemyAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.expendableFreezesNearbyEnemy;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  void onUse(Expendable item) {
    attributeOwnerEntity?.closeSensorBodies.forEach((element) {
      if (element is Enemy) {
        element.addAttribute(
          AttributeType.frozen,
          perpetratorEntity: attributeOwnerEntity,
          isTemporary: true,
          duration: 2,
        );
      }
    });
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onExpendableUsed.add(onUse);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onExpendableUsed.remove(onUse);
    }
    super.unMapUpgrade();
  }
}

class MeleeAttackFrozenEnemyShoveAttribute extends Attribute {
  MeleeAttackFrozenEnemyShoveAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.meleeAttackFrozenEnemyShove;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  bool onUse(DamageInstance damage) {
    if (damage.sourceWeapon is! MeleeFunctionality ||
        !damage.victim.statusEffects.contains(StatusEffects.frozen)) {
      return false;
    }

    if (damage.victim is MovementFunctionality) {
      (damage.victim as MovementFunctionality).applyKnockback(
        amount: 4000,
        direction: (damage.victim.center - damage.source.center).normalized(),
      );
    }

    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onHitOtherEntity.add(onUse);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onHitOtherEntity.remove(onUse);
    }
    super.unMapUpgrade();
  }
}

class OneWithTheColdAttribute extends Attribute {
  OneWithTheColdAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.oneWithTheCold;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'One With The Cold';

  bool modifyDamage(DamageInstance other) {
    var totalDamage = 0.0;
    for (final element in other.damageMap.entries) {
      totalDamage += element.value;
    }
    other.damageMap.clear();
    other.damageMap[DamageType.frost] = totalDamage;
    other.statusEffectChance[StatusEffects.chill] =
        (other.statusEffectChance[StatusEffects.chill] ?? 0.0) + .25;
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
