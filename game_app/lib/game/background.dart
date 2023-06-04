import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:game_app/game/player.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'main_game.dart';

class BackgroundComponent extends SpriteComponent {
  late final ParallaxComponent<FlameGame> background;
  late final GameLevel gameLevel;
  late final Player player;

  BackgroundComponent(this.gameRef, this.gameLevel);
  MainGame gameRef;

  Vector2? lastPlayerPosition;

  @override
  FutureOr<void> onLoad() async {
    player = gameRef.player;
    sprite = await Sprite.load('rock_background.jpg');
    priority = -500;
    anchor = Anchor.center;
    size = size / 6;
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
