import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/weapons/projectile_class.dart';

import '../entities/enemy.dart';
import '../entities/entity_mixin.dart';
import '../entities/player.dart';
import '../functions/vector_functions.dart';
import '../game/physics_filter.dart';

mixin SingularProjectile on Projectile {
  late final CircleComponent circleComponent;

  int enemiesHit = 0;

  void incrementHits() {
    enemiesHit++;
    projectileHasExpired = enemiesHit > weaponAncestor.pierce;
    if (projectileHasExpired) {
      killBullet();
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
      linearDamping: (5 - (5 * power)).clamp(0, 5),
      bullet: true,
      linearVelocity: delta * weaponAncestor.projectileVelocity,
      fixedRotation: !weaponAncestor.allowProjectileRotation,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    if (weaponAncestor.isHoming || weaponAncestor.isChaining) {
      bulletFilter.categoryBits = sensorCategory;
      sensorDef = FixtureDef(CircleShape()..radius = closeBodySensorRadius,
          userData: "homingSensor", isSensor: true, filter: bulletFilter);
      returnBody.createFixture(sensorDef!);
    }

    return returnBody;
  }

  @override
  Future<void> onLoad() {
    circleComponent = CircleComponent(
        radius: .3, anchor: Anchor.center, paint: BasicPalette.red.paint());
    add(circleComponent);

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawLine(
        Offset.zero, (body.linearVelocity.normalized() * -1).toOffset(), paint);
  }

  @override
  void update(double dt) {
    // if (!bulletHasExpired && weaponAncestor.parent != null) {
    //   bulletAngleCalc();
    // }
    super.update(dt);
  }

  void bulletAngleCalc() {
    if ((weaponAncestor).allowProjectileRotation) {
      // spriteComponent.angle =
      //     -radiansBetweenPoints(Vector2(0, 0.0001), body.linearVelocity);
    }
  }

  @override
  void bodyContact(HealthFunctionality other) {
    super.bodyContact(other);
    incrementHits();
    chain(other);
  }

  void chain(HealthFunctionality other) {
    if (weaponAncestor.isChaining &&
        !projectileHasExpired &&
        chainedTargets < weaponAncestor.chainingTargets) {
      int index = closeHomingBodies
          .indexWhere((element) => !hitHashcodes.contains(element.hashCode));
      if (index == -1) return;
      // delta = (closeHomingBodies[index].center - center).normalized();
      body.applyLinearImpulse(
          (closeHomingBodies[index].center - center) * 1000);
      chainedTargets++;
      projectileDeathTimer?.timer.reset();
    }
  }

  @override
  void sensorContact(HealthFunctionality other) {
    homingCalc(other);
    super.sensorContact(other);
  }

  void homingCalc(HealthFunctionality entity) {
    if (weaponAncestor.isHoming && !homingComplete) {
      Vector2? closetPosition;

      closetPosition = entity.center;

      final test = (closetPosition - body.worldCenter).normalized();
      body.applyLinearImpulse((test * weaponAncestor.projectileVelocity));
      homingComplete = true;
    }
  }
}

mixin LaserProjectile on Projectile {
  int enemiesHit = 0;
  abstract bool isContinuous;
  List<Vector2> lineThroughEnemies = [];
  late final CircleComponent circleComponent;

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
      type: BodyType.static,
      linearDamping: (5 - (5 * power)).clamp(0, 5),
      bullet: true,
      // linearVelocity: delta * weaponAncestor.projectileVelocity,
      // fixedRotation: !weaponAncestor.allowProjectileRotation,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    if (weaponAncestor.isHoming || weaponAncestor.isChaining) {
      bulletFilter.categoryBits = sensorCategory;

      sensorDef = FixtureDef(CircleShape()..radius = closeBodySensorRadius,
          userData: "homingSensor", isSensor: true, filter: bulletFilter);
      returnBody.createFixture(sensorDef!);
    }

    return returnBody;
  }

  bool infrontWeaponCheck(Body element) {
    return element.userData is Enemy &&
        isEntityInfrontOfPosition(element.position, body.position, delta);
  }

  double precisionPerDistance = .5;

  Vector2 previousDelta = Vector2.zero();

  @override
  Future<void> onLoad() async {
    circleComponent = CircleComponent(
        radius: .3, anchor: Anchor.center, paint: BasicPalette.red.paint());
    add(circleComponent);

    await super.onLoad();

    final sw = Stopwatch()..start();

    List<Body> bodies = game.world.bodies
        .where((element) => infrontWeaponCheck(element))
        .toList();
    bodies.sort(
      (a, b) => a.position
          .distanceTo(body.position)
          .compareTo(b.position.distanceTo(body.position)),
    );

    final amountOfPoints =
        precisionPerDistance * weaponAncestor.projectileVelocity;
    final pointStep = weaponAncestor.projectileVelocity / amountOfPoints;
    previousDelta = body.position;
    for (var i = 0; i < amountOfPoints; i++) {
      Body? bodyToJumpTo;
      if (chainedTargets < weaponAncestor.chainingTargets) {
        for (var element in bodies) {
          if (element.worldCenter.distanceTo(previousDelta) <
              closeBodySensorRadius) {
            bodyToJumpTo = element;
            break;
          }
        }
      }
      Vector2 newDelta;
      if (bodyToJumpTo != null) {
        newDelta = bodyToJumpTo.position;
        delta = (bodyToJumpTo.position - previousDelta).normalized();
        bodies.remove(bodyToJumpTo);
        chainedTargets++;
      } else {
        newDelta = ((delta * pointStep) + previousDelta);
      }

      lineThroughEnemies.add(newDelta);
      previousDelta = newDelta.clone();
    }
  }

  @override
  void render(Canvas canvas) {
    Vector2 previousDrawnDude = Vector2.zero();
    for (var element in lineThroughEnemies) {
      element = element - body.position;
      canvas.drawLine(previousDrawnDude.toOffset(), element.toOffset(), paint);
      previousDrawnDude = element.clone();
    }
  }

  @override
  void update(double dt) {
    // if (!bulletHasExpired && weaponAncestor.parent != null) {
    //   bulletAngleCalc();
    // }
    super.update(dt);
  }

  void bulletAngleCalc() {
    if ((weaponAncestor).allowProjectileRotation) {
      // spriteComponent.angle =
      //     -radiansBetweenPoints(Vector2(0, 0.0001), body.linearVelocity);
    }
  }
}
