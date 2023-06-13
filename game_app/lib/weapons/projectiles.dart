import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/main.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/enemy.dart';
import '../resources/enums.dart';

class Arrow extends Projectile {
  Arrow(
      {required super.delta,
      required super.speed,
      required super.originPosition,
      required super.id,
      required super.weaponAncestor});

  @override
  double embedIntoEnemyChance = .9;

  @override
  ProjectileType projectileType = ProjectileType.arrow;

  @override
  double size = 8;

  @override
  double ttl = 3.0;
}

class Fireball extends Projectile {
  Fireball(
      {required super.delta,
      required super.speed,
      required super.originPosition,
      required super.id,
      required super.weaponAncestor});

  @override
  double embedIntoEnemyChance = .8;

  @override
  ProjectileType projectileType = ProjectileType.fireball;

  @override
  double size = 5;

  @override
  double ttl = 1.0;
}

class Bullet extends Projectile {
  Bullet(
      {required super.delta,
      required super.speed,
      required super.originPosition,
      required super.id,
      required super.weaponAncestor});

  @override
  double embedIntoEnemyChance = .8;

  @override
  ProjectileType projectileType = ProjectileType.bullet;

  @override
  double size = 1.5;

  @override
  double ttl = 1.0;
}

class Pellet extends Projectile {
  Pellet(
      {required super.delta,
      required super.speed,
      required super.originPosition,
      required super.id,
      required super.weaponAncestor});

  @override
  double embedIntoEnemyChance = .7;

  @override
  ProjectileType projectileType = ProjectileType.pellet;

  @override
  double size = 1;

  @override
  double ttl = 1.0;
}

abstract class Projectile extends BodyComponent<GameRouter>
    with ContactCallbacks {
  Projectile(
      {required this.delta,
      required this.speed,
      required this.originPosition,
      required this.id,
      required this.weaponAncestor});

  late final CircleComponent circleComponent;

  bool bulletHasExpired = false;
  ProjectileFunctionality weaponAncestor;
  abstract double embedIntoEnemyChance;
  int enemiesHit = 0;
  double homingDistance = 30;
  String id;
  Vector2 originPosition;
  Vector2 previousPatternForce = Vector2.zero();
  abstract ProjectileType projectileType;

  Random rng = Random();
  late Shape shape;
  abstract double size;
  Vector2 delta;
  double speed;
  abstract double ttl;

  List<HealthFunctionality> closeHomingBodies = [];
  FixtureDef? sensorDef;
  TimerComponent? bulletDeathTimer;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! HealthFunctionality) {
      return;
    }

    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor &&
        other.targetsHomingEntity < other.maxTargetsHomingEntity) {
      closeHomingBodies.add(other);
      other.targetsHomingEntity++;
      closeHomingBodies.sort((a, b) =>
          a.center.distanceTo(center).compareTo(b.center.distanceTo(center)));
      homingCalc(other);
    } else if (!bulletHasExpired && !isHomingSensor && !other.isDead) {
      hitOther(id, other);
    }

    super.beginContact(other, contact);
  }

  void hitOther(String id, HealthFunctionality other) {
    chain(other);

    other.takeDamage(id, weaponAncestor.damage);
    incrementHits();
  }

  void incrementHits() {
    enemiesHit++;
    bulletHasExpired = enemiesHit > weaponAncestor.pierce;
    if (bulletHasExpired) {
      killBullet();
    }
  }

  int chainedTargets = 0;

  void chain(HealthFunctionality other) {
    if (weaponAncestor.isChaining &&
        !bulletHasExpired &&
        chainedTargets < weaponAncestor.chainingTargets) {
      int index = closeHomingBodies.indexWhere((element) => element != other);
      if (index == -1) return;
      // delta = (closeHomingBodies[index].center - center).normalized();
      body.applyLinearImpulse(
          (closeHomingBodies[index].center - center) * 10000);
      chainedTargets++;
      bulletDeathTimer?.timer.reset();
    }
  }

  @override
  Body createBody() {
    shape = CircleShape();
    shape.radius = circleComponent.radius;

    final bulletFilter = Filter();
    if (weaponAncestor.parentEntity is Enemy) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = bulletCategory;
    } else if (weaponAncestor.parentEntity is Player) {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = bulletCategory;
    }

    final fixtureDef = FixtureDef(shape,
        userData: this,
        restitution: 0,
        friction: 0,
        density: 0.00001,
        isSensor: true,
        filter: bulletFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.dynamic,
      bullet: true,
      linearVelocity: delta * speed,
      fixedRotation: !weaponAncestor.allowProjectileRotation,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    if (weaponAncestor.isHoming || weaponAncestor.isChaining) {
      bulletFilter.categoryBits = sensorCategory;
      sensorDef = FixtureDef(CircleShape()..radius = homingDistance / 2,
          userData: "homingSensor", isSensor: true, filter: bulletFilter);
      returnBody.createFixture(sensorDef!);
    }

    return returnBody;
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! HealthFunctionality) return;
    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor) {
      closeHomingBodies.remove(other);
      other.targetsHomingEntity--;
    }

    super.endContact(other, contact);
  }

  @override
  Future<void> onLoad() async {
    bulletDeathTimer = TimerComponent(
      period: ttl,
      onTick: () {
        killBullet();
      },
    );

    circleComponent = CircleComponent(
        radius: .3, anchor: Anchor.center, paint: Paint()..color = Colors.red);
    add(circleComponent);

    add(bulletDeathTimer!);

    return super.onLoad();
  }

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    contact.setEnabled(bulletHasExpired);
    super.preSolve(other, contact, oldManifold);
  }

  @override
  void render(Canvas canvas) {
    // final path = Path()
    //   ..moveTo(0, 0)
    //   ..moveTo(0, circleComponent.radius)
    //   ..moveTo(10, 0)
    //   ..moveTo(0, -circleComponent.radius)
    //   ..moveTo(0, 0)
    //   ..close();
    // canvas.drawPath(path, paint..style = PaintingStyle.fill);

    canvas.drawLine(Offset.zero,
        (body.linearVelocity.normalized() * -10).toOffset(), paint);
  }

  @override
  void update(double dt) {
    if (!bulletHasExpired && weaponAncestor.parent != null) {
      bulletAngleCalc();
    }
    // print('ere');
    // body.setTransform(body.position + ((delta * speed) * dt), 0);

    super.update(dt);
  }

  void bulletAngleCalc() {
    if ((weaponAncestor).allowProjectileRotation) {
      // spriteComponent.angle =
      //     -radiansBetweenPoints(Vector2(0, 0.0001), body.linearVelocity);
    }
  }

  bool homingComplete = false;

  void homingCalc(HealthFunctionality entity) {
    if (weaponAncestor.isHoming && !homingComplete) {
      Vector2? closetPosition;

      closetPosition = entity.center;

      final test = (closetPosition - body.worldCenter).normalized();
      body.applyLinearImpulse((test * weaponAncestor.projectileVelocity));
      homingComplete = true;
    }
  }

  void killBullet() async {
    removeFromParent();
  }
}

// class ProjectileTrail extends Path {
//   // ProjectileTrail(CircleComponent bullet, double dt) {
//   //   moveTo(0, 0);
//   //   moveTo(0, bullet.radius);
//   //   moveTo(10, 0);
//   //   moveTo(0, -bullet.radius);
//   //   moveTo(0, 0);
//   //   close();
//   // }
// }
