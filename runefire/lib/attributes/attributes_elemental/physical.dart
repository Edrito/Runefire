import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/entities/hidden_child_entities/hidden_child_entities.dart';
import 'package:runefire/events/event_class.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/weapons/custom_weapons.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

class DodgeChancePhysicalIncreaseAttribute extends Attribute {
  DodgeChancePhysicalIncreaseAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.dodgeChancePhysicalIncrease;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Dodge Chance Increase';

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is DodgeFunctionality) {
      final attr = attributeOwnerEntity! as DodgeFunctionality;
      attr.dodgeChance.setParameterFlatValue(attributeId, .15);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is DodgeFunctionality) {
      final attr = attributeOwnerEntity! as DodgeFunctionality;
      attr.dodgeChance.removeFlatKey(attributeId);
    }
    super.unMapUpgrade();
  }
}

class CritChancePhysicalIncreaseAttribute extends Attribute {
  CritChancePhysicalIncreaseAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.critChancePhysicalIncrease;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Crit Chance Increase';

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.critChance.setParameterFlatValue(attributeId, .15);

    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.critChance.removeFlatKey(attributeId);
    super.unMapUpgrade();
  }
}

class BloodPoolAttribute extends Attribute {
  BloodPoolAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.bloodPool;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Pool of Blood';

  final chance = 1;

  bool areaCreate(DamageInstance damage) {
    if (rng.nextDouble() > chance) {
      return false;
    }

    if (damage.victim.statusEffects.contains(StatusEffects.bleed)) {
      final areaEffect = AreaEffect(
        position: damage.victim.position,
        duration: 6,
        durationType: DurationType.temporary,
        onTick: (entity, areaId) {
          if (entity is AttributeFunctionality) {
            entity.addAttribute(
              AttributeType.slow,
              isTemporary: true,
              perpetratorEntity: attributeOwnerEntity,
              duration: 2,
            );
            entity.addAttribute(
              AttributeType.bleed,
              isTemporary: true,
              perpetratorEntity: attributeOwnerEntity,
              duration: 2,
            );
          }
        },
        sourceEntity: attributeOwnerEntity!,
      );

      gameEnviroment?.addPhysicsComponent([areaEffect]);
    }

    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(areaCreate);
    }

    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.remove(areaCreate);
    }
    super.unMapUpgrade();
  }
}

class BleedStunAttribute extends Attribute {
  BleedStunAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.bleedStunAttribute;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  @override
  int get maxLevel => 1;
}

class BleedingCritsAttribute extends Attribute {
  BleedingCritsAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.bleedingCrits;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Bleeding Crits';

  bool applyBleed(DamageInstance damage) {
    if (!damage.isCrit) {
      return false;
    }

    if (damage.victim is AttributeFunctionality) {
      (damage.victim as AttributeFunctionality).addAttribute(
        AttributeType.bleed,
        isTemporary: true,
        perpetratorEntity: attributeOwnerEntity,
      );
    }

    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPostDamageOtherEntity.add(applyBleed);
    }
    attributeOwnerEntity?.critDamage.setParameterPercentValue(attributeId, -.5);
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPostDamageOtherEntity.remove(applyBleed);
    }
    attributeOwnerEntity?.critDamage.removeKey(
      attributeId,
    );
    super.unMapUpgrade();
  }
}

class BleedChanceIncreaseAttribute extends Attribute {
  BleedChanceIncreaseAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.bleedChanceIncrease;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Blood blade';

  bool modifyBleed(DamageInstance damage) {
    damage.statusEffectChance.updateAll((key, value) {
      if (key == StatusEffects.bleed) {
        value += .25;
      } else {
        value *= .75;
      }
      return value;
    });

    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.add(modifyBleed);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onPreDamageOtherEntity.remove(modifyBleed);
    }

    super.unMapUpgrade();
  }
}

class WeaponMergeAttribute extends Attribute {
  WeaponMergeAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  List<Weapon> movedWeapons = [];

  @override
  AttributeType attributeType = AttributeType.weaponMerge;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Merge Weapons';

  @override
  String description() {
    return 'Merge Weapons';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttackFunctionality) {
      final attackEntity = attributeOwnerEntity! as AttackFunctionality;
      final otherWeapons =
          attributeOwnerEntity?.getAllWeaponItems(false, false);
      final currentWeapon = attackEntity.currentWeapon;
      if (otherWeapons != null && currentWeapon != null) {
        for (final element in otherWeapons
            .where((element) => element.weaponId != currentWeapon.weaponId)) {
          attackEntity.currentWeapon?.addAdditionalWeapon(element);
          movedWeapons.add(element);
        }

        attackEntity.carriedWeapons.removeWhere(
          (value) =>
              movedWeapons.any((element) => element.weaponId == value.weaponId),
        );

        attackEntity.swapWeapon(currentWeapon);
      }
    }
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttackFunctionality) {
      final attack = attributeOwnerEntity! as AttackFunctionality;
      final otherWeapons =
          attributeOwnerEntity?.getAllWeaponItems(false, false);
      final currentWeapon = attack.currentWeapon;
      if (otherWeapons != null && currentWeapon != null) {
        attack.carriedWeapons.addAll([currentWeapon, ...movedWeapons]);

        attack.swapWeapon(attack.currentWeapon);

        currentWeapon.additionalWeapons.removeWhere(
          (key, value) =>
              movedWeapons.any((element) => element.weaponId == value.weaponId),
        );
      }
    }
  }
}

class PhysicalProwessAttribute extends Attribute {
  PhysicalProwessAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.physicalProwess;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Physical Prowess';

  bool modifyDamage(DamageInstance other) {
    var totalDamage = 0.0;
    for (final element in other.damageMap.entries) {
      totalDamage += element.value;
    }
    other.damageMap.clear();
    other.damageMap[DamageType.physical] = totalDamage;
    other.statusEffectChance[StatusEffects.bleed] =
        (other.statusEffectChance[StatusEffects.bleed] ?? 0.0) + .25;
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
