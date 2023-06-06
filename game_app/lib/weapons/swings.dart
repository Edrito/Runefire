import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/weapons/weapon_class.dart';

import '../functions/vector_functions.dart';
import '../game/enemies.dart';

class MeleeDetection extends BodyComponent with ContactCallbacks {
  MeleeDetection(this.spriteComponent, this.parentAttack);
  MeleeAttack parentAttack;
  final SpriteComponent spriteComponent;
  late PolygonShape shape;

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Entity) {
      other.takeDamage(parentAttack.id, parentAttack.parentWeapon.damage);
    }

    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    shape = PolygonShape();

    shape.set([
      Vector2(-spriteComponent.size.x / 2, 0),
      Vector2(spriteComponent.size.x / 2, 0),
      Vector2(spriteComponent.size.x / 2, spriteComponent.size.y),
      Vector2(-spriteComponent.size.x / 2, spriteComponent.size.y),
    ]);
    final swordFilter = Filter();
    if (parentAttack.parentWeapon.parentEntity is Enemy) {
      swordFilter.maskBits = playerCategory;
    } else {
      swordFilter.maskBits = enemyCategory;
    }
    swordFilter.categoryBits = swordCategory;
    final fixtureDef = FixtureDef(shape,
        userData: this,
        restitution: 0,
        friction: 0,
        density: 0.1,
        isSensor: true,
        filter: swordFilter);

    final bodyDef = BodyDef(
      userData: this,
      // position: attackAncestor.position,
      // angle: attackAncestor.angle,
      type: BodyType.static,
    );
    renderBody = false;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class MeleeAttack extends PositionComponent {
  MeleeAttack(
      this.initPosition, this.initAngle, this.index, this.parentWeapon) {
    start = parentWeapon.attackPatterns[index];
    end = parentWeapon.attackPatterns[index + 1];
    duration = parentWeapon.fireRate;
    id = Random().nextDouble().toString();
  }

  late (Vector2, double) start;

  late (Vector2, double) end;
  late double duration;
  late String id;
  late final SpriteComponent spriteComponent;
  int index;
  Weapon parentWeapon;
  BodyComponent? bodyComponent;
  Vector2 initPosition;
  double? initAngle;

  @override
  Future<void> onLoad() async {
    spriteComponent =
        await parentWeapon.buildSpriteComponent(WeaponSpritePosition.hand);
    add(spriteComponent);
    bodyComponent = MeleeDetection(spriteComponent, this);

    parentWeapon.parentEntity?.ancestor.physicsComponent.add(bodyComponent!);

    anchor = Anchor.center;
    angle = radians(start.$2) +
        (initAngle ?? parentWeapon.parentEntity?.handJoint.angle ?? 0);
    final rotatedStartPosition = rotateVector2(start.$1, angle);
    final rotatedEndPosition = rotateVector2(end.$1, angle);

    position = initPosition + rotatedStartPosition;

    final totalAngle = end.$2 - start.$2;
    scale = Vector2.all(.98);

    add(TimerComponent(
      period: duration,
      onTick: () {
        removeFromParent();
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
          position + (parentWeapon.parentEntity?.center ?? Vector2.zero()),
          angle);
    }
    super.update(dt);
  }
}
