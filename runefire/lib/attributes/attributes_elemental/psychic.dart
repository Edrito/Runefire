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

class PsychicReflectionAttribute extends Attribute {
  PsychicReflectionAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.psychicReflection;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Psychic Reflection';

  final chance = .15;

  Set<String> setProjectiles = {};

  void flipCheck(Projectile projectile, Set<Projectile> currentProjectiles) {
    final opposingProjectile = attributeOwnerEntity is Player
        ? projectile.weaponAncestor.entityAncestor is Enemy
        : projectile.weaponAncestor.entityAncestor is Player;
    if (rng.nextDouble() > chance ||
        !opposingProjectile ||
        setProjectiles.contains(projectile.projectileId)) {
      return;
    }

    if (projectile is StandardProjectile &&
        projectile.weaponAncestor.entityAncestor is HealthFunctionality) {
      attributeOwnerEntity is Player
          ? projectile.setTargetFixture(projectile.body, EntityType.enemy)
          : projectile.setTargetFixture(projectile.body, EntityType.player);
      projectile.setTarget(
        projectile.weaponAncestor.entityAncestor! as HealthFunctionality,
      );
      projectile.canAffectOwner = true;
      setProjectiles.add(projectile.projectileId);
    }
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onProjectileSensorContact.add(flipCheck);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onProjectileSensorContact.remove(flipCheck);
    }

    super.unMapUpgrade();
  }
}

class OnHitEnemyConfusedAttribute extends Attribute {
  OnHitEnemyConfusedAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.onHitEnemyConfused;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Relalitory Confusion';

  final chance = .15;

  bool onHit(DamageInstance damage) {
    if (rng.nextDouble() > chance) {
      return false;
    }
    if (damage.source is AttributeFunctionality) {
      (damage.source as AttributeFunctionality).addAttribute(
        AttributeType.confused,
        perpetratorEntity: attributeOwnerEntity,
        isTemporary: true,
      );
    }
    return false;
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onHitByOtherEntity.add(onHit);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final call = attributeOwnerEntity! as AttributeCallbackFunctionality;
      call.onHitByOtherEntity.remove(onHit);
    }

    super.unMapUpgrade();
  }
}

class HoverJumpAttribute extends Attribute {
  HoverJumpAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.hoverJump;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Hover Jump';

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is JumpFunctionality) {
      final call = attributeOwnerEntity! as JumpFunctionality;
      call.jumpDuration.setParameterPercentValue(attributeId, 1);
    }

    super.mapUpgrade();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is JumpFunctionality) {
      final call = attributeOwnerEntity! as JumpFunctionality;
      call.jumpDuration.removeKey(attributeId);
    }
    super.unMapUpgrade();
  }
}

class GravityDashAttribute extends Attribute {
  GravityDashAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;

  @override
  AttributeType attributeType = AttributeType.gravityDash;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Gravity Dash!';

  Future<void> onDash() async {
    if (attributeOwnerEntity == null) {
      return;
    }
    final playerPos = attributeOwnerEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      durationType: DurationType.temporary,
      duration: 2.5,
      onTick: (entity, areaId) {
        entity.body
            .applyLinearImpulse((playerPos - entity.center).normalized() / 5);
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  String description() {
    return 'Something in those quantum equations...';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.dashBeginFunctions.add(onDash);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final dashFunc = attributeOwnerEntity! as AttributeCallbackFunctionality;
      dashFunc.dashBeginFunctions.remove(onDash);
    }
    super.unMapUpgrade();
  }

  @override
  double get upgradeFactor => .25;
}

class DefensivePulseAttribute extends Attribute {
  DefensivePulseAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;

  @override
  AttributeType attributeType = AttributeType.defensivePulse;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Defensive Pulse!';

  bool onHit(_) {
    if (attributeOwnerEntity == null) {
      return false;
    }
    final playerPos = attributeOwnerEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      onTick: (entity, areaId) {
        entity.body
            .applyLinearImpulse((playerPos - entity.center).normalized() / 5);
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
    return false;
  }

  @override
  String description() {
    return 'Something in those quantum equations...';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onHitByOtherEntity.add(onHit);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onHitByOtherEntity.add(onHit);
    }
    super.unMapUpgrade();
  }

  @override
  double get upgradeFactor => .25;
}

class SingularityAttribute extends Attribute {
  SingularityAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;

  @override
  AttributeType attributeType = AttributeType.singuarity;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Singularity!';

  void onKill(DamageInstance damage) {
    if (damage.victim.statusEffects.contains(StatusEffects.confused) ?? false) {
      final enemyPos = damage.victim.center.clone();
      final explosion = AreaEffect(
        sourceEntity: attributeOwnerEntity!,
        position: enemyPos,
        radius: baseSize + increasePercentOfBase(baseSize),
        tickRate: .05,
        durationType: DurationType.temporary,
        duration: 2.5,
        onTick: (entity, areaId) {
          entity.body
              .applyLinearImpulse((enemyPos - entity.center).normalized() / 5);
        },
      );
      attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
    }
  }

  @override
  String description() {
    return 'Something in those quantum equations...';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(onKill);
    }
    super.mapUpgrade();
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onKillOtherEntity.add(onKill);
    }
    super.unMapUpgrade();
  }

  @override
  double get upgradeFactor => .25;
}

class PsychicReachAttribute extends Attribute {
  PsychicReachAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  List<SourceAttackLocation?> previousLocations = [];

  @override
  AttributeType attributeType = AttributeType.psychicReach;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Psychic Reach';

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'Use your mind to swing your weapons even further!';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttackFunctionality) {
      return;
    }
    final att = attributeOwnerEntity! as AttackFunctionality;

    for (final element in att.carriedWeapons.whereType<MeleeFunctionality>()) {
      final weapon = element;
      previousLocations.add(weapon.sourceAttackLocation);
      weapon.sourceAttackLocation = SourceAttackLocation.mouse;
      if (weapon is StaminaCostFunctionality) {
        (weapon as StaminaCostFunctionality)
            .weaponStaminaCost
            .setParameterPercentValue(attributeId, 1);
      }
    }
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttackFunctionality) {
      return;
    }
    final att = attributeOwnerEntity! as AttackFunctionality;
    var i = 0;
    for (final element in att.carriedWeapons.whereType<MeleeFunctionality>()) {
      final weapon = element;
      weapon.sourceAttackLocation = previousLocations[i++];
      if (weapon is StaminaCostFunctionality) {
        (weapon as StaminaCostFunctionality)
            .weaponStaminaCost
            .removeKey(attributeId);
      }
    }
  }

  @override
  double get upgradeFactor => .25;
}

class StrengthOfTheStarsAttribute extends Attribute {
  StrengthOfTheStarsAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  @override
  AttributeType attributeType = AttributeType.strengthOfTheStars;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Strength of the Stars';

  bool modifyDamage(DamageInstance other) {
    var totalDamage = 0.0;
    for (final element in other.damageMap.entries) {
      totalDamage += element.value;
    }
    other.damageMap.clear();
    other.damageMap[DamageType.psychic] = totalDamage;
    other.statusEffectChance[StatusEffects.confused] =
        (other.statusEffectChance[StatusEffects.confused] ?? 0.0) + .25;
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
