import 'package:flame/components.dart';
import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/entities/child_entities.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/player/player.dart';
import 'package:game_app/resources/functions/vector_functions.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapon_class.dart';
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
    case AttributeType.sentryRangedAttack:
      return RangedAttackSentryAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.sentryGrabItems:
      return GrabItemsSentryAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.sentryElementalFly:
      return ElementalSentryAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.sentryCaptureBullet:
      return CaptureBulletSentryAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.mirrorOrb:
      return MirrorOrbAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.shieldSurround:
      return ShieldSentryAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.swordSurround:
      return SwordSentryAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.reverseKnockback:
      return ReverseKnockbackAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.projectileSplitExplode:
      return ProjectileSplitExplodeAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.dodgeStandStillIncrease:
      return DodgeIncreaseStandStillAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.damageStandStillIncrease:
      return DamageIncreaseStandStillAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.defenceStandStillIncrease:
      return DefenceIncreaseStandStillAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.invincibleDashing:
      return InvincibleDashAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.dashSpeedDistance:
      return DashSpeedDistanceAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.dashAttackEmpower:
      return DashAttackEmpowerAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.teleportDash:
      return TeleportDashAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.weaponMerge:
      return WeaponMergeAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.reloadSpray:
      return ReloadSprayAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.reloadInvincibility:
      return ReloadInvincibilityAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.reloadPush:
      return ReloadPushAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.focus:
      return FocusAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.sonicWave:
      return SonicWaveAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.daggerSwing:
      return DaggerSwingAttribute(level: level, victimEntity: victimEntity);

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

  void onKill(DamageInstance damage) async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: damage.victim.center,
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

  double baseSize = 5;
  double baseOomph = 8;

  @override
  void action() async {
    if (victimEntity == null) return;
    final radius = baseSize + increasePercentOfBase(baseSize);
    final playerPos = victimEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: victimEntity!.center,
      animationRandomlyFlipped: true,
      radius: radius,
      tickRate: .05,
      durationType: DurationType.instant,
      duration: victimEntity!.durationPercentIncrease.parameter * 2.5,
      onTick: (entity, areaId) {
        final increaseRes = increase(true, baseOomph);
        final double distanceScaled =
            (entity.center.distanceTo(playerPos).clamp(0, radius) / radius);
        entity.body.applyForce((entity.center - playerPos).normalized() *
            (baseOomph + increaseRes) *
            (1 - distanceScaled));
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

class RangedAttackSentryAttribute extends Attribute {
  RangedAttackSentryAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.sentryRangedAttack;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.frost, DamageType.energy, DamageType.magic};

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
      final temp = RangedAttackSentry(
          initialPosition: Vector2.zero(),
          enviroment: attr.enviroment,
          damageType: damageType ?? allowedDamageTypes.first,
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
    return "Periodically attack enemies";
  }
}

class GrabItemsSentryAttribute extends Attribute {
  GrabItemsSentryAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.sentryGrabItems;

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
      final temp = GrabItemsSentry(
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
    return "Grab dropped items scattered across the world";
  }
}

class ElementalSentryAttribute extends Attribute {
  ElementalSentryAttribute(
      {required super.level, required super.victimEntity, super.damageType});

  @override
  AttributeType attributeType = AttributeType.sentryElementalFly;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.psychic};

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
      final temp = ElementalAttackSentry(
          initialPosition: Vector2.zero(),
          enviroment: attr.enviroment,
          damageType: damageType ?? allowedDamageTypes.first,
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
    return "Attacks enemies";
  }
}

class CaptureBulletSentryAttribute extends Attribute {
  CaptureBulletSentryAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.sentryCaptureBullet;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

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
      final temp = ElementalCaptureBulletSentry(
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
    return "Redirect";
  }
}

class MirrorOrbAttribute extends Attribute {
  MirrorOrbAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.mirrorOrb;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

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
    attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = MirrorOrbSentry(
          initialPosition: Vector2.zero(),
          enviroment: attr.enviroment,
          upgradeLevel: upgradeLevel,
          parentEntity: attr);
      sentries.add(temp);
      attr.addBodyEntity(temp);
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    for (var element in sentries) {
      attr.removeBodyEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Redirect";
  }
}

class ShieldSentryAttribute extends Attribute {
  ShieldSentryAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.shieldSurround;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

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
    attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = ShieldSentry(
          initialPosition: Vector2.zero(),
          enviroment: attr.enviroment,
          upgradeLevel: upgradeLevel,
          parentEntity: attr);
      sentries.add(temp);
      attr.addBodyEntity(temp);
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    for (var element in sentries) {
      attr.removeBodyEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Shield";
  }
}

class SwordSentryAttribute extends Attribute {
  SwordSentryAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.swordSurround;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

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
    attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = SwordSentry(
          initialPosition: Vector2.zero(),
          enviroment: attr.enviroment,
          upgradeLevel: upgradeLevel,
          parentEntity: attr);
      sentries.add(temp);
      attr.addBodyEntity(temp);
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    for (var element in sentries) {
      attr.removeBodyEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Shield";
  }
}

class ReverseKnockbackAttribute extends Attribute {
  ReverseKnockbackAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.reverseKnockback;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void action() async {}

  @override
  void mapUpgrade() {
    victimEntity?.knockBackIncreaseParameter
        .setParameterPercentValue(attributeId, -2);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.knockBackIncreaseParameter.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Reverse Knockback";
  }
}

class ProjectileSplitExplodeAttribute extends Attribute {
  ProjectileSplitExplodeAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.projectileSplitExplode;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void action() async {}

  double cooldown = 3;
  TimerComponent? cooldownTimer;
  int count = 6;

  void projectileExplode(Projectile projectile) {
    if (cooldownTimer != null || projectile.hitIds.isEmpty) return;
    cooldownTimer = TimerComponent(
        period: cooldown,
        removeOnFinish: true,
        onTick: () => cooldownTimer = null)
      ..addToParent(victimEntity!);

    final position = projectile.center.clone();
    List<Vector2> temp =
        splitVector2DeltaIntoArea(projectile.delta, count, 360 - (360 / count));

    for (var element in temp) {
      final newProjectile = projectile.projectileType.generateProjectile(
          delta: element,
          originPositionVar: position,
          ancestorVar: projectile.weaponAncestor,
          chargeAmount: .5);

      newProjectile.hitIds.addAll(projectile.hitIds);

      victimEntity?.gameEnviroment.physicsComponent.add(newProjectile);
    }
  }

  @override
  void mapUpgrade() {
    if (victimEntity is AttackFunctionality) {
      for (var element in victimEntity?.getAllWeaponItems(true, true) ??
          const Iterable.empty()) {
        if (element is! AttributeWeaponFunctionsFunctionality ||
            element is! ProjectileFunctionality) continue;
        element.onProjectileDeath.add(projectileExplode);
      }
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is AttackFunctionality) {
      for (var element in victimEntity?.getAllWeaponItems(true, true) ??
          const Iterable.empty()) {
        if (element is! AttributeWeaponFunctionsFunctionality) continue;
        element.onProjectileDeath.remove(projectileExplode);
      }
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Projectile explode";
  }
}

abstract class StillAttribute extends Attribute {
  StillAttribute({required super.level, required super.victimEntity});

  @override
  void action() async {}

  double checkTimerDuration = .3;
  double delay = 3;
  late TimerComponent checkTimer;
  TimerComponent? delayTimer;
  bool isMapped = false;
  double notMovingSpeed = .01;

  void applyStandStillEffect(bool apply);

  void mapDodgeIncrease(bool apply) {
    if (apply) {
      applyStandStillEffect(apply);
      isMapped = true;
    } else {
      delayTimer?.timer.stop();
      delayTimer?.removeFromParent();
      delayTimer = null;
      applyStandStillEffect(apply);
      isMapped = false;
    }
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! MovementFunctionality) return;
    checkTimer = TimerComponent(
      period: checkTimerDuration,
      repeat: true,
      onTick: () {
        final currentSpeed =
            (victimEntity as MovementFunctionality).moveDelta.normalize();
        if (!isMapped && currentSpeed < notMovingSpeed && delayTimer == null) {
          delayTimer = TimerComponent(
              period: delay,
              onTick: () {
                mapDodgeIncrease(true);
              },
              removeOnFinish: true)
            ..addToParent(victimEntity!);
        } else if (isMapped && currentSpeed >= notMovingSpeed) {
          mapDodgeIncrease(false);
        }
      },
    )..addToParent(victimEntity!);

    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.dashBeginFunctions.add(dashFunction);
    }
  }

  void dashFunction() {
    mapDodgeIncrease(false);
  }

  @override
  void unMapUpgrade() {
    checkTimer.timer.stop();
    checkTimer.removeFromParent();
    mapDodgeIncrease(false);

    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.dashBeginFunctions.remove(dashFunction);
    }
  }
}

class DodgeIncreaseStandStillAttribute extends StillAttribute {
  DodgeIncreaseStandStillAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.dodgeStandStillIncrease;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void applyStandStillEffect(bool apply) {
    if (apply) {
      if (victimEntity is DodgeFunctionality) {
        final dodgeFunc = victimEntity as DodgeFunctionality;
        dodgeFunc.dodgeChance.setParameterFlatValue(attributeId, .5);
      }
    } else {
      if (victimEntity is DodgeFunctionality) {
        final dodgeFunc = victimEntity as DodgeFunctionality;
        dodgeFunc.dodgeChance.removeKey(attributeId);
      }
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Projectile explode";
  }
}

class DefenceIncreaseStandStillAttribute extends StillAttribute {
  DefenceIncreaseStandStillAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.defenceStandStillIncrease;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void action() async {}

  @override
  void applyStandStillEffect(bool apply) {
    if (apply) {
      Map<DamageType, double> returnMap = {};
      for (var element in DamageType.values) {
        returnMap[element] = -.5;
      }
      victimEntity?.damageTypeResistance
          .setDamagePercentIncrease(attributeId, returnMap);
    } else {
      victimEntity?.damageTypeResistance.removePercentKey(attributeId);
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Projectile explode";
  }
}

class DamageIncreaseStandStillAttribute extends StillAttribute {
  DamageIncreaseStandStillAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.damageStandStillIncrease;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void action() async {}

  @override
  void applyStandStillEffect(bool apply) {
    if (apply) {
      victimEntity?.damagePercentIncrease
          .setParameterPercentValue(attributeId, .2);
    } else {
      victimEntity?.damagePercentIncrease.removeKey(attributeId);
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Projectile explode";
  }
}

class InvincibleDashAttribute extends Attribute {
  InvincibleDashAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.invincibleDashing;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void action() async {}

  @override
  void mapUpgrade() {
    if (victimEntity is! DashFunctionality) return;
    final dashFunc = victimEntity as DashFunctionality;
    dashFunc.invincibleWhileDashing.setIncrease(attributeId, true);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! DashFunctionality) return;
    final dashFunc = victimEntity as DashFunctionality;
    dashFunc.invincibleWhileDashing.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Invincible Dashing";
  }
}

class DashSpeedDistanceAttribute extends Attribute {
  DashSpeedDistanceAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.dashSpeedDistance;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void action() async {}

  @override
  void mapUpgrade() {
    if (victimEntity is! DashFunctionality) return;
    final dashFunc = victimEntity as DashFunctionality;
    dashFunc.dashDistance.setParameterPercentValue(attributeId, .5);
    dashFunc.dashDuration.setParameterPercentValue(attributeId, -.5);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! DashFunctionality) return;
    final dashFunc = victimEntity as DashFunctionality;
    dashFunc.dashDistance.removeKey(attributeId);
    dashFunc.dashDuration.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Dash distance speed";
  }
}

class DashAttackEmpowerAttribute extends Attribute {
  DashAttackEmpowerAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.dashAttackEmpower;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void action() async {
    victimEntity?.addAttribute(AttributeType.empowered,
        isTemporary: true, perpetratorEntity: victimEntity);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.dashEndFunctions.add(action);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.dashEndFunctions.remove(action);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Empower dash attack";
  }
}

class TeleportDashAttribute extends Attribute {
  TeleportDashAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.teleportDash;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    if (victimEntity is! DashFunctionality) return;
    final dash = victimEntity as DashFunctionality;
    dash.teleportDash.setIncrease(attributeId, true);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! DashFunctionality) return;
    final dash = victimEntity as DashFunctionality;
    dash.teleportDash.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Teleport";
  }
}

class WeaponMergeAttribute extends Attribute {
  WeaponMergeAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.weaponMerge;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  List<Weapon> movedWeapons = [];

  @override
  void mapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final attackEntity = victimEntity as AttackFunctionality;
    final otherWeapons = victimEntity?.getAllWeaponItems(false, false);
    final currentWeapon = attackEntity.currentWeapon;
    if (otherWeapons == null || currentWeapon == null) return;

    for (var element in otherWeapons
        .where((element) => element.weaponId != currentWeapon.weaponId)) {
      attackEntity.currentWeapon?.addAdditionalWeapon(element);
      movedWeapons.add(element);
    }

    attackEntity.carriedWeapons.removeWhere((key, value) =>
        movedWeapons.any((element) => element.weaponId == value.weaponId));

    attackEntity.setWeapon(currentWeapon);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final attack = victimEntity as AttackFunctionality;
    final otherWeapons = victimEntity?.getAllWeaponItems(false, false);
    final currentWeapon = attack.currentWeapon;
    if (otherWeapons == null || currentWeapon == null) return;

    attack.carriedWeapons.addAll([currentWeapon, ...movedWeapons].asMap());

    attack.setWeapon(attack.currentWeapon!);

    currentWeapon.additionalWeapons.removeWhere((key, value) =>
        movedWeapons.any((element) => element.weaponId == value.weaponId));
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Teleport";
  }
}

class ThornsAttribute extends Attribute {
  ThornsAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.thorns;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  List<Weapon> movedWeapons = [];

  void onTouchBleed(HealthFunctionality other) {
    if (other is AttributeFunctionality) {
      final attr = other as AttributeFunctionality;
      attr.addAttribute(AttributeType.bleed,
          isTemporary: true, perpetratorEntity: victimEntity);
    }
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! TouchDamageFunctionality) return;
    final touch = victimEntity as TouchDamageFunctionality;

    touch.touchDamage.setDamageFlatIncrease(attributeId, DamageType.physical,
        1.0 * upgradeLevel, 5.0 * upgradeLevel);

    if (upgradeLevel != 2 || victimEntity is! AttributeFunctionsFunctionality) {
      return;
    }

    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onTouch.add(onTouchBleed);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! TouchDamageFunctionality) return;
    final touch = victimEntity as TouchDamageFunctionality;

    touch.touchDamage.removeKey(attributeId);
    if (victimEntity is! AttributeFunctionsFunctionality) {
      return;
    }

    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onTouch.remove(onTouchBleed);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Touch Damage";
  }
}

class ReloadSprayAttribute extends Attribute {
  ReloadSprayAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.reloadSpray;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  Map<String, int> weaponBulletCount = {};

  double cooldown = 3;
  TimerComponent? cooldownTimer;

  void projectileExplode(ProjectileFunctionality weapon) {
    final count = weaponBulletCount[weapon.weaponId] ?? 0;
    if (count == 0) return;
    final position = victimEntity?.center.clone() ?? Vector2.zero();
    List<Vector2> temp =
        splitVector2DeltaIntoArea(Vector2.zero(), count, 360 - (360 / count));
    for (var element in temp) {
      final newProjectile = weapon.projectileType!.generateProjectile(
          delta: element,
          originPositionVar: position,
          ancestorVar: weapon,
          chargeAmount: .5);

      victimEntity?.gameEnviroment.physicsComponent.add(newProjectile);
    }
  }

  void meleeExplode(MeleeFunctionality weapon) {
    final count = weaponBulletCount[weapon.weaponId] ?? 0;
    if (count == 0) return;
    final position = victimEntity?.center.clone() ?? Vector2.zero();
    List<double> temp = splitRadInCone(0.0, count, 360 - (360 / count));
    int i = 0;
    for (var element in temp) {
      final newSwing = MeleeAttackHandler(
          initPosition: position,
          initAngle: element,
          attachmentPoint: victimEntity,
          currentAttack: weapon.meleeAttacks[i % weapon.attackCount],
          weaponAncestor: weapon);

      victimEntity?.gameEnviroment.physicsComponent.add(newSwing);
      i++;
    }
  }

  void incrementCounter(Weapon weapon) {
    if (weapon is! ReloadFunctionality) return;

    weaponBulletCount[weapon.weaponId] = weapon.spentAttacks;
  }

  void shootAttacks(Weapon weapon) {
    if (cooldownTimer == null) {
      if (weapon is ProjectileFunctionality) {
        projectileExplode(weapon);
      }
      if (weapon is MeleeFunctionality) {
        meleeExplode(weapon);
      }
    }
    weaponBulletCount.remove(weapon.weaponId);

    cooldownTimer ??= TimerComponent(
        period: cooldown,
        removeOnFinish: true,
        onTick: () => cooldownTimer = null)
      ..addToParent(victimEntity!);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;

    attr.onAttack.add(incrementCounter);
    attr.onReload.add(shootAttacks);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;

    attr.onAttack.remove(incrementCounter);
    attr.onReload.remove(shootAttacks);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Reload Spray";
  }
}

class ReloadPushAttribute extends Attribute {
  ReloadPushAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.reloadPush;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  double baseSize = 4;
  double baseOomph = 7;

  void push(Weapon _) {
    if (victimEntity == null) return;
    final radius = baseSize + increasePercentOfBase(baseSize);
    final playerPos = victimEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: victimEntity!,
      position: victimEntity!.center,
      animationRandomlyFlipped: true,
      radius: radius,
      tickRate: .05,
      durationType: DurationType.instant,
      duration: victimEntity!.durationPercentIncrease.parameter * 2.5,
      onTick: (entity, areaId) {
        final increaseRes = increase(true, baseOomph);
        final double distanceScaled =
            (entity.center.distanceTo(playerPos).clamp(0, radius) / radius);
        entity.body.applyForce((entity.center - playerPos).normalized() *
            (baseOomph + increaseRes) *
            (1 - distanceScaled));
      },
    );
    victimEntity?.gameEnviroment.physicsComponent.add(explosion);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onReload.add(push);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onReload.remove(push);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Reload Push";
  }
}

class ReloadInvincibilityAttribute extends Attribute {
  ReloadInvincibilityAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.reloadPush;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;
  Map<String, double> weaponBulletSpentPercent = {};

  TimerComponent? invincibilityDuration;

  void incrementCounter(Weapon weapon) {
    if (weapon is! ReloadFunctionality) return;
    weaponBulletSpentPercent[weapon.weaponId] =
        (weapon.spentAttacks / weapon.maxAttacks.parameter).clamp(0, 1);
  }

  void onReload(ReloadFunctionality weapon) {
    victimEntity?.invincible.setIncrease(attributeId, true);
    invincibilityDuration?.timer.stop();
    invincibilityDuration?.removeFromParent();
    invincibilityDuration = TimerComponent(
      period: weapon.reloadTime.parameter *
          weaponBulletSpentPercent[weapon.weaponId]!,
      removeOnFinish: true,
      onTick: () {
        victimEntity?.invincible.removeKey(attributeId);
      },
    )..addToParent(victimEntity!);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onReload.add(onReload);
    attr.onAttack.add(incrementCounter);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onReload.remove(onReload);
    attr.onAttack.remove(incrementCounter);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Reload Invincible";
  }
}

class FocusAttribute extends Attribute {
  FocusAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.focus;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  Map<String, int> additionalCount = {};
  Map<String, int> successiveCounts = {};
  Map<String, TimerComponent> delayCheckers = {};

  int max = 2;

  void applyWeaponIncrease(Weapon weapon, bool remove) {
    if (remove) {
      delayCheckers.remove(weapon.weaponId);
      additionalCount.remove(weapon.weaponId);
      successiveCounts.remove(weapon.weaponId);
      weapon.baseAttackCount.removeKey(attributeId);
    } else {
      successiveCounts[weapon.weaponId] =
          (successiveCounts[weapon.weaponId] ?? 0) + 1;
      additionalCount[weapon.weaponId] =
          (successiveCounts[weapon.weaponId]! ~/ 3).clamp(0, max);
      weapon.baseAttackCount.setParameterFlatValue(
          attributeId, additionalCount[weapon.weaponId]!);
    }
  }

  void incrementCount(Weapon weapon) {
    if (delayCheckers[weapon.weaponId] != null) {
      applyWeaponIncrease(weapon, false);
    }
    delayCheckers[weapon.weaponId]?.timer.reset();
    delayCheckers[weapon.weaponId] ??= TimerComponent(
      period: weapon.attackTickRate.parameter * 2,
      onTick: () {
        applyWeaponIncrease(weapon, true);
      },
      removeOnFinish: true,
    )..addToParent(weapon);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onAttack.add(incrementCount);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.onAttack.remove(incrementCount);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Focus";
  }
}

class ChainingAttacksAttribute extends Attribute {
  ChainingAttacksAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.chainingAttacks;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 3;

  @override
  void mapUpgrade() {
    final weapons = victimEntity?.getAllWeaponItems(false, false);
    if (weapons == null) return;
    for (var element in weapons) {
      element.maxChainingTargets
          .setParameterFlatValue(attributeId, upgradeLevel);
    }
  }

  @override
  void unMapUpgrade() {
    final weapons = victimEntity?.getAllWeaponItems(false, false);
    if (weapons == null) return;
    for (var element in weapons) {
      element.maxChainingTargets.removeKey(attributeId);
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Increase chain count";
  }
}

class SonicWaveAttribute extends Attribute {
  SonicWaveAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.sonicWave;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  List<Weapon> newWeapons = [];

  @override
  void mapUpgrade() {
    final weapons = victimEntity
        ?.getAllWeaponItems(false, false)
        .whereType<MeleeFunctionality>();
    if (weapons == null) return;

    for (var element in weapons) {
      final newWeapon = WeaponType.blankProjectileWeapon
          .build(element.entityAncestor!, null, victimEntity!.gameRef, 0);
      element.addAdditionalWeapon(newWeapon);
      newWeapons.add(newWeapon);
    }
  }

  @override
  void unMapUpgrade() {
    final weapons = victimEntity
        ?.getAllWeaponItems(false, false)
        .whereType<MeleeFunctionality>();
    if (weapons == null) return;

    for (var element in weapons) {
      for (var additionalWeapon in newWeapons) {
        element.removeAdditionalWeapon(additionalWeapon.weaponId);
      }
    }
    newWeapons.clear();
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "add a sonic wave to your melee attacks";
  }
}

class DaggerSwingAttribute extends Attribute {
  DaggerSwingAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.daggerSwing;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  List<Weapon> newWeapons = [];

  @override
  void mapUpgrade() {
    final weapons = victimEntity
        ?.getAllWeaponItems(false, false)
        .whereType<ProjectileFunctionality>();
    if (weapons == null) return;

    for (var element in weapons) {
      final newWeapon = WeaponType.energySword
          .build(element.entityAncestor!, null, victimEntity!.gameRef, 0);
      element.addAdditionalWeapon(newWeapon);
      newWeapons.add(newWeapon);
    }
  }

  @override
  void unMapUpgrade() {
    final weapons = victimEntity
        ?.getAllWeaponItems(false, false)
        .whereType<ProjectileFunctionality>();
    if (weapons == null) return;

    for (var element in weapons) {
      for (var additionalWeapon in newWeapons) {
        element.removeAdditionalWeapon(additionalWeapon.weaponId);
      }
    }
    newWeapons.clear();
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Dagger attack to ranged weapons";
  }
}

class HomingProjectileAttribute extends Attribute {
  HomingProjectileAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.homingProjectiles;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    final weapons = victimEntity
        ?.getAllWeaponItems(false, true)
        .whereType<ProjectileFunctionality>();
    if (weapons == null) return;

    for (var element in weapons) {
      element.maxHomingTargets.setParameterFlatValue(attributeId, upgradeLevel);
    }
  }

  @override
  void unMapUpgrade() {
    final weapons = victimEntity
        ?.getAllWeaponItems(false, true)
        .whereType<ProjectileFunctionality>();
    if (weapons == null) return;

    for (var element in weapons) {
      element.maxHomingTargets.removeKey(attributeId);
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "add a sonic wave to your melee attacks";
  }
}
