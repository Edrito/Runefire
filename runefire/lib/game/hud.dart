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

enum HudScale {
  small(2),
  medium(3),
  large(4);

  const HudScale(this.scale);
  final double scale;
}

const smallBossBarWidthPercentOfMain = .5;

double xpBarWidthPadding(HudScale scale) => 64;
double xpBarHeigthtPadding(HudScale scale) => 8.0 * scale.scale;
double xpBarHeight(HudScale scale) => 16 * scale.scale;

double bossBarHeightPadding(HudScale scale) => 8.0 * scale.scale;
double bossBarWidthPadding(HudScale scale) => 64;

double bossBarHeight(HudScale scale) => 16 * scale.scale;

double smallBossBarHeightPadding(HudScale scale) => 16 * scale.scale;

double smallBossBarHeight(HudScale scale) => 16 * scale.scale;

class GameHud extends PositionComponent {
  GameHud(this.gameEnv);

  late final Paint barBackPaint;
  late final SpriteComponent bossBarLeftSprite;
  late final SpriteComponent bossBarMidSprite;
  late final SpriteComponent bossBarRightSprite;
  late final SpriteComponent characterPortrait;
  late final CircleComponent characterPortraitBacking;
  late final FpsTextComponent fpsCounter = FpsTextComponent(
      textRenderer:
          TextPaint(style: defaultStyle.copyWith(fontSize: hudFontSize * .75)),
      anchor: Anchor.bottomRight)
    ..loaded.then((value) => fpsTextPosition());

  late final Paint healthPaint;
  late final TextComponent levelCounter;
  late final Paint magicPaint;
  late final CaTextComponent timerText;
  late final SpriteComponent xpBarLeftSprite;
  late final SpriteComponent xpBarMidSprite;
  late final SpriteComponent xpBarRightSprite;
  late final Paint xpPaint;
  late final Paint xpPulsePaint;

  Map<int, SpriteComponent> ammoSprites = {};
  // Expendable? _currentExpendable;
  late Sprite blankExpendableSprite;

  late Paint bossBarBackPaint;
  late Paint bossBarHitPaint;
  late Paint bossBarPaint;
  late SpriteComponent bossBorderSprite;
  List<Entity> currentBosses = [];
  bool displayBossHit = false;
  late SpriteComponent expendableIcon;
  int fps = 0;
  GameEnviroment gameEnv;
  late SpriteAnimationComponent healthEnergyFrame;
  HudScale hudScale = HudScale.medium;
  //Level
  // late CircleComponent levelBackground;
  late PositionComponent levelWrapper;

  Color staminaColor = colorPalette.primaryColor;
  late Paint staminaPaint;
  //Timer
  // late HudMarginComponent timerParent;

  //Margin Parent
  late HudMarginComponent topLeftMarginParent;

  late SpriteComponent xpBarBorder;

  Sprite? ammoSprite;
  TextComponent? bossText;
  Sprite? noAmmoSprite;
  Player? player;
  Weapon? previousWeapon;
  Entity? primaryBoss;

  @override
  final double width = 100;

  bool get bossBarActive => primaryBoss != null;

  void addBoss(Entity boss) {
    currentBosses.add(boss);
  }

  void applyAmmoSizeEffect(
    SpriteComponent ammoSpriteComponent,
  ) {
    EffectController bulletUseEffectController = EffectController(
        duration: .15, reverseDuration: .05, curve: Curves.easeOutCirc);
    ammoSpriteComponent
        .add(ScaleEffect.by(Vector2.all(1.5), bulletUseEffectController));
  }

  void applyBossBorderPositions() {
    final gameSize = gameEnv.gameCamera.viewport.size;

    final heightPadding = bossBarHeightPadding(hudScale);
    final widthPadding = bossBarWidthPadding(hudScale);
    final height = bossBarHeight(hudScale);

    bossBarLeftSprite.position =
        Vector2(widthPadding, gameSize.y - heightPadding);
    bossBarRightSprite.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - widthPadding,
        gameSize.y - heightPadding);

    bossBarMidSprite.position = Vector2(
        (gameEnv.gameCamera.viewport.size.x / 2), gameSize.y - heightPadding);

    bossBorderSprite.position = Vector2(
        (gameEnv.gameCamera.viewport.size.x / 2), gameSize.y - heightPadding);
    bossBorderSprite.size = Vector2(
        gameEnv.gameCamera.viewport.size.x -
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

  void applyXpBorderPositions() {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);

    xpBarLeftSprite.position = Vector2(widthPadding, heightPadding);
    xpBarRightSprite.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - widthPadding, heightPadding);
    xpBarMidSprite.position =
        Vector2((gameEnv.gameCamera.viewport.size.x / 2), heightPadding);

    xpBarBorder.position =
        Vector2((gameEnv.gameCamera.viewport.size.x / 2), heightPadding);
    xpBarBorder.size = Vector2(
        gameEnv.gameCamera.viewport.size.x - (widthPadding * 2) - (height * 2),
        height);
  }

  void buildBossPaint() {
    final heightPadding = bossBarHeightPadding(hudScale);
    final height = bossBarHeight(hudScale);
    final viewportSize = gameEnv.gameCamera.viewport.size;
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
    final gameSize = gameEnv.gameCamera.viewport.size;
    bossText?.position =
        Vector2(gameSize.x / 2, gameSize.y - heightPadding - height);
  }

  Future<void> buildRemainingAmmoText(Player player) async {
    Weapon? currentWeapon = player.currentWeapon;
    // if (currentWeapon is ReloadFunctionality) {
    final reload = currentWeapon is ReloadFunctionality ? currentWeapon : null;
    String rtr = "";
    final remainingAmmo = reload?.remainingAttacks ?? 0;
    final maxAmmo = reload?.maxAttacks.parameter ?? 0;

    if (ammoSprites.length > maxAmmo) {
      final toRemove = ammoSprites.entries
          .where((element) => element.key >= maxAmmo)
          .toList();
      for (var element in toRemove) {
        element.value.removeFromParent();
        ammoSprites.remove(element.key);
      }
    }
    // bool noAmmo = true;
    for (var i = 0; i < maxAmmo; i++) {
      if (ammoSprites[i] == null) {
        ammoSprite ??= await Sprite.load(ImagesAssetsAmmo.ammo.flamePath);
        const maxYSize = 8.0;
        Vector2 size = ammoSprite!.srcSize
          ..scaledToDimension(true, maxYSize * hudScale.scale);
        final spriteComponent = SpriteComponent(
            sprite: ammoSprite!,
            anchor: Anchor.center,
            position: Vector2(
                ((i * size.x)) + (56 * hudScale.scale), 28 * hudScale.scale),
            size: size);
        ammoSprites[i] = spriteComponent;
        topLeftMarginParent.add(spriteComponent);
      }

      final currentSpriteComponent = ammoSprites[i]!;
      if (i >= remainingAmmo) {
        if (currentSpriteComponent.sprite != noAmmoSprite) {
          if (previousWeapon == currentWeapon) {
            applyAmmoSizeEffect(currentSpriteComponent);
          }
          toggleAmmoSprite(currentSpriteComponent, false);
        }
      } else {
        toggleAmmoSprite(currentSpriteComponent, true);
      }
    }
    if (reload?.isReloading ?? false) {
      final stepTime = reload!.reloadTime.parameter / maxAmmo;
      final tempWeapon = currentWeapon;
      int steps = 0;
      async.Timer.periodic(stepTime.seconds, (timer) {
        if (steps >= maxAmmo ||
            steps >= ammoSprites.length ||
            previousWeapon != tempWeapon) {
          timer.cancel();
          return;
        }
        applyAmmoSizeEffect(ammoSprites[steps]!);
        toggleAmmoSprite(ammoSprites[steps]!, true);
        steps++;
      });
    }

    // } else {

    // }
    previousWeapon = currentWeapon;
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

  void drawBossHealthBar(Canvas canvas) {
    final gameSize = gameEnv.gameCamera.viewport.size;
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

  void drawHealthAndStaminaBar(Canvas canvas) {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale) + (24 * hudScale.scale);
    final height = xpBarHeight(hudScale);
    final scale = hudScale.scale;
    //Health and Stamina
    // double leftPadding = widthPadding;
    double heightOfBar = 8 * scale;
    double startOfBars = 5 * scale;
    final maxWidth = (gameEnv.gameCamera.viewport.size.x / 2) -
        (widthPadding * 1.75).clamp(100, double.infinity);

    final double healthBarStartY = (heightPadding * 2) + height + startOfBars;

    final double healthBarWidth =
        (player!.maxHealth.parameter * 6 * hudScale.scale).clamp(0.0, maxWidth);
    final double staminaBarWidth =
        (player!.stamina.parameter * 3 * hudScale.scale).clamp(0.0, maxWidth);

    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(widthPadding, healthBarStartY),
          heightOfBar,
          healthBarWidth,
        ),
        barBackPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(widthPadding, healthBarStartY),
          heightOfBar,
          player!.healthPercentage * healthBarWidth,
        ),
        healthPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset((widthPadding + 5.0), healthBarStartY + heightOfBar),
          heightOfBar,
          staminaBarWidth,
        ),
        barBackPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset((widthPadding + 5.0), healthBarStartY + heightOfBar),
          heightOfBar,
          staminaBarWidth *
              (player!.remainingStamina / player!.stamina.parameter),
        ),
        staminaPaint);
  }

  void drawXpBar(Canvas canvas) {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);

    final viewportSize = gameEnv.gameCamera.viewport.size;
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

  void fpsTextPosition() {
    final heightPaddingBoss = bossBarHeightPadding(hudScale);
    final widthPaddingBoss = bossBarWidthPadding(hudScale);
    final heightBoss = bossBarHeight(hudScale);

    fpsCounter.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - widthPaddingBoss,
        gameEnv.gameCamera.viewport.size.y - heightBoss - heightPaddingBoss);
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

  void initPaints([bool staminaOnly = false]) {
    if (staminaOnly) {
      staminaPaint = Paint()
        ..shader = ui.Gradient.linear(Offset.zero, const Offset(300, 0), [
          staminaColor,
          staminaColor.brighten(.4),
        ]);
      return;
    }
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final height = xpBarHeight(hudScale);

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

    barBackPaint = ApolloColorPalette.deepGray.paint();
    buildBossPaint();
  }

  Future<void> initXpBorder() async {
    //                 final heightPaddingBoss = bossBarHeightPadding(hudScale);
    // final widthPaddingBoss = bossBarWidthPadding(hudScale);
    // final heightBoss = bossBarHeight(hudScale);
    //     final heightPadding = xpBarHeigthtPadding(hudScale);
    // final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);
    final baseSize = Vector2.all(height);
    xpBarLeftSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_left.png'),
      anchor: Anchor.topLeft,
      size: baseSize,
    );

    xpBarBorder = SpriteComponent(
        sprite: await Sprite.load('ui/xp_bar_border.png'),
        anchor: Anchor.topCenter,
        priority: -1);

    xpBarRightSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_right.png'),
      anchor: Anchor.topRight,
      size: baseSize,
    );
    xpBarMidSprite = SpriteComponent(
      sprite: await Sprite.load('ui/xp_bar_center.png'),
      size: baseSize,
      anchor: Anchor.topCenter,
    );
    applyXpBorderPositions();
    addAll([xpBarLeftSprite, xpBarRightSprite, xpBarMidSprite, xpBarBorder]);
  }

  void levelTextPosition() {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final height = xpBarHeight(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final startPointText = height + (heightPadding * 2);
    levelCounter.position =
        Vector2(gameEnv.gameCamera.viewport.size.x / 2, startPointText);
    timerText.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - widthPadding, startPointText);
  }

  void removeBoss(Entity boss) {
    currentBosses.remove(boss);
  }

  void setLevel(int level) {
    levelCounter.text = level.toString();
  }

  void toggleAmmoSprite(
      SpriteComponent ammoSpriteComponent, bool hasAmmo) async {
    if (hasAmmo) {
      ammoSprite ??= await Sprite.load(ImagesAssetsAmmo.ammo.flamePath);
      ammoSpriteComponent.sprite = ammoSprite;
      ammoSpriteComponent.opacity = 1;
    } else {
      noAmmoSprite ??= await Sprite.load(ImagesAssetsAmmo.ammoEmpty.flamePath);
      ammoSpriteComponent.sprite = noAmmoSprite;
      ammoSpriteComponent.opacity = .5;
    }
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

  double get hudFontSize => (16 * hudScale.scale);

  @override
  FutureOr<void> onLoad() async {
    player = (gameEnv).player;

    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);

    //Wrappers
    topLeftMarginParent = HudMarginComponent(
        margin: EdgeInsets.fromLTRB(
            widthPadding, (heightPadding * 2) + height, 0, 0),
        anchor: Anchor.center);
    levelWrapper = PositionComponent(
        anchor: Anchor.center, position: Vector2.all(40.0 * hudScale.scale));

    //Health Bar
    final sprite = await spriteAnimations.uiHealthBar1;

    final healthBarSize = sprite.frames.first.sprite.srcSize;

    healthBarSize.scaledToDimension(true, 32 * hudScale.scale);

    healthEnergyFrame = SpriteAnimationComponent(
      animation: sprite,
      size: healthBarSize,
    );

    //FPS

    Future.delayed(1.seconds).then((_) {
      add(fpsCounter);
    });
    //Timer
    // timerParent = HudMarginComponent(
    //     margin: EdgeInsets.fromLTRB(0, 10 + height + heightPadding,
    //         widthPadding + (110 * hudScale.scale), 0),
    //     anchor: Anchor.center);
    timerText = CaTextComponent(
      anchor: Anchor.topRight,
      textRenderer: TextPaint(
          style: defaultStyle.copyWith(
              shadows: [colorPalette.buildShadow(ShadowStyle.light)],
              fontSize: hudFontSize)),
    );

    //Level
    levelCounter = CaTextComponent(
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(
          fontSize: hudFontSize,
          color: ApolloColorPalette.lightCyan.color,
          shadows: [colorPalette.buildShadow(ShadowStyle.light)],
        )),
        text: player!.currentLevel.toString());

    //Expendable
    blankExpendableSprite =
        await Sprite.load(ImagesAssetsExpendables.blank.flamePath);
    expendableIcon = SpriteComponent(
        size: Vector2.all(32.0 * hudScale.scale),
        position: Vector2(0, 40 * hudScale.scale),
        sprite: blankExpendableSprite);

    //Character
    characterPortrait = SpriteComponent(
        scale: Vector2.all(1),
        anchor: Anchor.center,
        position: Vector2.all(healthBarSize.y / 2),
        size: Vector2(16, 20) * hudScale.scale,
        priority: -1,
        // position: Vector2(64 * hudScale.scale, 64 * hudScale.scale),
        sprite: await Sprite.load(ImagesAssetsUi.placeholderFace.flamePath));
    characterPortraitBacking = CircleComponent(
      radius: (healthBarSize.y / 2) * .9,
      position: Vector2.all(healthBarSize.y / 2),
      anchor: Anchor.center,
      priority: -2,
      // position: Vector2(64 * hudScale, 64 * hudScale),
      paint: ApolloColorPalette.darkestBlue.paint(),
    );

    // timerParent.add(timerText);
    topLeftMarginParent.add(healthEnergyFrame);
    topLeftMarginParent.add(levelWrapper);
    topLeftMarginParent.add(characterPortrait);
    topLeftMarginParent.add(expendableIcon);
    topLeftMarginParent.add(characterPortraitBacking);
    add(timerText);

    addAll([topLeftMarginParent]);
    add(levelCounter);

    initPaints();
    await initXpBorder();
    await initBossBorder();
    return super.onLoad();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (isLoaded) {
      final widthPadding = xpBarWidthPadding(hudScale);
      final height = xpBarHeight(hudScale);
      fpsCounter.position.x = gameEnv.gameCamera.viewport.size.x - 200;
      size = gameEnv.gameCamera.viewport.size;
      if (xpBarRightSprite.isLoaded) {
        xpBarRightSprite.position.x =
                gameEnv.gameCamera.viewport.size.x - widthPadding - height
            // +
            // 6 +
            // 3
            ;
        applyXpBorderPositions();
        levelTextPosition();
        fpsTextPosition();
        buildBossTextPosition();
        applyBossBorderPositions();
      }

      buildBossPaint();
    }
    super.onParentResize(maxSize);
  }

  @override
  void render(Canvas canvas) {
    // XP
    drawXpBar(canvas);
    drawBossHealthBar(canvas);
    drawHealthAndStaminaBar(canvas);

    super.render(canvas);
  }
}
