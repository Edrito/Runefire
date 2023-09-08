import 'dart:async';
import 'dart:math';
import 'package:game_app/resources/functions/custom.dart';
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
    damageType =
        weaponAncestor.baseDamage.damageBase.keys.toList().getRandomElement();
  }

  bool disableChaining = false;
  bool disableHoming = false;

  late DamageType damageType;

  double fadeOutDuration = .4;
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
  double closeBodySensorRadius = 3;
  Vector2 originPosition;
  abstract double size;
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
  bool homingComplete = false;

  //Attributes
  double power;
  int chainedTargets = 0;
  int homedTargets = 0;

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
    final damageInstance = weaponAncestor.calculateDamage(other, this);
    other.hitCheck(projectileId, damageInstance);
    onHitFunctions(damageInstance, other);
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
    projectileDeathTimer = TimerComponent(
      period: ttl,
      onTick: () {
        killBullet(true);
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

  bool isDead = false;

  void killBullet([bool withEffect = false]) async {
    body.setType(BodyType.static);
    removeFromParent();
    isDead = true;
  }
}
