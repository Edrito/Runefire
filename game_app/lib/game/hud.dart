import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/player.dart';

import '../resources/classes.dart';

class GameHud extends PositionComponent {
  late final Player player;
  GameHud(this.gameRef);
  int fps = 0;
  late final TextComponent fpsCounter;
  @override
  final double width = 100;
  GameEnviroment gameRef;

  @override
  FutureOr<void> onLoad() {
    player = gameRef.player;
    // add(RectangleComponent(
    //     position: Vector2.zero(), size: game.gameCamera.viewport.size / 11));

    fpsCounter = TextComponent(
        anchor: Anchor.topLeft,
        position: Vector2(gameRef.gameCamera.viewport.size.x - 50, 5),
        text: fps.toString());
    add(fpsCounter);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (dt != 0) {
      fps = (1 / dt).round();
    }
    fpsCounter.text = fps.toString();
    fpsCounter.position.x = gameRef.gameCamera.viewport.size.x - 50;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect((const Offset(10, 10) & Size(player.maxHealth * 5, 10)),
        Paint()..color = Colors.grey);
    canvas.drawRect(
        (const Offset(10, 25) & Size(width, 10)), Paint()..color = Colors.grey);

    canvas.drawRect(
        (const Offset(10, 10) &
            Size(
                player.maxHealth * 5 * (player.health / player.maxHealth), 10)),
        Paint()..color = Colors.red);

    canvas.drawRect((const Offset(10, 25) & const Size(10, 10)),
        Paint()..color = Colors.yellow);
    super.render(canvas);
  }
}
