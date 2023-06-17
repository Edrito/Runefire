import 'dart:async';
import 'dart:math';

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
      this.power = 1});

  Random rng = Random();

  //Structure
  ProjectileFunctionality weaponAncestor;
  double closeBodySensorRadius = 17.5;
  Vector2 originPosition;
  late Shape shape;
  abstract double size;
  abstract double ttl;
  abstract ProjectileType projectileType;

  //Status
  Vector2 delta;
  List<HealthFunctionality> closeHomingBodies = [];
  TimerComponent? projectileDeathTimer;
  bool projectileHasExpired = false;
  bool homingComplete = false;

  //Attributes
  double power;
  abstract double embedIntoEnemyChance;
  int chainedTargets = 0;

  FixtureDef? sensorDef;

  List<int> hitHashcodes = [];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! HealthFunctionality ||
        hitHashcodes.contains(other.hashCode)) {
      return;
    }
    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor &&
        other.targetsHomingEntity < other.maxTargetsHomingEntity) {
      sensorContact(other);
    } else if (!projectileHasExpired && !isHomingSensor && !other.isDead) {
      bodyContact(other);
    }

    super.beginContact(other, contact);
  }

  void sensorContact(HealthFunctionality other) {
    closeHomingBodies.add(other);
    other.targetsHomingEntity++;
  }

  void bodyContact(HealthFunctionality other) {
    hitHashcodes.add(other.hashCode);
    other.takeDamage(hashCode, weaponAncestor.damage);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! HealthFunctionality) return;
    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor) {
      sensorEndContact(other);
    }

    super.endContact(other, contact);
  }

  void sensorEndContact(HealthFunctionality other) {
    closeHomingBodies.remove(other);
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

    return super.onLoad();
  }

  void killBullet() async {
    removeFromParent();
  }
}
