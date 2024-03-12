import 'dart:async';
import 'dart:math';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/extensions.dart';
import 'package:runefire/weapons/projectile_mixin.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:uuid/uuid.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/main.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/resources/enums.dart';

abstract class FadeOutBullet extends Projectile {
  FadeOutBullet(super.projectileConfiguration);
  Curve fadeOutCurve = Curves.easeOut;
  double fadeOutDuration = .4;
  double timePassed = 0;

  @override
  double get opacity => fadeOutCurve.transform(
        (1 - ((timePassed - ttl + fadeOutDuration) / fadeOutDuration))
            .clamp(0, 1)
            .toDouble(),
      );

  @override
  void update(double dt) {
    timePassed += dt;
    super.update(dt);
  }
}

abstract class Projectile extends BodyComponent<GameRouter>
    with ContactCallbacks, UpdateFunctionsThenRemove {
  Projectile(this.projectileConfiguration) {
    projectileId = const Uuid().v4();
  }
  final ProjectileConfiguration projectileConfiguration;
  late final int targetsToChain = weaponAncestor.chainingTargets.parameter;
  late final int targetsToHome = weaponAncestor.maxHomingTargets.parameter;

  int chainedTargets = 0;
  List<HealthFunctionality> closeSensorBodies = [];
  DamageType get damageType =>
      projectileConfiguration.primaryDamageType ??
      weaponAncestor.baseDamage.damageBase.keys.toList().random();

  //Status
  Vector2 get delta => projectileConfiguration.delta;
  double get power => projectileConfiguration.power;
  Vector2 get originPosition =>
      customOriginPosition ?? projectileConfiguration.originPosition;
  Vector2? customOriginPosition;
  set originPosition(Vector2 newOriginPosition) {
    customOriginPosition = newOriginPosition;
  }

  double get size => projectileConfiguration.size;
  Weapon get weaponAncestor => projectileConfiguration.weaponAncestor;
  ProjectileFunctionality? get parentProjectileFunctionality =>
      weaponAncestor is ProjectileFunctionality
          ? weaponAncestor as ProjectileFunctionality
          : null;
  double get projectileVelocity =>
      parentProjectileFunctionality?.projectileVelocity.parameter ??
      defaultProjectileVelocity;
  double durationPassed = 0;
  bool enableChaining = false;
  bool enableHoming = false;
  List<String> hitIds = [];
  int homedTargets = 0;
  bool get isPlayer => weaponAncestor.entityAncestor?.isPlayer ?? false;

  bool canAffectOwner = false;

  Vector2 previousDelta = Vector2.zero();
  bool projectileHasExpired = false;
  late String projectileId;
  abstract ProjectileType projectileType;
  bool get removeOnEndAttack => false;
  Random rng = Random();
  double get ttl => parentProjectileFunctionality != null
      ? parentProjectileFunctionality!.projectileLifeSpan.parameter
      : defaultTtl;
  //Structure

  // TimerComponent? projectileDeathTimer;

  //Type declared is the target, such as Enemy, Player, or other.
  void setTargetFixture(
    Body body,
    EntityType type, {
    bool runFunction = false,
  }) {}

  bool get chainingComplete => chainedTargets > targetsToChain;
  bool get homingComplete => homedTargets > targetsToHome;
  bool get isSmallProjectile => size < projectileBigSizeThreshold;

  void bodyContact(HealthFunctionality other) {
    hitIds.add(other.entityId);
    final damageInstance = weaponAncestor.calculateDamage(other, this);
    other.hitCheck(projectileId, damageInstance);
  }

  void callBulletKillFunctions() {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      for (final element in weapon.onProjectileDeath) {
        element(this);
      }
    }
  }

  void callOnProjectileAttackFunctions() {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      for (final element in weapon.onAttackProjectile) {
        element(this);
      }
    }
  }

  Future<void> killBullet([bool withEffect = false]) async {
    projectileHasExpired = true;
    if (!world.physicsWorld.isLocked) {
      body.setType(BodyType.static);
    }
    removeFromParent();
    callBulletKillFunctions();
  }

  void sensorContact(HealthFunctionality other) {
    closeSensorBodies.add(other);
    other.targetsHomingEntity++;
  }

  void sensorEndContact(HealthFunctionality other) {
    closeSensorBodies.remove(other);
    other.targetsHomingEntity--;
  }

  void setDelta(Vector2 newDelta) {
    previousDelta = delta.clone();
    delta.setFrom(newDelta);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! HealthFunctionality || hitIds.contains(other.entityId)) {
      return super.beginContact(other, contact);
    }

    if (isPlayer && other is Player && !canAffectOwner) {
      return super.beginContact(other, contact);
    }
    if (!isPlayer &&
        other is Enemy &&
        (!weaponAncestor.entityAncestor!.affectsAllEntities.parameter &&
            !canAffectOwner)) {
      return super.beginContact(other, contact);
    }

    if (other == weaponAncestor.entityAncestor && !canAffectOwner) {
      return super.beginContact(other, contact);
    }

    final isHomingSensor =
        (contact.fixtureB.userData! as Map)['type'] == FixtureType.sensor ||
            (contact.fixtureA.userData! as Map)['type'] == FixtureType.sensor;

    if (isHomingSensor &&
        other.targetsHomingEntity < other.maxTargetsHomingEntity) {
      sensorContact(other);
    } else if (!projectileHasExpired && !isHomingSensor && !other.isDead) {
      bodyContact(other);
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! HealthFunctionality) {
      return;
    }
    final isHomingSensor =
        (contact.fixtureB.userData! as Map)['type'] == FixtureType.sensor ||
            (contact.fixtureA.userData! as Map)['type'] == FixtureType.sensor;

    if (isHomingSensor) {
      sensorEndContact(other);
    }

    super.endContact(other, contact);
  }

  bool parentWeaponHasStoppedAttacking = false;

  void onParentWeaponAttackingFinish(Weapon weapon) {
    parentWeaponHasStoppedAttacking = true;
    if (removeOnEndAttack) {
      killBullet(true);
    }
  }

  @override
  Future<void> onLoad() async {
    parentProjectileFunctionality?.activeProjectiles.add(this);
    callOnProjectileAttackFunctions();
    final future = projectileConfiguration.parentWeaponAttackingStopped?.future;

    (future ?? projectileTtlExpired).then((value) {
      onParentWeaponAttackingFinish(weaponAncestor);
    });

    return super.onLoad();
  }

  @override
  void onRemove() {
    parentProjectileFunctionality?.activeProjectiles.remove(this);

    super.onRemove();
  }

  Completer<bool> projectileTtlExpiredCompleter = Completer<bool>();
  Future<void> get projectileTtlExpired => projectileTtlExpiredCompleter.future;
  @override
  void update(double dt) {
    durationPassed += dt;
    if (durationPassed > ttl && !projectileTtlExpiredCompleter.isCompleted) {
      projectileTtlExpiredCompleter.complete(true);
    }

    if (projectileTtlExpiredCompleter.isCompleted &&
        !projectileHasExpired &&
        !removeOnEndAttack) {
      killBullet(true);
    }

    super.update(dt);
  }
}

@immutable
class ProjectileConfiguration {
  final Vector2 delta;
  final Vector2 originPosition;
  final Weapon weaponAncestor;
  final double size;
  final DamageType? primaryDamageType;
  final double power;
  final Completer<bool>? parentWeaponAttackingStopped;

  const ProjectileConfiguration({
    required this.delta,
    required this.originPosition,
    required this.weaponAncestor,
    this.size = 1,
    this.primaryDamageType,
    this.parentWeaponAttackingStopped,
    this.power = 1,
  });

  ProjectileConfiguration copyWith({
    Vector2? delta,
    Vector2? originPosition,
    Weapon? weaponAncestor,
    double? size,
    DamageType? primaryDamageType,
    double? power,
    Completer<bool>? parentWeaponAttackingStopped,
  }) {
    return ProjectileConfiguration(
      delta: delta ?? this.delta,
      originPosition: originPosition ?? this.originPosition,
      weaponAncestor: weaponAncestor ?? this.weaponAncestor,
      size: size ?? this.size,
      primaryDamageType: primaryDamageType ?? this.primaryDamageType,
      power: power ?? this.power,
      parentWeaponAttackingStopped:
          parentWeaponAttackingStopped ?? this.parentWeaponAttackingStopped,
    );
  }
}
