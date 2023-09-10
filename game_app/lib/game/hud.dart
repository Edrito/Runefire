import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:game_app/main.dart';
import 'package:game_app/player/player.dart';
import 'package:game_app/resources/functions/functions.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/custom.dart';
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
  // late CircleComponent levelBackground;
  late PositionComponent levelWrapper;

  late SpriteAnimationComponent healthEnergyFrame;

  late SpriteComponent expendableIcon;

  late TextComponent remainingAmmoText;

  double hudScale = 1;

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
    levelWrapper = PositionComponent(
        anchor: Anchor.center, position: Vector2.all(40 * hudScale));

    //Health Bar
    final sprite = await loadSpriteAnimation(1, 'ui/health_bar.png', 1, true);
    final healthBarSize = sprite.frames.first.sprite.srcSize;
    healthBarSize.scaleTo(325 * hudScale);
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
        margin: EdgeInsets.fromLTRB(0, 5, 110 * hudScale, 0),
        anchor: Anchor.center);
    timerText = CaTextComponent(
      textRenderer: TextPaint(
          style: defaultStyle.copyWith(
              fontSize: defaultStyle.fontSize! * hudScale)),
    );

    //Level
    levelCounter = CaTextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(
                fontSize: (defaultStyle.fontSize! * .8 * hudScale),
                color: ApolloColorPalette.lightCyan.color,
                shadows: [
              BoxShadow(
                  blurStyle: BlurStyle.solid,
                  color: ApolloColorPalette.lightCyan.color.darken(.75),
                  offset: const Offset(1, 1))
            ])),
        text: player?.currentLevel.toString());
    // levelBackground = CircleComponent(
    //   radius: 32,
    //   anchor: Anchor.center,
    //   paint: Paint()
    //     ..blendMode = BlendMode.darken
    //     ..color = Colors.black.withOpacity(.8),
    // );

    //Remaining Ammo text
    remainingAmmoText = TextComponent(
      position: Vector2(125 * hudScale, 57.5 * hudScale),
      textRenderer: TextPaint(
          style: defaultStyle.copyWith(
              fontSize: (defaultStyle.fontSize! * .65 * hudScale),
              color: ApolloColorPalette.offWhite.color,
              shadows: [
            BoxShadow(
                blurStyle: BlurStyle.solid,
                color: ApolloColorPalette.offWhite.color.darken(.75),
                offset: const Offset(1, 1))
          ])),
    );

    //Expendable
    blankExpendableSprite = await Sprite.load('expendables/blank.png');
    expendableIcon = SpriteComponent(
        position: Vector2(15 * hudScale, 85 * hudScale),
        sprite: blankExpendableSprite);

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

  Future<void> buildRemainingAmmoText(Player player) async {
    Weapon? currentWeapon = player.currentWeapon;
    if (currentWeapon is ReloadFunctionality) {
      remainingAmmoText.text =
          "${currentWeapon.remainingAttacks.toString()}/${currentWeapon.maxAttacks.parameter.toString()}";
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

      const peak = 1.05;
      const exponentialGrowth = 7.5;
      final viewportSize = gameRef.gameCamera.viewport.size;

      buildProgressBar(
          canvas: canvas,
          percentProgress: player!.percentOfLevelGained,
          color: colorPalette.secondaryColor,
          size: viewportSize,
          heightOfBar: 50,
          widthOfBar: widthOfBar,
          padding: 5,
          loadInPercent: 1,
          peak: peak,
          growth: exponentialGrowth);

      //Health and Stamina
      const leftPadding = 72.5;
      const heightOfSmallBar = 18.5;
      const startSmallBar = 42.0;

      canvas.drawPath(
          buildSlantedPath(
            1,
            Offset(
                leftPadding * hudScale, startSmallBar + (13 * (hudScale - 1))),
            (heightOfSmallBar + .2) * hudScale,
            player!.maxHealth.parameter *
                6 *
                player!.healthPercentage *
                hudScale,
          ),
          Paint()
            ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
              ApolloColorPalette.lightRed.color,
              ApolloColorPalette.red.color,
            ]));

      canvas.drawPath(
          buildSlantedPath(
            1,
            Offset(
                (leftPadding + 5) * hudScale,
                (startSmallBar + (heightOfSmallBar + .1) * hudScale) +
                    (13 * (hudScale - 1))),
            heightOfSmallBar * hudScale,
            player!.stamina.parameter *
                3 *
                (player!.remainingStamina / player!.stamina.parameter) *
                hudScale,
          ),
          Paint()
            ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
              staminaColor.brighten(.4),
              staminaColor,
            ]));
    }

    super.render(canvas);
  }

  Color staminaColor = colorPalette.primaryColor;
  void toggleStaminaColor(AttackType attackType) {
    switch (attackType) {
      case AttackType.magic:
        staminaColor = colorPalette.primaryColor;
      default:
        staminaColor = ApolloColorPalette.lightGreen.color;
    }
  }
}
