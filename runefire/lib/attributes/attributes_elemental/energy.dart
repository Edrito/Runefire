import 'dart:math';

import 'package:flame/extensions.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/entities/hidden_child_entities/hidden_child_entities.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/weapons/custom_weapons.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_class.dart';

class EnergySpeedBoostAttribute extends Attribute {
  EnergySpeedBoostAttribute({
    required super.level,
    required super.victimEntity,
    super.damageType,
  }) {
    resetDurationRemaining();
  }
  @override
  AttributeType attributeType = AttributeType.energySpeedBoost;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';
  int currentStacks = 0;
  double speedIncrease = 0.1;
  double speedDurationRemaining = 0;

  int maxStacks = 10;

  void update(double dt) {
    if (currentStacks > 0) {
      speedDurationRemaining -= dt;
      if (speedDurationRemaining <= 0) {
        currentStacks = 0;
        resetDurationRemaining();
        applyBoost(remove: true);
      }
    }
  }

  void applyBoost({bool remove = false}) {
    if (victimEntity is MovementFunctionality) {
      final movement = victimEntity! as MovementFunctionality;
      if (remove) {
        movement.speed.removeKey(attributeId);
      } else {
        movement.speed.setParameterPercentValue(
          attributeId,
          speedIncrease * currentStacks,
        );
      }
    }
  }

  void resetDurationRemaining() => speedDurationRemaining = 4;
  bool onKill(DamageInstance damage) {
    currentStacks = (currentStacks + 1).clamp(0, maxStacks);
    resetDurationRemaining();
    applyBoost();
    return false;
  }

  @override
  void mapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(update);
      attr.onKillOtherEntity.add(onKill);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (victimEntity is AttributeCallbackFunctionality) {
      final attr = victimEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.remove(update);
      attr.onKillOtherEntity.remove(onKill);
    }
    if (victimEntity is MovementFunctionality) {
      final movement = victimEntity! as MovementFunctionality;
      movement.speed.removeKey(attributeId);
    }
    super.unMapUpgrade();
  }
}

class EnergyArcAuraAttribute extends Attribute {
  EnergyArcAuraAttribute({
    required super.level,
    required super.victimEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.energyArcAura;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  double chance = .2;

  double pulseDuration = 1;

  double currentPulseDuration = 0;

  double radius = 5;
  void onPulse() {
    final potentialCandidates = getEntitiesInRadius(
      victimEntity!,
      radius,
      victimEntity!.gameEnviroment,
      test: (entity) =>
          (victimEntity?.isPlayer ?? true) ? entity is Enemy : entity is Player,
    );
    if (potentialCandidates.isEmpty) {
      return;
    }
    final projectile = ProjectileType.followLaser.generateProjectile(
      ProjectileConfiguration(
        delta: (potentialCandidates.random().position - victimEntity!.position)
            .normalized(),
        originPosition: victimEntity!.position,
        weaponAncestor: weaponAncestor,
        primaryDamageType: DamageType.energy,
        size: .5,
      ),
    );

    victimEntity!.gameEnviroment
        .addPhysicsComponent([projectile], priority: backgroundObjectPriority);
  }

  late DefaultGun weaponAncestor;
  late HiddenChildAimingEntity aimingEntity;

  @override
  void mapUpgrade() {
    aimingEntity = HiddenChildAimingEntity(
      initialPosition: victimEntity!.position,
      parentEntity: victimEntity!,
      upgradeLevel: 1,
    );

    weaponAncestor = DefaultGun(1, aimingEntity);
    weaponAncestor.projectileLifeSpan.baseParameter = .2;
    weaponAncestor.chainingTargets.baseParameter = 1;
    weaponAncestor.sourceAttackLocation = SourceAttackLocation.body;

    aimingEntity.loaded.then((value) {
      aimingEntity.swapWeapon(weaponAncestor);
    });

    victimEntity?.gameEnviroment.addPhysicsComponent(
      [aimingEntity],
      instant: true,
      priority: backgroundObjectPriority,
    );

    victimEntity?.gameEnviroment.eventManagement
        .addAiTimer((function: onPulse, id: attributeId, time: pulseDuration));
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    aimingEntity.removeFromParent();
    victimEntity?.gameEnviroment.eventManagement.removeAiTimer(id: attributeId);
    weaponAncestor.removeFromParent();
    super.unMapUpgrade();
  }
}

class ReducedEffectDurationsAttribute extends Attribute {
  ReducedEffectDurationsAttribute({
    required super.level,
    required super.victimEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.reducedEffectDurations;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  @override
  void mapUpgrade() {
    victimEntity?.durationPercentReduction.setParameterPercentValue(
      attributeId,
      -.5,
    );
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    victimEntity?.durationPercentReduction.removeKey(attributeId);
    super.unMapUpgrade();
  }
}

class InstantReflexAttribute extends Attribute {
  InstantReflexAttribute({
    required super.level,
    required super.victimEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.instantReflex;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = '';

  @override
  void mapUpgrade() {
    if (victimEntity is DodgeFunctionality) {
      final dodge = victimEntity! as DodgeFunctionality;
      dodge.dodgeChance.setParameterFlatValue(attributeId, .5);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (victimEntity is DodgeFunctionality) {
      final dodge = victimEntity! as DodgeFunctionality;
      dodge.dodgeChance.removeKey(attributeId);
    }

    super.unMapUpgrade();
  }
}
