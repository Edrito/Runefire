import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/parallax.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/game/player.dart';

import 'characters.dart';
import 'hud.dart';

enum GameLevel { space, forest }

class BackgroundComponent extends FlameGame {
  BackgroundComponent(this.gameLevel, this.player);

  late final ParallaxComponent<FlameGame> background;
  final GameLevel gameLevel;
  final Player player;

  @override
  FutureOr<void> onLoad() async {
    positionType = PositionType.viewport;
    background = await loadParallaxComponent([
      ParallaxImageData('temp.jpg'),
      ParallaxImageData('default.png'),
    ],
        baseVelocity: Vector2(0, 0),
        velocityMultiplierDelta: Vector2(1.2, 1.2),
        repeat: ImageRepeat.repeat);

    add(background);
    return super.onLoad();
  }

  Vector2? lastCameraPosition;

  @override
  void update(double dt) {
    if (lastCameraPosition != null) {
      Vector2 pos = player.position;
      double parVelX = (pos.x - lastCameraPosition!.x) / dt;
      double parVelY = (pos.y - lastCameraPosition!.y) / dt;
      background.parallax?.baseVelocity.x = parVelX;
      background.parallax?.baseVelocity.y = parVelY;
    }
    lastCameraPosition = player.position.clone();

    super.update(dt);
  }
}

class GameplayGame extends FlameGame with KeyboardEvents {
  late final Player player;
  late final GameHud hud;
  late final BackgroundComponent backgroundComponent;

  @override
  FutureOr<void> onLoad() async {
    player = Player(CharacterType.wizard);
    hud = GameHud(player);
    backgroundComponent = BackgroundComponent(GameLevel.forest, player);

    add(backgroundComponent);

    add(hud);

    add(player);

    camera.followComponent(player);
    return super.onLoad();
  }

  Map<LogicalKeyboardKey, double> keyDurationPress = {};

  double fps = 0;
  final speed = 3.0;
  double increase(LogicalKeyboardKey key, double dt) {
    double previousTime = keyDurationPress[key]!;
    previousTime += dt;
    keyDurationPress[key] = previousTime;
    double increase = speed * (previousTime / .2);
    if (increase > speed) increase = speed;
    return increase;
  }

  @override
  void update(double dt) {
    if (keyDurationPress.isNotEmpty) {
      Vector2 pos = player.position;
      if (keyDurationPress.containsKey(LogicalKeyboardKey.keyW)) {
        pos.y -= increase(LogicalKeyboardKey.keyW, dt);
      }
      if (keyDurationPress.containsKey(LogicalKeyboardKey.keyA)) {
        pos.x -= increase(LogicalKeyboardKey.keyA, dt);
      }
      if (keyDurationPress.containsKey(LogicalKeyboardKey.keyS)) {
        pos.y += increase(LogicalKeyboardKey.keyS, dt);
      }
      if (keyDurationPress.containsKey(LogicalKeyboardKey.keyD)) {
        pos.x += increase(LogicalKeyboardKey.keyD, dt);
      }
    }

    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    keyDurationPress.removeWhere((key, value) => !keysPressed.contains(key));
    for (LogicalKeyboardKey element in keysPressed) {
      keyDurationPress[element] ??= 0.0;
    }
    return KeyEventResult.handled;
  }
}
