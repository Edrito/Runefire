import 'dart:async';
import 'dart:math';
import 'package:uuid/uuid.dart';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/main.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/enums.dart';

abstract class Projectile extends BodyComponent<GameRouter>
    with ContactCallbacks {
  Projectile(
      {required this.delta,
      required this.originPosition,
      required this.weaponAncestor,
      this.power = 1}) {
    projectileId = const Uuid().v4();
  }

  late String projectileId;
  Random rng = Random();

  //Structure
  ProjectileFunctionality weaponAncestor;
  double closeBodySensorRadius = 3;
  Vector2 originPosition;
  abstract double size;
  abstract double ttl;
  abstract ProjectileType projectileType;

  //Status
  Vector2 delta;
  List<HealthFunctionality> closeSensorBodies = [];
  TimerComponent? projectileDeathTimer;
  bool projectileHasExpired = false;
  bool homingComplete = false;

  //Attributes
  double power;
  int chainedTargets = 0;

  FixtureDef? sensorDef;

  List<String> hitIds = [];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! HealthFunctionality || hitIds.contains(other.entityId)) {
      return;
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
    other.hitCheck(projectileId, weaponAncestor.damage);
    onHitFunctions(other);
  }

  void onHitFunctions(HealthFunctionality other) {
    if (weaponAncestor is AttributeWeaponFunctionsFunctionality) {
      final weapon = weaponAncestor as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onHitProjectile) {
        element(other);
      }
    }
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
    projectileDeathTimer = TimerComponent(
      period: ttl,
      onTick: () {
        killBullet();
      },
    );
    add(projectileDeathTimer!);
    weaponAncestor.activeProjectiles.add(this);
    return super.onLoad();
  }

  @override
  void onRemove() {
    weaponAncestor.activeProjectiles.remove(this);
    super.onRemove();
  }

  void killBullet() async {
    removeFromParent();
  }
}
