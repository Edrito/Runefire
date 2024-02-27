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

class StaminaUseHealAttribute extends Attribute {
  StaminaUseHealAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.staminaUseHeal;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Conversion Factor';

  double healingFactor = 0.02;

  void onStaminaModify(double amount) {
    if (amount < 0 && attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      final healAmount = amount * healingFactor;
      health.heal(healAmount.abs());
    }
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onStaminaModified.add(onStaminaModify);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onStaminaModified.remove(onStaminaModify);
    }

    super.unMapUpgrade();
  }
}

class DoubleCastAttribute extends Attribute {
  DoubleCastAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.doubleCast;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Double Cast';

  double chance = .1;

  Future<void> onAttack(Weapon weapon) async {
    if (rng.nextDouble() <= chance) {
      await attributeOwnerEntity?.game
          .gameAwait(weapon.attackTickRate.parameter / 2);
      weapon.standardAttack(
        const AttackConfiguration(
          useAmmo: false,
        ),
      );
    }
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onAttack.add(onAttack);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onAttack.remove(onAttack);
    }

    super.unMapUpgrade();
  }
}
