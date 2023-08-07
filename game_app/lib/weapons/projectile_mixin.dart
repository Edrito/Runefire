import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/attributes/child_entities.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/projectile_class.dart';

import '../enemies/enemy.dart';
import '../entities/player.dart';
import '../main.dart';
import '../resources/constants/physics_filter.dart';
import '../resources/enums.dart';
import '../resources/functions/vector_functions.dart';

mixin CanvasTrail on StandardProjectile {
  late int trailCount;
  late int skip;
  List<Vector2> trails = [];

  @override
  Future<void> onLoad() {
    trailCount = 20;
    skip = 2;
    add(CircleComponent(
        radius: size / 2,
        anchor: Anchor.center,
        paint: Paint()..color = Colors.blue.shade900.withOpacity(.4)));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    manageTrail();
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    drawBullet(canvas);
    super.render(canvas);
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

  void drawBullet(Canvas canvas) {
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

    canvas.drawPath(path, linePaint);
  }
}

mixin StandardProjectile on Projectile {
  int enemiesHit = 0;
  abstract double embedIntoEnemyChance;

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
    shape.radius = size * .45;
  }

  @override
  Body createBody() {
    createBodyShape();

    renderBody = false;

    final bulletFilter = Filter();
    if (!weaponAncestor.entityAncestor!.isPlayer) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = attackCategory;
      if (weaponAncestor.entityAncestor!.affectsAllEntities) {
        bulletFilter.maskBits = 0xFFFF;
      }
    } else {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = attackCategory;
    }

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0,
        isSensor: true,
        filter: bulletFilter);
    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.dynamic,
      linearDamping: (5 - (5 * power)).clamp(0, 5),
      bullet: true,
      linearVelocity: (delta * weaponAncestor.projectileVelocity.parameter),
      fixedRotation: true,
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

    return super.onLoad();
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
    } else if (body.linearVelocity.isZero()) {
      body.applyLinearImpulse(
        (Vector2.random() * 2) -
            Vector2.all(1) * weaponAncestor.projectileVelocity.parameter,
      );
    }
    super.update(dt);
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
    final impulse = (delta * weaponAncestor.projectileVelocity.parameter);

    body.applyLinearImpulse(impulse);

    if (other.isDead) setTarget(null);
  }

  void homingCheck(HealthFunctionality other) {
    if (weaponAncestor.weaponCanHome &&
        !homingComplete &&
        !hitIds.contains(other.entityId)) {
      setTarget(other);
      homedTargets++;
      if (homedTargets > weaponAncestor.maxHomingTargets.parameter) {
        homingComplete = true;
      }
    }
  }
}

mixin LaserProjectile on Projectile {
  int enemiesHit = 0;
  List<Vector2> lineThroughEnemies = [];
  List<Vector2> boxThroughEnemies = [];
  late Shape laserShape;
  double precisionPerDistance = .5;

  bool startChaining = false;
  double timePassed = 0;
  abstract final double baseWidth;
  late double width;

  Color get backColor => damageType.color.brighten(.6);
  Color get frontColor => damageType.color;

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
    } else if (weaponAncestor.entityAncestor is Player ||
        weaponAncestor.entityAncestor is ChildEntity) {
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
      type: BodyType.dynamic,
      bullet: false,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    return returnBody;
  }

  bool infrontWeaponCheck(Body element) {
    if (weaponAncestor.entityAncestor!.isPlayer) {
      return element.userData is Enemy &&
          !(element.userData as Enemy).isDead &&
          isEntityInfrontOfHandAngle(element.position, originPosition, delta);
    } else {
      return element.userData is Player &&
          !(element.userData as Player).isDead &&
          isEntityInfrontOfHandAngle(element.position, originPosition, delta);
    }
  }

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

    amountOfPoints = (amountOfPoints * .666) + (amountOfPoints * .333);

    startChaining =
        weaponAncestor.weaponCanHome && weaponAncestor.weaponCanChain;

    Vector2 previousStep = Vector2.zero();

    for (var i = 0; i < amountOfPoints; i++) {
      Body? bodyToJumpTo;

      Vector2 newPointPosition = ((delta * pointStep) + previousStep);

      if (weaponAncestor.weaponCanChain && !startChaining) {
        for (var element in bodies) {
          if ((element.position).distanceTo(newPointPosition + originPosition) <
              closeBodySensorRadius) {
            startChaining = true;
            break;
          }
        }
      }

      previousStep = newPointPosition.clone();

      bool shouldChain =
          chainedTargets < weaponAncestor.maxChainingTargets.parameter &&
              startChaining;

      //if should be bouncing, bounce
      if (!homingComplete || shouldChain) {
        for (var element in bodies) {
          if ((element.position).distanceTo(newPointPosition + originPosition) <
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
        homedTargets++;
        homingComplete = true;
      }

      lineThroughEnemies.add(newPointPosition);
      // previousDelta = newPointPosition.clone();
    }
  }

  @override
  Future<void> onLoad() async {
    width = (power * baseWidth * .4) + baseWidth * .15;
    lineThroughEnemies.add(previousDelta);

    if (weaponAncestor.weaponCanHome || weaponAncestor.weaponCanChain) {
      homingAndChainCalculations();
    }

    lineThroughEnemies = [...lineThroughEnemies.toSet().toList()];
    if (lineThroughEnemies.length < 3) {
      if (lineThroughEnemies.length == 2) {
        lineThroughEnemies.removeLast();
      }
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

  @override
  double get opacity => Curves.easeInCirc.transform(
      (1 - ((timePassed - fadeOutDuration) / fadeOutDuration))
          .clamp(0, 1)
          .toDouble());

  @override
  void update(double dt) {
    timePassed += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    var path = Path();
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
          ..color = backColor.withOpacity(opacity));
    canvas.drawPath(
        path,
        paint
          ..strokeWidth = width * .6 * opacity
          ..color = frontColor.withOpacity(opacity));
  }
}
