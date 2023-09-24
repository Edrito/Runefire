import 'dart:async';
import 'dart:math';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/weapons/projectile_mixin.dart';
import 'package:uuid/uuid.dart';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/main.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../resources/enums.dart';

abstract class FadeOutBullet extends Bullet with FadeOutProjectile {
  FadeOutBullet(
      {required super.delta,
      required super.originPosition,
      super.primaryDamageType,
      required super.weaponAncestor,
      required super.size,
      super.power});
}

abstract class Bullet extends Projectile with StandardProjectile {
  Bullet(
      {required super.delta,
      required super.originPosition,
      required super.weaponAncestor,
      required super.size,
      super.primaryDamageType,
      super.power});

  @override
  double ttl = 2;
}

mixin FadeOutProjectile on Projectile {
  @override
  void update(double dt) {
    timePassed += dt;
    super.update(dt);
  }

  double timePassed = 0;
  double fadeOutDuration = .4;
  Curve fadeOutCurve = Curves.easeOut;
  // @override
  // double get opacity => fadeOutCurve.transform(
  //     (1 - ((timePassed - ttl + fadeOutDuration) / fadeOutDuration))
  //         .clamp(0, 1)
  //         .toDouble());
  @override
  double get opacity => 1;
  // @override
  // void killBullet([bool withEffect = false]) async {}
}

abstract class Projectile extends BodyComponent<GameRouter>
    with ContactCallbacks {
  Projectile(
      {required this.delta,
      required this.originPosition,
      required this.weaponAncestor,
      required this.size,
      DamageType? primaryDamageType,
      this.power = 1}) {
    projectileId = const Uuid().v4();
    damageType = primaryDamageType ??
        weaponAncestor.baseDamage.damageBase.keys.toList().random();
  }

  double size;

  bool isPlayer = false;

  bool get isSmallProjectile => size < projectileBigSizeThreshold;

  bool enableChaining = false;
  bool enableHoming = false;
  bool removeOnEndAttack = false;

  late final int targetsToChain = weaponAncestor.chainingTargets.parameter;
  late final int targetsToHome = weaponAncestor.maxHomingTargets.parameter;
  int chainedTargets = 0;
  int homedTargets = 0;
  bool get homingComplete => homedTargets > targetsToHome;
  bool get chainingComplete => chainedTargets > targetsToChain;

  late DamageType damageType;

  late String projectileId;
  Random rng = Random();
  double durationPassed = 0;
  @override
  void update(double dt) {
    durationPassed += dt;
    super.update(dt);
  }

  //Structure
  ProjectileFunctionality weaponAncestor;
  Vector2 originPosition;
  abstract double ttl;
  abstract ProjectileType projectileType;

  //Status
  final Vector2 delta;
  Vector2 previousDelta = Vector2.zero();

  void setDelta(Vector2 newDelta) {
    previousDelta = delta.clone();
    delta.setFrom(newDelta);
  }

  List<HealthFunctionality> closeSensorBodies = [];
  TimerComponent? projectileDeathTimer;
  bool projectileHasExpired = false;

  //Attributes
  double power;

  FixtureDef? sensorDef;

  List<String> hitIds = [];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! HealthFunctionality || hitIds.contains(other.entityId)) {
      return super.beginContact(other, contact);
    }

    if (isPlayer && other is Player) {
      return super.beginContact(other, contact);
    }
    if (!isPlayer &&
        other is Enemy &&
        !weaponAncestor.entityAncestor!.affectsAllEntities) {
      return super.beginContact(other, contact);
    }

    bool isHomingSensor =
        (contact.fixtureB.userData as Map)['type'] == FixtureType.sensor ||
            (contact.fixtureA.userData as Map)['type'] == FixtureType.sensor;

    if (isHomingSensor &&
        other.targetsHomingEntity < other.maxTargetsHomingEntity) {
      sensorContact(other);
    } else if (!projectileHasExpired && !isHomingSensor && !other.isDead) {
      bodyContact(other);
    }

    super.beginContact(other, contact);
  }

  void sensorContact(HealthFunctionality other) {
    closeSensorBodies.add(other);
    other.targetsHomingEntity++;
  }

  void bodyContact(HealthFunctionality other) {
    hitIds.add(other.entityId);
    final damageInstance = weaponAncestor.calculateDamage(other, this);
    onHitFunctions(damageInstance, other);
    other.hitCheck(projectileId, damageInstance);
  }

  void onHitFunctions(
      DamageInstance damageInstance, HealthFunctionality victim) {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      bool result = false;

      for (var element in weapon.onHitProjectile) {
        result = result || element(damageInstance);
      }
    }
    weaponAncestor.entityAncestor?.attributeFunctionsFunctionality
        ?.onHitFunctions(damageInstance);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! HealthFunctionality) return;
    bool isHomingSensor =
        (contact.fixtureB.userData as Map)['type'] == FixtureType.sensor ||
            (contact.fixtureA.userData as Map)['type'] == FixtureType.sensor;

    if (isHomingSensor) {
      sensorEndContact(other);
    }

    super.endContact(other, contact);
  }

  void sensorEndContact(HealthFunctionality other) {
    closeSensorBodies.remove(other);
    other.targetsHomingEntity--;
  }

  @override
  Future<void> onLoad() async {
    if (removeOnEndAttack &&
        weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      (weaponAncestor as AttributeWeaponFunctionsFunctionality)
          .onAttackingFinish
          .add((weapon) {
        killBullet(true);
      });
    } else {
      projectileDeathTimer = TimerComponent(
        period: ttl,
        onTick: () {
          projectileHasExpired = true;
          killBullet(true);
        },
      );
      add(projectileDeathTimer!);
    }

    weaponAncestor.activeProjectiles.add(this);
    isPlayer = weaponAncestor.entityAncestor?.isPlayer ?? false;
    callOnProjectileAttackFunctions();
    return super.onLoad();
  }

  @override
  void onRemove() {
    weaponAncestor.activeProjectiles.remove(this);
    super.onRemove();
  }

  void callOnProjectileAttackFunctions() {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onAttackProjectile) {
        element(this);
      }
    }
  }

  void callBulletKillFunctions() {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onProjectileDeath) {
        element(this);
      }
    }
  }

  void killBullet([bool withEffect = false]) async {
    if (!world.physicsWorld.isLocked) {
      body.setType(BodyType.static);
    }
    removeFromParent();
    callBulletKillFunctions();
  }
}
