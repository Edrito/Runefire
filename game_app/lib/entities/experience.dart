import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Particle;
import 'package:game_app/overlays/weapon_menu.dart';
import 'package:game_app/resources/constants/physics_filter.dart';

import 'player.dart';
import '../functions/custom_mixins.dart';
import '../functions/vector_functions.dart';
import '../main.dart';
import '../resources/enums.dart';

class ExperienceItem extends BodyComponent<GameRouter> with ContactCallbacks {
  ExperienceItem(this.experienceAmount, this.originPosition);

  ExperienceAmount experienceAmount;
  late ShapeComponent shapeComponent;

  double radius = .1;
  Vector2 originPosition;
  double speed = 10;
  Player? target;
  late Color color;
  final int trailCount = 10;

  set setTarget(Player player) => target = player;
  Vector2 previousPoint = Vector2.zero();

  @override
  void render(Canvas canvas) {
    // final points =
    //     triangleZoomEffect(size, 2, previousPoint.clone(), center, 1);
    // previousPoint = center.clone();

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
    // for (var element in trails) {
    //   element = element - center;
    //   canvas.drawCircle(element.toOffset(), .05, paint);
    // }

    super.render(canvas);
  }

  List<Effect> effects = [];

  @override
  Future<void> onLoad() async {
    shapeComponent = experienceAmount.getShapeComponent(radius);
    color = experienceAmount.color;

    // final controller = EffectController(duration: 1);
    // final controller2 = InfiniteEffectController(EffectController(
    //     duration: .7,
    //     reverseDuration: .7,
    //     curve: Curves.easeInOutCubic,
    //     reverseCurve: Curves.easeInOutCubic));

    // final opac = OpacityEffect.fadeIn(controller);
    // final move = MoveEffect.by(Vector2(0, .2), controller2);
    // shapeComponent.add(opac);
    // shapeComponent.add(move);
    // effects.addAll([opac, move]);
    shapeComponent.paint = Paint()..color = color;
    add(shapeComponent);
    return super.onLoad();
  }

  late PolygonShape shape;

  List<Vector2> trails = [];

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Map || other['object'] is ExperienceItem) return;
    final otherObject = other['object'];
    final otherType = other['type'];
    if (otherType == FixtureType.sensor) {
      target = otherObject;
      for (var element in effects) {
        element.reset();
        element.removeFromParent();
      }
      // particleTimer = TimerComponent(
      //   period: .05,
      //   repeat: true,
      //   onTick: () {
      // shapeComponent.add(generateParticle());
      //   },
      // )..addToParent(this);
    } else if (otherType == FixtureType.body && otherObject is Player) {
      otherObject.gainExperience(experienceAmount.experienceAmount);
      removeFromParent();
    }

    super.beginContact(other, contact);
  }

  late TimerComponent particleTimer;
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
  Body createBody() {
    shape = PolygonShape();
    shape.set([
      Vector2(-shapeComponent.size.x / 2, -shapeComponent.size.y / 2),
      Vector2(shapeComponent.size.x / 2, -shapeComponent.size.y / 2),
      Vector2(shapeComponent.size.x / 2, shapeComponent.size.y / 2),
      Vector2(-shapeComponent.size.x / 2, shapeComponent.size.y / 2),
    ]);

    renderBody = false;
    final experienceFilter = Filter()
      ..maskBits = playerCategory
      ..categoryBits = experienceCategory;

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        isSensor: true,
        filter: experienceFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.static,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
