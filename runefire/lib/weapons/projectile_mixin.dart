import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../enemies/enemy.dart';
import '../player/player.dart';
import '../main.dart';
import '../resources/constants/physics_filter.dart';
import '../resources/enums.dart';
import '../resources/functions/vector_functions.dart';

mixin PaintProjectile on StandardProjectile, FadeOutProjectile {
  late int trailCount;
  late int skip;
  List<Vector2> trails = [];

  late Color projectileColor;

  late Paint bulletBackPaint;
  late Paint bulletPaint;
  late Paint glowPaint;

  @override
  Future<void> onLoad() {
    trailCount = 20;
    skip = 2;
    projectileColor = damageType.color;

    bulletBackPaint = colorPalette.buildProjectile(
      color: projectileColor,
      projectileType: projectileType,
      lighten: false,
    );
    bulletPaint = colorPalette.buildProjectile(
      color: projectileColor,
      projectileType: projectileType,
      lighten: true,
    );

    glowPaint = bulletBackPaint;
    glowPaint.blendMode = BlendMode.plus;
    glowPaint.shader = ui.Gradient.radial(
        Offset.zero, size * .75, [bulletBackPaint.color, Colors.transparent]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    manageTrail();
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawBullet(canvas);
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
    // final points = (trails.fold<List<Vector2>>([],
    //     (previousValue, element) => [...previousValue, (element - center)]));

    // final lengthShader =
    //     .5 + ((projectileLength * .5) * ((durationPassed * 2).clamp(0, 1)));
    // final gradientShader =
    //     ui.Gradient.linear(Offset.zero, -(delta).toOffset() * lengthShader, [
    //   Colors.blue.darken(.5),
    //   Colors.blue,
    //   Colors.transparent,
    // ], [
    //   0,
    //   .1,
    //   1
    // ]);

    canvas.drawCircle(Offset.zero, size * opacity, glowPaint);
    canvas.drawCircle(Offset.zero, size * .5 * opacity, bulletBackPaint);

    canvas.drawCircle(Offset.zero, size * .4 * opacity, bulletPaint);

    // if (opacity != 1) {
    //   canvas.drawCircle(
    //       Offset.zero,
    //       size,
    //       Paint()
    //         ..blendMode = BlendMode.dstOut
    //         ..color = Colors.black.withOpacity(1 - opacity));
    // }

    // final path = Path();
    // path.moveTo(0, 0);

    // if (points.length % 2 != 0) {
    //   points.add(points.last);
    // }

    // for (var i = 0; i < points.length; i += 2) {
    //   var firstPoint = points[i];
    //   var secondPoint = points[i + 1];
    //   path.quadraticBezierTo(
    //     firstPoint.x,
    //     firstPoint.y,
    //     secondPoint.x,
    //     secondPoint.y,
    //   );
    // }

    // canvas.drawPath(path, bulletPaint);
  }
}

mixin StandardProjectile on Projectile {
  int enemiesHit = 0;

  void incrementHits() {
    enemiesHit++;
    projectileHasExpired = enemiesHit > weaponAncestor.pierce.parameter;
  }

  late Shape shape;

  void createBodyShape() {
    shape = CircleShape();
    shape.radius = size * .45;
  }

  double defaultLinearDamping = 0;

  @override
  Body createBody() {
    createBodyShape();

    renderBody = false;

    final bulletFilter = Filter();
    if (!isPlayer) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = projectileCategory;

      if (weaponAncestor.entityAncestor!.affectsAllEntities) {
        bulletFilter.maskBits = 0xFFFF;
      }
    } else {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = projectileCategory;
    }

    bulletFilter.maskBits += sensorCategory;

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
      linearDamping: defaultLinearDamping + (3 - (3 * power)).clamp(0, 3),
      bullet: true,
      allowSleep: false,
      linearVelocity: (delta * weaponAncestor.projectileVelocity.parameter),
      fixedRotation: true,
    );
    Body returnBody;

    // if (weaponAncestor.weaponCanHome || weaponAncestor.weaponCanChain) {
    //   bulletFilter.categoryBits = sensorCategory;
    // sensorDef = FixtureDef(CircleShape()..radius = closeBodySensorRadius,
    //     userData: {"type": FixtureType.sensor, "object": this},
    //     isSensor: true,
    //     filter: bulletFilter);

    //   returnBody = world.createBody(bodyDef)
    //     ..createFixture(fixtureDef)
    //     ..createFixture(sensorDef!);
    // } else {
    returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    return returnBody;
  }

  @override
  Future<void> onLoad() {
    gameState.playAudio('sfx/projectiles/laser_sound_1.mp3');
    enableHoming = weaponAncestor.weaponCanHome;

    enableChaining = weaponAncestor.weaponCanChain;

    if (enableHoming || enableChaining) {
      beginHoming =
          Future.delayed(.1.seconds).then((value) => futureComplete = true);
    }

    return super.onLoad();
  }

  late Future beginHoming;
  bool futureComplete = false;

  HealthFunctionality? target;
  bool targetSet = false;
  void setTarget(HealthFunctionality? target) {
    bool instantHome = true;
    instantHome = (weaponAncestor).instantHome;
    targetSet = true;

    this.target = target;

    if (target == null) {
      body.linearDamping = defaultLinearDamping;
    }

    if (target != null && instantHome) {
      body.linearVelocity = (target.center - body.worldCenter).normalized();
    } else if (homingStopped) {
      body.applyLinearImpulse(
        ((Vector2.random() * 2) - Vector2.all(1)) *
            weaponAncestor.projectileVelocity.parameter,
      );
      homingStopped = false;
    }
  }

  bool homingStopped = false;

  @override
  void update(double dt) {
    if (target != null && futureComplete) {
      home(target!, dt);
    }
    super.update(dt);
  }

  @override
  void bodyContact(HealthFunctionality other) {
    setTarget(null);
    incrementHits();
    super.bodyContact(other);
    if (projectileHasExpired) {
      killBullet();
    }
    chain(other);
  }

  void chain(HealthFunctionality other) {
    if (enableChaining &&
        !projectileHasExpired &&
        chainedTargets < weaponAncestor.chainingTargets.parameter) {
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

  Vector2 impulse = Vector2.zero();

  @override
  void sensorContact(HealthFunctionality other) {
    homingCheck(other);
    super.sensorContact(other);
  }

  void home(HealthFunctionality other, double dt) {
    Vector2? closetPosition;

    closetPosition = other.center;

    setDelta((closetPosition - body.worldCenter).normalized());
    setDelta(((body.worldCenter.clone()..moveToTarget(closetPosition, 2)) -
        body.worldCenter));

    double distance = (other.center.distanceTo(center)) - .5;
    body.linearDamping = 6 - distance.clamp(0, 6);
    impulse.setFrom(delta *
        weaponAncestor.projectileVelocity.parameter *
        projectileHomingSpeedIncrease);

    body.applyForce(impulse);

    if (other.isDead) {
      homingStopped = true;
      setTarget(null);
    }
  }

  void homingCheck(HealthFunctionality other) {
    if (enableHoming &&
        !other.isDead &&
        !homingComplete &&
        !hitIds.contains(other.entityId)) {
      setTarget(other);
      homedTargets++;
      if (homedTargets > weaponAncestor.maxHomingTargets.parameter) {
        homingComplete = true;
        homingStopped = true;
      }
    }
  }

  @override
  void killBullet([bool withEffect = false]) async {
    // if (!world.physicsWorld.isLocked) {
    //   body.setType(BodyType.static);
    // }
    callBulletKillFunctions();
    if (withEffect) {
      if (this is ProjectileSpriteLifecycle) {
        await (this as ProjectileSpriteLifecycle)
            .animationComponent
            ?.triggerEnding();
      } else if (this is FadeOutProjectile) {
        await Future.delayed(
            (this as FadeOutProjectile).fadeOutDuration.seconds);
      }

      removeFromParent();
    } else {
      removeFromParent();
    }
  }
}

mixin LaserProjectile on FadeOutProjectile {
  int enemiesHit = 0;
  Set<Vector2> lineThroughEnemies = {};
  Set<Vector2> boxThroughEnemies = {};
  late Shape laserShape;
  double precisionPerDistance = .5;

  bool startChaining = false;
  abstract final double baseWidth;
  late double width;

  Color get brightColor => damageType.color.brighten(.7);
  Color get color => damageType.color;

  @override
  Body createBody() {
    debugMode = false;
    renderBody = true;

    laserShape = ChainShape()..createLoop(boxThroughEnemies.toList());

    final bulletFilter = Filter();
    if (weaponAncestor.entityAncestor is Enemy) {
      bulletFilter
        ..maskBits = playerCategory
        ..categoryBits = projectileCategory;
    } else if (weaponAncestor.entityAncestor is Player ||
        weaponAncestor.entityAncestor is ChildEntity) {
      bulletFilter
        ..maskBits = enemyCategory
        ..categoryBits = projectileCategory;
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

    List<Body> bodies = world.physicsWorld.bodies
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
              closeBodiesSensorRadius) {
            startChaining = true;
            break;
          }
        }
      }

      previousStep = newPointPosition.clone();

      bool shouldChain =
          chainedTargets < weaponAncestor.chainingTargets.parameter &&
              startChaining;

      //if should be bouncing, bounce
      if (!homingComplete || shouldChain) {
        for (var element in bodies) {
          if ((element.position).distanceTo(newPointPosition + originPosition) <
              closeBodiesSensorRadius) {
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
    enableHoming = weaponAncestor.weaponCanHome;
    enableChaining = weaponAncestor.weaponCanChain;
    if ((enableHoming || enableChaining)) {
      homingAndChainCalculations();
    }

    if (lineThroughEnemies.length < 3) {
      if (lineThroughEnemies.length == 2) {
        lineThroughEnemies = {lineThroughEnemies.first};
      }
      double distance = weaponAncestor.projectileVelocity.parameter;
      distance = (distance * .1 * power) + distance * .333;
      lineThroughEnemies.add(((delta * distance * .333) + previousDelta));
      lineThroughEnemies.add(((delta * distance * .666) + previousDelta));
      lineThroughEnemies.add(((delta * distance) + previousDelta));
    }

    boxThroughEnemies =
        expandToBox(lineThroughEnemies.toList(), width / 2).toSet();

    boxThroughEnemies =
        validateChainDistances(boxThroughEnemies.toList()).toSet();

    backPaint = colorPalette.buildProjectile(
      color: color,
      projectileType: projectileType,
      lighten: false,
      width: width,
      opacity: opacity,
    )..strokeWidth = width;

    frontPaint = colorPalette.buildProjectile(
      color: color,
      projectileType: projectileType,
      lighten: true,
      width: width * .7,
      opacity: opacity,
    )..strokeWidth = width * .7;
    return super.onLoad();
  }

  late Paint backPaint;
  late Paint frontPaint;

  @override
  void render(Canvas canvas) {
    var path = Path();
    for (var element in lineThroughEnemies) {
      path.lineTo(element.x, element.y);
    }
    if (opacity != 1) {
      canvas.drawPath(path, backPaint..strokeWidth = width * opacity);

      canvas.drawPath(path, frontPaint..strokeWidth = width * .7 * opacity);
    } else {
      canvas.drawPath(path, backPaint);

      canvas.drawPath(path, frontPaint);
    }
  }
}
