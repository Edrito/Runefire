import 'package:flame/components.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';

mixin HasOpacityProvider on Component {
  final Paint _paint = BasicPalette.transparent.paint();

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    canvas.drawPaint(_paint..blendMode = BlendMode.color);
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
