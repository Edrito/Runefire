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
  Curve fadeOutCurve = Curves.easeOut;
  double fadeOutDuration = .4;
  double timePassed = 0;

  // @override
  // void killBullet([bool withEffect = false]) async {}

  // @override
  // double get opacity => fadeOutCurve.transform(
  //     (1 - ((timePassed - ttl + fadeOutDuration) / fadeOutDuration))
  //         .clamp(0, 1)
  //         .toDouble());
  @override
  double get opacity => 1;

  @override
  void update(double dt) {
    timePassed += dt;
    super.update(dt);
  }
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

  late final int targetsToChain = weaponAncestor.chainingTargets.parameter;
  late final int targetsToHome = weaponAncestor.maxHomingTargets.parameter;

  int chainedTargets = 0;
  List<HealthFunctionality> closeSensorBodies = [];
  late DamageType damageType;
  //Status
  final Vector2 delta;

  double durationPassed = 0;
  bool enableChaining = false;
  bool enableHoming = false;
  List<String> hitIds = [];
  int homedTargets = 0;
  bool isPlayer = false;
  Vector2 originPosition;
  //Attributes
  double power;

  Vector2 previousDelta = Vector2.zero();
  bool projectileHasExpired = false;
  late String projectileId;
  abstract ProjectileType projectileType;
  bool removeOnEndAttack = false;
  Random rng = Random();
  double size;
  abstract double ttl;
  //Structure
  ProjectileFunctionality weaponAncestor;

  // TimerComponent? projectileDeathTimer;
  FixtureDef? sensorDef;

  bool get chainingComplete => chainedTargets > targetsToChain;
  bool get homingComplete => homedTargets > targetsToHome;
  bool get isSmallProjectile => size < projectileBigSizeThreshold;

  void bodyContact(HealthFunctionality other) {
    hitIds.add(other.entityId);
    final damageInstance = weaponAncestor.calculateDamage(other, this);
    onHitFunctions(damageInstance, other);
    other.hitCheck(projectileId, damageInstance);
  }

  void callBulletKillFunctions() {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onProjectileDeath) {
        element(this);
      }
    }
  }

  void callOnProjectileAttackFunctions() {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onAttackProjectile) {
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

  @override
  Future<void> onLoad() async {
    if (removeOnEndAttack &&
        weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      (weaponAncestor as AttributeWeaponFunctionsFunctionality)
          .onAttackingFinish
          .add((weapon) {
        killBullet(true);
      });
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

  @override
  void update(double dt) {
    durationPassed += dt;
    if (durationPassed > ttl && !projectileHasExpired) {
      projectileHasExpired = true;
      killBullet(true);
    }
    super.update(dt);
  }
}
