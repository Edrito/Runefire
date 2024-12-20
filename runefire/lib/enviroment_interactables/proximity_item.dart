import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle;
import 'package:flutter/animation.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/game_state_class.dart';

import 'package:runefire/player/player.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/enums.dart';

abstract class ProximityItem extends BodyComponent<GameRouter>
    with ContactCallbacks {
  ProximityItem({required this.originPosition}) {
    priority = backgroundPickupPriority;
  }

  Vector2 originPosition;

  double speed = 10;
  Entity? target;
  set setTarget(Entity player) => target = player;

  double radius = .1;

  late CircleShape shape;

  @override
  Body createBody() {
    shape = CircleShape();
    shape.radius = radius;

    renderBody = false;
    final proxFilter = Filter()
      ..maskBits = playerCategory
      ..categoryBits = proximityCategory;

    final fixtureDef = FixtureDef(
      shape,
      userData: {'type': FixtureType.body, 'object': this},
      isSensor: true,
      filter: proxFilter,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Player) {
      itemContact(
        (contact.fixtureA.userData as Map?)?['type'] as FixtureType,
        other,
      );
    }
    super.beginContact(other, contact);
  }

  void itemContact(FixtureType otherType, dynamic otherObject);
}

class ExperienceItem extends ProximityItem {
  ExperienceItem({
    required this.experienceAmount,
    required super.originPosition,
  });

  ExperienceAmount experienceAmount;
  // late ShapeComponent shapeComponent;

  late Color color;
  final int trailCount = 10;

  List<Vector2> trails = [];
  Vector2 previousPoint = Vector2.zero();
  List<Effect> effects = [];

  @override
  void render(Canvas canvas) {
    for (var i = trails.length - 1; i > 1; i--) {
      canvas.drawCircle(
        (trails[i] - center).toOffset(),
        radius * .65 / trailCount * (trailCount - i),
        trailPaint,
      );
    }

    canvas.drawPoints(
      PointMode.polygon,
      trails.fold(
        [],
        (previousValue, element) =>
            [...previousValue, (element - center).toOffset()],
      ),
      paint,
    );

    // canvas.drawCircle(Offset.zero, radius, xpPaint);

    super.render(canvas);
  }

  late final Paint trailPaint;
  // late final Paint xpPaint;
  late final SpriteComponent spriteComponent;

  @override
  Future<void> onLoad() async {
    color = experienceAmount.color;
    trailPaint = Paint()..color = color;

    final sprite = await Sprite.load(experienceAmount.fileData.flamePath);
    final size = sprite.srcSize
      ..scaledToHeight(null, env: GameState().currentEnviroment);
    spriteComponent = SpriteComponent(
      size: size,
      anchor: Anchor.center,
      sprite: sprite,
      priority: backgroundPickupPriority,
    )..addToParent(this);
    return super.onLoad();
  }

  void home(double dt) {
    if (target != null) {
      trails.insert(0, center.clone());
      if (trails.length > trailCount) {
        trails.removeLast();
      }
      final moveDelta = (target!.center - center).normalized();
      body.setTransform(
        center +
            moveDelta *
                (speed * dt) *
                target!.center.distanceTo(center).clamp(2, 4),
        angle,
      );
    }
  }

  Component generateParticle() {
    final moveDelta = (target!.center - center).normalized();
    final particleColor = color.withAlpha(120 + rng.nextInt(125));
    final particlePaint = Paint()..color = particleColor;
    final particle = Particle.generate(
      lifespan: 1,
      count: 1,
      generator: (i) => AcceleratedParticle(
        position: Vector2.all(radius / 2),
        speed: -moveDelta -
            randomizeVector2Delta(moveDelta, .05).normalized().clone() *
                (.5 + rng.nextDouble()),
        child: SquareParticle(
          size: Vector2.all(.1) * (1 + rng.nextDouble() * .5),
          paint: particlePaint,
        ),
      ),
    );

    return ParticleSystemComponent(particle: particle);
  }

  @override
  void update(double dt) {
    home(dt);
    super.update(dt);
  }

  @override
  void itemContact(FixtureType otherType, dynamic otherObject) {
    if (otherObject is! Player) {
      return;
    }
    if (otherType == FixtureType.sensor) {
      target = otherObject;
      for (final element in effects) {
        element.reset();
        element.removeFromParent();
      }
    } else {
      otherObject.gainExperience(experienceAmount.experienceAmount);
      removeFromParent();
    }
  }
}
