import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/resources/visuals.dart';
import 'package:game_app/weapons/projectile_class.dart';
// ignore: unused_import
import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../entities/enemy.dart';
import '../entities/entity_mixin.dart';
import '../entities/player.dart';
import '../resources/functions/vector_functions.dart';
import '../resources/enums.dart';
import '../resources/constants/physics_filter.dart';

mixin StandardProjectile on Projectile {
  int enemiesHit = 0;
  abstract double embedIntoEnemyChance;

  void incrementHits() {
    enemiesHit++;
    projectileHasExpired = enemiesHit > weaponAncestor.pierce.parameter;

    if (projectileHasExpired) {
      killBullet();
    }
  }

  late Shape shape;

  void createBodyShape() {
    shape = CircleShape();
    shape.radius = size / 2;
  }

  @override
  Body createBody() {
    createBodyShape();

    renderBody = false;

    final bulletFilter = Filter();
    if (weaponAncestor.entityAncestor is Enemy) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = attackCategory;
    } else if (weaponAncestor.entityAncestor is Player) {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = attackCategory;
    }

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0.0000001,
        isSensor: true,
        filter: bulletFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.dynamic,
      linearDamping: (5 - (5 * power)).clamp(0, 5),
      bullet: true,
      linearVelocity: (delta * weaponAncestor.projectileVelocity.parameter),
      fixedRotation: !weaponAncestor.allowProjectileRotation,
    );
    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    if (weaponAncestor.weaponCanHome || weaponAncestor.weaponCanChain) {
      bulletFilter.categoryBits = sensorCategory;
      sensorDef = FixtureDef(CircleShape()..radius = closeBodySensorRadius,
          userData: {"type": FixtureType.sensor, "object": this},
          isSensor: true,
          filter: bulletFilter);
      returnBody.createFixture(sensorDef!);
    }

    return returnBody;
  }

  @override
  void render(Canvas canvas) {
    if (!targetSet) {
      drawBullet(canvas);
    }
    super.render(canvas);
  }

  void drawBullet(Canvas canvas) {
    canvas.drawLine(
        Offset.zero,
        (body.linearVelocity.normalized() * -.5).toOffset(),
        paint
          ..strokeWidth = size
          ..shader = ui.Gradient.linear(
              (body.linearVelocity.normalized() * -.5).toOffset(),
              Offset.zero,
              [Colors.transparent, secondaryColor]));
    canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size, height: size),
        Paint()
          // ..strokeWidth = size
          ..color = primaryColor);
    // canvas.drawRect(
    //     Rect.fromCenter(center: Offset.zero, width: size / 2, height: size * 2),
    //     Paint()

    //       // ..strokeWidth = size
    //       ..color = primaryColor);
  }

  HealthFunctionality? target;
  bool targetSet = false;
  void setTarget(HealthFunctionality? target) {
    targetSet = true;
    this.target = target;
    if (target != null) {
      body.linearVelocity = Vector2.zero();
    }
  }

  @override
  void update(double dt) {
    if (target != null) {
      home(target!, dt);
    }
    super.update(dt);
  }

  @override
  void bodyContact(HealthFunctionality other) {
    setTarget(null);

    incrementHits();
    chain(other);
    super.bodyContact(other);
  }

  void chain(HealthFunctionality other) {
    if (weaponAncestor.weaponCanChain &&
        !projectileHasExpired &&
        chainedTargets < weaponAncestor.maxChainingTargets.parameter) {
      closeSensorBodies.sort((a, b) => rng.nextInt(2));
      int index = closeSensorBodies.indexWhere(
          (element) => !hitIds.contains(element.entityId) && !element.isDead);

      if (index == -1) {
        setTarget(null);
        return;
      }
      setTarget(closeSensorBodies[index]);
      chainedTargets++;
      projectileDeathTimer?.timer.reset();
    }
  }

  @override
  void sensorContact(HealthFunctionality other) {
    homingCheck(other);
    super.sensorContact(other);
  }

  void home(HealthFunctionality other, double dt) {
    Vector2? closetPosition;

    closetPosition = other.center;

    final delta = (closetPosition - body.worldCenter).normalized();
    final impulse = (delta * weaponAncestor.projectileVelocity.parameter) *
        dt *
        .000005 *
        target!.center.distanceTo(center).clamp(.5, 3);
    body.applyForce(impulse);

    if (other.isDead) setTarget(null);
  }

  void homingCheck(HealthFunctionality other) {
    if (weaponAncestor.weaponCanHome && !homingComplete) {
      setTarget(other);

      homingComplete = true;
    }
  }
}

mixin LaserProjectile on Projectile {
  int enemiesHit = 0;
  List<Vector2> lineThroughEnemies = [];
  List<Vector2> boxThroughEnemies = [];
  late Shape laserShape;

  @override
  Body createBody() {
    debugMode = false;
    renderBody = true;

    laserShape = ChainShape()..createLoop(boxThroughEnemies);

    final bulletFilter = Filter();
    if (weaponAncestor.entityAncestor is Enemy) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = attackCategory;
    } else if (weaponAncestor.entityAncestor is Player) {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = attackCategory;
    }
    final fixtureDef = FixtureDef(laserShape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: true,
        filter: bulletFilter);
    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      // linearVelocity: delta * rng.nextDouble() * 2,
      type: BodyType.dynamic,
      bullet: false,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    return returnBody;
  }

  bool infrontWeaponCheck(Body element) {
    return element.userData is Enemy &&
        !(element.userData as Enemy).isDead &&
        isEntityInfrontOfHandAngle(element.position, originPosition, delta);
  }

  double precisionPerDistance = .5;

  Vector2 previousDelta = Vector2.zero();
  bool startChaining = false;

  abstract final double baseWidth;
  late double width;

  void homingAndChainCalculations() {
    double distance = weaponAncestor.projectileVelocity.parameter;

    List<Body> bodies = game.world.bodies
        .where((element) => infrontWeaponCheck(element))
        .toList();

    homingComplete = !weaponAncestor.weaponCanHome;

    bodies.sort(
      (a, b) => a.position
          .distanceTo(originPosition)
          .compareTo(b.position.distanceTo(originPosition)),
    );

    var amountOfPoints = precisionPerDistance * distance;

    amountOfPoints = amountOfPoints.clamp(3, 200);

    final pointStep = distance / amountOfPoints;

    amountOfPoints = (amountOfPoints * .666) + amountOfPoints * .333;

    startChaining =
        weaponAncestor.weaponCanHome && weaponAncestor.weaponCanChain;

    for (var i = 0; i < amountOfPoints; i++) {
      Body? bodyToJumpTo;
      Vector2 newPointPosition;
      bool shouldChain =
          chainedTargets < weaponAncestor.maxChainingTargets.parameter &&
              startChaining;

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

      if (weaponAncestor.weaponCanChain && !startChaining) {
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

    width = (power * baseWidth * .4) + baseWidth * .15;
    lineThroughEnemies.add(previousDelta);

    if (weaponAncestor.weaponCanHome || weaponAncestor.weaponCanChain) {
      homingAndChainCalculations();
    } else {
      double distance = weaponAncestor.projectileVelocity.parameter;
      distance = (distance * .1 * power) + distance * .333;
      lineThroughEnemies.add(((delta * distance * .333) + previousDelta));
      lineThroughEnemies.add(((delta * distance * .666) + previousDelta));
      lineThroughEnemies.add(((delta * distance) + previousDelta));
    }

    boxThroughEnemies =
        expandToBox(lineThroughEnemies, width / 2).toSet().toList();
    boxThroughEnemies = validateChainDistances(boxThroughEnemies);
    return super.onLoad();
  }

  double timePassed = 0;

  @override
  double get opacity => (1 - ((timePassed - fadeOutDuration) / fadeOutDuration))
      .clamp(0, 1)
      .toDouble();

  @override
  void update(double dt) {
    timePassed += dt;
    super.update(dt);
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

    canvas.drawPath(
        path, paint..color = Colors.lightBlue.shade100.withOpacity(opacity));
    canvas.drawPath(
        path,
        paint
          ..strokeWidth = width * .6
          ..color = Colors.lightBlue.shade300.withOpacity(opacity));
  }
}
