import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/main.dart';
import 'package:game_app/weapons/projectile_class.dart';
// ignore: unused_import
import 'package:flutter/material.dart';
import '../entities/enemy.dart';
import '../entities/entity_mixin.dart';
import '../entities/player.dart';
import '../resources/functions/vector_functions.dart';
import '../resources/enums.dart';
import '../resources/constants/physics_filter.dart';
// ignore: unused_import
import 'dart:ui' as ui;

mixin StandardProjectile on Projectile {
  int enemiesHit = 0;
  abstract double embedIntoEnemyChance;
  late int trailCount;
  late int skip;
  List<Vector2> trails = [];
  double projectileLength = 5;

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
  Future<void> onLoad() {
    gameState.playAudio('sfx/projectiles/laser_sound_1.mp3');
    trailCount = 20;

    skip = 2;

    add(CircleComponent(
        radius: size / 2,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.blue.shade900.withOpacity(.4)));

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    drawBullet(canvas);
    super.render(canvas);
  }

  void drawBullet(Canvas canvas) {
    // print(body.worldCenter -
    //     weaponAncestor.entityAncestor!.handJoint.weaponTip!.absolutePosition);
    // final firstPoint = -(delta).toOffset() * projectileLength;
    // final secondPoint = -(delta - previousDelta).toOffset() * projectileLength;

    final points = (trails.fold<List<Vector2>>([],
        (previousValue, element) => [...previousValue, (element - center)]));

    final lengthShader =
        .5 + ((projectileLength * .5) * ((durationPassed * 2).clamp(0, 1)));
    final gradientShader =
        ui.Gradient.linear(Offset.zero, -(delta).toOffset() * lengthShader, [
      Colors.blue.darken(.5),
      Colors.blue,
      Colors.transparent,
    ], [
      0,
      .1,
      1
    ]);
    final linePaint = Paint()
      ..strokeWidth = size
      ..blendMode = BlendMode.plus
      ..style = PaintingStyle.stroke
      ..filterQuality = FilterQuality.none
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.bevel
      ..maskFilter = const MaskFilter.blur(BlurStyle.solid, .04)
      ..shader = gradientShader;
    final path = Path();
    path.moveTo(0, 0);

    if (points.length % 2 != 0) {
      points.add(points.last);
    }

    for (var i = 0; i < points.length; i += 2) {
      var firstPoint = points[i];
      var secondPoint = points[i + 1];
      path.quadraticBezierTo(
        firstPoint.x,
        firstPoint.y,
        secondPoint.x,
        secondPoint.y,
      );
    }
    // path.quadraticBezierTo(
    //     firstPoint.dx, firstPoint.dy, secondPoint.dx, secondPoint.dy);

    canvas.drawPath(path, linePaint);

    // canvas.drawLine(Offset.zero, firstPoint, linePaint);

    // canvas.drawLine(firstPoint, secondPoint, linePaint);
    // canvas.drawPoints(
    //     PointMode.points,
    //     trails.fold(
    //         [],
    //         (previousValue, element) =>
    //             [...previousValue, (element - center).toOffset()]),
    //     linePaint);
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
    manageTrail();
    super.update(dt);
  }

  int amountSkipped = 999;
  Vector2? previousTrailPoint;
  void manageTrail() {
    if (amountSkipped < skip) {
      amountSkipped++;
      return;
    }
    amountSkipped = 0;
    if (previousTrailPoint == null) {
      previousTrailPoint = center.clone();
      return;
    }
    trails.insert(0, previousTrailPoint!);
    trails.insert(0, center.clone());
    if (trails.length > trailCount) {
      trails.removeLast();
      trails.removeLast();
    }
    previousTrailPoint = null;
  }

  @override
  void bodyContact(HealthFunctionality other) {
    setTarget(null);
    incrementHits();
    super.bodyContact(other);
    chain(other);
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

    setDelta((closetPosition - body.worldCenter).normalized());
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
        setDelta((bodyToJumpTo.position - originPosition - previousDelta)
            .normalized());
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
      // previousDelta = newPointPosition.clone();
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
    paint.strokeCap = StrokeCap.butt;

    for (var element in lineThroughEnemies) {
      path.lineTo(element.x, element.y);
    }

    canvas.drawPath(
        path,
        paint
          ..strokeWidth = width * opacity
          ..color = Colors.lightBlue.shade100.withOpacity(opacity));
    canvas.drawPath(
        path,
        paint
          ..strokeWidth = width * .6 * opacity
          ..color = Colors.lightBlue.shade300.withOpacity(opacity));
  }
}
