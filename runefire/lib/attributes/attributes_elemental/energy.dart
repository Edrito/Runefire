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

class EnergySpeedBoostAttribute extends Attribute {
  EnergySpeedBoostAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    if (attributeOwnerEntity is MovementFunctionality) {
      final movement = attributeOwnerEntity! as MovementFunctionality;
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
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onUpdate.add(update);
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
      attr.onUpdate.remove(update);
      attr.onKillOtherEntity.remove(onKill);
    }
    if (attributeOwnerEntity is MovementFunctionality) {
      final movement = attributeOwnerEntity! as MovementFunctionality;
      movement.speed.removeKey(attributeId);
    }
    super.unMapUpgrade();
  }
}

class EnergyArcAuraAttribute extends Attribute {
  EnergyArcAuraAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
      attributeOwnerEntity!,
      radius,
      attributeOwnerEntity!.gameEnviroment,
      test: (entity) => (attributeOwnerEntity?.isPlayer ?? true)
          ? entity is Enemy
          : entity is Player,
    );
    if (potentialCandidates.isEmpty) {
      return;
    }
    final projectile = ProjectileType.followLaser.generateProjectile(
      ProjectileConfiguration(
        delta: (potentialCandidates.random().position -
                attributeOwnerEntity!.position)
            .normalized(),
        originPosition: attributeOwnerEntity!.position,
        weaponAncestor: weaponAncestor,
        primaryDamageType: DamageType.energy,
        size: .5,
      ),
    );

    attributeOwnerEntity!.gameEnviroment
        .addPhysicsComponent([projectile], priority: backgroundObjectPriority);
  }

  late EnergyArcGun weaponAncestor;

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AimFunctionality) {
      weaponAncestor =
          EnergyArcGun(1, attributeOwnerEntity! as AimFunctionality);
      weaponAncestor.projectileLifeSpan.baseParameter = .2;
      weaponAncestor.chainingTargets.baseParameter = 1;
      weaponAncestor.sourceAttackLocation = SourceAttackLocation.body;
      weaponAncestor.baseDamage.damageBase[DamageType.energy] = (.5, 1);
      attributeOwnerEntity?.gameEnviroment.eventManagement.addAiTimer(
        (function: onPulse, id: attributeId, time: pulseDuration),
      );
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.gameEnviroment.eventManagement
        .removeAiTimer(id: attributeId);
    weaponAncestor.removeFromParent();
    super.unMapUpgrade();
  }
}

class ReducedEffectDurationsAttribute extends Attribute {
  ReducedEffectDurationsAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    attributeOwnerEntity?.durationPercentReduction.setParameterPercentValue(
      attributeId,
      -.5,
    );
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.durationPercentReduction.removeKey(attributeId);
    super.unMapUpgrade();
  }
}

class InstantReflexAttribute extends Attribute {
  InstantReflexAttribute({
    required super.level,
    required super.attributeOwnerEntity,
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
    if (attributeOwnerEntity is DodgeFunctionality) {
      final dodge = attributeOwnerEntity! as DodgeFunctionality;
      dodge.dodgeChance.setParameterFlatValue(attributeId, .5);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is DodgeFunctionality) {
      final dodge = attributeOwnerEntity! as DodgeFunctionality;
      dodge.dodgeChance.removeKey(attributeId);
    }

    super.unMapUpgrade();
  }
}

class StaticDischargeAttribute extends Attribute {
  StaticDischargeAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.staticDischarge;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Static Discharge';

  double currentStatic = 0.0;
  double maxDamage = 10;
  double maxStatic = 100;
  bool increaseStaticCharge(DamageInstance damage) {
    final increaseAmount = (damage.damage / 3).clamp(0, 10);
    currentStatic = (currentStatic + increaseAmount).clamp(0, maxStatic);
    return false;
  }

  void generateStaticDischarge() {
    if (currentStatic < 10) {
      return;
    }
    final damageAmount = maxDamage * (currentStatic / 100);
    final areaEffect = AreaEffect(
      position: attributeOwnerEntity!.position,
      damage: {
        DamageType.energy: (damageAmount, damageAmount),
      },
      sourceEntity: attributeOwnerEntity!,
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent(
      [areaEffect],
      priority: backgroundObjectPriority,
    );
    currentStatic = 0;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final callback = attributeOwnerEntity! as AttributeCallbackFunctionality;
      callback.onHitOtherEntity.add(increaseStaticCharge);
      callback.jumpBeginFunctions.add(generateStaticDischarge);
    }

    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is DodgeFunctionality) {
      final dodge = attributeOwnerEntity! as DodgeFunctionality;
      dodge.dodgeChance.removeKey(attributeId);
    }

    super.unMapUpgrade();
  }
}

class HyperActivityAttribute extends Attribute {
  HyperActivityAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.hyperActivity;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Hyper Activity';

  @override
  void mapUpgrade() {
    for (final element in attributeOwnerEntity!.getAllWeaponItems(true, true)) {
      element.attackTickRate.setParameterPercentValue(
        attributeId,
        increasePercentOfBase(-.2, includeBase: true).toDouble(),
      );
      element.weaponRandomnessPercent.setParameterFlatValue(
        attributeId,
        increasePercentOfBase(.1, includeBase: true).toDouble(),
      );
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    for (final element in attributeOwnerEntity!.getAllWeaponItems(true, true)) {
      element.attackTickRate.removeKey(attributeId);
      element.weaponRandomnessPercent.removeKey(attributeId);
    }

    super.unMapUpgrade();
  }
}

class CrossTributeAttribute extends Attribute {
  CrossTributeAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.crossTribute;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Cross Tribute';
  @override
  String description() {
    return 'Your primary weapons attack in a cross formation,'
        ' while also reducing damage dealt by 50%';
  }

  List<double> pattern(double angle, int count) {
    return crossAttackSpread();
  }

  @override
  void mapUpgrade() {
    for (final element
        in attributeOwnerEntity!.getAllWeaponItems(false, false)) {
      element.attackSpreadPatterns.add(pattern);
      for (final damageType in DamageType.getValuesWithoutHealing) {
        element.baseDamage.setDamagePercentIncrease(
          attributeId,
          damageType,
          -.5,
          -.5,
        );
      }
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    for (final element
        in attributeOwnerEntity!.getAllWeaponItems(false, false)) {
      element.attackSpreadPatterns.remove(pattern);

      element.baseDamage.removeKey(
        attributeId,
      );
    }

    super.unMapUpgrade();
  }
}

class ReflectDamageAttribute extends Attribute {
  ReflectDamageAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.reflectDamage;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Path of Reflection';

  double reflectPercent = .15;

  @override
  int get maxLevel => 1;

  bool onHit(DamageInstance damage) {
    if (damage.source is HealthFunctionality) {
      final health = damage.source as HealthFunctionality;
      health.hitCheck(
        attributeId,
        DamageInstance(
          damageMap: {DamageType.energy: damage.damage * reflectPercent},
          source: attributeOwnerEntity!,
          victim: health,
          sourceAttack: attributeOwnerEntity,
        ),
      );
    }

    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final callback = attributeOwnerEntity! as AttributeCallbackFunctionality;
      callback.onHitByOtherEntity.add(onHit);
    }

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final callback = attributeOwnerEntity! as AttributeCallbackFunctionality;
      callback.onHitByOtherEntity.remove(onHit);
    }
    super.unMapUpgrade();
  }
}

class RandomDashingAttribute extends Attribute {
  RandomDashingAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.randomDashing;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Electrifying Dashes';

  Vector2 randomTeleport() {
    return SpawnLocation.inside
        .grabNewPosition(attributeOwnerEntity!.gameEnviroment);
  }

  double minDamage = 3;
  double maxDamage = 5;

  void generateElectricalExplosion() {
    final areaEffect = AreaEffect(
      position: attributeOwnerEntity!.position,
      damage: {
        DamageType.energy: (minDamage, maxDamage),
      },
      sourceEntity: attributeOwnerEntity!,
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent(
      [areaEffect],
      priority: backgroundObjectPriority,
    );
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is DashFunctionality) {
      final dash = attributeOwnerEntity! as DashFunctionality;
      dash.customTeleportDestinations.add(randomTeleport);
      dash.teleportDash.setIncrease(attributeId, true);
    }

    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final callback = attributeOwnerEntity! as AttributeCallbackFunctionality;

      callback.dashEndFunctions.add(generateElectricalExplosion);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is DashFunctionality) {
      final dash = attributeOwnerEntity! as DashFunctionality;
      dash.customTeleportDestinations.remove(randomTeleport);
      dash.teleportDash.removeKey(attributeId);
    }
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final callback = attributeOwnerEntity! as AttributeCallbackFunctionality;

      callback.dashEndFunctions.remove(generateElectricalExplosion);
    }
    super.unMapUpgrade();
  }
}

class EnergeticAffinityAttribute extends Attribute {
  EnergeticAffinityAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });
  @override
  AttributeType attributeType = AttributeType.energeticAffinity;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Energetic Affinity';

  bool onHit(DamageInstance damage) {
    var totalDamage = 0.0;

    damage.damageMap.entries.forEach((element) {
      totalDamage += element.value;
    });

    damage.damageMap.clear();
    damage.damageMap[DamageType.energy] = totalDamage;
    damage.statusEffectChance[StatusEffects.electrified] =
        (damage.statusEffectChance[StatusEffects.electrified] ?? 0.0) + .25;

    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final callback = attributeOwnerEntity! as AttributeCallbackFunctionality;
      callback.onHitOtherEntity.add(onHit);
    }

    super.mapUpgrade();
  }

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final callback = attributeOwnerEntity! as AttributeCallbackFunctionality;
      callback.onHitOtherEntity.remove(onHit);
    }
    super.unMapUpgrade();
  }

  @override
  int get maxLevel => 1;
}
