import 'dart:async';
import 'dart:async' as async;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/assets/assets.dart';
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

mixin BossBar on BaseHud {
  late final SpriteComponent bossBarLeftSprite;
  late final SpriteComponent bossBarMidSprite;
  late final SpriteComponent bossBarRightSprite;

  late Paint bossBarBackPaint;
  late Paint bossBarHitPaint;
  late Paint bossBarPaint;
  late SpriteComponent bossBorderSprite;
  List<Entity> currentBosses = [];
  bool displayBossHit = false;

  TextComponent? bossText;
  Entity? primaryBoss;

  bool get bossBarActive => primaryBoss != null;

  void addBoss(Entity boss) {
    currentBosses.add(boss);
  }

  void applyBossBorderPositions() {
    final gameSize = gameEnviroment.gameCamera.viewport.size;

    final heightPadding = bossBarHeightPadding(hudScale);
    final widthPadding = bossBarWidthPadding(hudScale);
    final height = bossBarHeight(hudScale);

    bossBarLeftSprite.position =
        Vector2(widthPadding, gameSize.y - heightPadding);
    bossBarRightSprite.position = Vector2(
        gameEnviroment.gameCamera.viewport.size.x - widthPadding,
        gameSize.y - heightPadding);

    bossBarMidSprite.position = Vector2(
        (gameEnviroment.gameCamera.viewport.size.x / 2),
        gameSize.y - heightPadding);

    bossBorderSprite.position = Vector2(
        (gameEnviroment.gameCamera.viewport.size.x / 2),
        gameSize.y - heightPadding);
    bossBorderSprite.size = Vector2(
        gameEnviroment.gameCamera.viewport.size.x -
            (widthPadding * 2) -
            bossBarLeftSprite.width,
        height);
  }

  void applyBossHitEffect([DamageType? color]) async {
    displayBossHit = true;
    if (color != null) {
      bossBarHitPaint.color = color.color.brighten(.2);
    } else {
      bossBarHitPaint.color = ApolloColorPalette.nearlyWhite.color;
    }
    await Future.delayed(.06.seconds).then((value) => displayBossHit = false);
  }

  void buildBossPaint() {
    final heightPadding = bossBarHeightPadding(hudScale);
    final height = bossBarHeight(hudScale);
    final viewportSize = gameEnviroment.gameCamera.viewport.size;
    bossBarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round
      ..shader = ui.Gradient.radial(
          Offset(viewportSize.x / 2,
              viewportSize.y - heightPadding - (height / 2)),
          viewportSize.x / 2,
          [
            ApolloColorPalette.lightRed.color,
            ApolloColorPalette.red.color,
            ApolloColorPalette.red.color,
            ApolloColorPalette.mediumRed.color,
            ApolloColorPalette.mediumRed.color,
            ApolloColorPalette.deepRed.color,
            ApolloColorPalette.deepRed.color,
            // ApolloColorPalette.darkestRed.color,
            // ApolloColorPalette.darkestRed.color,
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
            // 0.85001,
            // 1
          ]);

    bossBarBackPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round
      ..color = barBackPaint.color;
    bossBarHitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = height
      ..strokeCap = StrokeCap.round
      ..color = ApolloColorPalette.nearlyWhite.color;
  }

  void buildBossTextPosition() {
    final heightPadding = bossBarHeightPadding(hudScale);
    final height = bossBarHeight(hudScale);
    final gameSize = gameEnviroment.gameCamera.viewport.size;
    bossText?.position =
        Vector2(gameSize.x / 2, gameSize.y - heightPadding - height);
  }

  void drawBossHealthBar(Canvas canvas) {
    final gameSize = gameEnviroment.gameCamera.viewport.size;
    final heightPadding = bossBarHeightPadding(hudScale);
    final widthPadding = bossBarWidthPadding(hudScale);
    final height = bossBarHeight(hudScale);

    if (primaryBoss != null || true) {
      final y = gameSize.y - heightPadding - (height / 2);
      final xBegin = widthPadding + height / 2;
      final extraPadding = 1 * hudScale.scale;
      canvas.drawLine(Offset(xBegin + extraPadding, y),
          Offset(gameSize.x - xBegin - extraPadding, y), bossBarBackPaint);
      canvas.drawLine(Offset(xBegin + extraPadding + 250, y),
          Offset(gameSize.x - xBegin - extraPadding - 250, y), bossBarPaint);

      if (displayBossHit) {
        canvas.drawLine(Offset(widthPadding + 250, y),
            Offset(gameSize.x - widthPadding - 250, y), bossBarHitPaint);
      }

      bossText ??= TextComponent(
          text: primaryBoss?.entityType.name ?? "Placeholder Demon",
          anchor: Anchor.bottomCenter,
          textRenderer: colorPalette.buildTextPaint(hudFontSize * .75,
              ShadowStyle.light, ApolloColorPalette.red.color))
        ..addToParent(this)
        ..loaded.then((value) {
          buildBossTextPosition();
        });
    } else if (currentBosses.isNotEmpty) {
      primaryBoss = currentBosses.first;
      drawBossHealthBar(canvas);
      return;
    } else {
      return;
    }
    final bossWithoutPrimary =
        currentBosses.where((element) => element != primaryBoss).toList();
  }

  Future<void> initBossBorder() async {
    final heightBoss = bossBarHeight(hudScale);
    bossBarLeftSprite = SpriteComponent(
      sprite: await Sprite.load(ImagesAssetsUi.bossBarLeft.flamePath),
      anchor: Anchor.bottomLeft,
    );
    bossBarRightSprite = SpriteComponent(
      sprite: await Sprite.load(ImagesAssetsUi.bossBarRight.flamePath),
      anchor: Anchor.bottomRight,
    );
    bossBarMidSprite = SpriteComponent(
      // size: Vector2.,
      sprite: await Sprite.load(ImagesAssetsUi.bossBarCenter.flamePath),
      anchor: Anchor.bottomCenter,
    );

    bossBorderSprite = SpriteComponent(
        sprite: await Sprite.load(ImagesAssetsUi.bossBarBorder.flamePath),
        anchor: Anchor.bottomCenter,
        priority: -1);

    bossBarMidSprite.size = bossBarMidSprite.sprite!.srcSize
      ..scaledToDimension(true, heightBoss);
    bossBarLeftSprite.size = bossBarLeftSprite.sprite!.srcSize
      ..scaledToDimension(true, heightBoss);
    bossBarRightSprite.size = bossBarRightSprite.sprite!.srcSize
      ..scaledToDimension(true, heightBoss);

    applyBossBorderPositions();
    addAll([
      bossBarLeftSprite,
      bossBorderSprite,
      bossBarRightSprite,
      bossBarMidSprite,
    ]);
  }

  void removeBoss(Entity boss) {
    currentBosses.remove(boss);
  }

  @override
  void initPaints() {
    super.initPaints();
    buildBossPaint();
  }

  @override
  FutureOr<void> onLoad() async {
    await initBossBorder();

    return super.onLoad();
  }

  @override
  void onParentResize(Vector2 size) {
    if (isLoaded) {
      buildBossTextPosition();
      applyBossBorderPositions();
      buildBossPaint();
    }
    super.onParentResize(size);
  }

  @override
  void render(ui.Canvas canvas) {
    drawBossHealthBar(canvas);

    super.render(canvas);
  }
}

mixin ExperienceBar on BaseHud {
  late final SpriteComponent xpBarLeftSprite;
  late final SpriteComponent xpBarMidSprite;
  late final SpriteComponent xpBarRightSprite;
  late final Paint xpPaint;
  late final Paint xpPulsePaint;

  late SpriteComponent xpBarBorder;

  void applyXpBorderPositions() {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);

    xpBarLeftSprite.position = Vector2(widthPadding, heightPadding);
    xpBarRightSprite.position = Vector2(
        gameEnviroment.gameCamera.viewport.size.x - widthPadding,
        heightPadding);
    xpBarMidSprite.position =
        Vector2((gameEnviroment.gameCamera.viewport.size.x / 2), heightPadding);

    xpBarBorder.position =
        Vector2((gameEnviroment.gameCamera.viewport.size.x / 2), heightPadding);
    xpBarBorder.size = Vector2(
        gameEnviroment.gameCamera.viewport.size.x -
            (widthPadding * 2) -
            (height * 2),
        height);
  }

  void drawXpBar(Canvas canvas) {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);

    final viewportSize = gameEnviroment.gameCamera.viewport.size;
    final barSize = viewportSize.x - (widthPadding * 2);

    final basePath = buildSlantedPath(
        1, Offset(widthPadding, heightPadding), height, barSize, true);
    canvas.drawPath(basePath, barBackPaint);

    canvas.drawPath(
        buildSlantedPath(
            (player!.percentOfLevelGained * 2) - 1,
            Offset(widthPadding, heightPadding),
            height,
            barSize * player!.percentOfLevelGained,
            true,
            1),
        xpPaint);
  }

  Future<void> initXpBorder() async {
    //                 final heightPaddingBoss = bossBarHeightPadding(hudScale);
    // final widthPaddingBoss = bossBarWidthPadding(hudScale);
    // final heightBoss = bossBarHeight(hudScale);
    //     final heightPadding = xpBarHeigthtPadding(hudScale);
    // final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);
    // final baseSize = Vector2.all(height);
    xpBarLeftSprite = SpriteComponent(
      sprite: await Sprite.load(ImagesAssetsUi.xpBarLeft.flamePath),
      anchor: Anchor.topLeft,
    );

    xpBarBorder = SpriteComponent(
        sprite: await Sprite.load('ui/xp_bar_border.png'),
        anchor: Anchor.topCenter,
        priority: -1);

    xpBarRightSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_right.png'),
      anchor: Anchor.topRight,
    );
    xpBarMidSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_center.png'),
      anchor: Anchor.topCenter,
    );

    xpBarMidSprite.size = xpBarMidSprite.sprite!.srcSize
      ..scaledToDimension(true, height);
    xpBarLeftSprite.size = xpBarLeftSprite.sprite!.srcSize
      ..scaledToDimension(true, height);
    xpBarRightSprite.size = xpBarRightSprite.sprite!.srcSize
      ..scaledToDimension(true, height);

    applyXpBorderPositions();
    addAll([xpBarLeftSprite, xpBarRightSprite, xpBarMidSprite, xpBarBorder]);
  }

  @override
  void initPaints() {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final height = xpBarHeight(hudScale);

    xpPaint = Paint()
      ..shader = ui.Gradient.linear(
          Offset(0, heightPadding), Offset(0, heightPadding + height), [
        colorPalette.primaryColor,
        // colorPalette.secondaryColor,
        colorPalette.secondaryColor,
        colorPalette.primaryColor,
      ], [
        // 0.49,
        0.499,
        0.501,
        1
      ]);

    super.initPaints();
  }

  @override
  FutureOr<void> onLoad() async {
    await initXpBorder();
    return super.onLoad();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (isLoaded) {
      final widthPadding = xpBarWidthPadding(hudScale);
      final height = xpBarHeight(hudScale);
      xpBarRightSprite.position.x =
              gameEnviroment.gameCamera.viewport.size.x - widthPadding - height
          // +
          // 6 +
          // 3
          ;
      applyXpBorderPositions();
    }

    super.onParentResize(maxSize);
  }

  @override
  void render(Canvas canvas) {
    // XP
    drawXpBar(canvas);

    super.render(canvas);
  }
}
