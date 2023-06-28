import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/weapons/projectile_class.dart';

import '../entities/enemy.dart';
import '../entities/entity_mixin.dart';
import '../entities/player.dart';
import '../functions/vector_functions.dart';
import '../resources/enums.dart';
import '../resources/physics_filter.dart';

mixin StandardProjectile on Projectile {
  late final CircleComponent circleComponent;
  int enemiesHit = 0;
  abstract double embedIntoEnemyChance;

  void incrementHits() {
    enemiesHit++;
    projectileHasExpired = enemiesHit > weaponAncestor.pierce;
    if (projectileHasExpired) {
      killBullet();
    }
  }

  late Shape shape;

  void createBodyShape() {
    shape = CircleShape();
    shape.radius = circleComponent.radius;
  }

  @override
  Body createBody() {
    createBodyShape();

    renderBody = false;

    final bulletFilter = Filter();
    if (weaponAncestor.entityAncestor is Enemy) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = bulletCategory;
    } else if (weaponAncestor.entityAncestor is Player) {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = bulletCategory;
    }

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
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
          userData: {"type": FixtureType.sensor, "object": this},
          isSensor: true,
          filter: bulletFilter);
      returnBody.createFixture(sensorDef!);
    }

    return returnBody;
  }

  void createShapeComponent() {
    circleComponent = CircleComponent(
        radius: length / 2,
        anchor: Anchor.center,
        paint: BasicPalette.red.paint());
    add(circleComponent);
  }

  @override
  Future<void> onLoad() {
    createShapeComponent();
    return super.onLoad();
  }

  // @override
  // void render(Canvas canvas) {
  //   canvas.drawLine(
  //       Offset.zero, (body.linearVelocity.normalized() * -1).toOffset(), paint);
  // }

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
      int index = closeHomingBodies.indexWhere(
          (element) => !hitIds.contains(element.hashCode) && !element.isDead);
      if (index == -1) return;
      // delta = (closeHomingBodies[index].center - center).normalized();
      body.applyLinearImpulse(
          (closeHomingBodies[index].center - center).normalized() *
              weaponAncestor.projectileVelocity);
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
  List<Vector2> boxThroughEnemies = [];
  late Shape laserShape;

  @override
  Body createBody() {
    debugMode = false;
    renderBody = false;

    laserShape = ChainShape()..createLoop(boxThroughEnemies);

    final bulletFilter = Filter();
    if (weaponAncestor.entityAncestor is Enemy) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = bulletCategory;
    } else if (weaponAncestor.entityAncestor is Player) {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = bulletCategory;
    }
    final fixtureDef = FixtureDef(laserShape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: true,
        filter: bulletFilter);
    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      linearVelocity: delta * rng.nextDouble() * 2,
      type: BodyType.dynamic,
      bullet: false,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    return returnBody;
  }

  bool infrontWeaponCheck(Body element) {
    return element.userData is Enemy &&
        element.userData is HealthFunctionality &&
        !(element.userData as HealthFunctionality).isDead &&
        isEntityInfrontOfHandAngle(element.position, originPosition, delta);
  }

  double precisionPerDistance = .5;

  Vector2 previousDelta = Vector2.zero();
  bool startChaining = false;

  abstract double baseWidth;
  late double width;

  void homingAndChainCalculations() {
    double distance = weaponAncestor.projectileVelocity;

    List<Body> bodies = game.world.bodies
        .where((element) => infrontWeaponCheck(element))
        .toList();

    homingComplete = !weaponAncestor.isHoming;

    bodies.sort(
      (a, b) => a.position
          .distanceTo(originPosition)
          .compareTo(b.position.distanceTo(originPosition)),
    );

    var amountOfPoints = precisionPerDistance * distance;

    amountOfPoints = amountOfPoints.clamp(3, 200);

    final pointStep = distance / amountOfPoints;

    amountOfPoints = (amountOfPoints * .666 * power) + amountOfPoints * .333;

    startChaining = weaponAncestor.isHoming && weaponAncestor.isChaining;

    for (var i = 0; i < amountOfPoints; i++) {
      Body? bodyToJumpTo;
      Vector2 newPointPosition;
      bool shouldChain =
          chainedTargets < weaponAncestor.chainingTargets && startChaining;

      //if should be bouncing, bounce
      if (!homingComplete || shouldChain) {
        for (var element in bodies) {
          if ((element.position - originPosition).distanceTo(previousDelta) <
              closeBodySensorRadius) {
            bodyToJumpTo = element;
            break;
          }
        }
      }

      //if close body detected, jump to it
      if (bodyToJumpTo != null) {
        newPointPosition = bodyToJumpTo.position - originPosition;
        delta = (bodyToJumpTo.position - originPosition - previousDelta)
            .normalized();
        bodies.remove(bodyToJumpTo);

        chainedTargets++;
        homingComplete = true;
      } else {
        newPointPosition = ((delta * pointStep) + previousDelta);
      }

      //TODO: rework check if other body is hit from this line
      //if hit, then start chaining
      if (weaponAncestor.isChaining && !startChaining) {
        for (var element in bodies) {
          if ((element.position - originPosition).distanceTo(newPointPosition) <
              3) {
            startChaining = true;
            break;
          }
        }
      }

      lineThroughEnemies.add(newPointPosition);
      previousDelta = newPointPosition.clone();
    }
  }

  @override
  Future<void> onLoad() async {
    // circleComponent = CircleComponent(
    //     radius: .3, anchor: Anchor.center, paint: BasicPalette.red.paint());
    // add(circleComponent);

    width = (power * baseWidth) + baseWidth * .15;
    width = (power * baseWidth) + baseWidth * .15;
    lineThroughEnemies.add(previousDelta);

    if (weaponAncestor.isHoming || weaponAncestor.isChaining) {
      homingAndChainCalculations();
    } else {
      double distance = weaponAncestor.projectileVelocity;
      distance = (distance * .666 * power) + distance * .333;
      lineThroughEnemies.add(((delta * distance * .333) + previousDelta));
      lineThroughEnemies.add(((delta * distance * .666) + previousDelta));
      lineThroughEnemies.add(((delta * distance) + previousDelta));
    }

    boxThroughEnemies =
        expandToBox(lineThroughEnemies, width / 2).toSet().toList();
    boxThroughEnemies = validateChainDistances(boxThroughEnemies);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    var path = Path();
    var paint = BasicPalette.lightBlue.paint();
    paint.strokeWidth = width;
    paint.style = PaintingStyle.stroke;
    paint.strokeCap = StrokeCap.round;

    for (var element in lineThroughEnemies) {
      path.lineTo(element.x, element.y);
    }

    canvas.drawPath(path, paint);
    canvas.drawPath(
        path,
        paint
          ..strokeWidth = width * .6
          ..color = Colors.black);
  }
}
