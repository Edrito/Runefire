import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/player.dart';

void fireBullet(Player classRef, Vector2 speed, Vector2 origin) {
  classRef.parent?.add(Bullet(speed, origin));
}

class Gun extends SpriteComponent
    with HasGameRef<GameplayGame>, HasAncestor<Player> {
  Gun();

  final distanceFromPlayer = 3.0;

  late PositionComponent tipOfGun;

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('gun.png');
    size = sprite!.srcSize / 40;
    anchor = Anchor.topCenter;
    tipOfGun = PositionComponent(
        size: Vector2.zero(), position: Vector2(size.x / 2, size.y));

    tipOfGun.add(CircleComponent(radius: .5)..anchor = Anchor.center);
    add(tipOfGun);
    priority = 10;

    // angle = radians(180);
    return super.onLoad();
  }

  final double fireRate = 20;
  double timeSinceLastFire = 0;

  void shoot(Player classRef, double dt) {
    final fireRateConverted = 1 / fireRate;
    if (classRef.shooting && timeSinceLastFire >= fireRateConverted) {
      game.add(Bullet(
          (tipOfGun.absolutePosition -
                  classRef.handParentAnglePosition.absolutePosition) *
              15,
          tipOfGun.absolutePosition + classRef.body.position));
      timeSinceLastFire = 0;
    } else if (timeSinceLastFire < fireRateConverted) {
      timeSinceLastFire += dt;
    }
  }
}

class Bullet extends BodyComponent with ContactCallbacks {
  late PolygonShape shape;

  Bullet(this.speed, this.originPos);
  Duration ttl = const Duration(milliseconds: 1000);
  Vector2 speed;
  Vector2 originPos;

  @override
  Future<void> onLoad() {
    Future.delayed(ttl).then((value) => parent?.remove(this));

    return super.onLoad();
  }

  @override
  Body createBody() {
    shape = PolygonShape();
    shape.set([
      Vector2(0, 1),
      Vector2(1, 1),
      Vector2(1, 0),
      Vector2(0, 0),
    ]);
    final filter = Filter();
    filter.categoryBits = 0x0001;
    filter.maskBits = 0x0000;
    final fixtureDef = FixtureDef(shape,
        restitution: 0, friction: 0, density: 0.01, filter: filter);
    final bodyDef = BodyDef(
      userData: this,
      position: originPos - Vector2.all(.25),
      type: BodyType.dynamic,
      bullet: true,
      linearVelocity: speed,
      fixedRotation: true,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
