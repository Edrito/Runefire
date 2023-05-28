import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/ranged_weapon.dart';

import '../functions/functions.dart';
import 'enemies.dart';

class Projectile extends BodyComponent<GameplayGame> with ContactCallbacks {
  Projectile(
      {required this.speed,
      required this.originPosition,
      required this.projectileSprite,
      required this.ancestor});

  final ProjectileWeapon ancestor;
  late final SpriteComponent spriteComponent;

  double homingDistance = 50;
  bool bulletHasExpired = false;
  Sprite projectileSprite;
  int enemiesHit = 0;
  Vector2 originPosition;
  late PolygonShape shape;
  Vector2 speed;
  Duration ttl = const Duration(milliseconds: 4000);

  List<Entity> closeBodies = [];

  @override
  void beginContact(Object other, Contact contact) {
    bool isHomingSensor = contact.fixtureA.userData == "homingSensor" ||
        contact.fixtureB.userData == "homingSensor";

    if (isHomingSensor && other is Entity) {
      closeBodies.add(other);
      contact.setEnabled(false);
    } else if (!bulletHasExpired && other is Enemy) {
      enemiesHit++;
      other.hit(hashCode, ancestor.damage);

      bulletHasExpired = enemiesHit > ancestor.pierce;
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    closeBodies.remove(other);

    super.endContact(other, contact);
  }

  FixtureDef? sensorDef;

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
    bulletFilter.maskBits = 0xFFFF - playerCategory;

    final fixtureDef = FixtureDef(shape,
        userData: this,
        restitution: .2,
        friction: 0,
        density: 0.1,
        isSensor: false,
        filter: bulletFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.dynamic,
      bullet: true,
      linearDamping: 0,
      angularDamping: 2,
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
  Future<void> onLoad() async {
    Future.delayed(ttl).then((value) => killBullet());

    final rng = Random();

    spriteComponent = SpriteComponent(
        sprite: projectileSprite,
        priority: -rng.nextInt(20),
        angle: -radiansBetweenPoints(Vector2(0, 0.0001), speed),
        size: projectileSprite.srcSize.scaled(1.5 / projectileSprite.srcSize.y),
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

  int get getIterationTime =>
      (ttl.inSeconds / ancestor.deltaListSaved.length).round();
  double previousPulse = 0;
  int iteration = 0;
  @override
  void update(double dt) {
    if (ancestor.deltaListSaved.isNotEmpty) {
      if (iteration < ancestor.deltaListSaved.length &&
          previousPulse > getIterationTime) {
        body.applyForce(ancestor.deltaListSaved[iteration]);
        iteration++;
        previousPulse = 0;
      }
      previousPulse += dt;
    }
    if (ancestor.isHoming) {
      if (closeBodies.isNotEmpty) {
        Vector2? closetPosition;
        double smallestDistance = double.infinity;
        for (var element in closeBodies) {
          if (element.isDead) continue;
          closetPosition ??= element.body.worldCenter;

          final newDistance =
              body.worldCenter.distanceTo(element.body.worldCenter);
          if (newDistance < smallestDistance) {
            smallestDistance = newDistance;
            closetPosition = element.body.worldCenter;
          }
        }
        if (closetPosition == null) {
          if (noTargetsImpulseCompleted) return;
          closetPosition = Vector2.random() * 2;
          closetPosition -= Vector2.all(1);
          body.applyLinearImpulse(closetPosition * 20);
          noTargetsImpulseCompleted = true;
        } else {
          body.applyLinearImpulse(
              (closetPosition - body.worldCenter).normalized() * 1);
          noTargetsImpulseCompleted = false;
        }
      }
    }

    super.update(dt);
  }

  bool noTargetsImpulseCompleted = true;

  bool killBulletTimerStarted = false;
  void killBullet() async {
    if (killBulletTimerStarted) return;
    killBulletTimerStarted = true;
    spriteComponent.add(
        OpacityEffect.fadeOut(EffectController(duration: .2), onComplete: () {
      removeFromParent();
    }));
  }
}
