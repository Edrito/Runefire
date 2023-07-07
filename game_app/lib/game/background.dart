import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/resources/priorities.dart';

import '../main.dart';
import '../resources/enums.dart';
import 'enviroment.dart';

abstract class BackgroundComponent extends ParallaxComponent<GameRouter> {
  // late final ParallaxComponent<FlameGame> background;
  abstract final GameLevel gameLevel;
  // late TiledComponent tiled;
  BackgroundComponent(this.gameReference);
  GameEnviroment gameReference;
  // ObjectGroup? spawnObjects;
  // Vector2? lastPlayerPosition;

  @override
  Future<void> onLoad() async {
    final backgroundLayer = await game.loadParallaxLayer(
      ParallaxImageData('background/test_tile.png'),
      filterQuality: FilterQuality.none,
      fill: LayerFill.none,
      repeat: ImageRepeat.repeat,
    );

    parallax = Parallax(
      [
        backgroundLayer,
      ],
    );

    anchor = Anchor.center;
    priority = backgroundPriority;

    positionType = PositionType.viewport;

    size = size / 50;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    // if (gameReference.player.isMounted && dt != 0) {
    //   parallax!.baseVelocity
    //       .setFrom((gameReference.player.center - lastPlayerPosition) / dt);
    //   lastPlayerPosition.setFrom(gameReference.player.center);
    //   // position.setFrom(gameReference.player.center);
    // }

    super.update(dt);
  }

  Vector2 lastPlayerPosition = Vector2.zero();
}

class Forge2DComponent extends Component {}
