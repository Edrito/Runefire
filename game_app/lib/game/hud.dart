import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:game_app/entities/player.dart';

import '../resources/functions/custom_mixins.dart';
import '../resources/visuals.dart';
import 'enviroment.dart';

class GameHud extends PositionComponent {
  Player? player;
  GameHud(this.gameRef);
  int fps = 0;
  late final FpsTextComponent fpsCounter;
  late final TextComponent levelCounter;
  late final TextComponent levelCounterBg;
  @override
  final double width = 100;
  Enviroment gameRef;

  late HudMarginComponent timerParent;
  late final CaTextComponent timerText;

  late HudMarginComponent levelParent;
  late CircleComponent levelBackground;

  double loadInPercent = 0;
  double loadInTime = 2;

  @override
  FutureOr<void> onLoad() {
    if (gameRef is GameEnviroment) {
      player = (gameRef as GameEnviroment).player;
    }

    fpsCounter = FpsTextComponent(
      textRenderer: TextPaint(style: defaultStyle),
      position: Vector2(0, gameRef.gameCamera.viewport.size.y - 40),
    );

    timerParent = HudMarginComponent(
        margin: const EdgeInsets.fromLTRB(5, 0, 0, 40), anchor: Anchor.center);
    timerText = CaTextComponent(
      textRenderer: TextPaint(style: defaultStyle),
    );

    levelParent = HudMarginComponent(
        margin: const EdgeInsets.fromLTRB(0, 40, 40, 0), anchor: Anchor.center);

    levelCounter = CaTextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(style: defaultStyle),
        text: player?.currentLevel.toString());
    levelCounterBg = CaTextComponent(
        anchor: Anchor.center,
        position: Vector2.all(3),
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(color: Colors.blue.withOpacity(.5))),
        text: player?.currentLevel.toString());
    levelBackground = CircleComponent(
      radius: 32,
      anchor: Anchor.center,
      paint: Paint()
        ..blendMode = BlendMode.darken
        ..color = Colors.black.withOpacity(.8),
    );

    timerParent.add(timerText);
    levelParent.add(levelBackground);
    levelParent.add(levelCounterBg);
    levelParent.add(levelCounter);

    add(timerParent);

    Future.delayed(loadInTime.seconds, () => addAll([levelParent]));

    add(fpsCounter);

    return super.onLoad();
  }

  void setLevel(int level) {
    levelCounter.text = level.toString();
    levelCounterBg.text = level.toString();
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
      const exponentialGrowth = 6.0;
      final viewportSize = gameRef.gameCamera.viewport.size;

      buildProgressBar(
          canvas: canvas,
          percentProgress: player!.percentOfLevelGained,
          color: Colors.pink,
          size: viewportSize,
          heightOfBar: heightOfBar,
          widthOfBar: widthOfBar,
          padding: padding,
          loadInPercent: loadInPercent,
          peak: peak,
          growth: exponentialGrowth);

      //Health and Stamina

      const heightOfSmallBar = 10.0;
      const startSmallBar = heightOfBar / 2;
      const heightPadding = padding;

      canvas.drawRect(
          (const Offset(padding, startSmallBar) &
              Size(player!.maxHealth.parameter * 5, heightOfSmallBar)),
          Paint()..color = Colors.grey.shade900);

      canvas.drawRect(
          (const Offset(padding, startSmallBar) &
              Size(player!.maxHealth.parameter * 5 * player!.healthPercentage,
                  heightOfSmallBar)),
          Paint()..color = primaryColor);

      canvas.drawRect(
          (const Offset(
                  padding, startSmallBar + heightPadding + heightOfSmallBar) &
              Size(player!.stamina.parameter * 2, heightOfSmallBar)),
          Paint()..color = Colors.grey.shade900);
      canvas.drawRect(
          (const Offset(
                  padding, startSmallBar + heightPadding + heightOfSmallBar) &
              Size(
                  player!.stamina.parameter *
                      2 *
                      (player!.remainingStamina / player!.stamina.parameter),
                  heightOfSmallBar)),
          Paint()..color = secondaryColor);
    }

    super.render(canvas);
  }
}
