import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/weapon_class.dart';

import '../functions/vector_functions.dart';
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
      required Weapon ancestorVar,
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
  double ttl = 3.0;

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
  double ttl = 1.0;

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
  double ttl = 1.0;

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
    deltaSavedCopy = [];
  }

  final Weapon ancestor;
  late final SpriteComponent spriteComponent;

  bool bulletHasExpired = false;
  List<Entity> closeHittingBodies = [];
  late List<Vector2> deltaSavedCopy;
  abstract double embedIntoEnemyChance;
  int enemiesHit = 0;
  double homingDistance = 50;
  String id;
  bool noTargetsImpulseCompleted = true;
  Vector2 originPosition;
  Vector2 previousPatternForce = Vector2.zero();
  abstract Sprite projectileSprite;
  abstract ProjectileType projectileType;

  int randomPatternIteration = 0;
  double get getIterationTime => ttl / deltaSavedCopy.length;
  TimerComponent? deltaPathFollowTimer;
  Random rng = Random();
  late PolygonShape shape;
  abstract double size;
  Vector2 speed;
  abstract double ttl;

  Entity? closeHomingBody;
  FixtureDef? sensorDef;
  TimerComponent? bulletDeathTimer;

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
    } else if (!bulletHasExpired && !isHomingSensor && !other.isDead) {
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
      linearVelocity: speed,
      fixedRotation: !ancestor.allowProjectileRotation,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    if (ancestor.isHoming) {
      sensorDef = FixtureDef(CircleShape()..radius = homingDistance / 2,
          userData: "homingSensor",
          isSensor: true,
          filter: Filter()
            ..maskBits = enemyCategory
            ..categoryBits = sensorCategory);

      returnBody.createFixture(sensorDef!);
    }

    return returnBody;
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
    bulletDeathTimer = TimerComponent(
      period: ttl,
      onTick: () {
        killBullet();
      },
    );
    final rng = Random();

    spriteComponent = SpriteComponent(
        sprite: projectileSprite,
        priority: -rng.nextInt(20),
        angle: -radiansBetweenPoints(Vector2(0, 0.0001), speed),
        size:
            projectileSprite.srcSize.scaled(size / projectileSprite.srcSize.y),
        anchor: Anchor.center);

    add(spriteComponent);

    deltaPathFollowTimerSetup();

    return super.onLoad();
  }

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    contact.setEnabled(bulletHasExpired);
    super.preSolve(other, contact, oldManifold);
  }

  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {
    if (!bulletHasExpired && ancestor.parent != null) {
      bulletAngleCalc();
      homingCalc(dt);
      hitEnemies();
      if (!previousPatternForce.isZero()) body.applyForce(previousPatternForce);
    }

    super.update(dt);
  }

  void bulletAngleCalc() {
    if (ancestor.allowProjectileRotation) {
      spriteComponent.angle = -radiansBetweenPoints(Vector2(0, 0.0001),
          body.worldCenter - ancestor.ancestor.body.worldCenter);
    }
  }

  void deltaPathFollowTimerSetup() {
    if (deltaSavedCopy.isNotEmpty) {
      deltaPathFollowTimer = TimerComponent(
        period: getIterationTime,
        repeat: true,
        onTick: () {
          previousPatternForce =
              deltaSavedCopy[randomPatternIteration] - previousPatternForce;
          randomPatternIteration++;
        },
      );
      add(deltaPathFollowTimer!);
    }
  }

  void hitEnemies() {
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

  void homingCalc(double dt) {
    if (ancestor.isHoming) {
      Vector2? closetPosition;

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
    }
  }

  void killBullet() async {
    removeFromParent();
  }
}
