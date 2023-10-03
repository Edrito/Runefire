import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart' hide Effect;
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/main.dart';
import 'package:runefire/game/area_effects.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'dart:math' as math;
import '../../entities/entity_class.dart';
import '../../weapons/projectile_mixin.dart';

extension ResetTicker on SpriteAnimationGroupComponent {
  void resetTicker(dynamic key) {
    final newTicker = animations?[key]?.createTicker();
    if (newTicker != null) {
      animationTickers?[key] = newTicker;
    } else {
      animationTickers?.remove(key);
    }
  }
}

mixin HasOpacityProvider on Component {
  final Paint _paint = BasicPalette.transparent.paint();

  @override
  void renderTree(Canvas canvas) {
    super.renderTree(canvas);
    canvas.drawPaint(_paint..blendMode = BlendMode.color);
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

mixin ProjectileSpriteLifecycle on StandardProjectile {
  abstract SpriteAnimation? hitAnimation;

  abstract SimpleStartPlayEndSpriteAnimationComponent? animationComponent;

  void changeSpriteAngle() {
    final rad = -radiansBetweenPoints(Vector2(0, 1), body.linearVelocity);

    animationComponent?.angle = rad;
  }

  @override
  void update(double dt) {
    changeSpriteAngle();

    super.update(dt);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    changeSpriteAngle();
    animationComponent?.addToParent(this);
  }

  void applyHitAnimation(Entity other, Vector2 position) {
    if (hitAnimation == null) return;
    other.applyHitAnimation(hitAnimation!, position);
  }

  @override
  void killBullet([bool withEffect = false]) {
    if (!world.physicsWorld.isLocked) {
      body.setType(BodyType.static);
    }
    if (withEffect) {
      animationComponent?.triggerEnding().then((value) {
        removeFromParent();
      });
    } else {
      removeFromParent();
    }
    callBulletKillFunctions();
  }
}

class SimpleStartPlayEndSpriteAnimationComponent
    extends SpriteAnimationGroupComponent {
  SpriteAnimation? spawnAnimation;
  SpriteAnimation? playAnimation;
  SpriteAnimation? endAnimation;
  DurationType durationType;
  bool randomlyFlipped;

  SimpleStartPlayEndSpriteAnimationComponent(
      {this.spawnAnimation,
      this.playAnimation,
      this.durationType = DurationType.temporary,
      this.randomlyFlipped = false,
      this.endAnimation,
      this.randomizePlay = false,
      this.desiredWidth,
      super.position,
      super.anchor = Anchor.center}) {
    assert(playAnimation != null || spawnAnimation != null);
    assert(spawnAnimation != null || durationType != DurationType.instant);
    desiredWidth ??= 1.0;
    final bool isSizeZero = size.x == 0 || size.y == 0;
    if (isSizeZero) {
      final spriteSize = playAnimation?.frames.first.sprite.srcSize ??
          spawnAnimation!.frames.first.sprite.srcSize;

      size = spriteSize;
    }
    final widthRatio = desiredWidth! / (size.x);
    size = Vector2(desiredWidth!, size.y * widthRatio);
  }
  bool randomizePlay = false;
  late EntityStatus currentStatus;
  double? desiredWidth;
  @override
  FutureOr<void> onLoad() {
    // autoResize = true;
    // scale = Vector2.all(1);
    // size = Vector2.all(1);

    Map<dynamic, SpriteAnimation>? animationsToSet = {
      if (spawnAnimation != null) EntityStatus.spawn: spawnAnimation!,
      EntityStatus.idle: playAnimation ?? spawnAnimation!,
      if (endAnimation != null) EntityStatus.dead: endAnimation!,
    };
    animations = animationsToSet;

    if (randomlyFlipped && rng.nextBool()) {
      flipHorizontallyAroundCenter();
    }

    if (spawnAnimation != null) {
      _setStatus(EntityStatus.spawn);

      animationTicker?.onComplete = () {
        switch (durationType) {
          case DurationType.instant:
            triggerEnding();
            break;
          default:
            if (durationType == DurationType.permanent) {
              animation?.loop = true;
            }
            _setStatus(EntityStatus.idle);
        }
      };
    } else {
      _setStatus(EntityStatus.idle);
    }

    return super.onLoad();
  }

  void _setStatus(EntityStatus status) {
    currentStatus = status;
    current = status;
    if (status == EntityStatus.idle && randomizePlay) {
      animationTicker?.currentIndex = rng.nextInt(animation!.frames.length);
    }
  }

  Future<void> triggerEnding() async {
    if (endAnimation == null) {
      if (!animation!.loop && !animationTicker!.isPaused) {
        await animationTicker?.completed;
        removeFromParent();
      } else {
        const duration = .5;
        final controller = EffectController(
          curve: Curves.easeInCubic,
          duration: duration,
          onMax: () {
            removeFromParent();
          },
        );
        add(OpacityEffect.fadeOut(controller));
      }

      return;
    } else {
      _setStatus(EntityStatus.dead);
      if (animation != null) {
        animation?.loop = false;
        animationTicker?.onComplete = () {
          removeFromParent();
        };
        await animationTicker?.completed;
      } else {
        removeFromParent();
      }
    }
  }
}

class CustomParticleGenerator extends Component {
  CustomParticleGenerator({
    required this.minSize,
    required this.maxSize,
    required this.lifespan,
    required this.frequency,
    required this.velocity,
    this.color,
    required this.particlePosition,
    this.sprites,
    this.originPosition,
    this.duration,
    this.durationType = DurationType.temporary,
    this.damageType,
    this.parentBody,
    super.priority,
    super.key,
  });
  final Body? parentBody;
  final double frequency;
  final double minSize;
  final double maxSize;
  final Vector2? velocity;
  final Vector2? originPosition;
  final Color? color;
  final List<Sprite>? sprites;
  final double lifespan;
  final DamageType? damageType;
  final Vector2 particlePosition;
  final double? duration;
  final DurationType durationType;

  Paint? customPaint;

  late TimerComponent timer;

  late Vector2 position = Vector2.zero();

  int ticks = 0;

  // late ParticleSystemComponent particleSystem;

  Future<void> generateParticles() async {
    if (parentBody != null) {
      position = parentBody!.worldCenter;
    } else if (originPosition != null) {
      position = originPosition!;
    }

    double randomLifespan = ((rng.nextDouble() - .5) * lifespan) + (lifespan);
    int count = rng.nextInt((frequency / 2).ceil()) + (frequency * .75).round();
    // int i = 0;
    final particleSystem = ParticleSystemComponent(
        position: position,
        particle: Particle.generate(
          applyLifespanToChildren: true,
          lifespan: randomLifespan,
          count: count,
          // count: 50,
          generator: (p0) {
            final randomPosition = Vector2(
                ((rng.nextDouble() * 2) - 1) * particlePosition.x,
                ((rng.nextDouble() * 2) - 1) * particlePosition.y);
            Vector2? velocity;
            if (this.velocity != null) {
              velocity = Vector2(
                  ((rng.nextDouble() * 2) - 1) * this.velocity!.x,
                  ((rng.nextDouble() * 2) - 1) * this.velocity!.y);
            }

            (particlePosition * .75) +
                Vector2(rng.nextDouble() * .5 * particlePosition.x,
                    rng.nextDouble() * .5 * particlePosition.y);
            final size = rng.nextDouble() * (maxSize - minSize) + minSize;
            if (color != null) {
              customPaint = colorPalette.buildProjectile(
                  color: color!,
                  projectileType: ProjectileType.paintBullet,
                  lighten: false);
            }
            if (sprites != null && sprites!.isNotEmpty) {
              final sprite = sprites?.random();
              return SpriteParticle(
                  sprite: sprite!,
                  position: randomPosition,
                  lifespan: randomLifespan,
                  size: Vector2(size, size),
                  overridePaint: customPaint);
            }

            final particle = AcceleratedParticle(
              position: randomPosition,
              speed: velocity,
              child: CircleParticle(
                paint: customPaint!,
                lifespan: randomLifespan,
                radius: size / 2,
              ),
            );

            return particle;
          },
        ));
    add(particleSystem);
    await Future.delayed(randomLifespan.seconds).then((value) {
      particleSystem.removeFromParent();
    });
  }

  @override
  FutureOr<void> onLoad() async {
    if (durationType != DurationType.instant) {
      timer = TimerComponent(
        period: (rng.nextDouble() * .2) + .1,
        // period: 2,
        repeat: true,
        onTick: () {
          if (durationType != DurationType.permanent &&
              duration != null &&
              ticks > duration! / .05) {
            removeFromParent();
            return;
          }
          generateParticles();
          ticks++;
        },
      )..addToParent(this);
      timer.onTick();
    } else {
      generateParticles().then((value) => removeFromParent());
    }

    return super.onLoad();
  }
}

class ShakeEffect extends Effect with EffectTarget<PositionProvider> {
  final Vector2 _shakeBuffer;
  final double _shakeIntensity;

  double _shakeValue() => (rng.nextDouble() - 0.5) * 2 * _shakeIntensity;

  ShakeEffect(
    super.controller, {
    super.onComplete,
    required double intensity,
  })  : _shakeBuffer = Vector2.zero(),
        _shakeIntensity = intensity;

  @override
  void apply(double progress) {
    if (!_shakeBuffer.isZero()) {
      target.position -= _shakeBuffer;
    }
    _shakeBuffer.setValues(_shakeValue(), _shakeValue());
    target.position += _shakeBuffer;
  }

  @override
  void onFinish() {
    target.position -= _shakeBuffer;
    super.onFinish();
  }
}