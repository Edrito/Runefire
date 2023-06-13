import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/physics_filter.dart';

import '../entities/player.dart';
import '../main.dart';
import '../resources/enums.dart';

class ExperienceItem extends BodyComponent<GameRouter> with ContactCallbacks {
  ExperienceItem(this.experienceAmount, this.originPosition);

  ExperienceAmount experienceAmount;
  late SpriteComponent spriteComponent;
  double size = .6;
  Vector2 originPosition;

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
    if (other is! Player) return;
    other.experiencePointsGained += experienceAmount.experienceAmount;
    removeFromParent();
    super.beginContact(other, contact);
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
    final powerupFilter = Filter()
      ..maskBits = playerCategory
      ..categoryBits = powerupCategory;

    final fixtureDef = FixtureDef(shape,
        userData: this,
        restitution: 0,
        friction: 0,
        density: 0,
        isSensor: true,
        filter: powerupFilter);

    final bodyDef = BodyDef(
      userData: this,
      position: originPosition,
      type: BodyType.static,
      bullet: false,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
