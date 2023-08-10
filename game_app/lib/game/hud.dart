import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:game_app/player/player.dart';
import 'package:game_app/resources/functions/functions.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/custom_mixins.dart';
import '../resources/visuals.dart';
import '../weapons/weapon_class.dart';
import 'enviroment.dart';
import 'expendables.dart';

class GameHud extends PositionComponent {
  Player? player;
  GameHud(this.gameRef);
  int fps = 0;
  late final FpsTextComponent fpsCounter;
  late final TextComponent levelCounter;
  @override
  final double width = 100;
  Enviroment gameRef;
  //Timer
  late HudMarginComponent timerParent;
  late final CaTextComponent timerText;

  //Margin Parent
  late HudMarginComponent topLeftMarginParent;

  //Level
  late CircleComponent levelBackground;
  late PositionComponent levelWrapper;

  late SpriteAnimationComponent healthEnergyFrame;

  late SpriteComponent expendableIcon;

  late TextComponent remainingAmmoText;

  Expendable? _currentExpendable;
  late Sprite blankExpendableSprite;

  set currentExpendable(Expendable? expendable) {
    _currentExpendable = expendable;
    if (expendable != null) {
      expendable.expendableType
          .buildSprite()
          .then((value) => expendableIcon.sprite = value);
    } else {
      expendableIcon.sprite = blankExpendableSprite;
    }
  }

  @override
  FutureOr<void> onLoad() async {
    if (gameRef is GameEnviroment) {
      player = (gameRef as GameEnviroment).player;
    }

    //Wrappers
    topLeftMarginParent = HudMarginComponent(
        margin: const EdgeInsets.fromLTRB(8, 30, 0, 0), anchor: Anchor.center);
    levelWrapper =
        PositionComponent(anchor: Anchor.center, position: Vector2.all(40));

    //Health Bar
    final sprite = await loadSpriteAnimation(1, 'ui/health_bar.png', 1, true);
    final healthBarSize = sprite.frames.first.sprite.srcSize;
    healthBarSize.scaleTo(325);
    healthEnergyFrame = SpriteAnimationComponent(
      animation: await loadSpriteAnimation(1, 'ui/health_bar.png', 1, true),
      size: healthBarSize,
    );

    //FPS
    fpsCounter = FpsTextComponent(
      textRenderer: TextPaint(style: defaultStyle),
      position: Vector2(0, gameRef.gameCamera.viewport.size.y - 40),
    );

    //Timer
    timerParent = HudMarginComponent(
        margin: const EdgeInsets.fromLTRB(0, 20, 120, 0),
        anchor: Anchor.center);
    timerText = CaTextComponent(
      textRenderer: TextPaint(style: defaultStyle),
    );

    //Level
    levelCounter = CaTextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(
                fontSize: (defaultStyle.fontSize! * .8),
                color: ApolloColorPalette.lightCyan.color,
                shadows: [
              const BoxShadow(
                  spreadRadius: 1, blurRadius: 0, offset: Offset(2, 2))
            ])),
        text: player?.currentLevel.toString());
    levelBackground = CircleComponent(
      radius: 32,
      anchor: Anchor.center,
      paint: Paint()
        ..blendMode = BlendMode.darken
        ..color = Colors.black.withOpacity(.8),
    );

    //Remaining Ammo text
    remainingAmmoText = TextComponent(
      position: Vector2(100, 57.5),
      textRenderer: TextPaint(
          style: defaultStyle.copyWith(
              fontSize: (defaultStyle.fontSize! * .5),
              color: ApolloColorPalette.offWhite.color,
              shadows: [
            const BoxShadow(
                spreadRadius: 1, blurRadius: 0, offset: Offset(2, 2))
          ])),
    );
    buildRemainingAmmoText(player?.currentWeapon);

    //Expendable
    blankExpendableSprite = await Sprite.load('expendables/blank.png');
    expendableIcon = SpriteComponent(
        position: Vector2(15, 75), sprite: blankExpendableSprite);

    timerParent.add(timerText);
    levelWrapper.add(levelCounter);
    topLeftMarginParent.add(healthEnergyFrame);
    topLeftMarginParent.add(levelWrapper);
    topLeftMarginParent.add(expendableIcon);
    topLeftMarginParent.add(remainingAmmoText);

    add(timerParent);

    addAll([topLeftMarginParent]);
    add(fpsCounter);

    return super.onLoad();
  }

  void buildRemainingAmmoText(Weapon? weapon) {
    if (weapon == null) return;
    if (weapon is ReloadFunctionality) {
      remainingAmmoText.text =
          "${weapon.remainingAttacks.toString()}/${weapon.maxAttacks.parameter.toString()}";
    } else {
      remainingAmmoText.text = "";
    }
  }

  void setLevel(int level) {
    levelCounter.text = level.toString();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (isLoaded) {
      fpsCounter.position.x = gameRef.gameCamera.viewport.size.x - 50;
      size = gameRef.gameCamera.viewport.size;
    }
    super.onParentResize(maxSize);
  }

  Path buildSlantedPath(
      double slantPercent, Offset start, double height, double width) {
    final returnPath = Path();
    returnPath.moveTo(start.dx, start.dy);
    returnPath.lineTo(start.dx, start.dy + height);
    returnPath.lineTo(
        (start.dx + width) - (height * slantPercent), start.dy + height);
    returnPath.lineTo(start.dx + width, start.dy);
    return returnPath;
  }

  @override
  void render(Canvas canvas) {
    if (player != null) {
      // XP
      const widthOfBar = 6.0;

      const peak = 0.0;
      const exponentialGrowth = 2.0;
      final viewportSize = gameRef.gameCamera.viewport.size;

      buildProgressBar(
          canvas: canvas,
          percentProgress: player!.percentOfLevelGained,
          color: ApolloColorPalette().primaryColor,
          size: viewportSize,
          heightOfBar: 50,
          widthOfBar: widthOfBar,
          padding: 5,
          loadInPercent: 1,
          peak: peak,
          growth: exponentialGrowth);

      //Health and Stamina
      const leftPadding = 75.0;
      const heightOfSmallBar = 18.5;
      const startSmallBar = 42.0;

      canvas.drawPath(
          buildSlantedPath(
            1,
            const Offset(leftPadding, startSmallBar),
            heightOfSmallBar + .2,
            player!.maxHealth.parameter * 6 * player!.healthPercentage,
          ),
          Paint()
            ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
              ApolloColorPalette.lightRed.color,
              ApolloColorPalette.red.color,
            ]));

      canvas.drawPath(
          buildSlantedPath(
            1,
            const Offset(leftPadding + 10, startSmallBar + heightOfSmallBar),
            heightOfSmallBar,
            player!.stamina.parameter *
                3 *
                (player!.remainingStamina / player!.stamina.parameter),
          ),
          Paint()
            ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
              staminaColor.brighten(.4),
              staminaColor,
            ]));
    }

    super.render(canvas);
  }

  Color staminaColor = ApolloColorPalette().primaryColor;
  void toggleStaminaColor(AttackType attackType) {
    switch (attackType) {
      case AttackType.magic:
        staminaColor = ApolloColorPalette().primaryColor;
        break;
      case AttackType.melee:
        staminaColor = ApolloColorPalette.deepGreen.color;
        break;
      case AttackType.projectile:
        staminaColor = ApolloColorPalette.lightGreen.color;
        break;
    }
  }
}
