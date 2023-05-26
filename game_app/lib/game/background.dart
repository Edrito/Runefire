import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_app/game/player.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'games.dart';

class BackgroundComponent extends SpriteComponent {
  late final ParallaxComponent<FlameGame> background;
  late final GameLevel gameLevel;
  late final Player _player;

  BackgroundComponent(this._player, this.gameLevel);

  Vector2? lastPlayerPosition;

  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('rock_background.jpg');
    size = size / 10;
    anchor = Anchor.center;
    return super.onLoad();
  }
}

class Ball extends BodyComponent {
  Ball(this.position);
  Vector2 position;

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 5;

    final bodyRef =
        BodyDef(type: BodyType.dynamic, userData: this, position: position);
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0.5,
      density: 0.2,
    );
    return world.createBody(bodyRef)..createFixture(fixtureDef);
  }
}

class Wall extends BodyComponent {
  Wall(this.pos1, this.pos2);
  Vector2 pos1;
  Vector2 pos2;

  @override
  Body createBody() {
    final shape = EdgeShape();
    shape.set(pos1, pos2);

    final bodyRef = BodyDef(
        type: BodyType.static,
        userData: this,
        position: (parent as GameplayGame).size / 2);
    final fixtureDef = FixtureDef(
      shape,
      restitution: 0,
      density: 100,
    );
    return world.createBody(bodyRef)..createFixture(fixtureDef);
  }
}
