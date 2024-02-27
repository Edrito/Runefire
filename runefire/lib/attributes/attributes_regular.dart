import 'package:flame/components.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
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

Attribute? regularAttributeBuilder(
  AttributeType type,
  int level,
  AttributeFunctionality? attributeOwnerEntity,
  DamageType? damageType,
) {
  switch (type) {
    case AttributeType.explosionOnKill:
      return ExplosionOnKillAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );
    case AttributeType.explosiveDash:
      return ExplosiveDashAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.groundSlam:
      return GroundSlamAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.periodicPush:
      return PeriodicPushAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );
    case AttributeType.periodicMagicPulse:
      return PeriodicMagicPulseAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );
    case AttributeType.periodicStun:
      return PeriodicStunAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.combinePeriodicPulse:
      return CombinePeriodicPulseAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.increaseXpGrabRadius:
      return IncreaseExperienceGrabAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.sentryMarkEnemy:
      return MarkSentryAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );
    case AttributeType.sentryRangedAttack:
      return RangedAttackSentryAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );
    case AttributeType.sentryGrabItems:
      return GrabItemsSentryAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );
    case AttributeType.sentryElementalFly:
      return ElementalSentryAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
        damageType: damageType,
      );

    case AttributeType.sentryCaptureBullet:
      return CaptureBulletSentryAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    //TODO Sentry Combinations

    case AttributeType.mirrorOrb:
      return MirrorOrbAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.shieldSurround:
      return ShieldSentryAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.swordSurround:
      return SwordSentryAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.reverseKnockback:
      return ReverseKnockbackAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.projectileSplitExplode:
      return ProjectileSplitExplodeAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.dodgeStandStillIncrease:
      return DodgeIncreaseStandStillAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.damageStandStillIncrease:
      return DamageIncreaseStandStillAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.defenceStandStillIncrease:
      return DefenceIncreaseStandStillAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    //TODO Combination Standstill

    // case AttributeType.invincibleDashing:
    //   return InvincibleDashAttribute(level: level, attributeOwnerEntity: attributeOwnerEntity);
    case AttributeType.dashSpeedDistance:
      return DashSpeedDistanceAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.teleportDash:
      return TeleportDashAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.thorns:
      return ThornsAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.reloadSpray:
      return ReloadSprayAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.reloadInvincibility:
      return ReloadInvincibilityAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.reloadPush:
      return ReloadPushAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.focus:
      return FocusAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.sonicWave:
      return SonicWaveAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.daggerSwing:
      return DaggerSwingAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.chainingAttacks:
      return ChainingAttacksAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.homingProjectiles:
      return ChainingAttacksAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    ///DIFFERENT

    case AttributeType.battleScars:
      return BattleScarsAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.forbiddenMagic:
      return ForbiddenMagicAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.glassWand:
      return GlassWandAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.heavyHitter:
      return HeavyHitterAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.quickShot:
      return QuickShotAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.rapidFire:
      return RapidFireAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.bigPockets:
      return BigPocketsAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.secondsPlease:
      return SecondsPleaseAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.primalMagic:
      return PrimalMagicAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.appleADay:
      return AppleADayAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.critChanceDecreaseDamage:
      return CritChanceDecreaseDamageAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.putYourBackIntoIt:
      return PutYourBackIntoItAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.agile:
      return AgileAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.areaSizeDecreaseDamage:
      return AreaSizeDecreaseDamageAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.decreaseMaxAmmoIncreaseReloadSpeed:
      return DecreaseMaxAmmoIncreaseReloadSpeedAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.potionSeller:
      return PotionSellerAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.reduceHealthIncreaseLifeSteal:
      return ReduceHealthIncreaseLifeStealAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );
    case AttributeType.staminaSteal:
      return StaminaStealAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.splitDamage:
      return SplitDamageAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.rollTheDice:
      return RollTheDiceAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    case AttributeType.slugTrail:
      return SlugTrailAttribute(
        level: level,
        attributeOwnerEntity: attributeOwnerEntity,
      );

    default:
      return null;
  }
}

class ExplosionOnKillAttribute extends Attribute {
  ExplosionOnKillAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 1;

  @override
  AttributeType attributeType = AttributeType.explosionOnKill;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Exploding enemies!';

  late double chance;

  Future<void> onKill(DamageInstance damage) async {
    if (attributeOwnerEntity == null) {
      return;
    }
    if (rng.nextDouble() > chance) {
      return;
    }
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: damage.victim.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      // duration: attributeOwnerEntity!.durationPercentIncrease.parameter,
      damage: {
        damageType ?? allowedDamageTypes.first: (
          increase(true, 5).toDouble(),
          increase(true, 10).toDouble()
        ),
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.frost, DamageType.energy};

  @override
  String description() {
    return 'Something in that ammunition...';
  }

  @override
  void mapUpgrade() {
    chance = increasePercentOfBase(.1, includeBase: true).toDouble();
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attributeFunctions =
          attributeOwnerEntity! as AttributeCallbackFunctionality;
      attributeFunctions.onKillOtherEntity.add(onKill);
    }
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attributeFunctions =
          attributeOwnerEntity! as AttributeCallbackFunctionality;
      attributeFunctions.onKillOtherEntity.remove(onKill);
    }
  }

  @override
  double get upgradeFactor => .25;
}

class ExplosiveDashAttribute extends Attribute {
  ExplosiveDashAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 1;

  @override
  AttributeType attributeType = AttributeType.explosiveDash;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Explosive Dash!';

  Future<void> onDash() async {
    if (attributeOwnerEntity == null) {
      return;
    }
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      collisionDelay: .35,
      radius: baseSize + increasePercentOfBase(baseSize),
      duration: 1,
      damage: {
        damageType ?? allowedDamageTypes.first: (
          increase(true, 5).toDouble(),
          increase(true, 10).toDouble()
        ),
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.frost, DamageType.psychic};

  @override
  String description() {
    return 'Something in those beans...';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.dashBeginFunctions.add(onDash);
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.dashBeginFunctions.remove(onDash);
  }

  @override
  double get upgradeFactor => .25;
}

class GroundSlamAttribute extends Attribute {
  GroundSlamAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;

  @override
  AttributeType attributeType = AttributeType.groundSlam;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Ground Slam!';

  Future<void> onJump() async {
    if (attributeOwnerEntity == null) {
      return;
    }
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      duration: 1,
      damage: {
        damageType ?? allowedDamageTypes.first: (
          increase(true, 5).toDouble(),
          increase(true, 10).toDouble()
        ),
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.physical, DamageType.magic};

  @override
  String description() {
    return 'Apprentice, bring me another Eclair!';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final dashFunc = attributeOwnerEntity! as AttributeCallbackFunctionality;
    dashFunc.jumpEndFunctions.add(onJump);
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final dashFunc = attributeOwnerEntity! as AttributeCallbackFunctionality;
    dashFunc.jumpEndFunctions.remove(onJump);
  }

  @override
  double get upgradeFactor => .25;
}

class PeriodicPushAttribute extends Attribute {
  PeriodicPushAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseOomph = 8;
  double baseSize = 5;

  @override
  AttributeType attributeType = AttributeType.periodicPush;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Periodic Push';

  @override
  Future<void> action() async {
    if (attributeOwnerEntity == null) {
      return;
    }
    final radius = baseSize + increasePercentOfBase(baseSize);
    final playerPos = attributeOwnerEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: radius,
      tickRate: .05,
      duration: 2.5,
      onTick: (entity, areaId) {
        final increaseRes = increase(true, baseOomph);
        final distanceScaled =
            entity.center.distanceTo(playerPos).clamp(0, radius) / radius;
        entity.body.applyForce(
          (entity.center - playerPos).normalized() *
              (baseOomph + increaseRes) *
              (1 - distanceScaled),
        );
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'Periodically push enemies away from you!';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.addPulseFunction(action);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.removePulseFunction(action);
    }
  }

  @override
  double get upgradeFactor => .25;
}

class PeriodicMagicPulseAttribute extends Attribute {
  PeriodicMagicPulseAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;

  @override
  AttributeType attributeType = AttributeType.periodicMagicPulse;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Magic Pulse';

  @override
  Future<void> action() async {
    if (attributeOwnerEntity == null) {
      return;
    }
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      duration: 2.5,
      damage: {
        DamageType.magic: (
          increase(true, 5).toDouble(),
          increase(true, 10).toDouble()
        ),
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'The power of the arcane flows through you, maybe a little too much though...';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.addPulseFunction(action);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.removePulseFunction(action);
  }

  @override
  double get upgradeFactor => .25;
}

// aaa
class PeriodicStunAttribute extends Attribute {
  PeriodicStunAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;

  @override
  AttributeType attributeType = AttributeType.periodicStun;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Stun Pulse';

  @override
  Future<void> action() async {
    if (attributeOwnerEntity == null) {
      return;
    }
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      duration: 2.5,
      onTick: (entity, areaId) {
        if (entity is AttributeFunctionality) {
          entity.addAttribute(
            AttributeType.stun,
            duration: 1,
            perpetratorEntity: attributeOwnerEntity,
            isTemporary: true,
          );
        }
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'Stun your enemies!';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.addPulseFunction(action);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.removePulseFunction(action);
  }

  @override
  double get upgradeFactor => .25;
}

// aaa
class CombinePeriodicPulseAttribute extends Attribute {
  CombinePeriodicPulseAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];

  @override
  AttributeType attributeType = AttributeType.combinePeriodicPulse;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Combined pulse';

  @override
  Future<void> action() async {
    if (attributeOwnerEntity == null) {
      return;
    }
    final playerPos = attributeOwnerEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      tickRate: .05,
      duration: 2.5,
      damage: {
        DamageType.magic: (
          increase(true, 5).toDouble(),
          increase(true, 10).toDouble()
        ),
      },
      onTick: (entity, areaId) {
        if (entity is AttributeFunctionality) {
          entity.addAttribute(
            AttributeType.stun,
            duration: 1,
            perpetratorEntity: attributeOwnerEntity,
            isTemporary: true,
          );
        }
        final increaseRes = increase(true, 3);
        entity.body.applyForce(
          (entity.center - playerPos).normalized() *
              (3 + increaseRes).toDouble(),
        );
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'Concentrate your magic into a singular powerful pulse!';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;

    final periodicMagicPulse =
        attributeOwnerEntity?.getAttribute(AttributeType.periodicMagicPulse);
    final periodicPush =
        attributeOwnerEntity?.getAttribute(AttributeType.periodicPush);
    final periodicStun =
        attributeOwnerEntity?.getAttribute(AttributeType.periodicStun);

    attr.addPulseFunction(action);

    pulseAttributes.addAll([
      if (periodicMagicPulse != null) periodicMagicPulse..unMapUpgrade(),
      if (periodicPush != null) periodicPush..unMapUpgrade(),
      if (periodicStun != null) periodicStun..unMapUpgrade(),
    ]);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in pulseAttributes) {
      element.mapUpgrade();
    }
    attr.removePulseFunction(action);
  }

  @override
  double get upgradeFactor => .25;
}

// aaa
class IncreaseExperienceGrabAttribute extends Attribute {
  IncreaseExperienceGrabAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];

  @override
  AttributeType attributeType = AttributeType.increaseXpGrabRadius;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Increase experience grab radius';

  @override
  Future<void> action() async {}

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'Double experience grab radius';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! Player) {
      return;
    }
    final player = attributeOwnerEntity! as Player;
    player.xpSensorRadius.setParameterFlatValue(attributeId, 5);
    player.xpGrabRadiusFixture.shape.radius = player.xpSensorRadius.parameter;
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! Player) {
      return;
    }
    final player = attributeOwnerEntity! as Player;
    player.xpSensorRadius.removeKey(attributeId);
    player.xpGrabRadiusFixture.shape.radius = player.xpSensorRadius.parameter;
  }

  @override
  double get upgradeFactor => .25;
}

class MarkSentryAttribute extends Attribute {
  MarkSentryAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.sentryMarkEnemy;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'Mark enemies for crit';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (var i = 0; i < upgradeLevel; i++) {
      final temp = MarkEnemySentry(
        initialPosition: Vector2.zero(),
        upgradeLevel: upgradeLevel,
        parentEntity: attr,
      );
      sentries.add(temp);
      attr.addHeadEntity(temp);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeHeadEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class RangedAttackSentryAttribute extends Attribute {
  RangedAttackSentryAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.sentryRangedAttack;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.frost, DamageType.energy, DamageType.magic};

  @override
  String description() {
    return 'Periodically attack enemies';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      for (var i = 0; i < upgradeLevel; i++) {
        final temp = RangedAttackSentry(
          initialPosition: Vector2.zero(),
          damageType: damageType ?? allowedDamageTypes.first,
          upgradeLevel: upgradeLevel,
          parentEntity: attr,
        );
        sentries.add(temp);
        attr.addHeadEntity(temp);
      }
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeHeadEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class GrabItemsSentryAttribute extends Attribute {
  GrabItemsSentryAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.sentryGrabItems;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  Set<DamageType> get allowedDamageTypes => {};

  @override
  String description() {
    return 'Grab dropped items scattered across the world';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (var i = 0; i < upgradeLevel; i++) {
      final temp = GrabItemsSentry(
        initialPosition: Vector2.zero(),
        upgradeLevel: upgradeLevel,
        parentEntity: attr,
      );
      sentries.add(temp);
      attr.addHeadEntity(temp);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeHeadEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class ElementalSentryAttribute extends Attribute {
  ElementalSentryAttribute({
    required super.level,
    required super.attributeOwnerEntity,
    super.damageType,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.sentryElementalFly;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.psychic};

  @override
  String description() {
    return 'Attacks enemies';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (var i = 0; i < upgradeLevel; i++) {
      final temp = ElementalAttackSentry(
        initialPosition: Vector2.zero(),
        damageType: damageType ?? allowedDamageTypes.first,
        upgradeLevel: upgradeLevel,
        parentEntity: attr,
      );
      sentries.add(temp);
      attr.addHeadEntity(temp);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeHeadEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class CaptureBulletSentryAttribute extends Attribute {
  CaptureBulletSentryAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.sentryCaptureBullet;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  String description() {
    return 'Redirect';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (var i = 0; i < upgradeLevel; i++) {
      final temp = ElementalCaptureBulletSentry(
        initialPosition: Vector2.zero(),
        upgradeLevel: upgradeLevel,
        parentEntity: attr,
      );
      sentries.add(temp);
      attr.addHeadEntity(temp);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeHeadEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class MirrorOrbAttribute extends Attribute {
  MirrorOrbAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.mirrorOrb;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  String description() {
    return 'Redirect';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = MirrorOrbSentry(
        initialPosition: Vector2.zero(),
        upgradeLevel: upgradeLevel,
        parentEntity: attr,
      );
      sentries.add(temp);
      attr.addBodyEntity(temp);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeBodyEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class ShieldSentryAttribute extends Attribute {
  ShieldSentryAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.shieldSurround;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  String description() {
    return 'Shield';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    // attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = ShieldSentry(
        initialPosition: Vector2.zero(),
        upgradeLevel: upgradeLevel,
        parentEntity: attr,
      );
      sentries.add(temp);
      attr.addBodyEntity(temp);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeBodyEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class SwordSentryAttribute extends Attribute {
  SwordSentryAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double baseSize = 4;
  List<Attribute> pulseAttributes = [];
  List<ChildEntity> sentries = [];

  @override
  AttributeType attributeType = AttributeType.swordSurround;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  String description() {
    return 'Shield';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    // attr.removeAllHeadEntities();

    for (var i = 0; i < upgradeLevel; i++) {
      final temp = SwordSentry(
        initialPosition: Vector2.zero(),
        upgradeLevel: upgradeLevel,
        parentEntity: attr,
      );
      sentries.add(temp);
      attr.addBodyEntity(temp);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    for (final element in sentries) {
      attr.removeBodyEntity(element.entityId);
    }
    sentries.clear();
  }

  @override
  double get upgradeFactor => .25;
}

class ReverseKnockbackAttribute extends Attribute {
  ReverseKnockbackAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.reverseKnockback;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  String description() {
    return 'Reverse Knockback';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.knockBackIncreaseParameter
        .setParameterPercentValue(attributeId, -2);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.knockBackIncreaseParameter.removeKey(attributeId);
  }

  @override
  double get upgradeFactor => .25;
}

class ProjectileSplitExplodeAttribute extends Attribute {
  ProjectileSplitExplodeAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double cooldown = 3;
  int count = 6;

  TimerComponent? cooldownTimer;

  @override
  AttributeType attributeType = AttributeType.projectileSplitExplode;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  void projectileExplode(Projectile projectile) {
    if (cooldownTimer != null || projectile.hitIds.isEmpty) {
      return;
    }
    cooldownTimer = TimerComponent(
      period: cooldown,
      removeOnFinish: true,
      onTick: () => cooldownTimer = null,
    )..addToParent(attributeOwnerEntity!);

    var position = projectile.center.clone();
    if (projectile.projectileType == ProjectileType.laser) {
      final list = (projectile as LaserProjectile).linePairs.toList();

      position = list[rng.nextInt(list.length.clamp(0, 3))].$1;
    }
    final temp =
        splitVector2DeltaIntoArea(projectile.delta, count, 360 - (360 / count));
    final newProjectiles = <Projectile>[];
    for (final element in temp) {
      final newProjectile = projectile.projectileType.generateProjectile(
        ProjectileConfiguration(
          delta: element,
          originPosition: position,
          weaponAncestor: projectile.weaponAncestor,
          size: projectile.size,
          power: .5,
          primaryDamageType: damageType,
        ),
      );

      newProjectile.hitIds.addAll(projectile.hitIds);
      newProjectiles.add(newProjectile);
    }
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent(newProjectiles);
  }

  @override
  Future<void> action() async {}

  @override
  String description() {
    return 'Projectile explode';
  }

  @override
  void mapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! AttributeWeaponFunctionsFunctionality ||
            weapon is! ProjectileFunctionality) {
          return;
        }
        weapon.onProjectileDeath.add(projectileExplode);
      },
      true,
      true,
    );
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! AttributeWeaponFunctionsFunctionality) {
          return;
        }
        weapon.onProjectileDeath.remove(projectileExplode);
      },
      true,
      true,
    );
  }

  @override
  double get upgradeFactor => .25;
}

abstract class StandStillAttribute extends Attribute {
  StandStillAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  late TimerComponent checkTimer;
  double checkTimerDuration = .3;
  double delay = 3;
  bool isMapped = false;
  double notMovingSpeed = .01;

  TimerComponent? delayTimer;

  void applyStandStillEffect(bool apply);

  void dashFunction() {
    mapDodgeIncrease(false);
  }

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
  Future<void> action() async {}

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! MovementFunctionality) {
      return;
    }
    checkTimer = TimerComponent(
      period: checkTimerDuration,
      repeat: true,
      onTick: () {
        final currentSpeed = (attributeOwnerEntity! as MovementFunctionality)
            .currentMoveDelta
            .normalize();
        if (!isMapped && currentSpeed < notMovingSpeed && delayTimer == null) {
          delayTimer = TimerComponent(
            period: delay,
            onTick: () {
              mapDodgeIncrease(true);
            },
            removeOnFinish: true,
          )..addToParent(attributeOwnerEntity!);
        } else if (isMapped && currentSpeed >= notMovingSpeed) {
          mapDodgeIncrease(false);
        }
      },
    )..addToParent(attributeOwnerEntity!);

    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.dashBeginFunctions.add(dashFunction);
    }
  }

  @override
  void unMapUpgrade() {
    checkTimer.timer.stop();
    checkTimer.removeFromParent();
    mapDodgeIncrease(false);

    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.dashBeginFunctions.remove(dashFunction);
    }
  }
}

class DodgeIncreaseStandStillAttribute extends StandStillAttribute {
  DodgeIncreaseStandStillAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.dodgeStandStillIncrease;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  void applyStandStillEffect(bool apply) {
    if (apply) {
      if (attributeOwnerEntity is DodgeFunctionality) {
        final dodgeFunc = attributeOwnerEntity! as DodgeFunctionality;
        dodgeFunc.dodgeChance.setParameterFlatValue(attributeId, .5);
      }
    } else {
      if (attributeOwnerEntity is DodgeFunctionality) {
        final dodgeFunc = attributeOwnerEntity! as DodgeFunctionality;
        dodgeFunc.dodgeChance.removeKey(attributeId);
      }
    }
  }

  @override
  String description() {
    return 'Dodge increase stand still';
  }

  @override
  int get maxLevel => 1;

  @override
  double get upgradeFactor => .25;
}

class DefenceIncreaseStandStillAttribute extends StandStillAttribute {
  DefenceIncreaseStandStillAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.defenceStandStillIncrease;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  void applyStandStillEffect(bool apply) {
    if (apply) {
      final returnMap = <DamageType, double>{};
      for (final element in DamageType.values) {
        returnMap[element] = -.5;
      }
      attributeOwnerEntity?.damageTypeResistance
          .setDamagePercentIncrease(attributeId, returnMap);
    } else {
      attributeOwnerEntity?.damageTypeResistance.removePercentKey(attributeId);
    }
  }

  @override
  String description() {
    return 'Defence increase stand still';
  }

  @override
  int get maxLevel => 1;

  @override
  double get upgradeFactor => .25;
}

class DamageIncreaseStandStillAttribute extends StandStillAttribute {
  DamageIncreaseStandStillAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.damageStandStillIncrease;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  void applyStandStillEffect(bool apply) {
    if (apply) {
      attributeOwnerEntity?.damagePercentIncrease
          .setParameterPercentValue(attributeId, .2);
    } else {
      attributeOwnerEntity?.damagePercentIncrease.removeKey(attributeId);
    }
  }

  @override
  String description() {
    return 'Damage increase stand still';
  }

  @override
  int get maxLevel => 1;

  @override
  double get upgradeFactor => .25;
}

// class InvincibleDashAttribute extends Attribute {
//   InvincibleDashAttribute({required super.level, required super.attributeOwnerEntity});

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
//     if (attributeOwnerEntity is! DashFunctionality) return;
//     final dashFunc = attributeOwnerEntity as DashFunctionality;
//     dashFunc.invincibleWhileDashing.setIncrease(attributeId, true);
//   }

//   @override
//   void unMapUpgrade() {
//     if (attributeOwnerEntity is! DashFunctionality) return;
//     final dashFunc = attributeOwnerEntity as DashFunctionality;
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
  DashSpeedDistanceAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.dashSpeedDistance;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {}

  @override
  String description() {
    return 'Dash distance speed';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! DashFunctionality) {
      return;
    }
    final dashFunc = attributeOwnerEntity! as DashFunctionality;
    dashFunc.dashDistance.setParameterPercentValue(attributeId, .5);
    dashFunc.dashDuration.setParameterPercentValue(attributeId, -.5);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! DashFunctionality) {
      return;
    }
    final dashFunc = attributeOwnerEntity! as DashFunctionality;
    dashFunc.dashDistance.removeKey(attributeId);
    dashFunc.dashDuration.removeKey(attributeId);
  }

  @override
  double get upgradeFactor => .25;
}

class DashAttackEmpowerAttribute extends Attribute {
  DashAttackEmpowerAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.dashAttackEmpower;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  Future<void> action() async {
    attributeOwnerEntity?.addAttribute(
      AttributeType.empowered,
      isTemporary: true,
      perpetratorEntity: attributeOwnerEntity,
    );
  }

  @override
  String description() {
    return 'Empower dash attack';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.dashEndFunctions.add(action);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.dashEndFunctions.remove(action);
  }

  @override
  double get upgradeFactor => .25;
}

class TeleportDashAttribute extends Attribute {
  TeleportDashAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.teleportDash;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  String description() {
    return 'Teleport';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! DashFunctionality) {
      return;
    }
    final dash = attributeOwnerEntity! as DashFunctionality;
    dash.teleportDash.setIncrease(attributeId, true);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! DashFunctionality) {
      return;
    }
    final dash = attributeOwnerEntity! as DashFunctionality;
    dash.teleportDash.removeKey(attributeId);
  }

  @override
  double get upgradeFactor => .25;
}

class ThornsAttribute extends Attribute {
  ThornsAttribute({required super.level, required super.attributeOwnerEntity});

  List<Weapon> movedWeapons = [];

  @override
  AttributeType attributeType = AttributeType.thorns;

  @override
  DamageType? damageType = DamageType.physical;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  void onTouchBleed(HealthFunctionality other) {
    if (other is AttributeFunctionality) {
      final attr = other as AttributeFunctionality;
      attr.addAttribute(
        AttributeType.bleed,
        isTemporary: true,
        perpetratorEntity: attributeOwnerEntity,
      );
    }
  }

  @override
  String description() {
    return 'Touch Damage';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is TouchDamageFunctionality) {
      final touch = attributeOwnerEntity! as TouchDamageFunctionality;

      touch.touchDamage.setDamageFlatIncrease(
        attributeId,
        DamageType.physical,
        1.0 * upgradeLevel,
        5.0 * upgradeLevel,
      );
    }

    if (upgradeLevel == 2 &&
        attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onTouch.add(onTouchBleed);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is TouchDamageFunctionality) {
      final touch = attributeOwnerEntity! as TouchDamageFunctionality;
      touch.touchDamage.removeKey(attributeId);
    }

    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onTouch.remove(onTouchBleed);
    }
  }
}

class ReloadSprayAttribute extends Attribute {
  ReloadSprayAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double cooldown = 3;
  Map<String, int> weaponBulletCount = {};

  TimerComponent? cooldownTimer;

  @override
  AttributeType attributeType = AttributeType.reloadSpray;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  void incrementCounter(Weapon weapon) {
    if (weapon is! ReloadFunctionality) {
      return;
    }

    weaponBulletCount[weapon.weaponId] = weapon.spentAttacks;
  }

  void meleeExplode(MeleeFunctionality weapon) {
    final count = weaponBulletCount[weapon.weaponId] ?? 0;
    if (count == 0) {
      return;
    }
    final position = attributeOwnerEntity?.center.clone() ?? Vector2.zero();
    final temp = splitRadInCone(0.0, count, 360 - (360 / count), false);
    var i = 0;
    final newSwings = <MeleeAttackHandler>[];
    for (final element in temp) {
      final newSwing = MeleeAttackHandler(
        initPosition: position,
        initAngle: element,
        attachmentPoint: attributeOwnerEntity,
        currentAttack: weapon.meleeAttacks[i % weapon.getAttackCount(0)],
        weaponAncestor: weapon,
      );

      newSwings.add(newSwing);
      i++;
    }

    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent(newSwings);
  }

  void projectileExplode(ProjectileFunctionality weapon) {
    final count = weaponBulletCount[weapon.weaponId] ?? 0;
    if (count == 0) {
      return;
    }
    final position = attributeOwnerEntity?.center.clone() ?? Vector2.zero();
    final temp =
        splitVector2DeltaIntoArea(Vector2.zero(), count, 360 - (360 / count));
    final newProjectiles = <Projectile>[];
    for (final element in temp) {
      final newProjectile = weapon.projectileType!.generateProjectile(
        ProjectileConfiguration(
          delta: element,
          originPosition: position,
          weaponAncestor: weapon,
          power: .5,
          primaryDamageType: damageType,
        ),
      );

      newProjectiles.add(newProjectile);
    }
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent(newProjectiles);
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
      onTick: () => cooldownTimer = null,
    )..addToParent(attributeOwnerEntity!);
  }

  @override
  String description() {
    return 'Reload Spray';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;

    attr.onAttack.add(incrementCounter);
    attr.onReload.add(shootAttacks);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;

    attr.onAttack.remove(incrementCounter);
    attr.onReload.remove(shootAttacks);
  }
}

class ReloadPushAttribute extends Attribute {
  ReloadPushAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double baseOomph = 7;
  double baseSize = 4;

  @override
  AttributeType attributeType = AttributeType.reloadPush;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  void push(Weapon _) {
    if (attributeOwnerEntity == null) {
      return;
    }
    final radius = baseSize + increasePercentOfBase(baseSize);
    final playerPos = attributeOwnerEntity!.center.clone();
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: radius,
      tickRate: .05,
      duration: 2.5,
      onTick: (entity, areaId) {
        final increaseRes = increase(true, baseOomph);
        final distanceScaled =
            entity.center.distanceTo(playerPos).clamp(0, radius) / radius;
        entity.body.applyForce(
          (entity.center - playerPos).normalized() *
              (baseOomph + increaseRes) *
              (1 - distanceScaled),
        );
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  String description() {
    return 'Reload Push';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onReload.add(push);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onReload.remove(push);
  }
}

class ReloadInvincibilityAttribute extends Attribute {
  ReloadInvincibilityAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  Map<String, double> weaponBulletSpentPercent = {};

  TimerComponent? invincibilityDuration;

  @override
  AttributeType attributeType = AttributeType.reloadPush;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  void incrementCounter(Weapon weapon) {
    if (weapon is! ReloadFunctionality) {
      return;
    }
    weaponBulletSpentPercent[weapon.weaponId] =
        (weapon.spentAttacks / weapon.maxAttacks.parameter).clamp(0, 1);
  }

  void onReload(ReloadFunctionality weapon) {
    attributeOwnerEntity?.invincible.setIncrease(attributeId, true);
    invincibilityDuration?.timer.stop();
    invincibilityDuration?.removeFromParent();
    invincibilityDuration = TimerComponent(
      period: weapon.reloadTime.parameter *
          weaponBulletSpentPercent[weapon.weaponId]!,
      removeOnFinish: true,
      onTick: () {
        attributeOwnerEntity?.invincible.removeKey(attributeId);
      },
    )..addToParent(attributeOwnerEntity!);
  }

  @override
  String description() {
    return 'Reload Invincible';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onReload.add(onReload);
    attr.onAttack.add(incrementCounter);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onReload.remove(onReload);
    attr.onAttack.remove(incrementCounter);
  }
}

class FocusAttribute extends Attribute {
  FocusAttribute({required super.level, required super.attributeOwnerEntity});

  Map<String, int> additionalCount = {};
  Map<String, TimerComponent> delayCheckers = {};
  int max = 2;
  Map<String, int> successiveCounts = {};

  @override
  AttributeType attributeType = AttributeType.focus;

  // @override
  // double get factor => .25;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

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
        attributeId,
        additionalCount[weapon.weaponId]!,
      );
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
  String description() {
    return 'Focus';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onAttack.add(incrementCount);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }
    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
    attr.onAttack.remove(incrementCount);
  }
}

class ChainingAttacksAttribute extends Attribute {
  ChainingAttacksAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.chainingAttacks;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  String description() {
    return 'Increase chain count';
  }

  @override
  void mapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        weapon.chainingTargets.setParameterFlatValue(attributeId, upgradeLevel);
      },
      false,
      false,
    );
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        weapon.chainingTargets.removeKey(attributeId);
      },
      false,
      false,
    );
  }
}

class SonicWaveAttribute extends Attribute {
  SonicWaveAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  List<Weapon> newWeapons = [];

  @override
  AttributeType attributeType = AttributeType.sonicWave;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  String description() {
    return 'add a sonic wave to your melee attacks';
  }

  @override
  void mapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! MeleeFunctionality) {
          return;
        }
        final newWeapon = WeaponType.blankProjectileWeapon.build(
          ancestor: weapon.entityAncestor,
          customWeaponLevel: 0,
        );
        weapon.addAdditionalWeapon(newWeapon);
        newWeapons.add(newWeapon);
      },
      false,
      false,
    );
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! MeleeFunctionality) {
          return;
        }
        for (final additionalWeapon in newWeapons) {
          weapon.removeAdditionalWeapon(additionalWeapon.weaponId);
        }
      },
      false,
      false,
    );

    newWeapons.clear();
  }
}

class DaggerSwingAttribute extends Attribute {
  DaggerSwingAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  List<Weapon> newWeapons = [];

  @override
  AttributeType attributeType = AttributeType.daggerSwing;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  String description() {
    return 'Dagger attack to ranged weapons';
  }

  @override
  void mapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon.weaponType.attackType == AttackType.melee) {
          return;
        }
        final newWeapon = WeaponType.sanctifiedEdge.build(
          ancestor: weapon.entityAncestor,
          customWeaponLevel: 0,
        );

        if (newWeapon is StaminaCostFunctionality) {
          newWeapon.weaponStaminaCost.setParameterPercentValue(attributeId, -1);
        }

        weapon.addAdditionalWeapon(newWeapon);

        newWeapons.add(newWeapon);
      },
      false,
      false,
    );
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! ProjectileFunctionality) {
          return;
        }
        for (final additionalWeapon in newWeapons) {
          weapon.removeAdditionalWeapon(additionalWeapon.weaponId);
        }
      },
      false,
      false,
    );

    newWeapons.clear();
  }
}

class HomingProjectileAttribute extends Attribute {
  HomingProjectileAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.homingProjectiles;

  // @override
  // double get factor => 1;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Keep a watchful eye';

  @override
  String description() {
    return 'Homing projectiles';
  }

  @override
  void mapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! ProjectileFunctionality) {
          return;
        }
        weapon.maxHomingTargets
            .setParameterFlatValue(attributeId, upgradeLevel);
      },
      false,
      true,
    );
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! ProjectileFunctionality) {
          return;
        }
        weapon.maxHomingTargets.removeKey(attributeId);
      },
      false,
      true,
    );
  }
}

class HeavyHitterAttribute extends Attribute {
  HeavyHitterAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.heavyHitter;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Heavy Hitter';

  @override
  String description() {
    return 'Reduce attack speed while increasing damage';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, .25);

    applyActionToWeapons(
      (weapon) {
        weapon.attackTickRate.setParameterPercentValue(attributeId, .35);
      },
      false,
      true,
    );
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease.removeKey(attributeId);
    applyActionToWeapons(
      (weapon) {
        weapon.attackTickRate.removeKey(attributeId);
      },
      false,
      true,
    );
  }
}

class QuickShotAttribute extends Attribute {
  QuickShotAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.quickShot;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Quick Shot';

  @override
  String description() {
    return 'Increase attack speed while decreasing damage';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.35);
    applyActionToWeapons(
      (weapon) {
        weapon.attackTickRate.setParameterPercentValue(attributeId, -.25);
      },
      false,
      true,
    );
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease.removeKey(attributeId);

    applyActionToWeapons(
      (weapon) {
        weapon.attackTickRate.removeKey(attributeId);
      },
      false,
      true,
    );
  }
}

class RapidFireAttribute extends Attribute {
  RapidFireAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.rapidFire;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Quick Shot';

  @override
  String description() {
    return 'Increase attack speed while decreasing damage';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.15 * upgradeLevel);

    applyActionToWeapons(
      (weapon) {
        weapon.attackTickRate
            .setParameterPercentValue(attributeId, -.15 * upgradeLevel);
        if (weapon is ReloadFunctionality) {
          weapon.maxAttacks
              .setParameterPercentValue(attributeId, .25 * upgradeLevel);
        }
      },
      false,
      true,
    );
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease.removeKey(attributeId);

    applyActionToWeapons(
      (weapon) {
        weapon.attackTickRate.removeKey(attributeId);
        if (weapon is ReloadFunctionality) {
          weapon.maxAttacks.removeKey(attributeId);
        }
      },
      false,
      true,
    );
  }
}

class BigPocketsAttribute extends Attribute {
  BigPocketsAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.bigPockets;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Bag of Holding';

  @override
  String description() {
    return 'Increase max ammo, reduce movement speed';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttackFunctionality) {
      return;
    }
    final attack = attributeOwnerEntity! as AttackFunctionality;

    applyActionToWeapons(
      (weapon) {
        if (weapon is ReloadFunctionality) {
          weapon.maxAttacks.setParameterPercentValue(attributeId, .5);
        }
      },
      false,
      true,
    );

    if (attributeOwnerEntity is! MovementFunctionality) {
      return;
    }
    final move = attributeOwnerEntity! as MovementFunctionality;
    move.speed.setParameterPercentValue(attributeId, -.25);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttackFunctionality) {
      return;
    }

    applyActionToWeapons(
      (weapon) {
        if (weapon is ReloadFunctionality) {
          weapon.maxAttacks.removeKey(attributeId);
        }
      },
      false,
      true,
    );

    if (attributeOwnerEntity is! MovementFunctionality) {
      return;
    }
    final move = attributeOwnerEntity! as MovementFunctionality;
    move.speed.removeKey(attributeId);
  }
}

class SecondsPleaseAttribute extends Attribute {
  SecondsPleaseAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.secondsPlease;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Seconds Please';

  @override
  String description() {
    return 'Increase health, reduce movement speed, increase max health';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is MovementFunctionality) {
      final move = attributeOwnerEntity! as MovementFunctionality;
      move.speed.setParameterPercentValue(attributeId, -.2);
    }

    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.maxHealth.setParameterPercentValue(attributeId, .5);
    }

    attributeOwnerEntity?.height.setParameterFlatValue(attributeId, 1);
    attributeOwnerEntity?.applyHeightToSprite();
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! MovementFunctionality) {
      return;
    }
    final move = attributeOwnerEntity! as MovementFunctionality;
    move.speed.removeKey(attributeId);

    if (attributeOwnerEntity is! HealthFunctionality) {
      return;
    }
    final health = attributeOwnerEntity! as HealthFunctionality;
    health.maxHealth.removeKey(attributeId);
    attributeOwnerEntity?.height.removeKey(attributeId);
    attributeOwnerEntity?.applyHeightToSprite();
  }
}

class PrimalMagicAttribute extends Attribute {
  PrimalMagicAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.primalMagic;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Primal Magic';

  @override
  String description() {
    return 'Increase Stamina Regen';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! StaminaFunctionality) {
      return;
    }
    final stamina = attributeOwnerEntity! as StaminaFunctionality;
    stamina.staminaRegen
        .setParameterPercentValue(attributeId, .25 * upgradeLevel);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! StaminaFunctionality) {
      return;
    }
    final stamina = attributeOwnerEntity! as StaminaFunctionality;
    stamina.staminaRegen.removeKey(attributeId);
  }
}

class AppleADayAttribute extends Attribute {
  AppleADayAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.appleADay;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Primal Magic';

  @override
  String description() {
    return 'Increase Stamina Regen';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! HealthRegenFunctionality) {
      return;
    }
    final health = attributeOwnerEntity! as HealthRegenFunctionality;
    health.healthRegen
        .setParameterPercentValue(attributeId, .25 * upgradeLevel);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! HealthRegenFunctionality) {
      return;
    }
    final health = attributeOwnerEntity! as HealthRegenFunctionality;
    health.healthRegen.removeKey(attributeId);
  }
}

class CritChanceDecreaseDamageAttribute extends Attribute {
  CritChanceDecreaseDamageAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.critChanceDecreaseDamage;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Critical Switch';

  @override
  String description() {
    return 'Increase Crit Chance while also Decrease Crit Damage';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.critChance.setParameterFlatValue(attributeId, .4);
    attributeOwnerEntity?.critDamage
        .setParameterPercentValue(attributeId, -.25);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.critChance.removeKey(attributeId);
    attributeOwnerEntity?.critDamage.removeKey(attributeId);
  }
}

class PutYourBackIntoItAttribute extends Attribute {
  PutYourBackIntoItAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.putYourBackIntoIt;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Put your back into it';

  bool increaseDamage(DamageInstance instance) {
    final health = attributeOwnerEntity! as HealthFunctionality;
    final increase =
        ((health.maxHealth.parameter / 100) / 2).clamp(1.0, double.infinity);
    instance.increaseByPercent(increase);
    return true;
  }

  @override
  String description() {
    return 'Melee attacks deal more damage the more health you have';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality ||
        attributeOwnerEntity is! HealthFunctionality) {
      return;
    }

    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;

    attr.onHitOtherEntity.add(increaseDamage);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! AttributeCallbackFunctionality) {
      return;
    }

    final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;

    attr.onHitOtherEntity.remove(increaseDamage);
  }
}

class AgileAttribute extends Attribute {
  AgileAttribute({required super.level, required super.attributeOwnerEntity});

  @override
  AttributeType attributeType = AttributeType.agile;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Agile';

  @override
  String description() {
    return 'Reduce max health by X and increase speed';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is! HealthFunctionality) {
      return;
    }

    final health = attributeOwnerEntity! as HealthFunctionality;

    health.maxHealth.setParameterPercentValue(attributeId, -.2);

    if (attributeOwnerEntity is! MovementFunctionality) {
      return;
    }

    final move = attributeOwnerEntity! as MovementFunctionality;

    move.speed.setParameterPercentValue(attributeId, .3);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is! HealthFunctionality) {
      return;
    }

    final health = attributeOwnerEntity! as HealthFunctionality;

    health.maxHealth.removeKey(attributeId);

    if (attributeOwnerEntity is! MovementFunctionality) {
      return;
    }

    final move = attributeOwnerEntity! as MovementFunctionality;

    move.speed.removeKey(attributeId);
  }
}

class AreaSizeDecreaseDamageAttribute extends Attribute {
  AreaSizeDecreaseDamageAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.areaSizeDecreaseDamage;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Area Size Decrease Damage';

  @override
  String description() {
    return 'Reduce area damage and increase area size';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.areaSizePercentIncrease
        .setParameterPercentValue(attributeId, .5);
    attributeOwnerEntity?.areaDamagePercentIncrease
        .setParameterPercentValue(attributeId, -.25);
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.areaSizePercentIncrease.removeKey(attributeId);
    attributeOwnerEntity?.areaDamagePercentIncrease.removeKey(attributeId);
  }
}

class DecreaseMaxAmmoIncreaseReloadSpeedAttribute extends Attribute {
  DecreaseMaxAmmoIncreaseReloadSpeedAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType =
      AttributeType.decreaseMaxAmmoIncreaseReloadSpeed;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Decrease Max Ammo Increase Reload Speed';

  @override
  String description() {
    return 'Reduce max ammo while increase attack rate';
  }

  @override
  void mapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! ReloadFunctionality) {
          return;
        }
        weapon.maxAttacks.setParameterPercentValue(attributeId, -.5);
        weapon.reloadTime.setParameterPercentValue(attributeId, .25);
      },
      false,
      true,
    );
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    applyActionToWeapons(
      (weapon) {
        if (weapon is! ReloadFunctionality) {
          return;
        }
        weapon.maxAttacks.removeKey(attributeId);
        weapon.reloadTime.removeKey(attributeId);
      },
      false,
      true,
    );
  }
}

class PotionSellerAttribute extends Attribute {
  PotionSellerAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.potionSeller;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Potion Seller';

  @override
  String description() {
    return 'Increase the effects of status effects and dots, while reducing regular damage.';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.2);
    attributeOwnerEntity?.tickDamageIncrease
        .setParameterPercentValue(attributeId, .5);

    for (final element in StatusEffects.values) {
      attributeOwnerEntity?.statusEffectsPercentIncrease
          .setDamagePercentIncrease(attributeId, element, .5);
    }
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.damagePercentIncrease.removeKey(attributeId);
    attributeOwnerEntity?.tickDamageIncrease.removeKey(attributeId);
    attributeOwnerEntity?.statusEffectsPercentIncrease
        .removePercentKey(attributeId);
  }
}

class BattleScarsAttribute extends Attribute {
  BattleScarsAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.battleScars;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Battle Scars';

  @override
  String description() {
    return 'Reducing dash effectivness, while increasing health by 200%';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.maxHealth.setParameterPercentValue(attributeId, 1.0);
    }
    if (attributeOwnerEntity is DashFunctionality) {
      final dash = attributeOwnerEntity! as DashFunctionality;
      dash.dashDistance.setParameterPercentValue(attributeId, -.5);
      dash.dashCooldown.setParameterPercentValue(attributeId, .5);
    }
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.maxHealth.removeKey(attributeId);
    }
    if (attributeOwnerEntity is DashFunctionality) {
      final dash = attributeOwnerEntity! as DashFunctionality;
      dash.dashDistance.removeKey(attributeId);
      dash.dashCooldown.removeKey(attributeId);
    }
  }
}

class ForbiddenMagicAttribute extends Attribute {
  ForbiddenMagicAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  bool previousValue = false;

  @override
  AttributeType attributeType = AttributeType.forbiddenMagic;

  // @override
  // double get factor => .33;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Forbidden Magic';

  @override
  String description() {
    return 'Remove stamina, stamina actions reduce health, increase health regen by 100% for each stamina consuming weapon possessed';
  }

  @override
  void mapUpgrade() {
    var amountOfStaminaWeapons = 0;
    applyActionToWeapons(
      (weapon) {
        if (weapon is StaminaCostFunctionality) {
          amountOfStaminaWeapons++;
        }
      },
      true,
      true,
    );

    if (attributeOwnerEntity is HealthRegenFunctionality) {
      final health = attributeOwnerEntity! as HealthRegenFunctionality;
      health.healthRegen.setParameterPercentValue(
        attributeId,
        amountOfStaminaWeapons.clamp(0.5, double.infinity).toDouble(),
      );
    }
    if (attributeOwnerEntity is StaminaFunctionality) {
      final stamina = attributeOwnerEntity! as StaminaFunctionality;
      stamina.stamina.setParameterPercentValue(attributeId, -1);
      previousValue = stamina.isForbiddenMagic;
      stamina.isForbiddenMagic = true;
    }
  }

  @override
  int get maxLevel => 1;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is HealthRegenFunctionality) {
      final health = attributeOwnerEntity! as HealthRegenFunctionality;
      health.healthRegen.removeKey(attributeId);
    }
    if (attributeOwnerEntity is StaminaFunctionality) {
      final stamina = attributeOwnerEntity! as StaminaFunctionality;
      stamina.stamina.removeKey(attributeId);
      stamina.isForbiddenMagic = previousValue;
    }
  }
}

class ReduceHealthIncreaseLifeStealAttribute extends Attribute {
  ReduceHealthIncreaseLifeStealAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.reduceHealthIncreaseLifeSteal;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Reduce Health Increase Life Steal';

  @override
  String description() {
    return 'Reduce max health, increase life steal';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.maxHealth
          .setParameterPercentValue(attributeId, -.1 * upgradeLevel);
    }

    attributeOwnerEntity?.essenceSteal
        .setParameterPercentValue(attributeId, increase(false).toDouble());
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;
      health.maxHealth.removeKey(attributeId);
    }

    attributeOwnerEntity?.essenceSteal.removeKey(attributeId);
  }

  @override
  double get upgradeFactor => .035;
}

class StaminaStealAttribute extends Attribute {
  StaminaStealAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.staminaSteal;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Stamina Steal';

  @override
  String description() {
    return 'Converts life steal to stamina steal';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.staminaSteal.setIncrease(attributeId, true);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.staminaSteal.removeKey(attributeId);
  }

  @override
  double get upgradeFactor => .035;
}

class SplitDamageAttribute extends Attribute {
  SplitDamageAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.splitDamage;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Damage Split';

  bool splitDamage(DamageInstance instance) {
    final count = DamageType.values.length;
    var totalDamage = 0.0;

    for (final element in instance.damageMap.values) {
      totalDamage += element;
    }

    final splitDamage = totalDamage / count;

    instance.damageMap.clear();

    for (final element in DamageType.values
        .where((element) => element != DamageType.healing)) {
      instance.damageMap[element] = splitDamage;
    }

    return true;
  }

  @override
  String description() {
    return 'Evenly distributes damage across all damage types';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onHitOtherEntity.add(splitDamage);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    if (attributeOwnerEntity is AttributeCallbackFunctionality) {
      final attr = attributeOwnerEntity! as AttributeCallbackFunctionality;
      attr.onHitOtherEntity.remove(splitDamage);
    }
  }

  @override
  double get upgradeFactor => .035;
}

class RollTheDiceAttribute extends Attribute {
  RollTheDiceAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.rollTheDice;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Increase crit chance and damage, while reducing damage';

  @override
  String description() {
    return 'Increase crit chance and damage by 25%, while reducing base damage by 50%';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.critChance.setParameterFlatValue(attributeId, .25);
    attributeOwnerEntity?.critDamage.setParameterFlatValue(attributeId, .25);
    attributeOwnerEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, -.5);
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {
    attributeOwnerEntity?.critChance.removeKey(attributeId);
    attributeOwnerEntity?.critDamage.removeKey(attributeId);
    attributeOwnerEntity?.damagePercentIncrease.removeKey(attributeId);
  }

  @override
  double get upgradeFactor => .035;
}

class GlassWandAttribute extends Attribute {
  GlassWandAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  @override
  AttributeType attributeType = AttributeType.glassWand;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Glass Wand';

  @override
  String description() {
    return 'Doubling damage, adding 10 lives but reducing max health to 1.';
  }

  @override
  void mapUpgrade() {
    attributeOwnerEntity?.maxLives.setParameterFlatValue(attributeId, 10);
    attributeOwnerEntity?.damagePercentIncrease
        .setParameterPercentValue(attributeId, 1);
    if (attributeOwnerEntity is HealthFunctionality) {
      final health = attributeOwnerEntity! as HealthFunctionality;

      health.maxHealth.setParameterPercentValue(attributeId, -0.9999999);
    }
  }

  @override
  int get maxLevel => 2;

  @override
  void unMapUpgrade() {}

  @override
  double get upgradeFactor => .035;
}

class SlugTrailAttribute extends Attribute {
  SlugTrailAttribute({
    required super.level,
    required super.attributeOwnerEntity,
  });

  double baseSize = 2.5;
  double interval = 2.0;
  double notMovingSpeed = .01;

  TimerComponent? timer;

  @override
  AttributeType attributeType = AttributeType.slugTrail;

  @override
  bool increaseFromBaseParameter = false;

  @override
  String title = 'Slug trail';

  @override
  void action() {
    final explosion = AreaEffect(
      sourceEntity: attributeOwnerEntity!,
      position: attributeOwnerEntity!.center,
      radius: baseSize + increasePercentOfBase(baseSize),
      durationType: DurationType.temporary,
      duration: 2,

      ///Map<DamageType, (double, double)>>>>
      damage: {
        damageType ?? allowedDamageTypes.first: (
          increase(true, 2).toDouble(),
          increase(true, 5).toDouble()
        ),
      },
    );
    attributeOwnerEntity?.gameEnviroment.addPhysicsComponent([explosion]);
  }

  @override
  Set<DamageType> get allowedDamageTypes =>
      {DamageType.fire, DamageType.energy};

  @override
  String description() {
    return 'While moving, leave a damaging area effect';
  }

  @override
  void mapUpgrade() {
    if (attributeOwnerEntity is MovementFunctionality) {
      timer = TimerComponent(
        period: interval,
        onTick: () {
          final move = attributeOwnerEntity! as MovementFunctionality;
          final speed = move.currentMoveDelta.clone().normalize();

          if (speed >= notMovingSpeed) {
            action();
          }
        },
        repeat: true,
      );
      attributeOwnerEntity?.add(timer!);
    }
  }

  @override
  int get maxLevel => 3;

  @override
  void unMapUpgrade() {}

  @override
  double get upgradeFactor => .25;
}
