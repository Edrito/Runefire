import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:game_app/entities/player.dart';

import '../functions/custom_mixins.dart';
import '../resources/visuals.dart';
import 'enviroment.dart';

class GameHud extends PositionComponent {
  Player? player;
  GameHud(this.gameRef);
  int fps = 0;
  late final FpsTextComponent fpsCounter;
  late final TextComponent levelCounter;
  late final TextComponent levelCounter2;
  @override
  final double width = 100;
  Enviroment gameRef;

  late HudMarginComponent levelParent;
  late CircleComponent levelBackground;

  double loadInPercent = 0;
  double loadInTime = 2;

  @override
  FutureOr<void> onLoad() {
    if (gameRef is GameEnviroment) {
      player = (gameRef as GameEnviroment).player;
    }

    // add(RectangleComponent(
    //     position: Vector2.zero(), size: game.gameCamera.viewport.size / 11));

    fpsCounter = FpsTextComponent(
      anchor: Anchor.topLeft,
      textRenderer: TextPaint(style: defaultStyle),
      position: Vector2(gameRef.gameCamera.viewport.size.x - 100, 5),
    );

    levelParent = HudMarginComponent(
        margin: const EdgeInsets.fromLTRB(0, 40, 40, 0), anchor: Anchor.center);
    levelCounter = CaTextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(style: defaultStyle),
        text: player?.currentLevel.toString());
    levelCounter2 = CaTextComponent(
        anchor: Anchor.center,
        position: Vector2.all(3),
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(color: Colors.pink.withOpacity(.5))),
        text: player?.currentLevel.toString());
    levelBackground = CircleComponent(
      radius: 32,
      anchor: Anchor.center,
      paint: Paint()
        ..blendMode = BlendMode.darken
        ..color = Colors.black.withOpacity(.8),
    );

    levelParent.add(levelBackground);
    levelParent.add(levelCounter2);
    levelParent.add(levelCounter);
    Future.delayed(loadInTime.seconds, () => add(levelParent));

    // add(fpsCounter);
    return super.onLoad();
  }

  void setLevel(int level) {
    levelCounter.text = level.toString();
    levelCounter2.text = level.toString();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (isLoaded) {
      fpsCounter.position.x = gameRef.gameCamera.viewport.size.x - 50;
      size = gameRef.gameCamera.viewport.size;
    }
    super.onParentResize(maxSize);
  }

  @override
  void update(double dt) {
    if (loadInPercent < 1) {
      loadInPercent += dt / loadInTime;
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    if (player != null) {
      //XP
      const widthOfBar = 6.0;
      const heightOfBar = 30.0;
      const padding = 3.0;
      const peak = 1.2;
      const exponentialGrowth = 6;
      final viewportSize = gameRef.gameCamera.viewport.size;

      final noXpPaint = Paint()
        ..shader = ui.Gradient.linear(Offset.zero, Offset(viewportSize.x, 0),
            [Colors.grey.shade900, Colors.grey.shade700]);
      final xpPaint = Paint()
        ..shader = ui.Gradient.linear(
            Offset.zero, Offset(viewportSize.x, 0), [Colors.pink, Colors.red]);

      final amountOfBars = (viewportSize.x / (widthOfBar + padding)).floor();
      final iteration = (viewportSize.x - padding / 2) / amountOfBars;
      final xpCutOff = player!.percentOfLevelGained * amountOfBars;
      for (var i = 0; i < amountOfBars; i++) {
        final iRatio = i / amountOfBars;
        if (iRatio > loadInPercent) continue;
        final ratio = iRatio * peak;
        final isXpBar = xpCutOff > i;
        canvas.drawRect(
            (Offset((padding / 2) + (iteration * i), 0) &
                Size(
                  widthOfBar,
                  (heightOfBar / 3) +
                      heightOfBar * pow(ratio, exponentialGrowth),
                )),
            isXpBar ? xpPaint : noXpPaint);
      }

      //Health and Stamina

      const heightOfSmallBar = 10.0;
      const startSmallBar = heightOfBar / 2;
      const heightPadding = padding;

      canvas.drawRect(
          (const Offset(padding, startSmallBar) &
              Size(player!.maxHealth * 5, heightOfSmallBar)),
          Paint()..color = Colors.grey.shade900);

      canvas.drawRect(
          (const Offset(padding, startSmallBar) &
              Size(player!.maxHealth * 5 * player!.healthPercentage,
                  heightOfSmallBar)),
          Paint()..color = Colors.red);

      canvas.drawRect(
          (const Offset(
                  padding, startSmallBar + heightPadding + heightOfSmallBar) &
              Size(player!.maxStamina * 2, heightOfSmallBar)),
          Paint()..color = Colors.grey);
      canvas.drawRect(
          (const Offset(
                  padding, startSmallBar + heightPadding + heightOfSmallBar) &
              Size(
                  player!.maxStamina *
                      2 *
                      (player!.remainingStamina / player!.maxStamina),
                  heightOfSmallBar)),
          Paint()..color = Colors.pink);
    }

    super.render(canvas);
  }
}
