import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flutter/material.dart';
import 'enums.dart';
import 'functions/functions.dart';

const uiWidthMax = 1300.0;

extension CustomColors on BasicPalette {
  static const PaletteEntry secondaryColorPalette =
      PaletteEntry(secondaryColor);
  static const PaletteEntry primaryColorPalette = PaletteEntry(primaryColor);
}

const Color primaryColor = ui.Color.fromARGB(255, 67, 164, 255);
const Color secondaryColor = ui.Color.fromARGB(255, 133, 210, 255);
const Color buttonDownColor = secondaryColor;
const Color buttonUpColor = primaryColor;
const Color backgroundColor1 = ui.Color.fromARGB(255, 22, 0, 5);
const Color backgroundColor2 = ui.Color.fromARGB(255, 48, 99, 158);
const Color lockedColor = ui.Color.fromARGB(255, 49, 49, 49);
const Color hoverColor = ui.Color.fromARGB(255, 0, 59, 107);
const Color unlockedColor = ui.Color.fromARGB(255, 24, 24, 24);
const Color secondaryEquippedColor = ui.Color.fromARGB(255, 163, 113, 255);
const Color levelUnlockedUnequipped = ui.Color.fromARGB(255, 62, 31, 119);

double defaultFrameDuration = .15;

Future<SpriteAnimation> getEffectSprite(StatusEffects statusEffect) async {
  SpriteAnimation spriteAnimation;

  switch (statusEffect) {
    case StatusEffects.stun:
      spriteAnimation = await buildSpriteSheet(
          4, 'status_effects/fire_effect.png', defaultFrameDuration, true);

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
      spriteAnimation = await buildSpriteSheet(
          4, 'status_effects/fire_effect.png', defaultFrameDuration, true);
  }
  return spriteAnimation;
}

final defaultStyle = TextStyle(
  fontSize: Platform.isAndroid || Platform.isIOS ? 21 : 45,
  fontFamily: "Alagard",
  // fontWeight: FontWeight.bold,

  color: buttonUpColor,
  shadows: const [],
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
