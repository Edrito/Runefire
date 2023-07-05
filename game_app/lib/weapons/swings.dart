import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/physics_filter.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:uuid/uuid.dart';

import '../functions/vector_functions.dart';
import '../entities/enemy.dart';
import '../resources/enums.dart';

class MeleeDetection extends BodyComponent with ContactCallbacks {
  MeleeDetection(this.size, this.parentAttack);
  MeleeAttack parentAttack;
  final Vector2 size;
  late PolygonShape shape;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is HealthFunctionality) {
      other.hit(parentAttack.meleeId, parentAttack.parentWeapon.damage);
    }

    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    shape = PolygonShape();

    shape.set([
      Vector2(-size.x / 2, 0),
      Vector2(size.x / 2, 0),
      Vector2(size.x / 2, size.y),
      Vector2(-size.x / 2, size.y),
    ]);

    final swordFilter = Filter();
    if (parentAttack.parentWeapon.entityAncestor is Enemy) {
      swordFilter.maskBits = playerCategory;
    } else {
      swordFilter.maskBits = enemyCategory;
    }
    swordFilter.categoryBits = swordCategory;
    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0.1,
        isSensor: true,
        filter: swordFilter);

    final bodyDef = BodyDef(
      userData: this,
      type: BodyType.dynamic,
    );
    renderBody = false;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class MeleeAttack extends PositionComponent {
  MeleeAttack(
      {required this.initPosition,
      this.initAngle,
      required this.index,
      required this.parentWeapon}) {
    start = parentWeapon.attackHitboxPatterns[index];
    end = parentWeapon.attackHitboxPatterns[index + 1];
    duration = parentWeapon.attackRate;
    meleeId = const Uuid().v4();
  }

  late (Vector2, double) start;
  late (Vector2, double) end;

  late double duration;
  late String meleeId;
  late final SpriteAnimation? spriteAnimation;
  late final SpriteAnimationComponent? spriteAnimationComponent;

  int index;
  MeleeFunctionality parentWeapon;
  BodyComponent? bodyComponent;
  Vector2 initPosition;
  double? initAngle;

  @override
  Future<void> onLoad() async {
    size = parentWeapon.attackHitboxSizes[(index / 2).round()];

    if (parentWeapon.attackHitboxSpriteAnimations.isNotEmpty) {
      spriteAnimation =
          parentWeapon.attackHitboxSpriteAnimations[(index / 2).round()];
      spriteAnimation!.stepTime = duration;
      add(spriteAnimationComponent = SpriteAnimationComponent(
          anchor: Anchor.topCenter,
          size: size,
          animation: spriteAnimation!,
          removeOnFinish: true));
    }

    bodyComponent = MeleeDetection(size, this);

    parentWeapon.entityAncestor?.ancestor.physicsComponent.add(bodyComponent!);

    // anchor = Anchor.center;
    angle = radians(start.$2) +
        (initAngle ?? parentWeapon.entityAncestor?.handJoint.angle ?? 0);
    final rotatedStartPosition = rotateVector2(start.$1, angle);
    final rotatedEndPosition = rotateVector2(end.$1, angle);

    position = initPosition + rotatedStartPosition;

    final totalAngle = end.$2 - start.$2;
    scale = Vector2.all(.98);

    add(TimerComponent(
      period: duration,
      onTick: () {
        if (spriteAnimationComponent != null) {
          spriteAnimationComponent?.add(OpacityEffect.fadeOut(EffectController(
            duration: .05,
            onMax: () {
              removeFromParent();
            },
          )));
        } else {
          removeFromParent();
        }

        bodyComponent?.removeFromParent();
      },
    ));

    final effectController = EffectController(
      duration: duration * 2,
      curve: Curves.fastOutSlowIn,
    );
    final effectControllerTwo = EffectController(
        duration: duration / 2,
        reverseDuration: duration / 2,
        curve: Curves.fastOutSlowIn,
        reverseCurve: Curves.fastOutSlowIn);
    addAll([
      ScaleEffect.to(Vector2.all(1), effectControllerTwo),
      RotateEffect.by(
        radians(totalAngle),
        effectController,
      ),
      MoveEffect.by(
        rotatedEndPosition,
        effectController,
      )
    ]);

    return super.onLoad();
  }

  @override
  void update(double dt) {
    if (bodyComponent?.isLoaded ?? false) {
      bodyComponent?.body.setTransform(
          position + (parentWeapon.entityAncestor?.center ?? Vector2.zero()),
          angle);
    }
    super.update(dt);
  }
}
