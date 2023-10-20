import 'package:flame/components.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
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

import '../game/area_effects.dart';
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
    case AttributeType.gravityDash:
      return GravityDashAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.groundSlam:
      return GroundSlamAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.psychicReach:
      return PsychicReachAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.periodicPush:
      return PeriodicPushAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.periodicMagicPulse:
      return PeriodicMagicPulseAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);
    case AttributeType.periodicStun:
      return PeriodicStunAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);

    case AttributeType.combinePeriodicPulse:
      return CombinePeriodicPulseAttribute(
          level: level, victimEntity: victimEntity, damageType: damageType);

    case AttributeType.increaseXpGrabRadius:
      return IncreaseExperienceGrabAttribute(
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

    //TODO Sentry Combinations

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
    //TODO Combination Standstill

    // case AttributeType.invincibleDashing:
    //   return InvincibleDashAttribute(level: level, victimEntity: victimEntity);
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
    case AttributeType.thorns:
      return ThornsAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.reloadSpray:
      return ReloadSprayAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.reloadInvincibility:
      return ReloadInvincibilityAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.reloadPush:
      return ReloadPushAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.focus:
      return FocusAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.battleScars:
      return BattleScarsAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.sonicWave:
      return SonicWaveAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.daggerSwing:
      return DaggerSwingAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.forbiddenMagic:
      return ForbiddenMagicAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.glassWand:
      return GlassWandAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.chainingAttacks:
      return ChainingAttacksAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.homingProjectiles:
      return ChainingAttacksAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.heavyHitter:
      return HeavyHitterAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.quickShot:
      return QuickShotAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.rapidFire:
      return RapidFireAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.bigPockets:
      return BigPocketsAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.secondsPlease:
      return SecondsPleaseAttribute(level: level, victimEntity: victimEntity);
    case AttributeType.primalMagic:
      return PrimalMagicAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.appleADay:
      return AppleADayAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.critChanceDecreaseDamage:
      return CritChanceDecreaseDamageAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.putYourBackIntoIt:
      return PutYourBackIntoItAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.agile:
      return AgileAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.areaSizeDecreaseDamage:
      return AreaSizeDecreaseDamageAttribute(
          level: level, victimEntity: victimEntity);

    case AttributeType.decreaseMaxAmmoIncreaseReloadSpeed:
      return DecreaseMaxAmmoIncreaseReloadSpeedAttribute(
          level: level, victimEntity: victimEntity);

    case AttributeType.potionSeller:
      return PotionSellerAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.reduceHealthIncreaseLifeSteal:
      return ReduceHealthIncreaseLifeStealAttribute(
          level: level, victimEntity: victimEntity);
    case AttributeType.staminaSteal:
      return StaminaStealAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.splitDamage:
      return SplitDamageAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.rollTheDice:
      return RollTheDiceAttribute(level: level, victimEntity: victimEntity);

    case AttributeType.slugTrail:
      return SlugTrailAttribute(level: level, victimEntity: victimEntity);

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

  double baseSize = 1;

  void onKill(DamageInstance damage) async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: damage.victim.center,
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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
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

  double baseSize = 1;

  void onDash() async {
    if (victimEntity == null) return;
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: victimEntity!.center,
        animationRandomlyFlipped: true,
        collisionDelay: .35,
        radius: baseSize + increasePercentOfBase(baseSize),
        durationType: DurationType.instant,
        duration: victimEntity!.durationPercentIncrease.parameter,
        damage: {
          damageType ?? allowedDamageTypes.first: (
            increase(true, 5),
            increase(true, 10)
          )
        });
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.dashBeginFunctions.add(onDash);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.dashBeginFunctions.remove(onDash);
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
  AttributeType attributeType = AttributeType.gravityDash;

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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;
    final attr = victimEntity as AttributeFunctionsFunctionality;
    attr.dashBeginFunctions.add(onDash);
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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
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
  String title = "Periodic Push";

  @override
  String description() {
    return "Periodically push enemies away from you!";
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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
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
  AttributeType attributeType = AttributeType.increaseXpGrabRadius;

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
    player.xpSensorRadius.setParameterFlatValue(attributeId, 5);
    player.xpGrabRadiusFixture.shape.radius = player.xpSensorRadius.parameter;
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! Player) return;
    final player = victimEntity as Player;
    player.xpSensorRadius.removeKey(attributeId);
    player.xpGrabRadiusFixture.shape.radius = player.xpSensorRadius.parameter;
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Increase experience grab radius";

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
    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      for (var i = 0; i < upgradeLevel; i++) {
        final temp = RangedAttackSentry(
            initialPosition: Vector2.zero(),
            damageType: damageType ?? allowedDamageTypes.first,
            upgradeLevel: upgradeLevel,
            parentEntity: attr);
        sentries.add(temp);
        attr.addHeadEntity(temp);
      }
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
    // attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = ShieldSentry(
          initialPosition: Vector2.zero(),
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
    // attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = SwordSentry(
          initialPosition: Vector2.zero(),
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

    Vector2 position = projectile.center.clone();
    if (projectile.projectileType == ProjectileType.laser) {
      final list = (projectile as LaserProjectile).linePairs.toList();

      position = list[rng.nextInt(list.length.clamp(0, 3))].$1;
    }
    List<Vector2> temp =
        splitVector2DeltaIntoArea(projectile.delta, count, 360 - (360 / count));
    final List<Projectile> newProjectiles = [];
    for (var element in temp) {
      final newProjectile = projectile.projectileType.generateProjectile(
          delta: element,
          size: projectile.size,
          originPositionVar: position,
          ancestorVar: projectile.weaponAncestor,
          chargeAmount: .5);

      newProjectile.hitIds.addAll(projectile.hitIds);
      newProjectiles.add(newProjectile);
    }
    victimEntity?.gameEnviroment.addPhysicsComponent(newProjectiles);
  }

  @override
  void mapUpgrade() {
    applyActionToWeapons((weapon) {
      if (weapon is! AttributeWeaponFunctionsFunctionality ||
          weapon is! ProjectileFunctionality) return;
      weapon.onProjectileDeath.add(projectileExplode);
    }, true, true);
  }

  @override
  void unMapUpgrade() {
    applyActionToWeapons((weapon) {
      if (weapon is! AttributeWeaponFunctionsFunctionality) return;
      weapon.onProjectileDeath.remove(projectileExplode);
    }, true, true);
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

abstract class StandStillAttribute extends Attribute {
  StandStillAttribute({required super.level, required super.victimEntity});

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
        final currentSpeed = (victimEntity as MovementFunctionality)
            .currentMoveDelta
            .normalize();
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

class DodgeIncreaseStandStillAttribute extends StandStillAttribute {
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
    return "Dodge increase stand still";
  }
}

class DefenceIncreaseStandStillAttribute extends StandStillAttribute {
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
    return "Defence increase stand still";
  }
}

class DamageIncreaseStandStillAttribute extends StandStillAttribute {
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
    return "Damage increase stand still";
  }
}

// class InvincibleDashAttribute extends Attribute {
//   InvincibleDashAttribute({required super.level, required super.victimEntity});

//   @override
//   AttributeType attributeType = AttributeType.invincibleDashing;

//   @override
//   double get factor => .25;

//   @override
//   bool increaseFromBaseParameter = false;

//   @override
//   int get maxLevel => 1;

//   @override
//   void action() async {}

//   @override
//   void mapUpgrade() {
//     if (victimEntity is! DashFunctionality) return;
//     final dashFunc = victimEntity as DashFunctionality;
//     dashFunc.invincibleWhileDashing.setIncrease(attributeId, true);
//   }

//   @override
//   void unMapUpgrade() {
//     if (victimEntity is! DashFunctionality) return;
//     final dashFunc = victimEntity as DashFunctionality;
//     dashFunc.invincibleWhileDashing.removeKey(attributeId);
//   }

//   @override
//   String icon = "attributes/topSpeed.png";

//   @override
//   String title = "Keep a watchful eye";

//   @override
//   String description() {
//     return "Invincible Dashing";
//   }
// }

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
  String title = "Merge Weapons";

  @override
  String description() {
    return "Merge Weapons";
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
    final List<Projectile> newProjectiles = [];
    for (var element in temp) {
      final newProjectile = weapon.projectileType!.generateProjectile(
          delta: element,
          originPositionVar: position,
          ancestorVar: weapon,
          chargeAmount: .5);

      newProjectiles.add(newProjectile);
    }
    victimEntity?.gameEnviroment.addPhysicsComponent(newProjectiles);
  }

  void meleeExplode(MeleeFunctionality weapon) {
    final count = weaponBulletCount[weapon.weaponId] ?? 0;
    if (count == 0) return;
    final position = victimEntity?.center.clone() ?? Vector2.zero();
    List<double> temp = splitRadInCone(0.0, count, 360 - (360 / count), false);
    int i = 0;
    final List<MeleeAttackHandler> newSwings = [];
    for (var element in temp) {
      final newSwing = MeleeAttackHandler(
          initPosition: position,
          initAngle: element,
          attachmentPoint: victimEntity,
          currentAttack: weapon.meleeAttacks[i % weapon.getAttackCount(0)],
          weaponAncestor: weapon);

      newSwings.add(newSwing);
      i++;
    }

    victimEntity?.gameEnviroment.addPhysicsComponent(newSwings);
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
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
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
      weapon.attackCountIncrease.removeKey(attributeId);
    } else {
      successiveCounts[weapon.weaponId] =
          (successiveCounts[weapon.weaponId] ?? 0) + 1;
      additionalCount[weapon.weaponId] =
          (successiveCounts[weapon.weaponId]! ~/ 3).clamp(0, max);
      weapon.attackCountIncrease.setParameterFlatValue(
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
    applyActionToWeapons((weapon) {
      weapon.chainingTargets.setParameterFlatValue(attributeId, upgradeLevel);
    }, false, false);
  }

  @override
  void unMapUpgrade() {
    applyActionToWeapons((weapon) {
      weapon.chainingTargets.removeKey(attributeId);
    }, false, false);
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
    applyActionToWeapons((weapon) {
      if (weapon is! MeleeFunctionality) return;
      final newWeapon = WeaponType.blankProjectileWeapon
          .build(weapon.entityAncestor!, null, victimEntity!.game, 0);
      weapon.addAdditionalWeapon(newWeapon);
      newWeapons.add(newWeapon);
    }, false, false);
  }

  @override
  void unMapUpgrade() {
    applyActionToWeapons((weapon) {
      if (weapon is! MeleeFunctionality) return;
      for (var additionalWeapon in newWeapons) {
        weapon.removeAdditionalWeapon(additionalWeapon.weaponId);
      }
    }, false, false);

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
    applyActionToWeapons((weapon) {
      if (weapon is! ProjectileFunctionality) return;
      final newWeapon = WeaponType.holySword
          .build(weapon.entityAncestor!, null, victimEntity!.game, 0);

      if (newWeapon is StaminaCostFunctionality) {
        newWeapon.weaponStaminaCost.setParameterPercentValue(attributeId, -1);
      }

      weapon.addAdditionalWeapon(newWeapon);

      newWeapons.add(newWeapon);
    }, false, false);
  }

  @override
  void unMapUpgrade() {
    applyActionToWeapons((weapon) {
      if (weapon is! ProjectileFunctionality) return;
      for (var additionalWeapon in newWeapons) {
        weapon.removeAdditionalWeapon(additionalWeapon.weaponId);
      }
    }, false, false);

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
    applyActionToWeapons((weapon) {
      if (weapon is! ProjectileFunctionality) return;
      weapon.maxHomingTargets.setParameterFlatValue(attributeId, upgradeLevel);
    }, false, true);
  }

  @override
  void unMapUpgrade() {
    applyActionToWeapons((weapon) {
      if (weapon is! ProjectileFunctionality) return;
      weapon.maxHomingTargets.removeKey(attributeId);
    }, false, true);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Keep a watchful eye";

  @override
  String description() {
    return "Homing projectiles";
  }
}

class HeavyHitterAttribute extends Attribute {
  HeavyHitterAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.heavyHitter;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    victimEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, .25);

    applyActionToWeapons((weapon) {
      weapon.attackTickRate.setParameterPercentValue(attributeId, .35);
    }, false, true);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damagePercentIncrease.removeKey(attributeId);
    applyActionToWeapons((weapon) {
      weapon.attackTickRate.removeKey(attributeId);
    }, false, true);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Heavy Hitter";

  @override
  String description() {
    return "Reduce attack speed while increasing damage";
  }
}

class QuickShotAttribute extends Attribute {
  QuickShotAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.quickShot;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    victimEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.35);
    applyActionToWeapons((weapon) {
      weapon.attackTickRate.setParameterPercentValue(attributeId, -.25);
    }, false, true);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damagePercentIncrease.removeKey(attributeId);

    applyActionToWeapons((weapon) {
      weapon.attackTickRate.removeKey(attributeId);
    }, false, true);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Quick Shot";

  @override
  String description() {
    return "Increase attack speed while decreasing damage";
  }
}

class RapidFireAttribute extends Attribute {
  RapidFireAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.rapidFire;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    victimEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.15 * upgradeLevel);

    applyActionToWeapons((weapon) {
      weapon.attackTickRate
          .setParameterPercentValue(attributeId, -.15 * upgradeLevel);
      if (weapon is ReloadFunctionality) {
        weapon.maxAttacks
            .setParameterPercentValue(attributeId, .25 * upgradeLevel);
      }
    }, false, true);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damagePercentIncrease.removeKey(attributeId);

    applyActionToWeapons((weapon) {
      weapon.attackTickRate.removeKey(attributeId);
      if (weapon is ReloadFunctionality) {
        weapon.maxAttacks.removeKey(attributeId);
      }
    }, false, true);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Quick Shot";

  @override
  String description() {
    return "Increase attack speed while decreasing damage";
  }
}

class BigPocketsAttribute extends Attribute {
  BigPocketsAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.bigPockets;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;
    final attack = victimEntity as AttackFunctionality;

    applyActionToWeapons((weapon) {
      if (weapon is ReloadFunctionality) {
        weapon.maxAttacks.setParameterPercentValue(attributeId, .5);
      }
    }, false, true);

    if (victimEntity is! MovementFunctionality) return;
    final move = victimEntity as MovementFunctionality;
    move.speed.setParameterPercentValue(attributeId, -.25);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttackFunctionality) return;

    applyActionToWeapons((weapon) {
      if (weapon is ReloadFunctionality) {
        weapon.maxAttacks.removeKey(attributeId);
      }
    }, false, true);

    if (victimEntity is! MovementFunctionality) return;
    final move = victimEntity as MovementFunctionality;
    move.speed.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Bag of Holding";

  @override
  String description() {
    return "Increase max ammo, reduce movement speed";
  }
}

class SecondsPleaseAttribute extends Attribute {
  SecondsPleaseAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.secondsPlease;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    if (victimEntity is MovementFunctionality) {
      final move = victimEntity as MovementFunctionality;
      move.speed.setParameterPercentValue(attributeId, -.2);
    }

    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.maxHealth.setParameterPercentValue(attributeId, .5);
    }

    victimEntity?.height.setParameterFlatValue(attributeId, 1);
    victimEntity?.applyHeightToSprite();
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! MovementFunctionality) return;
    final move = victimEntity as MovementFunctionality;
    move.speed.removeKey(attributeId);

    if (victimEntity is! HealthFunctionality) return;
    final health = victimEntity as HealthFunctionality;
    health.maxHealth.removeKey(attributeId);
    victimEntity?.height.removeKey(attributeId);
    victimEntity?.applyHeightToSprite();
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Seconds Please";

  @override
  String description() {
    return "Increase health, reduce movement speed, increase max health";
  }
}

class PrimalMagicAttribute extends Attribute {
  PrimalMagicAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.primalMagic;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    if (victimEntity is! StaminaFunctionality) return;
    final stamina = victimEntity as StaminaFunctionality;
    stamina.staminaRegen
        .setParameterPercentValue(attributeId, .25 * upgradeLevel);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! StaminaFunctionality) return;
    final stamina = victimEntity as StaminaFunctionality;
    stamina.staminaRegen.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Primal Magic";

  @override
  String description() {
    return "Increase Stamina Regen";
  }
}

class AppleADayAttribute extends Attribute {
  AppleADayAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.appleADay;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    if (victimEntity is! HealthRegenFunctionality) return;
    final health = victimEntity as HealthRegenFunctionality;
    health.healthRegen
        .setParameterPercentValue(attributeId, .25 * upgradeLevel);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! HealthRegenFunctionality) return;
    final health = victimEntity as HealthRegenFunctionality;
    health.healthRegen.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Primal Magic";

  @override
  String description() {
    return "Increase Stamina Regen";
  }
}

class CritChanceDecreaseDamageAttribute extends Attribute {
  CritChanceDecreaseDamageAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.critChanceDecreaseDamage;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    victimEntity?.critChance.setParameterFlatValue(attributeId, .4);
    victimEntity?.critDamage.setParameterPercentValue(attributeId, -.25);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.critChance.removeKey(attributeId);
    victimEntity?.critDamage.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Critical Switch";

  @override
  String description() {
    return "Increase Crit Chance while also Decrease Crit Damage";
  }
}

class PutYourBackIntoItAttribute extends Attribute {
  PutYourBackIntoItAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.putYourBackIntoIt;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  bool increaseDamage(DamageInstance instance) {
    final health = victimEntity as HealthFunctionality;
    final increase =
        ((health.maxHealth.parameter / 100) / 2).clamp(1.0, double.infinity);
    instance.increaseByPercent(increase);
    return true;
  }

  @override
  void mapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality ||
        victimEntity is! HealthFunctionality) return;

    final attr = victimEntity as AttributeFunctionsFunctionality;

    attr.onHitOtherEntity.add(increaseDamage);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! AttributeFunctionsFunctionality) return;

    final attr = victimEntity as AttributeFunctionsFunctionality;

    attr.onHitOtherEntity.remove(increaseDamage);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Put your back into it";

  @override
  String description() {
    return "Melee attacks deal more damage the more health you have";
  }
}

class AgileAttribute extends Attribute {
  AgileAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.agile;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    if (victimEntity is! HealthFunctionality) return;

    final health = victimEntity as HealthFunctionality;

    health.maxHealth.setParameterPercentValue(attributeId, -.2);

    if (victimEntity is! MovementFunctionality) return;

    final move = victimEntity as MovementFunctionality;

    move.speed.setParameterPercentValue(attributeId, .3);
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is! HealthFunctionality) return;

    final health = victimEntity as HealthFunctionality;

    health.maxHealth.removeKey(attributeId);

    if (victimEntity is! MovementFunctionality) return;

    final move = victimEntity as MovementFunctionality;

    move.speed.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Agile";

  @override
  String description() {
    return "Reduce max health by X and increase speed";
  }
}

class AreaSizeDecreaseDamageAttribute extends Attribute {
  AreaSizeDecreaseDamageAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.areaSizeDecreaseDamage;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    victimEntity?.areaSizePercentIncrease
        .setParameterPercentValue(attributeId, .5);
    victimEntity?.areaDamagePercentIncrease
        .setParameterPercentValue(attributeId, -.25);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.areaSizePercentIncrease.removeKey(attributeId);
    victimEntity?.areaDamagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Area Size Decrease Damage";

  @override
  String description() {
    return "Reduce area damage and increase area size";
  }
}

class DecreaseMaxAmmoIncreaseReloadSpeedAttribute extends Attribute {
  DecreaseMaxAmmoIncreaseReloadSpeedAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType =
      AttributeType.decreaseMaxAmmoIncreaseReloadSpeed;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    applyActionToWeapons((weapon) {
      if (weapon is! ReloadFunctionality) return;
      weapon.maxAttacks.setParameterPercentValue(attributeId, -.5);
      weapon.reloadTime.setParameterPercentValue(attributeId, .25);
    }, false, true);
  }

  @override
  void unMapUpgrade() {
    applyActionToWeapons((weapon) {
      if (weapon is! ReloadFunctionality) return;
      weapon.maxAttacks.removeKey(attributeId);
      weapon.reloadTime.removeKey(attributeId);
    }, false, true);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Decrease Max Ammo Increase Reload Speed";

  @override
  String description() {
    return "Reduce max ammo while increase attack rate";
  }
}

class PotionSellerAttribute extends Attribute {
  PotionSellerAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.potionSeller;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    victimEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.2);
    victimEntity?.tickDamageIncrease.setParameterPercentValue(attributeId, .5);

    for (var element in StatusEffects.values) {
      victimEntity?.statusEffectsPercentIncrease
          .setDamagePercentIncrease(attributeId, element, .5);
    }
  }

  @override
  void unMapUpgrade() {
    victimEntity?.damagePercentIncrease.removeKey(attributeId);
    victimEntity?.tickDamageIncrease.removeKey(attributeId);
    victimEntity?.statusEffectsPercentIncrease.removePercentKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Potion Seller";

  @override
  String description() {
    return "Increase the effects of status effects and dots, while reducing regular damage.";
  }
}

class BattleScarsAttribute extends Attribute {
  BattleScarsAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.battleScars;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  @override
  void mapUpgrade() {
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.maxHealth.setParameterPercentValue(attributeId, 1.0);
    }
    if (victimEntity is DashFunctionality) {
      final dash = victimEntity as DashFunctionality;
      dash.dashDistance.setParameterPercentValue(attributeId, -.5);
      dash.dashCooldown.setParameterPercentValue(attributeId, .5);
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.maxHealth.removeKey(attributeId);
    }
    if (victimEntity is DashFunctionality) {
      final dash = victimEntity as DashFunctionality;
      dash.dashDistance.removeKey(attributeId);
      dash.dashCooldown.removeKey(attributeId);
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Battle Scars";

  @override
  String description() {
    return "Reducing dash effectivness, while increasing health by 200%";
  }
}

class ForbiddenMagicAttribute extends Attribute {
  ForbiddenMagicAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.forbiddenMagic;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 1;

  bool previousValue = false;

  @override
  void mapUpgrade() {
    int amountOfStaminaWeapons = 0;
    applyActionToWeapons((weapon) {
      if (weapon is StaminaCostFunctionality) {
        amountOfStaminaWeapons++;
      }
    }, true, true);

    if (victimEntity is HealthRegenFunctionality) {
      final health = victimEntity as HealthRegenFunctionality;
      health.healthRegen.setParameterPercentValue(attributeId,
          amountOfStaminaWeapons.clamp(0.5, double.infinity).toDouble());
    }
    if (victimEntity is StaminaFunctionality) {
      final stamina = victimEntity as StaminaFunctionality;
      stamina.stamina.setParameterPercentValue(attributeId, -1);
      previousValue = stamina.isForbiddenMagic;
      stamina.isForbiddenMagic = true;
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is HealthRegenFunctionality) {
      final health = victimEntity as HealthRegenFunctionality;
      health.healthRegen.removeKey(attributeId);
    }
    if (victimEntity is StaminaFunctionality) {
      final stamina = victimEntity as StaminaFunctionality;
      stamina.stamina.removeKey(attributeId);
      stamina.isForbiddenMagic = previousValue;
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Forbidden Magic";

  @override
  String description() {
    return "Remove stamina, stamina actions reduce health, increase health regen by 100% for each stamina consuming weapon possessed";
  }
}

class ReduceHealthIncreaseLifeStealAttribute extends Attribute {
  ReduceHealthIncreaseLifeStealAttribute(
      {required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.reduceHealthIncreaseLifeSteal;

  @override
  double get factor => .035;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.maxHealth
          .setParameterPercentValue(attributeId, -.1 * upgradeLevel);
    }

    victimEntity?.essenceSteal
        .setParameterPercentValue(attributeId, increase(false));
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;
      health.maxHealth.removeKey(attributeId);
    }

    victimEntity?.essenceSteal.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Reduce Health Increase Life Steal";

  @override
  String description() {
    return "Reduce max health, increase life steal";
  }
}

class StaminaStealAttribute extends Attribute {
  StaminaStealAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.staminaSteal;

  @override
  double get factor => .035;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    victimEntity?.staminaSteal.setIncrease(attributeId, true);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.staminaSteal.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Stamina Steal";

  @override
  String description() {
    return "Converts life steal to stamina steal";
  }
}

class SplitDamageAttribute extends Attribute {
  SplitDamageAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.splitDamage;

  @override
  double get factor => .035;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  bool splitDamage(DamageInstance instance) {
    final count = DamageType.values.length;
    double totalDamage = 0;

    for (var element in instance.damageMap.values) {
      totalDamage += element;
    }

    final splitDamage = totalDamage / count;

    instance.damageMap.clear();

    for (var element in DamageType.values
        .where((element) => element != DamageType.healing)) {
      instance.damageMap[element] = splitDamage;
    }

    return true;
  }

  @override
  void mapUpgrade() {
    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.onHitOtherEntity.add(splitDamage);
    }
  }

  @override
  void unMapUpgrade() {
    if (victimEntity is AttributeFunctionsFunctionality) {
      final attr = victimEntity as AttributeFunctionsFunctionality;
      attr.onHitOtherEntity.remove(splitDamage);
    }
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Damage Split";

  @override
  String description() {
    return "Evenly distributes damage across all damage types";
  }
}

class RollTheDiceAttribute extends Attribute {
  RollTheDiceAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.rollTheDice;

  @override
  double get factor => .035;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    victimEntity?.critChance.setParameterFlatValue(attributeId, .25);
    victimEntity?.critDamage.setParameterFlatValue(attributeId, .25);
    victimEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.5);
  }

  @override
  void unMapUpgrade() {
    victimEntity?.critChance.removeKey(attributeId);
    victimEntity?.critDamage.removeKey(attributeId);
    victimEntity?.damagePercentIncrease.removeKey(attributeId);
  }

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Increase crit chance and damage, while reducing damage";

  @override
  String description() {
    return "Increase crit chance and damage by 25%, while reducing base damage by 50%";
  }
}

class GlassWandAttribute extends Attribute {
  GlassWandAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.glassWand;

  @override
  double get factor => .035;

  @override
  bool increaseFromBaseParameter = false;

  @override
  int get maxLevel => 2;

  @override
  void mapUpgrade() {
    victimEntity?.maxLives.setParameterFlatValue(attributeId, 10);
    victimEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, 1);
    if (victimEntity is HealthFunctionality) {
      final health = victimEntity as HealthFunctionality;

      health.maxHealth.setParameterPercentValue(attributeId, -0.9999999);
    }
  }

  @override
  void unMapUpgrade() {}

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Glass Wand";

  @override
  String description() {
    return "Doubling damage, adding 10 lives but reducing max health to 1.";
  }
}

class SlugTrailAttribute extends Attribute {
  SlugTrailAttribute({required super.level, required super.victimEntity});

  @override
  AttributeType attributeType = AttributeType.slugTrail;

  @override
  double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.energy};

  @override
  int get maxLevel => 3;

  double baseSize = 2.5;

  @override
  void action() {
    final explosion = AreaEffect(
        sourceEntity: victimEntity!,
        position: victimEntity!.center,
        animationRandomlyFlipped: true,
        radius: baseSize + increasePercentOfBase(baseSize),
        durationType: DurationType.temporary,
        duration: victimEntity!.durationPercentIncrease.parameter * 2,

        ///Map<DamageType, (double, double)>>>>
        damage: {
          damageType ?? allowedDamageTypes.first: (
            increase(true, 2),
            increase(true, 5)
          )
        });
    victimEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  TimerComponent? timer;
  double interval = 2.0;
  double notMovingSpeed = .01;

  @override
  void mapUpgrade() {
    if (victimEntity is MovementFunctionality) {
      timer = TimerComponent(
          period: interval,
          onTick: () {
            final move = victimEntity as MovementFunctionality;
            final speed = move.currentMoveDelta.clone().normalize();

            if (speed >= notMovingSpeed) {
              action();
            }
          },
          repeat: true);
      victimEntity?.add(timer!);
    }
  }

  @override
  void unMapUpgrade() {}

  @override
  String icon = "attributes/topSpeed.png";

  @override
  String title = "Slug trail";

  @override
  String description() {
    return "While moving, leave a damaging area effect";
  }
}
