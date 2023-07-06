import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/player.dart';

import '../functions/custom_mixins.dart';
import '../resources/visuals.dart';
import 'enviroment.dart';

class GameHud extends PositionComponent {
  late final Player player;
  GameHud(this.gameRef);
  int fps = 0;
  late final TextComponent fpsCounter;
  late final TextComponent levelCounter;
  @override
  final double width = 100;
  GameEnviroment gameRef;

  @override
  FutureOr<void> onLoad() {
    player = gameRef.player;
    // add(RectangleComponent(
    //     position: Vector2.zero(), size: game.gameCamera.viewport.size / 11));

    fpsCounter = CaTextComponent(
        anchor: Anchor.topLeft,
        textRenderer: TextPaint(style: defaultStyle),
        position: Vector2(gameRef.gameCamera.viewport.size.x - 50, 5),
        text: fps.toString());
    levelCounter = CaTextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(style: defaultStyle),
        position: Vector2(gameRef.gameCamera.viewport.size.x / 2, 45),
        text: player.currentLevel.toString());
    add(levelCounter);
    add(fpsCounter);
    return super.onLoad();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (isLoaded) {
      fpsCounter.position.x = gameRef.gameCamera.viewport.size.x - 50;
      levelCounter.position.x = gameRef.gameCamera.viewport.size.x / 2;
    }
    super.onParentResize(maxSize);
  }

  @override
  void update(double dt) {
    if (dt != 0) {
      fps = (1 / dt).round();
    }
    fpsCounter.text = fps.toString();
    levelCounter.text = player.currentLevel.toString();

    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        (const Offset(0, 0) & Size(gameRef.gameCamera.viewport.size.x, 10)),
        Paint()..color = Colors.grey);

    canvas.drawRect(
        (const Offset(0, 0) &
            Size(
                gameRef.gameCamera.viewport.size.x *
                    player.percentOfLevelGained,
                10)),
        Paint()..color = unlockedColor);

    canvas.drawRect((const Offset(10, 25) & Size(player.maxHealth * 5, 10)),
        Paint()..color = Colors.grey);

    canvas.drawRect(
        (const Offset(10, 25) &
            Size(player.maxHealth * 5 * player.healthPercentage, 10)),
        Paint()..color = Colors.red);

    canvas.drawRect((const Offset(10, 40) & Size(player.maxStamina * 2, 10)),
        Paint()..color = Colors.grey);
    canvas.drawRect(
        (const Offset(10, 40) &
            Size(
                player.maxStamina *
                    2 *
                    (player.remainingStamina / player.maxStamina),
                10)),
        Paint()..color = Colors.yellow);
    canvas.drawCircle(Offset(gameRef.gameCamera.viewport.size.x / 2, 40), 30,
        BasicPalette.black.paint());
    super.render(canvas);
  }
}
