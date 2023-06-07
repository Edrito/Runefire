import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/main.dart';

import '../functions/vector_functions.dart';
import '../entities/enemies.dart';
import '../resources/enums.dart';

class Arrow extends Projectile {
  Arrow(
      {required super.speed,
      required super.originPosition,
      required super.id,
      required super.weaponAncestor});

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

class Fireball extends Projectile {
  Fireball(
      {required super.speed,
      required super.originPosition,
      required super.id,
      required super.weaponAncestor});

  @override
  double embedIntoEnemyChance = .8;

  @override
  late Sprite projectileSprite;

  @override
  ProjectileType projectileType = ProjectileType.fireball;

  @override
  double size = 5;

  @override
  double ttl = 1.0;

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
      required super.id,
      required super.weaponAncestor});

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
      required super.id,
      required super.weaponAncestor});

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

abstract class Projectile extends BodyComponent<GameRouter>
    with ContactCallbacks {
  Projectile(
      {required this.speed,
      required this.originPosition,
      required this.id,
      required this.weaponAncestor}) {
    deltaSavedCopy = [];
  }

  late final SpriteComponent spriteComponent;

  bool bulletHasExpired = false;
  Weapon weaponAncestor;
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
    if (other is! Entity) {
      return;
    }

    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor &&
        closeHomingBody == null &&
        other.targetsHomingEntity < other.maxTargetsHomingEntity) {
      closeHomingBody = other;
      other.targetsHomingEntity++;
    } else if (!bulletHasExpired && !isHomingSensor && !other.isDead) {
      closeHittingBodies.add(other);
      other.takeDamage(id, weaponAncestor.damage);
      enemiesHit++;
      bulletHasExpired = enemiesHit > weaponAncestor.pierce;
      if (bulletHasExpired) {
        killBullet();
      }
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
        density: 0.1,
        isSensor: true,
        filter: bulletFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.dynamic,
      bullet: false,
      linearVelocity: speed,
      fixedRotation: !weaponAncestor.allowProjectileRotation,
    );

    var returnBody = world.createBody(bodyDef)..createFixture(fixtureDef);

    if (weaponAncestor.isHoming) {
      bulletFilter.categoryBits = sensorCategory;
      sensorDef = FixtureDef(CircleShape()..radius = homingDistance / 2,
          userData: "homingSensor", isSensor: true, filter: bulletFilter);
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
    add(bulletDeathTimer!);
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
    if (!bulletHasExpired && weaponAncestor.parent != null) {
      bulletAngleCalc();
      homingCalc(dt);
      if (!previousPatternForce.isZero()) body.applyForce(previousPatternForce);
    }

    super.update(dt);
  }

  void bulletAngleCalc() {
    if (weaponAncestor.allowProjectileRotation) {
      spriteComponent.angle =
          -radiansBetweenPoints(Vector2(0, 0.0001), body.linearVelocity);
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

  void homingCalc(double dt) {
    if (weaponAncestor.isHoming) {
      Vector2? closetPosition;

      if (closeHomingBody == null) {
        if (noTargetsImpulseCompleted) return;
        closetPosition = Vector2.random() * 2;
        closetPosition -= Vector2.all(1);
        body.applyForce(
            closetPosition * weaponAncestor.projectileVelocity * size);
        noTargetsImpulseCompleted = true;
      } else {
        closetPosition = closeHomingBody!.body.worldCenter;

        // print(distance);
        final test = (closetPosition - body.worldCenter).normalized();
        body.applyForce(
            (test * weaponAncestor.projectileVelocity * size) / (dt * 40));
        noTargetsImpulseCompleted = false;
      }
    }
  }

  void killBullet() async {
    removeFromParent();
  }
}
