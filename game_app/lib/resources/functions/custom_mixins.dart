import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:game_app/main.dart';

mixin HasOpacityProvider on Component {
  final Paint _paint = BasicPalette.transparent.paint();

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    canvas.drawPaint(_paint..blendMode = BlendMode.color);
  }
}

mixin RandomGrabber on List {
  T getRandomElement<T>() {
    return this[rng.nextInt(length)] as T;
  }
}

extension ColorExtension on Color {
  /// Merges two colors based on a merge factor between 0 and 1.
  Color mergeWith(Color other, double mergeFactor) {
    mergeFactor = mergeFactor.clamp(0.0, 1.0);

    int mergedRed =
        ((red + (other.red - red) * mergeFactor).round()).clamp(0, 255);
    int mergedGreen =
        ((green + (other.green - green) * mergeFactor).round()).clamp(0, 255);
    int mergedBlue =
        ((blue + (other.blue - blue) * mergeFactor).round()).clamp(0, 255);

    return Color.fromARGB(alpha, mergedRed, mergedGreen, mergedBlue);
  }
}

class CaTextComponent extends TextComponent with HasOpacityProvider {
  CaTextComponent(
      {super.anchor,
      super.angle,
      super.children,
      super.position,
      super.priority,
      super.scale,
      super.size,
      super.text,
      super.textRenderer});
}

class SquareParticle extends Particle {
  final Paint paint;
  final Vector2 size;

  SquareParticle({
    required this.paint,
    required this.size,
    super.lifespan,
  });

  @override
  void render(Canvas canvas) {
    canvas.drawRect(
        Rect.fromCenter(center: Offset.zero, width: size.x, height: size.y),
        paint);
  }
}

class FadeOutCircleParticle extends CircleParticle {
  FadeOutCircleParticle({
    required Paint paint,
    required double lifespan,
    double radius = 10.0,
  }) : super(paint: paint, radius: radius, lifespan: lifespan) {
    lifespanForOpacity = lifespan;
  }
  late double lifespanForOpacity;
  double duration = 0;
  @override
  void update(double dt) {
    duration += dt;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = paint.color
              .withOpacity((1 - duration / lifespanForOpacity).clamp(0, 1)));
  }
}

mixin UpgradeFunctions {
  int upgradeLevel = 0;
  abstract int maxLevel;
  bool get isMaxLevel => upgradeLevel == maxLevel;

  void changeLevel(int newUpgradeLevel, int maxLevel) {
    removeUpgrade();
    upgradeLevel = newUpgradeLevel.clamp(0, maxLevel);
    applyUpgrade();
  }

  void incrementLevel(int increment) {
    changeLevel(upgradeLevel + increment, maxLevel);
  }

  void reMapUpgrade() {
    removeUpgrade();
    applyUpgrade();
  }

  void applyUpgrade() {
    if (upgradeApplied) {
      return;
    }
    mapUpgrade();
    upgradeApplied = true;
  }

  void mapUpgrade() {}

  void removeUpgrade() {
    if (!upgradeApplied) {
      return;
    }
    unMapUpgrade();
    upgradeApplied = false;
  }

  void unMapUpgrade() {}

  bool upgradeApplied = false;
}
