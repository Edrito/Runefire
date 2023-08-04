import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/main.dart';
import 'package:game_app/resources/functions/vector_functions.dart';

import '../../entities/entity.dart';
import '../../weapons/projectile_mixin.dart';

mixin HasOpacityProvider on Component {
  final Paint _paint = BasicPalette.transparent.paint();

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    canvas.drawPaint(_paint..blendMode = BlendMode.color);
  }
}

extension RandomGrabber on List {
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
  abstract int? maxLevel;
  bool get isMaxLevel => upgradeLevel == maxLevel;

  void changeLevel(int newUpgradeLevel) {
    removeUpgrade();

    upgradeLevel = newUpgradeLevel;

    if (maxLevel != null) upgradeLevel = upgradeLevel.clamp(0, maxLevel!);

    applyUpgrade();
  }

  void incrementLevel(int increment) {
    changeLevel(upgradeLevel + increment);
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

mixin ProjectileSpriteLifecycle on StandardProjectile, BasicSpriteLifecycle {
  abstract SpriteAnimation? hitAnimation;

  void changeSpriteAngle() {
    final rad = -radiansBetweenPoints(Vector2(0, 1), delta);

    spriteAnimationComponent?.angle = rad;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    changeSpriteAngle();
  }

  @override
  void home(HealthFunctionality other, double dt) {
    changeSpriteAngle();
    super.home(other, dt);
  }

  void applyHitAnimation(Entity other, Vector2 position) {
    if (hitAnimation == null) return;
    other.add(ParticleSystemComponent(
        particle: SpriteAnimationParticle(
            size: Vector2.all(.7),
            animation: hitAnimation!,
            lifespan: .35,
            position: position - other.center)));
  }
}

mixin BasicSpriteLifecycle on Component {
  abstract SpriteAnimation? spawnAnimation;
  abstract SpriteAnimation? playAnimation;
  abstract SpriteAnimation? endAnimation;
  abstract double size;

  abstract bool isInstant;
  SpriteAnimationComponent? spriteAnimationComponent;

  @override
  Future<void> onLoad() async {
    spawnAnimation ??= playAnimation;
    spriteAnimationComponent = SpriteAnimationComponent(
      animation: spawnAnimation ?? playAnimation,
      anchor: Anchor.center,
      size: Vector2.all(size),
    );

    add(spriteAnimationComponent!);
    if (!isInstant) {
      spriteAnimationComponent!.animationTicker?.onComplete = () {
        spriteAnimationComponent!.animation = playAnimation;
      };
    }
    return super.onLoad();
  }

  Future<void> killSprite() async {
    if (endAnimation != null) {
      spriteAnimationComponent?.animation = endAnimation;
      spriteAnimationComponent?.animationTicker?.onComplete = () {
        removeFromParent();
      };
      await spriteAnimationComponent?.animationTicker?.completed;
    } else {
      final controller = EffectController(
        curve: Curves.easeInCubic,
        duration: .5,
        onMax: () {
          removeFromParent();
        },
      );
      spriteAnimationComponent?.add(OpacityEffect.fadeOut(controller));
      await Future.delayed(controller.duration!.seconds);
    }
  }
}
