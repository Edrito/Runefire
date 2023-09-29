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

  late final Paint barBackPaint;
  late final SpriteComponent bossBarLeftSprite;
  late final SpriteComponent bossBarMidSprite;
  late final SpriteComponent bossBarRightSprite;
  late final SpriteComponent characterPortrait;
  late final CircleComponent characterPortraitBacking;
  late final FpsTextComponent fpsCounter = FpsTextComponent(
      textRenderer: TextPaint(style: defaultStyle.copyWith(fontSize: 32)),
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

  // Expendable? _currentExpendable;
  late Sprite blankExpendableSprite;

  late Paint bossBarBackPaint;
  late Paint bossBarHitPaint;
  late Paint bossBarPaint;
  late SpriteComponent bossBorderSprite;
  Sprite? ammoSprite;
  Sprite? noAmmoSprite;
  Map<int, SpriteComponent> ammoSprites = {};
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

  late SpriteComponent xpBarBorder;

  TextComponent? bossText;
  Player? player;
  Entity? primaryBoss;

  @override
  final double width = 100;

  bool get bossBarActive => primaryBoss != null;

  bool displayBossHit = false;

  void applyBossHitEffect([DamageType? color]) async {
    displayBossHit = true;
    if (color != null) {
      bossBarHitPaint.color = color.color.brighten(.2);
    } else {
      bossBarHitPaint.color = ApolloColorPalette.nearlyWhite.color;
    }
    await Future.delayed(.06.seconds).then((value) => displayBossHit = false);
  }

  void addBoss(Entity boss) {
    currentBosses.add(boss);
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

    bossBorderSprite.position = Vector2(
        (gameEnv.gameCamera.viewport.size.x / 2),
        gameSize.y - bossBarHeightPadding + 4);
    bossBorderSprite.size = Vector2(
        gameEnv.gameCamera.viewport.size.x - (bossBarWidthPadding * 2),
        bossBarHeight + 8);
  }

  void applyXpBorderPositions() {
    xpBarLeftSprite.position = Vector2(xpBarWidthPadding, xpBarHeigthtPadding);
    xpBarRightSprite.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - xpBarWidthPadding - xpBarHeight,
        xpBarHeigthtPadding);
    xpBarMidSprite.position =
        Vector2((gameEnv.gameCamera.viewport.size.x / 2), xpBarHeigthtPadding);

    xpBarBorder.position =
        Vector2((gameEnv.gameCamera.viewport.size.x / 2), xpBarHeigthtPadding);
    xpBarBorder.size = Vector2(
        gameEnv.gameCamera.viewport.size.x -
            (xpBarWidthPadding * 2) -
            (xpBarHeight * 2),
        xpBarHeight);
  }

  void buildBossHealthBar(Canvas canvas) {
    final gameSize = gameEnv.gameCamera.viewport.size;

    if (primaryBoss != null || true) {
      final y = gameSize.y - bossBarHeightPadding - (bossBarHeight / 2);
      canvas.drawLine(Offset(bossBarWidthPadding, y),
          Offset(gameSize.x - bossBarWidthPadding, y), bossBarBackPaint);
      canvas.drawLine(Offset(bossBarWidthPadding + 250, y),
          Offset(gameSize.x - bossBarWidthPadding - 250, y), bossBarPaint);

      if (displayBossHit) {
        canvas.drawLine(Offset(bossBarWidthPadding + 250, y),
            Offset(gameSize.x - bossBarWidthPadding - 250, y), bossBarHitPaint);
      }

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

  void buildBossPaint() {
    final viewportSize = gameEnv.gameCamera.viewport.size;
    bossBarPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bossBarHeight
      ..strokeCap = StrokeCap.round
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
      ..strokeWidth = bossBarHeight
      ..strokeCap = StrokeCap.round
      ..color = barBackPaint.color;
    bossBarHitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = bossBarHeight
      ..strokeCap = StrokeCap.round
      ..color = ApolloColorPalette.nearlyWhite.color;
  }

  void buildBossTextPosition() {
    final gameSize = gameEnv.gameCamera.viewport.size;
    bossText?.position = Vector2(
        gameSize.x / 2, gameSize.y - bossBarHeightPadding - bossBarHeight - 10);
  }

  Weapon? previousWeapon;
  Future<void> buildRemainingAmmoText(Player player) async {
    Weapon? currentWeapon = player.currentWeapon;
    if (currentWeapon is ReloadFunctionality) {
      String rtr = "";
      final remainingAmmo = currentWeapon.remainingAttacks;
      final maxAmmo = currentWeapon.maxAttacks.parameter;

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
          ammoSprite ??= await Sprite.load('ui/ammo.png');
          const maxYSize = 16;
          Vector2 size =
              ammoSprite!.srcSize.scaledToDimension(true, maxYSize * hudScale);
          final spriteComponent = SpriteComponent(
              sprite: ammoSprite!,
              anchor: Anchor.center,
              position: Vector2(
                  ((i * size.x * .75 * hudScale)) + (132.5 * hudScale),
                  68 * hudScale),
              size: size);
          ammoSprites[i] = spriteComponent;
          topLeftMarginParent.add(spriteComponent);
        }

        final currentSpriteComponent = ammoSprites[i]!;
        if (i >= remainingAmmo!) {
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
      if (currentWeapon.isReloading) {
        final stepTime = currentWeapon.reloadTime.parameter / maxAmmo;
        final tempWeapon = currentWeapon;
        int steps = 0;
        async.Timer.periodic(stepTime.seconds, (timer) {
          if (steps >= maxAmmo ||
              steps >= ammoSprites.length ||
              previousWeapon != tempWeapon) {
            timer.cancel();
            return;
          }
          applyAmmoSizeEffect(ammoSprites[steps]!, true);
          steps++;
        });
      }

      remainingAmmoText.text = rtr;
    } else {
      remainingAmmoText.text = "";
    }
    previousWeapon = currentWeapon;
  }

  void toggleAmmoSprite(
      SpriteComponent ammoSpriteComponent, bool hasAmmo) async {
    if (hasAmmo) {
      ammoSprite ??= await Sprite.load('ui/ammo.png');
      ammoSpriteComponent.sprite = ammoSprite;
      ammoSpriteComponent.opacity = 1;
    } else {
      noAmmoSprite ??= await Sprite.load('ui/ammo_empty.png');
      ammoSpriteComponent.sprite = noAmmoSprite;
      ammoSpriteComponent.opacity = .5;
    }
  }

  void applyAmmoSizeEffect(SpriteComponent ammoSpriteComponent,
      [bool sizeEffect = false]) {
    EffectController bulletUseEffectController = EffectController(
        onMax: () {
          if (sizeEffect) {
            toggleAmmoSprite(ammoSpriteComponent, true);
          }
        },
        duration: .15,
        reverseDuration: .05,
        curve: Curves.easeOutCirc);
    ammoSpriteComponent
        .add(ScaleEffect.by(Vector2.all(1.5), bulletUseEffectController));
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
    const heightOfBar = 18.5;
    const startOfBars = 12.0;
    final heightOfBarScaled = heightOfBar * hudScale;
    final maxWidth = (gameEnv.gameCamera.viewport.size.x / 2) -
        (leftPadding * hudScale) -
        (xpBarWidthPadding * 2);

    final double healthBarStartY = (xpBarHeigthtPadding * 2) +
        xpBarHeight +
        startOfBars +
        (13 * (hudScale - 1));

    final double healthBarWidth =
        (player!.maxHealth.parameter * 6 * hudScale).clamp(0, maxWidth);
    final double staminaBarWidth = player!.stamina.parameter * 3 * hudScale;

    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(leftPadding * hudScale, healthBarStartY),
          heightOfBarScaled,
          healthBarWidth,
        ),
        barBackPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(leftPadding * hudScale, healthBarStartY),
          heightOfBarScaled,
          player!.healthPercentage * healthBarWidth,
        ),
        healthPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset((leftPadding + 5) * hudScale,
              healthBarStartY + heightOfBarScaled),
          heightOfBarScaled,
          staminaBarWidth,
        ),
        barBackPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset((leftPadding + 5) * hudScale,
              healthBarStartY + heightOfBarScaled),
          heightOfBarScaled,
          staminaBarWidth *
              (player!.remainingStamina / player!.stamina.parameter),
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

  void fpsTextPosition() {
    fpsCounter.position = Vector2(
        gameEnv.gameCamera.viewport.size.x - bossBarWidthPadding,
        gameEnv.gameCamera.viewport.size.y -
            bossBarHeight -
            (bossBarHeightPadding * 2));
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

    bossBorderSprite = SpriteComponent(
        sprite: await Sprite.load('ui/boss_bar_border.png'),
        anchor: Anchor.bottomCenter,
        priority: -1);

    bossBarMidSprite.size = bossBarMidSprite.sprite!.srcSize
        .scaledToDimension(true, bossBarHeight + 8);
    bossBarLeftSprite.size = bossBarLeftSprite.sprite!.srcSize
        .scaledToDimension(true, bossBarHeight + 8);
    bossBarRightSprite.size = bossBarRightSprite.sprite!.srcSize
        .scaledToDimension(true, bossBarHeight + 8);
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
      ..shader = ui.Gradient.linear(const Offset(0, xpBarHeigthtPadding),
          const Offset(0, xpBarHeigthtPadding + xpBarHeight), [
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
    final baseSize = Vector2.all(xpBarHeight);
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
      anchor: Anchor.topLeft,
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
    levelCounter.position = Vector2(gameEnv.gameCamera.viewport.size.x / 2,
        xpBarHeight + (xpBarHeigthtPadding * 2));
  }

  void removeBoss(Entity boss) {
    currentBosses.remove(boss);
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
    final double hudTextSize = (defaultStyle.fontSize! * .8 * hudScale);

    //Wrappers
    topLeftMarginParent = HudMarginComponent(
        margin: const EdgeInsets.fromLTRB(
            xpBarWidthPadding, (xpBarHeigthtPadding * 2) + xpBarHeight, 0, 0),
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
              fontSize: hudTextSize)),
    );

    //Level
    levelCounter = CaTextComponent(
        anchor: Anchor.topCenter,
        textRenderer: TextPaint(
            style: defaultStyle.copyWith(
          fontSize: hudTextSize,
          color: ApolloColorPalette.lightCyan.color,
          shadows: [colorPalette.buildShadow(ShadowStyle.light)],
        )),
        text: player!.currentLevel.toString());

    //Remaining Ammo text
    remainingAmmoText = TextComponent(
      position: Vector2(125 * hudScale, 57.5 * hudScale),
      textRenderer: TextPaint(
          style: defaultStyle.copyWith(
              fontSize: hudTextSize * .8,
              color: ApolloColorPalette.offWhite.color,
              shadows: [colorPalette.buildShadow(ShadowStyle.light)])),
    );

    //Expendable
    blankExpendableSprite = await Sprite.load('expendables/blank.png');
    expendableIcon = SpriteComponent(
        size: Vector2.all(hudScale * 64),
        position: Vector2(15 * hudScale, 85 * hudScale),
        sprite: blankExpendableSprite);

    //Character
    characterPortrait = SpriteComponent(
        scale: Vector2.all(1),
        anchor: Anchor.center,
        position: Vector2.all(healthBarSize.y / 2),
        size: Vector2.all(healthBarSize.y * .9),
        priority: -1,
        // position: Vector2(64 * hudScale, 64 * hudScale),
        sprite: await Sprite.load('ui/placeholder_face.png'));
    characterPortraitBacking = CircleComponent(
      radius: (healthBarSize.y / 2) * .9,
      position: Vector2.all(healthBarSize.y / 2),
      anchor: Anchor.center,
      priority: -2,
      // position: Vector2(64 * hudScale, 64 * hudScale),
      paint: ApolloColorPalette.darkestBlue.paint(),
    );

    timerParent.add(timerText);
    topLeftMarginParent.add(healthEnergyFrame);
    topLeftMarginParent.add(levelWrapper);
    topLeftMarginParent.add(characterPortrait);
    topLeftMarginParent.add(expendableIcon);
    topLeftMarginParent.add(characterPortraitBacking);
    topLeftMarginParent.add(remainingAmmoText);
    add(timerParent);

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
    buildBossHealthBar(canvas);
    drawHealthAndStaminaBar(canvas);

    super.render(canvas);
  }
}
