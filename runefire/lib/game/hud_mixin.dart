import 'dart:async';
import 'dart:async' as async;
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ScaleEffect;
import 'package:recase/recase.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/resources/damage_type_enum.dart';

class ElementalPowerIndicatorComponent extends PositionComponent {
  ElementalPowerIndicatorComponent({
    required this.player,
    required this.baseHud,
    super.position,
  }) : super(
          size: Vector2.zero(),
        );
  BaseHud baseHud;
  Player player;

  late final Paint frontPaint = Paint();
  late final ui.Gradient gradient;
  late final List<DamageType> damageTypeList;
  @override
  FutureOr<void> onLoad() async {
    damageTypeList = [...DamageType.values]..remove(DamageType.healing);
    final stops = <double>[
      for (int i = 0; i < damageTypeList.length + 1; i++) ...[
        i / (damageTypeList.length),
        i / (damageTypeList.length),
      ],
    ];
    stops.removeLast();
    stops.removeAt(0);

    gradient = ui.Gradient.sweep(
      Offset.zero,
      [
        for (final type in damageTypeList) ...[type.color, type.color],
      ],
      stops,
    );
    elementalPie = SpriteComponent(
      sprite: await Sprite.load(ImagesAssetsUi.elementalPie.flamePath),
      size: ImagesAssetsUi.elementalPie.size.asVector2 * baseHud.hudScale.scale,
      anchor: Anchor.center,
    );
    add(elementalPie);
    radius = elementalPie.size.y * .45;
    return super.onLoad();
  }

  Map<DamageType, double> get elementalPower => player.elementalPower;
  late final SpriteComponent elementalPie;
  late final double radius;

  Path hexPath = Path();
  Map<DamageType, Path> circleElementalPaths = {};
  Map<DamageType, Paint> circleElementalPaints = {};
  late final Paint backPaint = ApolloColorPalette.darkestGray.paint();

  @override
  void render(ui.Canvas canvas) {
    // canvas.drawCircle(const Offset(0, 0), radius, backPaint);
    const sixthAngle = 2 * pi / 6;
    final elementalPowerMap = elementalPower;
    frontPaint.shader = gradient;
    for (var i = 0; i < damageTypeList.length; i++) {
      final type = damageTypeList[i];
      circleElementalPaths[type] ??= Path();
      circleElementalPaints[type] ??= Paint()
        ..isAntiAlias = true
        ..color = type.color;
      // ..shader = ui.Gradient.radial(Offset.zero, radius, [
      //   type.color.darken(.2),
      //   type.color.darken(.2),
      //   type.color,
      //   type.color,
      //   type.color.brighten(.2),
      //   type.color.brighten(.2),
      // ], [
      //   .0,
      //   .33,
      //   .331,
      //   .66,
      //   .661,
      //   .1
      // ]);
      final tempRadius = (elementalPowerMap[type] ?? 0) * radius;
      final path = circleElementalPaths[type]!;
      path.reset();

      path.moveTo(0, 0);

      final angle1 = (sixthAngle * i) + sixthAngle / 2;
      final angle2 = (sixthAngle * (i + 1)) + sixthAngle / 2;

      final x1 = tempRadius * cos(angle1);
      final y1 = tempRadius * sin(angle1);

      path.lineTo(x1, y1);
      path.addArc(
        Rect.fromCircle(center: Offset.zero, radius: tempRadius),
        angle1,
        angle2 - angle1,
      );
      path.lineTo(0, 0);
      // path.lineTo(tempRadius * cos(angle2), tempRadius * sin(angle2));

      hexPath.close();

      canvas.drawPath(path, circleElementalPaints[type]!);
    }

    // frontPaint.shader = gradient;
    // hexPath.reset();
    // final radius = 400 * sqrt(3) / 2;
    // bool moved = false;
    // for (var i = 0; i < damageTypeList.length; i++) {
    //   final type = damageTypeList[i];
    //   final tempRadius = ((elementalPower[type] ?? 0) * radius) + 10;
    //   final x = tempRadius * cos(angle);
    //   final y = tempRadius * sin(angle);
    //   if (!moved) {
    //     hexPath.moveTo(tempRadius * cos((pi / 6)), 0);
    //     moved = true;
    //   }
    //   hexPath.lineTo(x, y);
    // }

    // // for (var element in damageTypeList) {}

    // // for (int i = 0; i < 6; i++) {}

    // hexPath.close();

    // canvas.drawPath(hexPath, frontPaint);

    super.render(canvas);
  }
}

mixin ElementalPowerIndicator on BaseHud {
  late final ElementalPowerIndicatorComponent elementalPowerIndicatorSprite;
  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    elementalPowerIndicatorSprite = ElementalPowerIndicatorComponent(
      player: player!,
      baseHud: this,
      position: Vector2.all(ImagesAssetsUi.elementalPie.size!.$2 * .5) *
          hudScale.scale,
    )..addToParent(topLeftMarginParent);
  }
}

mixin BossBar on BaseHud {
  SpriteComponent? bossBarLeftSprite;
  SpriteComponent? bossBarMidSprite;
  SpriteComponent? bossBarRightSprite;

  late Paint bossBarBackPaint;
  late Paint bossBarHitPaint;
  late Paint bossBarPaint;
  SpriteComponent? bossBorderSprite;

  List<Entity> currentBosses = [];
  bool displayBossHit = false;

  TextComponent? bossText;
  Entity? _activeBoss;

  bool get bossBarActive => currentBosses.isNotEmpty;

  void setActiveBoss(String? entityId) {
    _activeBoss = currentBosses
        .where((element) => element.entityId == entityId)
        .firstOrNull;
    buildBossText();
  }

  void addBosses(List<Entity> bosses, {String? primaryBossId}) {
    currentBosses.addAll(bosses);
    if (_activeBoss == null) {
      initBossBorder();

      if (primaryBossId != null) {
        setActiveBoss(primaryBossId);
      } else {
        setActiveBoss(currentBosses.firstOrNull?.entityId);
      }
    }
  }

  void removeBosses(List<Entity> bosses) {
    for (final boss in bosses) {
      removeBoss(boss);
    }
  }

  void applyBossBorderPositions() {
    final gameSize = gameEnviroment.gameCamera.viewport.size;

    final heightPadding = bossBarHeightPadding(hudScale);
    final widthPadding = bossBarWidthPadding(hudScale);
    final height = bossBarHeight(hudScale);

    bossBarLeftSprite?.position =
        Vector2(widthPadding, gameSize.y - heightPadding);
    bossBarRightSprite?.position = Vector2(
      gameEnviroment.gameCamera.viewport.size.x - widthPadding,
      gameSize.y - heightPadding,
    );

    bossBarMidSprite?.position = Vector2(
      gameEnviroment.gameCamera.viewport.size.x / 2,
      gameSize.y - heightPadding,
    );

    bossBorderSprite?.position = Vector2(
      gameEnviroment.gameCamera.viewport.size.x / 2,
      gameSize.y - heightPadding,
    );
    bossBorderSprite?.size = Vector2(
      gameEnviroment.gameCamera.viewport.size.x -
          (widthPadding * 2) -
          (bossBarLeftSprite?.width ?? 0),
      height,
    );
  }

  Future<void> applyBossHitEffect([DamageType? color]) async {
    displayBossHit = true;
    if (color != null) {
      bossBarHitPaint.color = color.color.brighten(.2);
    } else {
      bossBarHitPaint.color = ApolloColorPalette.nearlyWhite.color;
    }

    await gameEnviroment.game
        .gameAwait(.06)
        .then((value) => displayBossHit = false);
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
          Offset(
            viewportSize.x / 2,
            viewportSize.y - heightPadding - (height / 2),
          ),
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

    if (_activeBoss != null) {
      final y = gameSize.y - heightPadding - (height / 2);
      final xBegin = widthPadding + height / 2;
      final extraPadding = 1 * hudScale.scale;
      canvas.drawLine(
        Offset(xBegin + extraPadding, y),
        Offset(gameSize.x - xBegin - extraPadding, y),
        bossBarBackPaint,
      );
      final start = xBegin + extraPadding;
      final end = gameSize.x - xBegin - extraPadding;
      final length = end - start;
      final halfLength = length / 2;
      final primaryBossHealthPercent =
          (_activeBoss! as HealthFunctionality).healthPercentage;
      final offsetBegin =
          xBegin + extraPadding + (halfLength * (1 - primaryBossHealthPercent));
      final offsetEnd = gameSize.x -
          xBegin -
          extraPadding -
          (halfLength * (1 - primaryBossHealthPercent));
      canvas.drawLine(
        Offset(
          offsetBegin,
          y,
        ),
        Offset(
          offsetEnd,
          y,
        ),
        bossBarPaint,
      );

      if (displayBossHit) {
        canvas.drawLine(
          Offset(offsetBegin, y),
          Offset(offsetEnd, y),
          bossBarHitPaint,
        );
      }

      bossText ??= TextComponent(
        anchor: Anchor.bottomCenter,
        textRenderer: colorPalette.buildTextPaint(
          hudFontSize * .75,
          ShadowStyle.light,
          ApolloColorPalette.red.color,
        ),
      )
        ..addToParent(this)
        ..loaded.then((value) {
          buildBossTextPosition();
          buildBossText();
        });
    }
    final bossWithoutPrimary =
        currentBosses.where((element) => element != _activeBoss).toList();
    if (bossWithoutPrimary.isNotEmpty) {}
    //Todo add other boss bars
  }

  void buildBossText() {
    bossText?.text = _activeBoss is Enemy
        ? (_activeBoss! as Enemy).enemyType.enemyName
        : (_activeBoss?.entityType.name.titleCase ?? 'Placeholder Demon');
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
      priority: -1,
    );

    bossBarMidSprite?.size = bossBarMidSprite!.sprite!.srcSize
      ..scaledToDimension(true, heightBoss);
    bossBarLeftSprite?.size = bossBarLeftSprite!.sprite!.srcSize
      ..scaledToDimension(true, heightBoss);
    bossBarRightSprite?.size = bossBarRightSprite!.sprite!.srcSize
      ..scaledToDimension(true, heightBoss);

    applyBossBorderPositions();
    bossBarLeftSprite?.addToParent(this);
    bossBorderSprite?.addToParent(this);
    bossBarMidSprite?.addToParent(this);
    bossBarRightSprite?.addToParent(this);
  }

  void _removeBossBorder() {
    bossText?.removeFromParent();
    bossBarLeftSprite?.removeFromParent();
    bossBarRightSprite?.removeFromParent();
    bossBarMidSprite?.removeFromParent();
    bossBorderSprite?.removeFromParent();

    bossText = null;
    bossBarLeftSprite = null;
    bossBarRightSprite = null;
    bossBarMidSprite = null;
    bossBorderSprite = null;
  }

  void removeBoss(Entity boss) {
    currentBosses.remove(boss);
    if (boss.entityId == _activeBoss?.entityId) {
      setActiveBoss(currentBosses.firstOrNull?.entityId);
    }

    if (_activeBoss == null) {
      _removeBossBorder();
    }
  }

  @override
  void initPaints() {
    super.initPaints();
    buildBossPaint();
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
      heightPadding,
    );
    xpBarMidSprite.position =
        Vector2(gameEnviroment.gameCamera.viewport.size.x / 2, heightPadding);

    xpBarBorder.position =
        Vector2(gameEnviroment.gameCamera.viewport.size.x / 2, heightPadding);
    xpBarBorder.size = Vector2(
      gameEnviroment.gameCamera.viewport.size.x -
          (widthPadding * 2) -
          (height * 2),
      height,
    );
  }

  void drawXpBar(Canvas canvas) {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);

    final viewportSize = gameEnviroment.gameCamera.viewport.size;
    final barSize = viewportSize.x - (widthPadding * 2);

    final basePath = buildSlantedPath(
      1,
      Offset(widthPadding, heightPadding),
      height,
      barSize,
      true,
    );
    canvas.drawPath(basePath, barBackPaint);

    canvas.drawPath(
      buildSlantedPath(
        (player!.percentOfLevelGained * 2) - 1,
        Offset(widthPadding, heightPadding),
        height,
        barSize * player!.percentOfLevelGained,
        true,
        1,
      ),
      xpPaint,
    );
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
      priority: -1,
    );

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
        1,
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
