import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/cupertino.dart';
import 'package:game_app/resources/constants/priorities.dart';

import '../main.dart';
import '../resources/enums.dart';
import 'enviroment.dart';

abstract class BackgroundComponent extends ParallaxComponent<GameRouter> {
  abstract final GameLevel gameLevel;
  BackgroundComponent(this.gameReference);
  Enviroment gameReference;
}

class Forge2DComponent extends Component {}

class BlankBackground extends BackgroundComponent {
  BlankBackground(super.gameReference);

  @override
  GameLevel get gameLevel => GameLevel.menu;

  @override
  FutureOr<void> onLoad() async {
    final backgroundLayer = await game.loadParallaxLayer(
      ParallaxImageData('background/blank.png'),
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
}
