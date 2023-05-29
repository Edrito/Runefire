import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/ranged_weapon.dart';

import '../functions/functions.dart';
import 'enemies.dart';

enum ProjectileType { pellet, bullet, arrow }

extension ProjectileTypeExtension on ProjectileType {
  String getFilename() {
    switch (this) {
      case ProjectileType.pellet:
        return 'pellet.png';
      case ProjectileType.bullet:
        return 'bullet.png';
      case ProjectileType.arrow:
        return 'arrow.png';
      default:
        return '';
    }
  }

  Projectile generateProjectile(
      {required Vector2 speedVar,
      required Vector2 originPositionVar,
      required ProjectileWeapon ancestorVar,
      required String idVar}) {
    switch (this) {
      case ProjectileType.pellet:
        return Pellet(
          ancestor: ancestorVar,
          originPosition: originPositionVar,
          speed: speedVar,
          id: idVar,
        );
      case ProjectileType.bullet:
        return Bullet(
          ancestor: ancestorVar,
          originPosition: originPositionVar,
          speed: speedVar,
          id: idVar,
        );
      case ProjectileType.arrow:
        return Arrow(
          ancestor: ancestorVar,
          originPosition: originPositionVar,
          speed: speedVar,
          id: idVar,
        );
      default:
        return Bullet(
          ancestor: ancestorVar,
          originPosition: originPositionVar,
          speed: speedVar,
          id: idVar,
        );
    }
  }
}

class Arrow extends Projectile {
  Arrow(
      {required super.speed,
      required super.originPosition,
      required super.ancestor,
      required super.id});

  @override
  double embedIntoEnemyChance = .9;

  @override
  late Sprite projectileSprite;

  @override
  ProjectileType projectileType = ProjectileType.arrow;

  @override
  double size = 8;

  @override
  Duration ttl = const Duration(seconds: 3);

  @override
  Future<void> onLoad() async {
    projectileSprite = await Sprite.load(projectileType.getFilename());

    return super.onLoad();
  }
}

class Bullet extends Projectile {
  Bullet(
      {required super.speed,
      required super.originPosition,
      required super.ancestor,
      required super.id});

  @override
  double embedIntoEnemyChance = .8;

  @override
  late Sprite projectileSprite;

  @override
  ProjectileType projectileType = ProjectileType.bullet;

  @override
  double size = 1.5;

  @override
  Duration ttl = const Duration(seconds: 1);

  @override
  Future<void> onLoad() async {
    projectileSprite = await Sprite.load(projectileType.getFilename());

    return super.onLoad();
  }
}

class Pellet extends Projectile {
  Pellet(
      {required super.speed,
      required super.originPosition,
      required super.ancestor,
      required super.id});

  @override
  double embedIntoEnemyChance = .7;

  @override
  late Sprite projectileSprite;

  @override
  ProjectileType projectileType = ProjectileType.pellet;

  @override
  double size = 1;

  @override
  Duration ttl = const Duration(seconds: 1);

  @override
  Future<void> onLoad() async {
    projectileSprite = await Sprite.load(projectileType.getFilename());

    return super.onLoad();
  }
}

abstract class Projectile extends BodyComponent<GameplayGame>
    with ContactCallbacks {
  Projectile(
      {required this.speed,
      required this.originPosition,
      required this.ancestor,
      required this.id}) {
    deltaSavedCopy = [...ancestor.deltaListSaved];
  }

  final ProjectileWeapon ancestor;
  late final SpriteComponent spriteComponent;
  late List<Vector2> deltaSavedCopy;
  bool bulletHasExpired = false;
  List<Entity> closeHittingBodies = [];
  abstract double embedIntoEnemyChance;
  int enemiesHit = 0;
  double homingDistance = 50;
  double homingPulseIterationDuration = .05;
  String id;
  bool killBulletTimerStarted = false;
  bool noTargetsImpulseCompleted = true;
  Vector2 originPosition;
  double previousHomingPulse = 0;
  double previousRandomPathPulse = 0;
  abstract Sprite projectileSprite;
  abstract ProjectileType projectileType;
  int randomPatternIteration = 0;
  Random rng = Random();
  late PolygonShape shape;
  abstract double size;
  Vector2 speed;
  abstract Duration ttl;

  Entity? closeHomingBody;
  FixtureDef? sensorDef;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Enemy) return;

    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor &&
        closeHomingBody == null &&
        other.targetsHomingEntity < other.maxTargetsHomingEntity) {
      closeHomingBody = other;
      other.targetsHomingEntity++;
    } else if (!bulletHasExpired && !isHomingSensor) {
      closeHittingBodies.add(other);
    }

    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    shape = PolygonShape();
    shape.set([
      Vector2(-spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, spriteComponent.size.y / 2),
      Vector2(-spriteComponent.size.x / 2, spriteComponent.size.y / 2),
    ]);

    final bulletFilter = Filter();
    bulletFilter.categoryBits = bulletCategory; // Category bit for the bullet
    bulletFilter.maskBits = 0xFFFF - playerCategory - bulletCategory;

    final fixtureDef = FixtureDef(shape,
        userData: this,
        restitution: 0,
        friction: 0,
        density: 0.1,
        isSensor: true,
        filter: bulletFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.dynamic,
      bullet: false,
      // linearDamping: 0,
      // angularDamping: 2,
      linearVelocity: speed,
      fixedRotation: !ancestor.allowProjectileRotation,
    );

    if (ancestor.isHoming) {
      sensorDef = FixtureDef(CircleShape()..radius = homingDistance / 2,
          userData: "homingSensor",
          isSensor: true,
          filter: Filter()
            ..maskBits = enemyCategory
            ..categoryBits = sensorCategory);
      return world.createBody(bodyDef)
        ..createFixture(fixtureDef)
        ..createFixture(sensorDef!);
    } else {
      return world.createBody(bodyDef)..createFixture(fixtureDef);
    }
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is! Enemy) return;
    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor && other == closeHomingBody) {
      closeHomingBody = null;
      other.targetsHomingEntity--;
    } else {
      closeHittingBodies.remove(other);
    }

    super.endContact(other, contact);
  }

  // final double pulseStrength = 80;

  @override
  Future<void> onLoad() async {
    Future.delayed(ttl).then((value) => killBullet());

    final rng = Random();

    spriteComponent = SpriteComponent(
        sprite: projectileSprite,
        priority: -rng.nextInt(20),
        angle: -radiansBetweenPoints(Vector2(0, 0.0001), speed),
        size:
            projectileSprite.srcSize.scaled(size / projectileSprite.srcSize.y),
        anchor: Anchor.center);

    add(spriteComponent);
    return super.onLoad();
  }

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    contact.setEnabled(bulletHasExpired);
    if (bulletHasExpired) {
      killBullet();
    }

    super.preSolve(other, contact, oldManifold);
  }

  @override
  void render(Canvas canvas) {}

  Vector2 previousPatternForce = Vector2.zero();

  @override
  void update(double dt) {
    if (ancestor.allowProjectileRotation) {
      spriteComponent.angle =
          -radiansBetweenPoints(Vector2(0, 0.0001), body.linearVelocity);
    }

    if (deltaSavedCopy.isNotEmpty) {
      if (randomPatternIteration < deltaSavedCopy.length &&
          previousRandomPathPulse > getIterationTime) {
        previousPatternForce = deltaSavedCopy[randomPatternIteration];
        randomPatternIteration++;
        previousRandomPathPulse = 0;
      }
      if (randomPatternIteration < deltaSavedCopy.length) {
        body.applyForce(previousPatternForce);
      }
      previousRandomPathPulse += dt;
    }

    if (ancestor.isHoming) {
      Vector2? closetPosition;
      // double smallestDistance = double.infinity;
      // for (var element in closeHomingBodies) {
      //   if (element.isDead) continue;
      //   closetPosition ??= element.body.worldCenter;

      //   final newDistance =
      //       body.worldCenter.distanceTo(element.body.worldCenter);
      //   if (newDistance < smallestDistance) {
      //     smallestDistance = newDistance;
      //     closetPosition = element.body.worldCenter;
      //   }
      // }

      if (closeHomingBody == null) {
        if (noTargetsImpulseCompleted) return;
        closetPosition = Vector2.random() * 2;
        closetPosition -= Vector2.all(1);
        body.applyForce(closetPosition * ancestor.projectileVelocity * size);
        noTargetsImpulseCompleted = true;
      } else {
        closetPosition = closeHomingBody!.body.worldCenter;

        // print(distance);
        final test = (closetPosition - body.worldCenter).normalized();
        body.applyForce(
            (test * ancestor.projectileVelocity * size) / (dt * 40));
        noTargetsImpulseCompleted = false;
      }
      previousHomingPulse = 0;
    } else {
      previousHomingPulse += dt;
    }

    if (!bulletHasExpired) {
      for (var element in closeHittingBodies) {
        if (element.takeDamage(id, ancestor.damage)) {
          enemiesHit++;
          bulletHasExpired = enemiesHit > ancestor.pierce;
          if (bulletHasExpired) {
            killBullet();
            break;
          }
        }
      }
    }

    super.update(dt);
  }

  int get getIterationTime => (ttl.inSeconds / deltaSavedCopy.length).round();

  void killBullet() async {
    // if (killBulletTimerStarted) return;
    // killBulletTimerStarted = true;
    // spriteComponent.add(
    //     OpacityEffect.fadeOut(EffectController(duration: .2), onComplete: () {
    removeFromParent();
    // }));
  }
}
