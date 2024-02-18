import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/vector_functions.dart';

mixin PaintProjectile on StandardProjectile {
  int amountSkipped = 999;
  late Paint bulletBackPaint;
  late Paint bulletPaint;
  late Paint glowPaint;
  late Color projectileColor;
  late int skip;
  late int trailCount;
  List<Vector2> trails = [];

  Vector2? previousTrailPoint;

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
    // print(opacity);
    canvas.drawRect(
      Rect.fromCircle(center: Offset.zero, radius: size * opacity),
      glowPaint,
    );
    canvas.drawRect(
      Rect.fromCircle(center: Offset.zero, radius: size * .5 * opacity),
      bulletBackPaint,
    );

    canvas.drawRect(
      Rect.fromCircle(center: Offset.zero, radius: size * .4 * opacity),
      bulletPaint,
    );

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
      Offset.zero,
      size * .75,
      [bulletBackPaint.color.withOpacity(.5), Colors.transparent],
    );

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    drawBullet(canvas);
  }

  @override
  void update(double dt) {
    manageTrail();
    super.update(dt);
  }
}

mixin StandardProjectile on Projectile {
  late Future beginHoming;
  double defaultLinearDamping = 0;
  int enemiesHit = 0;
  bool futureComplete = false;
  bool homingStopped = false;
  Vector2 impulse = Vector2.zero();
  bool isReverseHoming = false;
  late Shape shape;
  bool targetSet = false;

  HealthFunctionality? target;

  void chain(HealthFunctionality other) {
    if (enableChaining && !projectileHasExpired && !chainingComplete) {
      closeSensorBodies.sort((a, b) => rng.nextInt(2));

      final index = closeSensorBodies.indexWhere(
        (element) => !hitIds.contains(element.entityId) && !element.isDead,
      );

      if (index == -1) {
        setTarget(null);
        return;
      }
      setTarget(closeSensorBodies[index], true);
      chainedTargets++;
      durationPassed = 0;
    }
  }

  void createBodyShape() {
    shape = CircleShape();
    shape.radius = size * .45;
  }

  void home(HealthFunctionality other, double dt) {
    Vector2? closetPosition;

    closetPosition = other.center;

    // setDelta((closetPosition - body.worldCenter).normalized());
    setDelta(
      (body.worldCenter.clone()..moveToTarget(closetPosition, 2)) -
          body.worldCenter,
    );

    final distance = (other.center.distanceTo(center)) - .5;
    body.linearDamping = 6 - distance.clamp(0, 6);
    impulse.setFrom(
      delta *
          projectileVelocity *
          projectileHomingSpeedIncrease *
          (isReverseHoming ? -1 : 1),
    );

    body.applyForce(impulse);

    if (other.isDead) {
      homingStopped = true;
      setTarget(null);
    }
  }

  void homingCheck(HealthFunctionality other) {
    if (enableHoming &&
        !other.isDead &&
        (!homingComplete || isReverseHoming) &&
        !hitIds.contains(other.entityId)) {
      setTarget(other);
      homedTargets++;
      if (homingComplete) {
        homingStopped = true;
      }
    }
  }

  void incrementHits() {
    enemiesHit++;
    projectileHasExpired = enemiesHit > weaponAncestor.pierceParameter;
  }

  void setTarget(HealthFunctionality? target, [bool isChain = false]) {
    var instantHome = true;
    instantHome = isChain;
    targetSet = true;

    this.target = target;

    if (target == null) {
      body.linearDamping = defaultLinearDamping;
    }

    if (target != null && instantHome) {
      body.linearVelocity = (target.center - body.worldCenter).normalized();
    } else if (homingStopped) {
      body.applyLinearImpulse(
        ((Vector2.random() * 2) - Vector2.all(1)) * projectileVelocity,
      );
      homingStopped = false;
    }
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

    final fixtureDef = FixtureDef(
      shape,
      userData: {'type': FixtureType.body, 'object': this},
      isSensor: true,
      filter: bulletFilter,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.dynamic,
      linearDamping: defaultLinearDamping + (3 - (3 * power)).clamp(0, 3),
      bullet: true,
      allowSleep: false,
      linearVelocity: delta * projectileVelocity,
      fixedRotation: true,
    );
    Body returnBody;

    returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    return returnBody;
  }

  @override
  Future<void> killBullet([bool withEffect = false]) async {
    // if (!world.physicsWorld.isLocked) {
    //   body.setType(BodyType.static);
    // }
    callBulletKillFunctions();
    if (withEffect) {
      if (this is ProjectileSpriteLifecycle) {
        await (this as ProjectileSpriteLifecycle)
            .animationComponent
            ?.triggerEnding();
      } else if (this is FadeOutBullet) {
        await Future.delayed(
          (this as FadeOutBullet).fadeOutDuration.seconds,
        );
      }

      removeFromParent();
    } else {
      removeFromParent();
    }
  }

  @override
  Future<void> onLoad() {
    // gameState.playAudio('sfx/projectiles/laser_sound_1.mp3');
    isReverseHoming = weaponAncestor.reverseHoming.parameter;
    enableHoming = weaponAncestor.weaponCanHome || isReverseHoming;
    enableChaining = weaponAncestor.weaponCanChain;

    if (enableHoming || enableChaining) {
      beginHoming =
          Future.delayed(.1.seconds).then((value) => futureComplete = true);
    }

    return super.onLoad();
  }

  @override
  void sensorContact(HealthFunctionality other) {
    homingCheck(other);
    super.sensorContact(other);
  }

  @override
  void update(double dt) {
    if (target != null && futureComplete) {
      home(target!, dt);
    }
    super.update(dt);
  }
}

mixin LaserProjectile on FadeOutBullet {
  List<(Vector2, Vector2)> linePairs = [];
  bool allowChainingOrHoming = true;
  late Paint backGlowPaint;
  late Paint backPaint;
  List<Set<Vector2>> boxes = [];
  int enemiesHit = 0;
  bool followWeapon = false;
  late Paint frontPaint;
  Vector2 initDelta = Vector2.zero();
  double initHandJointRad = 0;
  int laserSteps = 0;
  double lightningChangeInterval = .025;
  double lightningChangeIntervalElapsed = 0;
  bool lightningEffect = false;
  late List<Vector2> lightningEffectVectors = generateLightning(
    getLines,
    amplitude: .9,
    frequency: 1,
    currentAngle: weaponAncestor.entityAncestor!.handJoint.angle,
  );

  double precisionPerDistance = .5;
  Map<int, String> preferredPathIds = {};
  bool rememberTargets = true;
  Set<Fixture> savedFixtures = {};
  bool startChaining = false;
  late double width;

  Color get brightColor => damageType.color.brighten(.7);
  Color get color => damageType.color;
  Set<Vector2> get getLines => linePairs.fold<Set<Vector2>>(
        {},
        (previousValue, element) => {...previousValue, element.$1, element.$2},
      );

  double get handJointDifference =>
      weaponAncestor.entityAncestor!.handJoint.angle - initHandJointRad;

  FixtureDef buildFixture(Set<Vector2> element) {
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

    return FixtureDef(
      PolygonShape()..set(element.toList()),
      userData: {'type': FixtureType.body, 'object': this},
      isSensor: true,
      filter: bulletFilter,
    );
  }

  void convertLine(List<Vector2> lineThroughEnemies) {
    //todo build off off the line pairs

    linePairs = [...separateIntoAnglePairs(lineThroughEnemies)];
    boxes = [...turnPairsIntoBoxes(linePairs, width)];
  }

  void createLaserPath() {
    final lineThroughEnemies = <Vector2>[];
    lineThroughEnemies.add(Vector2.zero());
    originPosition = weaponAncestor
        .generateGlobalPosition(weaponAncestor.sourceAttackLocation!);

    if (isMounted) {
      body.setTransform(originPosition, angle);
      setDelta(
        rotateVector2(initDelta.normalized(), handJointDifference).normalized(),
      );
    }

    generateLine(lineThroughEnemies);

    convertLine(lineThroughEnemies.toList());

    if (!isMounted) {
      return;
    }
    var goodBoxes = 0;

    while (true) {
      if (boxes.length <= goodBoxes) {
        break;
      }
      if (isBoxValid(boxes[goodBoxes])) {
        goodBoxes++;
      } else {
        boxes.remove(boxes[goodBoxes]);
      }
    }

    for (var i = 0; i < max(boxes.length, savedFixtures.length); i++) {
      if (i >= boxes.length && i >= savedFixtures.length) {
        break;
      }

      if (i < boxes.length) {
        if (i < savedFixtures.length) {
          (savedFixtures.elementAt(i).shape as PolygonShape).set(
            boxes[i].toList(),
          );
        } else {
          savedFixtures.add(body.createFixture(buildFixture(boxes[i])));
        }
      } else {
        body.destroyFixture(savedFixtures.elementAt(i));
        savedFixtures.remove(savedFixtures.elementAt(i));
        continue;
      }
    }
  }

  void generateLine(List<Vector2> lineThroughEnemies) {
    enableHoming = targetsToHome != 0;
    enableChaining = targetsToChain != 0;
    laserSteps = 1 + targetsToChain + targetsToHome;

    if ((enableHoming || enableChaining) && allowChainingOrHoming) {
      homingAndChainCalculations(lineThroughEnemies);
    }

    if (lineThroughEnemies.length < 2) {
      var distance = projectileVelocity;
      distance = distance * power;
      lineThroughEnemies.add(delta * distance);
    }
  }

  void homingAndChainCalculations(List<Vector2> lineThroughEnemies) {
    final maxDistance = projectileVelocity;

    laserSteps = laserSteps.clamp(2, 30);

    final pointStep = maxDistance / laserSteps;

    startChaining = targetsToChain != 0;

    var previousStep = Vector2.zero();
    var tempStep = Vector2.zero();
    // print(laserSteps);

    final bodies = <Entity>[
      ...world.physicsWorld.bodies
          .where(infrontWeaponCheck)
          .map((e) => e.userData! as Entity),
    ];

    for (var i = 0; i < laserSteps; i++) {
      Entity? bodyToJumpTo;
      homedTargets = 0;
      chainedTargets = 0;
      final preferredPathId = preferredPathIds[i];

      var newPointPosition = (delta * pointStep) + previousStep;

      //if should be bouncing, bounce
      if (!homingComplete || !chainingComplete) {
        for (var j = 0; j < laserCheckPointsFrequency; j++) {
          tempStep = previousStep +
              (newPointPosition - previousStep) *
                  (j / laserCheckPointsFrequency);

          final closeBodies = bodies
              .where(
                (element) =>
                    element.center.distanceTo(tempStep + originPosition) <
                    (closeBodiesSensorRadius + (element.spriteHeight / 4)),
              )
              .toList();

          if (closeBodies.isNotEmpty) {
            if (rememberTargets &&
                closeBodies
                    .any((element) => element.entityId == preferredPathId)) {
              bodyToJumpTo = closeBodies
                  .firstWhere((element) => element.entityId == preferredPathId);
              break;
            }

            bodyToJumpTo = closeBodies.random();
            break;
          }
        }
      }

      //if close body detected, jump to it
      if (bodyToJumpTo != null) {
        if (rememberTargets) {
          preferredPathIds[i] = bodyToJumpTo.entityId;
        }
        newPointPosition = bodyToJumpTo.position - originPosition;
        setDelta((newPointPosition - previousStep).normalized());
        bodies.remove(bodyToJumpTo);

        if (!homingComplete) {
          homedTargets++;
        } else if (!chainingComplete) {
          chainedTargets++;
        }
      }
      previousStep = newPointPosition.clone();
      lineThroughEnemies.add(newPointPosition);
    }
    // print(lineThroughEnemies);
  }

  bool infrontWeaponCheck(Body element) {
    if (weaponAncestor.entityAncestor!.isPlayer) {
      return element.userData is Enemy &&
          !(element.userData! as Enemy).isDead &&
          isEntityInfrontOfHandAngle(
            element.position,
            !isMounted ? originPosition : center,
            delta,
          );
    } else {
      return element.userData is Player &&
          !(element.userData! as Player).isDead &&
          isEntityInfrontOfHandAngle(
            element.position,
            !isMounted ? originPosition : center,
            delta,
          );
    }
  }

  bool isBoxValid(Set<Vector2> box) {
    if (box.length < 4) {
      return false;
    }
    for (var i = 0; i < box.length; i++) {
      for (var j = 0; j < box.length; j++) {
        if (i == j) {
          continue;
        }
        if (box.elementAt(i).distanceToSquared(box.elementAt(j)) <
            0.5 * 0.005) {
          return false;
        }
      }
    }

    return true;
  }

  @override
  Body createBody() {
    // debugMode = false;
    renderBody = false;

    // assert(!allowChainingOrHoming || !followWeapon);

    final fixtures = <FixtureDef>[];

    for (final element in boxes) {
      if (isBoxValid(element)) {
        fixtures.add(buildFixture(element));
      }
    }

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      allowSleep: false,
    );

    final returnBody = world.createBody(bodyDef);

    for (final element in fixtures) {
      savedFixtures.add(returnBody.createFixture(element));
    }

    return returnBody;
  }

  @override
  Future<void> onLoad() async {
    width = (power * size * .4) + size * .15;
    initDelta = delta.clone();
    initHandJointRad = weaponAncestor.entityAncestor!.handJoint.angle;
    createLaserPath();

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
      width: width * .85,
      opacity: opacity,
    )..strokeWidth = width * .85;

    // backGlowPaint = colorPalette.buildProjectile(
    //     color: color,
    //     projectileType: projectileType,
    //     lighten: false,
    //     width: width,
    //     opacity: opacity,
    //     // maskFilter: const MaskFilter.blur(BlurStyle.outer, .1),
    //     filterQuality: FilterQuality.low)
    //   ..strokeWidth = width;

    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {
    final path = Path();
    path.moveTo(linePairs.first.$1.x, linePairs.first.$1.y);
    if (lightningEffect) {
      for (final element in lightningEffectVectors) {
        path.lineTo(element.x, element.y);
      }
    } else {
      // final curveReadyList = generateBezierPoints(getLines.toList(), .45);
      // final curveReadyList2 = generateCurvePoints(getLines, .4);
      final curveReadyList = generateCurvePoints(getLines, .4);

      var skip = false;
      var flip = false;
      var firstCondition = false;
      var secondCondition = false;
      var isEnd = false;
      const isConic = true;
      Vector2 target;

      // for (var element in curveReadyList2) {
      //   canvas.drawCircle(element.toOffset(), .1, backPaint);
      // }

      for (var i = 0; i < curveReadyList.length; i++) {
        target = curveReadyList.elementAt(i);

        if (isConic) {
          if (skip) {
            skip = false;
            continue;
          }
          isEnd = i == curveReadyList.length - 1;
          if (flip) {
            firstCondition = i.isOdd;
            secondCondition = i.isEven || i == 1;
          } else {
            firstCondition = i.isEven || i == 1;
            secondCondition = i.isOdd;
          }

          if (firstCondition || isEnd) {
            path.lineTo(target.x, target.y);
          } else if (secondCondition) {
            final next = curveReadyList.elementAt(i + 1);
            if (isConic) {
              path.conicTo(target.x, target.y, next.x, next.y, 1);
            }
            // else {
            // path.quadraticBezierTo(target.x, target.y, next.x, next.y);
            // }
            skip = true;
            flip = !flip;
          }
        }
      }
    }
    // if (opacity != 1) {
    //   canvas.drawPath(path, backPaint..strokeWidth = width * opacity);

    //   // canvas.drawPath(path, backGlowPaint..strokeWidth = width * opacity);

    //   canvas.drawPath(path, frontPaint..strokeWidth = width * .85 * opacity);
    // } else {
    canvas.drawPath(path, backPaint);
    // canvas.drawPath(path, backGlowPaint);

    canvas.drawPath(path, frontPaint);
    // canvas.drawCircle(
    //     getLines.last.toOffset(),
    //     width * 1.3,
    //     Paint()
    //       ..shader = ui.Gradient.radial(getLines.last.toOffset(), width * 2,
    //           [color, Colors.transparent], [0.5, 1])
    //       ..blendMode = BlendMode.plus);
    // }
    super.render(canvas);
  }

  @override
  void update(double dt) {
    createLaserPath();

    if (lightningEffect) {
      if (lightningChangeIntervalElapsed > lightningChangeInterval) {
        lightningEffectVectors = [
          ...generateLightning(
            getLines,
            amplitude: .6,
            frequency: 1,
            currentAngle: weaponAncestor.entityAncestor!.handJoint.angle,
          ),
        ];
        lightningChangeIntervalElapsed = 0;
      } else {
        lightningChangeIntervalElapsed += dt;
      }
    }

    super.update(dt);
  }
}
