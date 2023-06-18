import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/resources/physics_filter.dart';

import '../entities/player.dart';
import '../main.dart';
import '../resources/enums.dart';

class ExperienceItem extends BodyComponent<GameRouter> with ContactCallbacks {
  ExperienceItem(this.experienceAmount, this.originPosition);

  ExperienceAmount experienceAmount;
  late SpriteComponent spriteComponent;
  double size = 1.2;
  Vector2 originPosition;
  double speed = 3;

  Player? target;

  set setTarget(Player player) => target = player;

  @override
  Future<void> onLoad() async {
    spriteComponent = SpriteComponent(
        sprite: await Sprite.load(experienceAmount.getSpriteString()),
        size: Vector2.all(size),
        anchor: Anchor.center);
    spriteComponent.add(OpacityEffect.fadeIn(EffectController(duration: 1)));
    spriteComponent.add(MoveEffect.by(
        Vector2(0, 1.2),
        InfiniteEffectController(
            EffectController(duration: .5, reverseDuration: .5))));
    add(spriteComponent);
    return super.onLoad();
  }

  late PolygonShape shape;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is! Map) return;
    if (other['type'] == FixtureType.sensor) {
      target = other['object'];
    } else if (other['type'] == FixtureType.body) {
      other['object'].experiencePointsGained +=
          experienceAmount.experienceAmount;
      removeFromParent();
    }

    super.beginContact(other, contact);
  }

  @override
  void update(double dt) {
    if (target != null) {
      body.applyLinearImpulse((target!.center - center) * speed);
    }
    super.update(dt);
  }

  @override
  Body createBody() {
    shape = PolygonShape();
    shape.set([
      Vector2(-spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, -spriteComponent.size.y / 2),
      Vector2(spriteComponent.size.x / 2, spriteComponent.size.y / 2),
      Vector2(-spriteComponent.size.x / 2, spriteComponent.size.y / 2),
    ]);

    renderBody = false;
    final experienceFilter = Filter()
      ..maskBits = experienceCategory + playerCategory
      ..categoryBits = experienceCategory;

    final fixtureDef = FixtureDef(shape,
        userData: this, isSensor: true, filter: experienceFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      linearDamping: 1,
      type: BodyType.dynamic,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
