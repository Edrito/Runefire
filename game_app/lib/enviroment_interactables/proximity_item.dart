import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle;
import 'package:flutter/animation.dart';
import 'package:game_app/entities/entity_class.dart';
import 'package:game_app/resources/constants/physics_filter.dart';

import '../player/player.dart';
import '../resources/functions/custom.dart';
import '../resources/functions/vector_functions.dart';
import '../main.dart';
import '../resources/enums.dart';

abstract class ProximityItem extends BodyComponent<GameRouter>
    with ContactCallbacks {
  ProximityItem({required this.originPosition});

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
      ..maskBits = enemyCategory + playerCategory
      ..categoryBits = proximityCategory;

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: true,
        filter: proxFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.static,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Map || other['object'] is ProximityItem) return;
    final otherObject = other['object'];
    final otherType = other['type'];
    itemContact(otherType, otherObject);
  }

  void itemContact(FixtureType otherType, dynamic otherObject);
}

class ExperienceItem extends ProximityItem {
  ExperienceItem(
      {required this.experienceAmount, required super.originPosition});

  ExperienceAmount experienceAmount;
  // late ShapeComponent shapeComponent;

  late Color color;
  final int trailCount = 10;
  late TimerComponent particleTimer;

  List<Vector2> trails = [];
  Vector2 previousPoint = Vector2.zero();
  List<Effect> effects = [];

  @override
  void render(Canvas canvas) {
    for (var i = trails.length - 1; i > 1; i--) {
      canvas.drawCircle(((trails[i] - center)).toOffset(),
          radius * .65 / trailCount * (trailCount - i), Paint()..color = color);
    }

    canvas.drawPoints(
        PointMode.polygon,
        trails.fold(
            [],
            (previousValue, element) =>
                [...previousValue, (element - center).toOffset()]),
        paint);

    canvas.drawCircle(
        Offset.zero,
        radius,
        colorPalette.buildProjectile(
            color: color,
            projectileType: ProjectileType.bullet,
            lighten: false));

    super.render(canvas);
  }

  @override
  Future<void> onLoad() async {
    // shapeComponent = experienceAmount.getShapeComponent(radius);
    color = experienceAmount.color;
    // shapeComponent.paint = Paint()..color = color;
    // shapeComponent.size = Vector2.all(0);
    // shapeComponent.position -= Vector2(0, .5);
    // final controller = EffectController(curve: Curves.easeOutCirc, duration: 1);

    // shapeComponent.add(SizeEffect.to(Vector2.all(radius * 2), controller));
    // shapeComponent.add(MoveEffect.by(Vector2(0, .5), controller));

    // add(shapeComponent);

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
          angle);
    }
  }

  Component generateParticle() {
    final moveDelta = (target!.center - center).normalized();
    var particleColor = color.withAlpha(120 + rng.nextInt(125));
    final particle = Particle.generate(
      lifespan: 1,
      count: 1,
      generator: (i) => AcceleratedParticle(
        position: Vector2.all(radius / 2),
        speed: -moveDelta -
            (randomizeVector2Delta(moveDelta, .05).normalized()).clone() *
                (.5 + rng.nextDouble()),
        child: SquareParticle(
          size: Vector2.all(.1) * (1 + rng.nextDouble() * .5),
          paint: Paint()..color = particleColor,
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
    if (otherType == FixtureType.sensor && otherObject is Player) {
      target = otherObject;
      for (var element in effects) {
        element.reset();
        element.removeFromParent();
      }
    } else if (otherType == FixtureType.body && otherObject is Player) {
      otherObject.gainExperience(experienceAmount.experienceAmount);
      removeFromParent();
    }
  }
}
