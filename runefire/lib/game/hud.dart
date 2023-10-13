import 'dart:async';
import 'dart:async' as async;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide ScaleEffect, ColorEffect, MoveEffect;
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/game/hud_mixin.dart';
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
double xpBarHeight(HudScale scale) => 8 * scale.scale;
double healthStaminaBarHeight(HudScale scale) => 8 * scale.scale;

double bossBarHeightPadding(HudScale scale) => 8.0 * scale.scale;
double bossBarWidthPadding(HudScale scale) => 64;

double bossBarHeight(HudScale scale) => 8 * scale.scale;

double smallBossBarHeightPadding(HudScale scale) => 16 * scale.scale;

double smallBossBarHeight(HudScale scale) => 16 * scale.scale;

enum BarType {
  xpBar,
  bossBar,
  healthBar,
  staminaBar,
}

class GameHud extends BaseHud with BossBar, ExperienceBar {
  GameHud(super.gameEnviroment);
}

abstract class BaseHud extends PositionComponent {
  BaseHud(this.gameEnviroment) {
    hudScale = gameEnviroment.gameRef.systemDataComponent.dataObject.hudScale;
  }

  late final Paint barBackPaint;
  late final SpriteComponent characterPortrait;
  late final CircleComponent characterPortraitBacking;
  late final FpsTextComponent fpsCounter = FpsTextComponent(
      textRenderer:
          TextPaint(style: defaultStyle.copyWith(fontSize: hudFontSize * .75)),
      anchor: Anchor.bottomRight)
    ..loaded.then((value) => fpsTextPosition());

  late final SpriteComponent healthBarEnd;
  late final SpriteComponent healthBarMid;
  late final Paint healthPaint;
  late final TextComponent levelCounter;
  late final Paint magicPaint;
  late final SpriteComponent staminaBarEnd;
  late final SpriteComponent staminaBarMid;
  SpriteComponent? ammoPlaceholder;
  late final CaTextComponent timerText;

  Map<int, SpriteComponent> ammoSprites = {};
  late Sprite blankExpendableSprite;
  late SpriteComponent expendableIcon;
  int fps = 0;
  GameEnviroment gameEnviroment;
  late SpriteAnimationComponent healthEnergyFrame;
  late HudScale hudScale;
  bool isMagic = false;
  //Level
  // late CircleComponent levelBackground;
  late PositionComponent levelWrapper;

  //Timer
  // late HudMarginComponent timerParent;

  //Margin Parent
  late HudMarginComponent topLeftMarginParent;

  Sprite? ammoSprite;
  Sprite? noAmmoSprite;
  Player? player;
  Weapon? previousWeapon;

  @override
  final double width = 100;

  double get healthBarWidth =>
      (player!.maxHealth.parameter * 2 * hudScale.scale)
          .clamp(0.0, maxBarWidth);

  double get hudFontSize => (16 * hudScale.scale);
  double get maxBarWidth => (gameEnviroment.gameCamera.viewport.size.x * .35)
      .clamp(100, double.infinity);

  double get staminaBarWidth =>
      (player!.stamina.parameter * 2 * hudScale.scale).clamp(0.0, maxBarWidth);

  void applyAmmoSizeEffect(
    SpriteComponent ammoSpriteComponent,
  ) {
    EffectController bulletUseEffectController = EffectController(
        duration: .15, reverseDuration: .05, curve: Curves.easeOutCirc);
    ammoSpriteComponent
        .add(ScaleEffect.by(Vector2.all(1.5), bulletUseEffectController));
  }

  void barFlash(BarType barType) {
    final controller = EffectController(duration: .1, reverseDuration: .01);
    switch (barType) {
      case BarType.healthBar:
        healthBarEnd.add(ColorEffect(
            ApolloColorPalette.lightRed.color, const Offset(0, 1), controller));
        healthBarMid.add(ColorEffect(
            ApolloColorPalette.lightRed.color, const Offset(0, 1), controller));

        break;

      case BarType.staminaBar:
        final color = isMagic
            ? ApolloColorPalette.lightCyan.color
            : ApolloColorPalette.lightYellowGreen.color;
        staminaBarEnd.add(ColorEffect(color, const Offset(0, 1), controller));
        staminaBarMid.add(ColorEffect(color, const Offset(0, 1), controller));
        break;
      default:
    }
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
    previousWeapon = currentWeapon;
    checkPlaceholder(previousWeapon!);
  }

  bool placeholderEngaged = false;
  void checkPlaceholder(Weapon weapon) async {
    if (ammoSprites.isEmpty) {
      if (placeholderEngaged) return;
      placeholderEngaged = true;
      Sprite sprite = await Sprite.load(ImagesAssetsUi.inf.flamePath);

      // switch (weapon.weaponType.attackType) {
      //   case AttackType.magic:
      //     sprite = await Sprite.load(ImagesAssetsUi.magicIconSmall.flamePath);
      //     break;
      //   case AttackType.guns:
      //     sprite = await Sprite.load(ImagesAssetsUi.rangedIconSmall.flamePath);

      //     break;
      //   case AttackType.melee:
      //     sprite = await Sprite.load(ImagesAssetsUi.meleeIconSmall.flamePath);

      //     break;
      //   default:
      // }

      final size = sprite.srcSize..scaledToHeight(null, amount: hudScale.scale);
      final pos = Vector2((58 * hudScale.scale), 27.5 * hudScale.scale);

      ammoPlaceholder?.sprite = sprite;

      ammoPlaceholder ??=
          SpriteComponent(anchor: Anchor.center, size: size, sprite: sprite)
            ..addToParent(topLeftMarginParent);
      ammoPlaceholder?.position = pos + Vector2(50, 0);
      final controller =
          EffectController(duration: 1, curve: Curves.easeOutCirc);
      ammoPlaceholder?.add(OpacityEffect.fadeIn(controller));
      ammoPlaceholder?.add(MoveEffect.to(pos, controller));
    } else {
      placeholderEngaged = false;
      ammoPlaceholder?.sprite = null;
      ammoPlaceholder?.opacity = 0;
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
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale) + (24 * hudScale.scale);
    final height = xpBarHeight(hudScale);
    final scale = hudScale.scale;
    //Health and Stamina
    // double leftPadding = widthPadding;
    double heightOfBar = 8 * scale;
    double startOfBars = 5 * scale;

    final double healthBarStartY = (heightPadding * 2) + height + startOfBars;
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset(widthPadding, healthBarStartY),
          heightOfBar,
          healthBarWidth + (6 * scale),
        ),
        barBackPaint);
    // canvas.drawPath(
    //     buildSlantedPath(
    //       1,
    //       Offset(widthPadding, healthBarStartY),
    //       heightOfBar,
    //       player!.healthPercentage * healthBarWidth,
    //     ),
    //     healthPaint);
    canvas.drawPath(
        buildSlantedPath(
          1,
          Offset((widthPadding + 5.0), healthBarStartY + heightOfBar),
          heightOfBar,
          staminaBarWidth + (8 * scale),
        ),
        barBackPaint);
    // canvas.drawPath(
    //     buildSlantedPath(
    //       1,
    //       Offset((widthPadding + 5.0), healthBarStartY + heightOfBar),
    //       heightOfBar,
    //       staminaBarWidth *
    //           (player!.remainingStamina / player!.stamina.parameter),
    //     ),
    //     staminaPaint);
  }

  void fpsTextPosition() {
    final heightPaddingBoss = bossBarHeightPadding(hudScale);
    final widthPaddingBoss = bossBarWidthPadding(hudScale);
    final heightBoss = bossBarHeight(hudScale);

    fpsCounter.position = Vector2(
        gameEnviroment.gameCamera.viewport.size.x - widthPaddingBoss,
        gameEnviroment.gameCamera.viewport.size.y -
            heightBoss -
            heightPaddingBoss);
  }

  void initPaints() {
    barBackPaint = ApolloColorPalette.deepGray.paint();
  }

  void levelTextPosition() {
    final heightPadding = xpBarHeigthtPadding(hudScale);
    final height = xpBarHeight(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final startPointText = height + (heightPadding * 2);
    levelCounter.position =
        Vector2(gameEnviroment.gameCamera.viewport.size.x / 2, startPointText);
    timerText.position = Vector2(
        gameEnviroment.gameCamera.viewport.size.x - widthPadding,
        startPointText);
  }

  double previousHealthWidth = 0;
  double previousStaminaWidth = 0;

  void repositionHealthStaminaBar() {
    final double healthWidth =
        (healthBarWidth * player!.healthPercentage).clamp(0, 600);
    final double staminaWidth = (staminaBarWidth *
            (player!.remainingStamina / player!.stamina.parameter))
        .clamp(0, 600);

    if (healthWidth == previousHealthWidth &&
        staminaWidth == previousStaminaWidth) {
      return;
    }

    final height = healthStaminaBarHeight(hudScale);
    final widthPadding = (24 * hudScale.scale);
    final scale = hudScale.scale;

    final shiftLeft = height * .5;
    double startOfBars = 5 * scale;
    final staminaMidCircleOffsetRight = (4 * scale);

    final offset = Vector2(
        widthPadding - shiftLeft + staminaMidCircleOffsetRight / 2,
        startOfBars);

    healthBarMid.size = Vector2(healthWidth + 2, height);
    staminaBarMid.size = Vector2(staminaWidth + 2, height);

    healthBarEnd.position = Vector2(healthWidth, 0) + offset;
    healthBarMid.position = offset;

    staminaBarEnd.position =
        Vector2(staminaWidth + staminaMidCircleOffsetRight, height) + offset;
    staminaBarMid.position =
        Vector2(staminaMidCircleOffsetRight, height) + offset;

    previousHealthWidth = healthWidth;
    previousStaminaWidth = staminaWidth;
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

  void toggleStaminaColor(AttackType attackType) async {
    isMagic = attackType == AttackType.magic;
    await loaded;
    switch (attackType) {
      case AttackType.magic:
        staminaBarEnd.sprite =
            await Sprite.load(ImagesAssetsUi.magicBarCap.flamePath);
        staminaBarMid.sprite =
            await Sprite.load(ImagesAssetsUi.magicBarMid.flamePath);

        break;

      default:
        staminaBarEnd.sprite =
            await Sprite.load(ImagesAssetsUi.staminaBarCap.flamePath);
        staminaBarMid.sprite =
            await Sprite.load(ImagesAssetsUi.staminaBarMid.flamePath);
    }
  }

  @override
  FutureOr<void> onLoad() async {
    player = (gameEnviroment).player;

    final heightPadding = xpBarHeigthtPadding(hudScale);
    final widthPadding = xpBarWidthPadding(hudScale);
    final height = xpBarHeight(hudScale);
    final healthStaminaHeight = healthStaminaBarHeight(hudScale);

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

    healthBarEnd = SpriteComponent(
        anchor: Anchor.topLeft,
        size: Vector2.all(healthStaminaHeight),
        position: Vector2.zero(),
        priority: -5,
        sprite: await Sprite.load(ImagesAssetsUi.healthBarCap.flamePath));
    healthBarMid = SpriteComponent(
        anchor: Anchor.topLeft,
        priority: -10,
        position: Vector2(healthBarEnd.size.y, 0),
        sprite: await Sprite.load(ImagesAssetsUi.healthBarMid.flamePath));

    staminaBarEnd = SpriteComponent(
        anchor: Anchor.topLeft,
        size: Vector2.all(healthStaminaHeight),
        priority: -5,
        position: Vector2.zero(),
        sprite: await Sprite.load(ImagesAssetsUi.staminaBarCap.flamePath));
    staminaBarMid = SpriteComponent(
        anchor: Anchor.topLeft,
        priority: -10,
        position: Vector2(staminaBarEnd.size.y, 0),
        sprite: await Sprite.load(ImagesAssetsUi.staminaBarMid.flamePath));
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
    topLeftMarginParent.addAll([
      staminaBarEnd,
      staminaBarMid,
      healthBarEnd,
      healthBarMid,
    ]);
    add(timerText);

    addAll([topLeftMarginParent]);
    add(levelCounter);

    initPaints();
    repositionHealthStaminaBar();
    return super.onLoad();
  }

  @override
  void onParentResize(Vector2 maxSize) {
    if (isLoaded) {
      fpsCounter.position.x = gameEnviroment.gameCamera.viewport.size.x - 200;
      size = gameEnviroment.gameCamera.viewport.size;
      levelTextPosition();
      fpsTextPosition();
    }

    super.onParentResize(maxSize);
  }

  @override
  void render(Canvas canvas) {
    drawHealthAndStaminaBar(canvas);

    super.render(canvas);
  }

  @override
  void update(double dt) {
    repositionHealthStaminaBar();

    super.update(dt);
  }
}
