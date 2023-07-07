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
    // tiled = await TiledComponent.load(
    //     gameLevel.getTileFilename(), Vector2(32, 16),
    //     priority: priorities.backgroundPriority);

    // spawnObjects = tiled.tileMap.getLayer<ObjectGroup>('spawn');
    // Vector2 positionTest = Vector2.zero();
    // if (spawnObjects != null) {
    //   for (var element in spawnObjects!.objects) {
    //     if (element.isPoint) {
    //       positionTest =
    //           tiledObjectToOrtho(Vector2(element.x, element.y), tiled);
    //     }
    //   }
    // }
    // anchor = Anchor.center;
    // parent?.add(tiled);
    // // gameRef.player.loaded
    // //     .whenComplete(() => gameRef.player.body.setTransform(positionTest, 0));
    final backgroundLayer = await game.loadParallaxLayer(
      ParallaxImageData('background/test_tile.png'),
      // velocityMultiplier: Vector2(4, 0),
      filterQuality: FilterQuality.none,

      fill: LayerFill.none,
      repeat: ImageRepeat.repeat,
      // alignment: Alignment.topLeft,
    );

    // backgroundLayer.parallaxRenderer.filterQuality = FilterQuality.none;
// game.loadParallaxImage('background/test_tile.png', filterQuality: FilterQuality.none)l
    parallax = Parallax(
      [
        backgroundLayer,
      ],
    );

    anchor = Anchor.center;
    priority = backgroundPriority;

    // add(parallaxComponent);
    positionType = PositionType.viewport;

    size = size / 10;

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (gameReference.player.isMounted && dt != 0) {
      parallax!.baseVelocity
          .setFrom((gameReference.player.center - lastPlayerPosition) / dt);
      lastPlayerPosition.setFrom(gameReference.player.center);
      // position.setFrom(gameReference.player.center);
    }

    super.update(dt);
  }

  Vector2 lastPlayerPosition = Vector2.zero();
}

class Forge2DComponent extends Component {}
