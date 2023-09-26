import 'dart:async';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../resources/enums.dart';
import '../resources/functions/custom.dart';
import '../resources/visuals.dart';
import '../weapons/weapon_class.dart';
import 'enviroment.dart';
import '../enviroment_interactables/expendables.dart';

class GameHud extends PositionComponent {
  GameHud(this.gameEnv);

  late final FpsTextComponent fpsCounter = FpsTextComponent(
    textRenderer: TextPaint(style: defaultStyle),
    position: Vector2(0, gameEnv.gameCamera.viewport.size.y - 50),
  );

  late final Paint healthPaint;
  late final TextComponent levelCounter;
  late final Paint magicPaint;
  late final CaTextComponent timerText;
  late final Paint barBackPaint;
  late final SpriteComponent xpBarLeftSprite;
  late final SpriteComponent xpBarMidSprite;
  late final SpriteComponent xpBarRightSprite;

  late final SpriteComponent bossBarLeftSprite;
  late final SpriteComponent bossBarMidSprite;
  late final SpriteComponent bossBarRightSprite;

  late final Paint xpPaint;
  late Paint bossBarPaint;
  late final Paint xpPulsePaint;

  // Expendable? _currentExpendable;
  late Sprite blankExpendableSprite;

  List<Entity> currentBosses = [];
  late SpriteComponent expendableIcon;
  int fps = 0;
  GameEnviroment gameEnv;
  late SpriteAnimationComponent healthEnergyFrame;
  double hudScale = 1.35;
  //Level
  // late CircleComponent levelBackground;
  late PositionComponent levelWrapper;

  late TextComponent remainingAmmoText;
  Color staminaColor = colorPalette.primaryColor;
  late Paint staminaPaint;
  //Timer
  late HudMarginComponent timerParent;

  //Margin Parent
  late HudMarginComponent topLeftMarginParent;

  Player? player;
  Entity? primaryBoss;
  TextComponent? bossText;

  @override
  final double width = 100;

  void buildBossTextPosition() {
    final gameSize = gameEnv.gameCamera.viewport.size;
    bossText?.position = Vector2(
        gameSize.x / 2, gameSize.y - bossBarHeightPadding - bossBarHeight - 10);
  }

  void buildBossHealthBar(Canvas canvas) {
    final gameSize = gameEnv.gameCamera.viewport.size;

    if (primaryBoss != null || true) {
      final y = gameSize.y - bossBarHeightPadding - (bossBarHeight / 2);
      canvas.drawLine(Offset(bossBarWidthPadding, y),
          Offset(gameSize.x - bossBarWidthPadding, y), bossBarPaint);

      bossText ??= TextComponent(
          text: primaryBoss?.entityType.name ?? "Placeholder Demon",
          anchor: Anchor.bottomCenter,
          textRenderer: colorPalette.buildTextPaint(
              32, ShadowStyle.light, ApolloColorPalette.red.color))
        ..addToParent(this)
        ..loaded.then((value) {
          buildBossTextPosition();
        });
    } else if (currentBosses.isNotEmpty) {
      primaryBoss = currentBosses.first;
      buildBossHealthBar(canvas);
      return;
    } else {
      return;
    }
    final bossWithoutPrimary =
        currentBosses.where((element) => element != primaryBoss).toList();
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

  Path buildSlantedPath(
      double slantPercent, Offset start, double height, double width,
      [bool bothSides = false, double? leftSlantPercent]) {
    final returnPath = Path();
    returnPath.moveTo(start.dx, start.dy);
    if (bothSides) {
      returnPath.lineTo(
          start.dx + (height * (leftSlantPercent ?? slantPercent)),
          start.dy + height);
    } else {
      returnPath.lineTo(start.dx, start.dy + height);
    }

    returnPath.lineTo(
        (start.dx + width) - (height * slantPercent), start.dy + height);

    returnPath.lineTo(start.dx + width, start.dy);

    return returnPath;
  }

  set currentExpendable(Expendable? expendable) {
    // _currentExpendable = expendable;
    if (expendable != null) {
      expendable.expendableType
          .buildSprite()
          .then((value) => expendableIcon.sprite = value);
    } else {
      expendableIcon.sprite = blankExpendableSprite;
    }
  }

  void drawHealthAndStaminaBar(Canvas canvas) {
    //Health and Stamina
    const leftPadding = 72.5;
    const heightOfSmallBar = 18.5;
    const startSmallBar = 42.0;

    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(
              leftPadding * hudScale,
              xpBarHeight +
                  startSmallBar +
                  (13 * (hudScale - 1)) -
                  xpBarHeigthtPadding / 2),
          (heightOfSmallBar + .2) * hudScale,
          player!.maxHealth.parameter * 6 * hudScale,
        ),
        barBackPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(
              leftPadding * hudScale,
              xpBarHeight +
                  startSmallBar +
                  (13 * (hudScale - 1)) -
                  xpBarHeigthtPadding / 2),
          (heightOfSmallBar + .2) * hudScale,
          player!.maxHealth.parameter * 6 * player!.healthPercentage * hudScale,
        ),
        healthPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(
              (leftPadding + 5) * hudScale,
              xpBarHeight +
                  (startSmallBar + (heightOfSmallBar) * hudScale) +
                  (13 * (hudScale - 1)) -
                  (xpBarHeigthtPadding / 2)),
          heightOfSmallBar * hudScale,
          player!.stamina.parameter * 3 * hudScale,
        ),
        barBackPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(
              (leftPadding + 5) * hudScale,
              xpBarHeight +
                  (startSmallBar + (heightOfSmallBar) * hudScale) +
                  (13 * (hudScale - 1)) -
                  (xpBarHeigthtPadding / 2)),
          heightOfSmallBar * hudScale,
          player!.stamina.parameter *
              3 *
              (player!.remainingStamina / player!.stamina.parameter) *
              hudScale,
        ),
        staminaPaint);
  }

  void drawXpBar(Canvas canvas) {
    final viewportSize = gameEnv.gameCamera.viewport.size;
    final barSize = viewportSize.x - (xpBarWidthPadding * 2);

    final basePath = buildSlantedPath(
        1,
        const Offset(xpBarWidthPadding, xpBarHeigthtPadding),
        xpBarHeight,
        barSize,
        true);
    canvas.drawPath(basePath, barBackPaint);

    canvas.drawPath(
        buildSlantedPath(
            (player!.percentOfLevelGained * 2) - 1,
            const Offset(xpBarWidthPadding, xpBarHeigthtPadding),
            xpBarHeight,
            barSize * player!.percentOfLevelGained,
            true,
            1),
        xpPaint);
  }

  void buildBossPaint() {
    final viewportSize = gameEnv.gameCamera.viewport.size;
    bossBarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bossBarHeight
      ..strokeCap = StrokeCap.round
      // ..shader = ui.Gradient.linear(
      //     Offset(0, viewportSize.y - bossBarHeightPadding - bossBarHeight),
      //     Offset(0, viewportSize.y - bossBarHeightPadding), [
      //   ApolloColorPalette.mediumRed.color,
      //   ApolloColorPalette.red.color,
      //   ApolloColorPalette.red.color,
      //   ApolloColorPalette.mediumRed.color,
      // ], [
      //   0,
      //   .35,
      //   .55,
      //   .58
      // ])
      // ;
      ..shader = ui.Gradient.radial(
          Offset(viewportSize.x / 2,
              viewportSize.y - bossBarHeightPadding - (bossBarHeight / 2)),
          viewportSize.x / 2,
          [
            ApolloColorPalette.lightRed.color,
            ApolloColorPalette.red.color,
            ApolloColorPalette.red.color,
            ApolloColorPalette.mediumRed.color,
            ApolloColorPalette.mediumRed.color,
            ApolloColorPalette.deepRed.color,
            ApolloColorPalette.deepRed.color,
            ApolloColorPalette.darkestRed.color,
            ApolloColorPalette.darkestRed.color,
          ],
          [
            // 0,
            0.02,
            0.02001,
            0.165,
            0.165001,
            0.5,
            0.5001,
            0.85,
            0.85001,
            1
          ]);
  }

  void initPaints([bool staminaOnly = false]) {
    if (staminaOnly) {
      staminaPaint = Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
          staminaColor,
          staminaColor.brighten(.4),
        ]);
      return;
    }

    staminaPaint = Paint()
      ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
        staminaColor,
        staminaColor.brighten(.4),
      ]);
    healthPaint = Paint()
      ..isAntiAlias = true
      ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
        ApolloColorPalette.red.color,
        ApolloColorPalette.lightRed.color,
      ]);

    buildBossPaint();

    xpPaint = Paint()
      ..shader = ui.Gradient.linear(const Offset(0, xpBarHeigthtPadding),
          const Offset(0, xpBarHeigthtPadding + xpBarHeight), [
        colorPalette.primaryColor,
        colorPalette.secondaryColor,
        colorPalette.secondaryColor,
        colorPalette.primaryColor,
      ], [
        0.42,
        0.45,
        0.65,
        1
      ]);

    barBackPaint = ApolloColorPalette.deepGray.paint();
  }

  void applyBossBorderPositions() {
    final gameSize = gameEnv.gameCamera.viewport.size;
    bossBarLeftSprite.position = Vector2(
        bossBarWidthPadding + 16, gameSize.y - bossBarHeightPadding + 4);
    bossBarRightSprite.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - bossBarWidthPadding - 16,
        gameSize.y - bossBarHeightPadding + 4);
    bossBarMidSprite.position = Vector2(
        (gameEnv.gameCamera.viewport.size.x / 2),
        gameSize.y - bossBarHeightPadding + 4);
  }

  Future<void> initBossBorder() async {
    bossBarLeftSprite = SpriteComponent(
      sprite: await Sprite.load('ui/boss_bar_left.png'),
      anchor: Anchor.bottomCenter,
    );
    bossBarRightSprite = SpriteComponent(
      sprite: await Sprite.load('ui/boss_bar_right.png'),
      anchor: Anchor.bottomCenter,
    );
    bossBarMidSprite = SpriteComponent(
      sprite: await Sprite.load('ui/boss_bar_center.png'),
      // size: Vector2.,
      anchor: Anchor.bottomCenter,
    );
    bossBarMidSprite.size = bossBarMidSprite.sprite!.srcSize
        .scaledToDimension(true, bossBarHeight + 8);
    bossBarLeftSprite.size = bossBarLeftSprite.sprite!.srcSize
        .scaledToDimension(true, bossBarHeight + 8);
    bossBarRightSprite.size = bossBarRightSprite.sprite!.srcSize
        .scaledToDimension(true, bossBarHeight + 8);
    applyBossBorderPositions();
    addAll([
      bossBarLeftSprite,
      bossBarRightSprite,
      bossBarMidSprite,
    ]);
  }

  void applyXpBorderPositions() {
    xpBarLeftSprite.position =
        Vector2(xpBarWidthPadding - 3, xpBarHeigthtPadding - 3);
    xpBarRightSprite.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - xpBarWidthPadding - xpBarHeight,
        xpBarHeigthtPadding - 3);
    xpBarMidSprite.position = Vector2(
        (gameEnv.gameCamera.viewport.size.x / 2), xpBarHeigthtPadding - 3);
  }

  Future<void> initXpBorder() async {
    final baseSize = Vector2.all(xpBarHeight + 6);
    xpBarLeftSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_left.png'),
      size: baseSize,
    );
    xpBarRightSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_right.png'),
      size: baseSize,
    );
    xpBarMidSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_center.png'),
      size: baseSize * 1.1,
      anchor: Anchor.topCenter,
    );
    applyXpBorderPositions();
    addAll([
      xpBarLeftSprite,
      xpBarRightSprite,
      xpBarMidSprite,
    ]);
  }

  void setLevel(int level) {
    levelCounter.text = level.toString();
  }

  void toggleStaminaColor(AttackType attackType) {
    switch (attackType) {
      case AttackType.magic:
        staminaColor = colorPalette.primaryColor;
      default:
        staminaColor = ApolloColorPalette.lightGreen.color;
    }
    initPaints(true);
  }

  @override
  FutureOr<void> onLoad() async {
    player = (gameEnv).player;

    //Wrappers
    topLeftMarginParent = HudMarginComponent(
        margin: const EdgeInsets.fromLTRB(xpBarWidthPadding, 60, 0, 0),
        anchor: Anchor.center);
    levelWrapper = PositionComponent(
        anchor: Anchor.center, position: Vector2.all(40 * hudScale));

    //Health Bar
    final sprite = await spriteAnimations.uiHealthBar1;

    final healthBarSize = sprite.frames.first.sprite.srcSize;
    healthBarSize.scaleTo(325 * hudScale);
    healthEnergyFrame = SpriteAnimationComponent(
      animation: sprite,
      size: healthBarSize,
    );

    //FPS

    Future.delayed(2.seconds).then((_) {
      add(fpsCounter);
    });
    //Timer
    timerParent = HudMarginComponent(
        margin: EdgeInsets.fromLTRB(0, 10 + xpBarHeight + xpBarHeigthtPadding,
            xpBarWidthPadding + (110 * hudScale), 0),
        anchor: Anchor.center);
    timerText = CaTextComponent(
      textRenderer: TextPaint(
          style: defaultStyle.copyWith(
              shadows: [colorPalette.buildShadow(ShadowStyle.light)],
              fontSize: defaultStyle.fontSize! * hudScale)),
    );

    //Level
    levelCounter = CaTextComponent(
        anchor: Anchor.center,
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(
          fontSize: (defaultStyle.fontSize! * .8 * hudScale),
          color: ApolloColorPalette.lightCyan.color,
          shadows: [colorPalette.buildShadow(ShadowStyle.light)],
        )),
        text: player?.currentLevel.toString());

    //Remaining Ammo text
    remainingAmmoText = TextComponent(
      position: Vector2(125 * hudScale, 57.5 * hudScale),
      textRenderer: TextPaint(
          style: defaultStyle.copyWith(
              fontSize: (defaultStyle.fontSize! * .65 * hudScale),
              color: ApolloColorPalette.offWhite.color,
              shadows: [colorPalette.buildShadow(ShadowStyle.light)])),
    );

    //Expendable
    blankExpendableSprite = await Sprite.load('expendables/blank.png');
    expendableIcon = SpriteComponent(
        scale: Vector2.all(hudScale),
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

    initPaints();
    await initXpBorder();
    await initBossBorder();
    return super.onLoad();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (isLoaded) {
      fpsCounter.position.x = gameEnv.gameCamera.viewport.size.x - 200;
      size = gameEnv.gameCamera.viewport.size;
      if (xpBarRightSprite.isLoaded) {
        xpBarRightSprite.position.x = gameEnv.gameCamera.viewport.size.x -
                xpBarWidthPadding -
                xpBarHeight
            // +
            // 6 +
            // 3
            ;
        applyXpBorderPositions();
        buildBossTextPosition();
        applyBossBorderPositions();
      }

      buildBossPaint();
    }
    super.onParentResize(maxSize);
  }

  @override
  void render(Canvas canvas) {
    if (player != null) {
      // XP
      drawXpBar(canvas);
      buildBossHealthBar(canvas);
      drawHealthAndStaminaBar(canvas);
    }

    super.render(canvas);
  }
}
