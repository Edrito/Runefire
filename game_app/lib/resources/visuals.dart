import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'dart:ui';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'package:game_app/main.dart';
import 'enums.dart';
import 'functions/functions.dart';

const uiWidthMax = 1700.0;

class ApolloColorPalette {
  Color get primaryColor => lightBlue.color;
  Color get secondaryColor => lightCyan.color;

  static const PaletteEntry darkestBlue = PaletteEntry(Color(0xFF172038));
  static const PaletteEntry deepBlue = PaletteEntry(Color(0xFF253A5E));
  static const PaletteEntry blue = PaletteEntry(Color(0xFF3C5E8B));
  static const PaletteEntry lightBlue = PaletteEntry(Color(0xFF4F8FBA));
  static const PaletteEntry paleBlue = PaletteEntry(Color(0xFF73BED3));
  static const PaletteEntry lightCyan = PaletteEntry(Color(0xFFA4DDDB));
  static const PaletteEntry darkestGreen = PaletteEntry(Color(0xFF19332D));
  static const PaletteEntry deepGreen = PaletteEntry(Color(0xFF25562E));
  static const PaletteEntry mediumGreen = PaletteEntry(Color(0xFF468232));
  static const PaletteEntry lightGreen = PaletteEntry(Color(0xFF75A743));
  static const PaletteEntry paleGreen = PaletteEntry(Color(0xFFA8CA58));
  static const PaletteEntry lightYellowGreen = PaletteEntry(Color(0xFFD0DA91));
  static const PaletteEntry darkestSkin = PaletteEntry(Color(0xFF4D2B32));
  static const PaletteEntry deepSkin = PaletteEntry(Color(0xFF7A4841));
  static const PaletteEntry mediumSkin = PaletteEntry(Color(0xFFAD7757));
  static const PaletteEntry lightSkin = PaletteEntry(Color(0xFFC09473));
  static const PaletteEntry paleSkin = PaletteEntry(Color(0xFFD7B594));
  static const PaletteEntry lightestSkin = PaletteEntry(Color(0xFFE7D5B3));
  static const PaletteEntry darkestOrange = PaletteEntry(Color(0xFF341C27));
  static const PaletteEntry deepOrange = PaletteEntry(Color(0xFF602C2C));
  static const PaletteEntry mediumOrange = PaletteEntry(Color(0xFF884B2B));
  static const PaletteEntry lightOrange = PaletteEntry(Color(0xFFBE772B));
  static const PaletteEntry paleOrange = PaletteEntry(Color(0xFFDE9E41));
  static const PaletteEntry yellow = PaletteEntry(Color(0xFFE8C170));
  static const PaletteEntry darkestRed = PaletteEntry(Color(0xFF241527));
  static const PaletteEntry deepRed = PaletteEntry(Color(0xFF411D31));
  static const PaletteEntry mediumRed = PaletteEntry(Color(0xFF752438));
  static const PaletteEntry red = PaletteEntry(Color(0xFFA53030));
  static const PaletteEntry lightRed = PaletteEntry(Color(0xFFCF573C));
  static const PaletteEntry orange = PaletteEntry(Color(0xFFDA863E));
  static const PaletteEntry darkPurple = PaletteEntry(Color(0xFF1E1D39));
  static const PaletteEntry deepPurple = PaletteEntry(Color(0xFF402751));
  static const PaletteEntry purple = PaletteEntry(Color(0xFF7A367B));
  static const PaletteEntry pink = PaletteEntry(Color(0xFFA23E8C));
  static const PaletteEntry palePink = PaletteEntry(Color(0xFFC65197));
  static const PaletteEntry lightPink = PaletteEntry(Color(0xFFDF84A5));
  static const PaletteEntry darkestGray = PaletteEntry(Color(0xFF090A14));
  static const PaletteEntry deepGray = PaletteEntry(Color(0xFF10141F));
  static const PaletteEntry mediumGray = PaletteEntry(Color(0xFF151D28));
  static const PaletteEntry lightGray = PaletteEntry(Color(0xFF202E37));
  static const PaletteEntry paleGray = PaletteEntry(Color(0xFF394A50));
  static const PaletteEntry veryLightGray = PaletteEntry(Color(0xFF577277));
  static const PaletteEntry extraLightGray = PaletteEntry(Color(0xFF819796));
  static const PaletteEntry lightestGray = PaletteEntry(Color(0xFFA8B5B2));
  static const PaletteEntry nearlyWhite = PaletteEntry(Color(0xFFC7CFCC));
  static const PaletteEntry offWhite = PaletteEntry(Color(0xFFebede9));

  Map<String, Paint> cachedPaints = {};

  Paint buildProjectile({
    required Color color,
    required ProjectileType projectileType,
    required bool lighten,
    BlendMode? blendMode,
    double opacity = 1,
    double width = 1,
    MaskFilter? maskFilter,
    FilterQuality filterQuality = FilterQuality.none,
  }) {
    String key = color.value.toString() +
        projectileType.toString() +
        lighten.toString() +
        blendMode.toString() +
        opacity.toString() +
        maskFilter.toString() +
        filterQuality.toString();
    if (cachedPaints.containsKey(key)) return cachedPaints[key]!;
    Paint returnPaint = Paint()
      ..maskFilter = maskFilter
      ..filterQuality = filterQuality
      ..isAntiAlias = true
      ..colorFilter = ColorFilter.mode(
          (lighten ? color.brighten(.8) : color).withOpacity(opacity),
          BlendMode.srcATop);
    if (blendMode != null) {
      returnPaint.blendMode = blendMode;
    }

    if (projectileType == ProjectileType.laser) {
      returnPaint.strokeWidth = width;
      returnPaint.style = PaintingStyle.stroke;
    }

    cachedPaints[key] = returnPaint;
    return returnPaint;
  }
}

double defaultFrameDuration = .15;

Future<SpriteAnimation> getEffectSprite(StatusEffects statusEffect) async {
  SpriteAnimation spriteAnimation;

  switch (statusEffect) {
    case StatusEffects.stun:
      spriteAnimation = await loadSpriteAnimation(
          4, 'status_effects/fire_effect.png', defaultFrameDuration, true);

      break;
    case StatusEffects.marked:
      spriteAnimation = await loadSpriteAnimation(
          4, 'attribute_sprites/mark_enemy_4.png', defaultFrameDuration, true);

      break;
    // case StatusEffects.slow:
    //   break;

    // case StatusEffects.burn:
    //   break;

    // case StatusEffects.freeze:
    //   break;

    // case StatusEffects.bleed:
    //   break;

    // case StatusEffects.energy:
    //   break;

    // case StatusEffects.misc:
    //   break;

    default:
      spriteAnimation = await loadSpriteAnimation(
          4, 'status_effects/fire_effect.png', defaultFrameDuration, true);
  }
  return spriteAnimation;
}

final defaultStyle = TextStyle(
  fontSize: Platform.isAndroid || Platform.isIOS ? 21 : 45,
  fontFamily: "Alagard",
  // fontWeight: FontWeight.bold,

  color: colorPalette.secondaryColor,
  shadows: const [],
);

ScrollBehavior scrollConfiguration(BuildContext context) =>
    ScrollConfiguration.of(context).copyWith(
      scrollbars: false,
      dragDevices: {
        // Allows to swipe in web browsers
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse
      },
    );

void buildProgressBar(
    {required Canvas canvas,
    required double percentProgress,
    required Color color,
    required Vector2 size,
    double widthOfBar = .2,
    double heightOfBar = .5,
    double padding = .1,
    double peak = 1.2,
    double growth = 5,
    double loadInPercent = 1.0}) {
  final noXpPaint = Paint()
    ..shader = ui.Gradient.linear(Offset.zero, Offset(size.x, 0),
        [Colors.grey.shade900, Colors.grey.shade700]);
  final xpPaint = Paint()
    ..shader = ui.Gradient.linear(
        Offset.zero, Offset(size.x, 0), [color.brighten(.2), color]);

  final amountOfBars = (size.x / (widthOfBar + padding)).floor();
  final iteration = (size.x - padding / 2) / amountOfBars;
  final xpCutOff = percentProgress * amountOfBars;

  for (var i = 0; i < amountOfBars; i++) {
    final iRatio = i / amountOfBars;
    if (iRatio > loadInPercent) continue;
    final ratio = iRatio * peak;
    final isXpBar = xpCutOff > i;
    canvas.drawRect(
        (Offset((padding / 2) + (iteration * i), 0) &
            Size(
              widthOfBar,
              (heightOfBar / 3) + heightOfBar * pow(ratio, growth),
            )),
        isXpBar ? xpPaint : noXpPaint);
  }
}
