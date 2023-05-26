import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/games.dart';

import '../functions/functions.dart';
import 'characters.dart';
import 'gun.dart';

class PlayerSprite extends SpriteComponent {
  final CharacterType characterType;
  PlayerSprite(this.characterType);

  @override
  Future<void> onLoad() async {
    switch (characterType) {
      case CharacterType.wizard:
        sprite = await Sprite.load('wizard.png');
        size = sprite!.srcSize / 100;
        anchor = Anchor.topLeft;
        break;
      default:
    }
    priority = 0;
    return super.onLoad();
  }

  void jump(EffectController controller) {
    final jumpSizeUpEffect = ScaleEffect.by(
      Vector2(1.035, 1.035),
      controller,
    );
    final jumpMoveUpEffect = MoveEffect.by(
      Vector2(0, -1.9),
      controller,
    );

    add(jumpSizeUpEffect);
    add(jumpMoveUpEffect);
  }
}

class Player extends BodyComponent with ContactCallbacks {
  Player(this.characterType);

  final CharacterType characterType;
  late PositionComponent handParentAnglePosition;
  late PlayerSprite sprite;
  late Vector2 spriteOffset;

  Gun? gun;

  Map<LogicalKeyboardKey, double> keyDurationPress = {};

  double maxSpeed = 8000;
  double fireRate = .1;
  double timeSincePreviousFire = 0;
  double bulletSpeed = 100;

  double invinciblePercent = .5;
  double jumpDuration = .5;

  double handAngle = 0;
  Vector2 moveAngle = Vector2.zero();

  bool isMoveJoystickControlled = false;

  bool isJumping = false;
  bool isJumpingInvincible = false;

  @override
  Future<void> onLoad() async {
    sprite = PlayerSprite(characterType);

    handParentAnglePosition =
        PositionComponent(anchor: Anchor.center, size: Vector2.zero());

    add(handParentAnglePosition);
    add(sprite);

    gun = Gun();

    handParentAnglePosition.mounted
        .whenComplete(() => handParentAnglePosition.addAll([gun!]));

    await sprite.loaded.whenComplete(
        () => spriteOffset = Vector2(sprite.size.x / 2, sprite.size.y / 2));

    return super.onLoad();
  }

  bool singleShot = false;
  bool singleRenderComplete = true;

  @override
  void update(double dt) {
    handleKeyboardInputs();

    if (!handParentAnglePosition.isFlippedHorizontally &&
        !sprite.isFlippedHorizontally) {
      sprite.flipHorizontallyAroundCenter();
    } else if (handParentAnglePosition.isFlippedHorizontally &&
        sprite.isFlippedHorizontally) {
      sprite.flipHorizontallyAroundCenter();
    }
    if (target != null && gun != null) {
      final newTarget = camera.screenToWorld(target!);

      handAngle =
          angleBetweenPoints(newTarget, center, center + Vector2(0, -0.0001));
      handParentAnglePosition.position =
          newPosition(spriteOffset, handAngle, gun!.distanceFromPlayer);
      handParentAnglePosition.angle = -handAngle * degrees2Radians;
      if (handAngle < 0 && !handParentAnglePosition.isFlippedHorizontally) {
        handParentAnglePosition.flipHorizontally();
      } else if (handAngle > 0 &&
          handParentAnglePosition.isFlippedHorizontally) {
        handParentAnglePosition.flipHorizontally();
      }
      gun!.shoot(this, dt);
    }

    if (!singleRenderComplete) {
      singleRenderComplete = true;
    }

    super.update(dt);
  }

  bool shooting = false;

  late PolygonShape shape;
  @override
  Body createBody() {
    shape = PolygonShape();
    shape.set([
      Vector2(0, sprite.size.y),
      Vector2(sprite.size.x, sprite.size.y),
      Vector2(sprite.size.x, 0),
      Vector2(0, 0),
    ]);

    final filter = Filter();
    filter.maskBits = 0x0000;
    filter.categoryBits = 0x0001;

    final fixtureDef = FixtureDef(shape,
        restitution: 0, friction: 0, density: 0.1, filter: filter);
    final bodyDef = BodyDef(
      userData: this,
      position: Vector2.all(0),
      type: BodyType.dynamic,
      linearDamping: 12,
      fixedRotation: true,
    );

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  void render(Canvas canvas) {}

  void onTapDown(TapDownInfo info) {
    startShooting();
    target = info.eventPosition.viewport;
  }

  Future<void> onTapUp() async {
    await endShooting();
  }

  void onDrag(int pointerId, DragUpdateInfo info) {
    target = info.eventPosition.viewport;
    startShooting();
  }

  void startShooting() {
    print(isMoveJoystickControlled);
    if (isMoveJoystickControlled) {
      shooting = false;
      return;
    }
    shooting = true;
    singleRenderComplete = false;
  }

  Future<void> endShooting() async {
    await Future.doWhile(() => Future.delayed(const Duration(milliseconds: 10))
        .then((value) => !singleRenderComplete));
    shooting = false;
  }

  Vector2? target;

  void onMouseMove(PointerHoverInfo info) {
    target = info.eventPosition.viewport;
  }

  void handleKeyboardInputs() {
    moveAngle.setZero();

    if (isMoveJoystickControlled) {
      moveAngle = (parent as GameplayGame).joystick.relativeDelta * maxSpeed;
      print(moveAngle);
    } else if (keyDurationPress.isNotEmpty) {
      moveAngle.x +=
          keyDurationPress[LogicalKeyboardKey.keyD] != null ? maxSpeed : 0;
      moveAngle.x -=
          keyDurationPress[LogicalKeyboardKey.keyA] != null ? maxSpeed : 0;

      moveAngle.y -=
          keyDurationPress[LogicalKeyboardKey.keyW] != null ? maxSpeed : 0;
      moveAngle.y +=
          keyDurationPress[LogicalKeyboardKey.keyS] != null ? maxSpeed : 0;
    }
    jump(keyDurationPress[LogicalKeyboardKey.space], this);

    body.applyForce(moveAngle.clone());
  }
}

// bool xDifferentDirection(Vector2 one, Vector2 two) {
//   return (one.x > 0 && two.x < 0 || one.x < 0 && two.x > 0);
// }

// bool yDifferentDirection(Vector2 one, Vector2 two) {
//   return (one.y >= 0 && two.y <= 0 || one.y <= 0 && two.y >= 0);
// }

void jump(double? previousTime, Player classRef) {
  if (previousTime == null || classRef.isJumping) return;

  double jumpDuration = classRef.jumpDuration;
  double invinciblePercent = classRef.invinciblePercent;

  classRef.isJumping = true;

  double elapsed = 0;
  double min = (jumpDuration / 2) - jumpDuration * (invinciblePercent / 2);
  double max = (jumpDuration / 2) + jumpDuration * (invinciblePercent / 2);

  final controller = EffectController(
    duration: jumpDuration,
    curve: Curves.ease,
    reverseDuration: jumpDuration,
    reverseCurve: Curves.ease,
  );
  Future.doWhile(
      () => Future.delayed(const Duration(milliseconds: 25)).then((value) {
            elapsed += .025;

            classRef.isJumpingInvincible = elapsed > min && elapsed < max;

            return !(elapsed >= jumpDuration || controller.completed);
          })).then((_) {
    classRef.isJumping = false;
  });
  classRef.sprite.jump(controller);
}
