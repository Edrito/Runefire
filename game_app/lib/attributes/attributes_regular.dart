import 'package:flame/components.dart';
import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/child_entities.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/player/player.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/area_effects.dart';
import '../resources/functions/functions.dart';
import 'attributes_structure.dart';
import '../resources/enums.dart';

Attribute? regularAttributeBuilder(AttributeType type, int level,
    AttributeFunctionality victimEntity, DamageType? damageType) {
  switch (type) {
    case AttributeType.explosionOnKill:
      return ExplosionOnKillAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.explosiveDash:
      return ExplosiveDashAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.sentryMarkEnemy:
      return MarkSentryAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);

    default:
      return null;
  }
}

class ExplosionOnKillAttribute extends Attribute {
  ExplosionOnKillAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.explosionOnKill;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.frost, DamageType.energy};

  @override
  int get maxLevel => 3;

  double baseSize = 3;

  void onKill(HealthFunctionality other) async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: other.center,
        animationRandomlyFlipped: true,
        radius: baseSize + increasePercentOfBase(baseSize),
        durationType: DurationType.instant,
        duration: victimEntity!.durationPercentIncrease.parameter,

        ///Map<DamageType, (double, double)>>>>
        damage: {
          damageType ?? allowedDamageTypes.first: (
            increase(true, 5),
            increase(true, 10)
          )
        });
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attributeFunctions = victimEntity as AttributeFunctionsFunctionality;
    attributeFunctions.onKillOtherEntity.add(onKill);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attributeFunctions = victimEntity as AttributeFunctionsFunctionality;
    attributeFunctions.onKillOtherEntity.remove(onKill);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Exploding enemies!";

  @override
  String description() {
    return "Something in that ammunition...";
  }
}

class ExplosiveDashAttribute extends Attribute {
  ExplosiveDashAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.explosiveDash;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.frost, DamageType.psychic};

  @override
  int get maxLevel => 3;

  double baseSize = 3;

  void onDash() async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: victimEntity!.center,
        animationRandomlyFlipped: true,
        radius: baseSize + increasePercentOfBase(baseSize),
        durationType: DurationType.instant,
        duration: victimEntity!.durationPercentIncrease.parameter,
        damage: {
          damageType ?? allowedDamageTypes.first: (
            increase(true, 5),
            increase(true, 10)
          )
        });
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final dashFunc = victimEntity as AttributeFunctionsFunctionality;
    dashFunc.dashBeginFunctions.add(onDash);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final dashFunc = victimEntity as AttributeFunctionsFunctionality;
    dashFunc.dashBeginFunctions.remove(onDash);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Explosive Dash!";

  @override
  String description() {
    return "Something in those beans...";
  }
}

class GravityDashAttribute extends Attribute {
  GravityDashAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.gravityWell;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 3;

  double baseSize = 4;

  void onDash() async {
    if (victimEntity == null) return;
    final playerPos = victimEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: victimEntity!.center,
      animationRandomlyFlipped: true,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      durationType: DurationType.temporary,
      duration: victimEntity!.durationPercentIncrease.parameter * 2.5,
      onTick: (entity, areaId) {
        entity.body.applyForce((playerPos - entity.center).normalized() / 5);
      },
    );
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final dashFunc = victimEntity as AttributeFunctionsFunctionality;
    dashFunc.dashBeginFunctions.add(onDash);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final dashFunc = victimEntity as AttributeFunctionsFunctionality;
    dashFunc.dashBeginFunctions.remove(onDash);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Gravity Dash!";

  @override
  String description() {
    return "Something in those quantum equations...";
  }
}

class GroundSlamAttribute extends Attribute {
  GroundSlamAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.groundSlam;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.physical, DamageType.magic};

  @override
  int get maxLevel => 3;

  double baseSize = 4;

  void onJump() async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: victimEntity!.center,
        animationRandomlyFlipped: true,
        radius: baseSize + increasePercentOfBase(baseSize),
        durationType: DurationType.instant,
        duration: victimEntity!.durationPercentIncrease.parameter,
        damage: {
          damageType ?? allowedDamageTypes.first: (
            increase(true, 5),
            increase(true, 10)
          )
        });
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final dashFunc = victimEntity as AttributeFunctionsFunctionality;
    dashFunc.jumpEndFunctions.add(onJump);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final dashFunc = victimEntity as AttributeFunctionsFunctionality;
    dashFunc.jumpEndFunctions.remove(onJump);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Ground Slam!";

  @override
  String description() {
    return "Apprentice, bring me another Eclair!";
  }
}

class PsychicReachAttribute extends Attribute {
  PsychicReachAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.psychicReach;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  int get maxLevel => 1;

  Map<int, SourceAttackLocation?> previousLocations = {};

  @override
  void mapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final att = victimEntity as AttackFunctionality;

    for (var element in att.carriedWeapons.entries
        .where((element) => element.value is MeleeFunctionality)) {
      final weapon = element.value;
      previousLocations[element.key] = weapon.sourceAttackLocation;
      weapon.sourceAttackLocation = SourceAttackLocation.mouse;
      if (weapon is StaminaCostFunctionality) {
        weapon.weaponStaminaCost.setParameterPercentValue(attributeId, 1);
      }
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final att = victimEntity as AttackFunctionality;
    for (var element in att.carriedWeapons.entries
        .where((element) => element.value is MeleeFunctionality)) {
      final weapon = element.value;
      weapon.sourceAttackLocation = previousLocations[element.key];
      if (weapon is StaminaCostFunctionality) {
        weapon.weaponStaminaCost.removeKey(attributeId);
      }
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Psychic Reach";

  @override
  String description() {
    return "Use your mind to swing your weapons even further!";
  }
}

class PeriodicPushAttribute extends Attribute {
  PeriodicPushAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.periodicPush;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  int get maxLevel => 2;

  double baseSize = 4;

  @override
  void action() async {
    if (victimEntity == null) return;
    final playerPos = victimEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: victimEntity!.center,
      animationRandomlyFlipped: true,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      durationType: DurationType.instant,
      duration: victimEntity!.durationPercentIncrease.parameter * 2.5,
      onTick: (entity, areaId) {
        final increaseRes = increase(true, 3);
        entity.body.applyForce(
            (entity.center - playerPos).normalized() * (3 + increaseRes));
      },
    );
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.addPulseFunction(action);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.removePulseFunction(action);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Psychic Reach";

  @override
  String description() {
    return "Use your mind to swing your sword even further!";
  }
}

class PeriodicMagicPulseAttribute extends Attribute {
  PeriodicMagicPulseAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.periodicMagicPulse;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  int get maxLevel => 2;

  double baseSize = 4;

  @override
  void action() async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: victimEntity!.center,
        animationRandomlyFlipped: true,
        radius: baseSize + increasePercentOfBase(baseSize),
        tickRate: .05,
        durationType: DurationType.instant,
        duration: victimEntity!.durationPercentIncrease.parameter * 2.5,
        damage: {DamageType.magic: (increase(true, 5), increase(true, 10))});
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.addPulseFunction(action);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.removePulseFunction(action);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Magic Pulse";

  @override
  String description() {
    return "The power of the arcane flows through you, maybe a little too much though...";
  }
}

// aaa
class PeriodicStunAttribute extends Attribute {
  PeriodicStunAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.periodicStun;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  int get maxLevel => 2;

  double baseSize = 4;

  @override
  void action() async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: victimEntity!.center,
      animationRandomlyFlipped: true,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      durationType: DurationType.instant,
      duration: victimEntity!.durationPercentIncrease.parameter * 2.5,
      onTick: (entity, areaId) {
        if (entity is AttributeFunctionality) {
          entity.addAttribute(AttributeType.stun,
              duration: victimEntity!.durationPercentIncrease.parameter * 1,
              perpetratorEntity: victimEntity,
              isTemporary: true);
        }
      },
    );
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.addPulseFunction(action);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.removePulseFunction(action);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Stun Pulse";

  @override
  String description() {
    return "Stun your enemies!";
  }
}

// aaa
class CombinePeriodicPulseAttribute extends Attribute {
  CombinePeriodicPulseAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.combinePeriodicPulse;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes => {};

  List<Attribute> pulseAttributes = [];

  @override
  int get maxLevel => 2;

  double baseSize = 4;

  @override
  void action() async {
    if (victimEntity == null) return;
    final playerPos = victimEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: victimEntity!.center,
      animationRandomlyFlipped: true,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      durationType: DurationType.instant,
      duration: victimEntity!.durationPercentIncrease.parameter * 2.5,
      damage: {DamageType.magic: (increase(true, 5), increase(true, 10))},
      onTick: (entity, areaId) {
        if (entity is AttributeFunctionality) {
          entity.addAttribute(AttributeType.stun,
              duration: victimEntity!.durationPercentIncrease.parameter * 1,
              perpetratorEntity: victimEntity,
              isTemporary: true);
        }
        final increaseRes = increase(true, 3);
        entity.body.applyForce(
            (entity.center - playerPos).normalized() * (3 + increaseRes));
      },
    );
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;

    final periodicMagicPulse =
        victimEntity?.currentAttributes[AttributeType.periodicMagicPulse];
    final periodicPush =
        victimEntity?.currentAttributes[AttributeType.periodicPush];
    final periodicStun =
        victimEntity?.currentAttributes[AttributeType.periodicStun];

    attr.addPulseFunction(action);

    pulseAttributes.addAll([
      if (periodicMagicPulse != null) periodicMagicPulse..unMapUpgrade(),
      if (periodicPush != null) periodicPush..unMapUpgrade(),
      if (periodicStun != null) periodicStun..unMapUpgrade()
    ]);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    for (var element in pulseAttributes) {
      element.mapUpgrade();
    }
    attr.removePulseFunction(action);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Combined pulse";

  @override
  String description() {
    return "Concentrate your magic into a singular powerful pulse!";
  }
}

// aaa
class IncreaseExperienceGrabAttribute extends Attribute {
  IncreaseExperienceGrabAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.combinePeriodicPulse;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes => {};

  List<Attribute> pulseAttributes = [];

  @override
  int get maxLevel => 1;

  double baseSize = 4;

  @override
  void action() async {}

  @override
  void mapUpgrade() {
    if (victimEntity is! Player) return;
    final player = victimEntity as Player;
    player.xpSensorRadius.setParameterPercentValue(attributeId, 1);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! Player) return;
    final player = victimEntity as Player;
    player.xpSensorRadius.removePercentKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Focus.";

  @override
  String description() {
    return "Double experience grab radius";
  }
}

// aaa
class MarkSentryAttribute extends Attribute {
  MarkSentryAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.sentryMarkEnemy;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes => {};

  List<Attribute> pulseAttributes = [];

  @override
  int get maxLevel => 2;

  double baseSize = 4;

  List<ChildEntity> sentries = [];

  @override
  void action() async {}

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    for (var i = 0; i < upgradeLevel; i++) {
      final temp = MarkEnemySentry(
          initialPosition: Vector2.zero(),
          enviroment: attr.enviroment,
          upgradeLevel: upgradeLevel,
          parentEntity: attr);
      sentries.add(temp);
      attr.addHeadEntity(temp);
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    for (var element in sentries) {
      attr.removeHeadEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Mark enemies for crit";
  }
}
