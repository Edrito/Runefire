import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/weapons.dart';
import 'package:game_app/game/weapon_class.dart';

import 'characters.dart';

class Player extends Entity with ContactCallbacks {
  Player(this.characterType)
      : super(
          file: characterType.getFilename(),
          position: Vector2.zero(),
        );

  final CharacterType characterType;

  Map<InputType, Vector2> inputAimAngles = {};
  Map<InputType, Vector2> inputAimPositions = {};
  double invinciblePercent = .5;
  bool isJumping = false;
  bool isJumpingInvincible = false;
  double jumpDuration = .5;
  Vector2 moveAngle = Vector2.zero();
  Map<InputType, Vector2> moveVelocities = {};
  late PolygonShape shape;
  // bool singleRenderComplete = true;
  bool singleShot = false;

  Weapon? _projectileWeapon;

  void swapWeapon() {
    _projectileWeapon?.removeFromParent();
    bool isFlipped = _projectileWeapon?.isFlippedHorizontally ?? false;
    if (_projectileWeapon is Pistol) {
      _projectileWeapon = null;
      _projectileWeapon = Shotgun();
    } else {
      _projectileWeapon = null;
      _projectileWeapon = Pistol();
    }
    if (_projectileWeapon?.isFlippedHorizontally != isFlipped) {
      _projectileWeapon?.flipHorizontallyAroundCenter();
    }
    aimingAnglePosition.add(_projectileWeapon!);
  }

  @override
  Future<void> onLoad() async {
    _projectileWeapon = Pistol();

    await super.onLoad();
    aimingAnglePosition.mounted
        .whenComplete(() => aimingAnglePosition.add(_projectileWeapon!));
    testCircle = CircleComponent(radius: 1, anchor: Anchor.center);
    add(testCircle);
  }

  late CircleComponent testCircle;

  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {
    flipSpriteCheck();
    moveCharacter();

    if (inputAimPositions.containsKey(InputType.mouseMove)) {
      testCircle.position = inputAimPositions[InputType.mouseMove]!;
    }

    super.update(dt);
  }

  @override
  void moveCharacter({Vector2? delta}) {
    previousPulse = moveVelocities[InputType.moveJoy] ??
        moveVelocities[InputType.keyboard] ??
        Vector2.zero();
    super.moveCharacter(delta: previousPulse.normalized());
  }

  @override
  void aimCharacter({Vector2? delta}) {
    final delta = (inputAimAngles[InputType.aimJoy] ??
        inputAimAngles[InputType.tapClick] ??
        inputAimAngles[InputType.mouseDrag] ??
        inputAimAngles[InputType.mouseMove] ??
        lastAimingPosition);

    super.aimCharacter(delta: delta);
  }

  void endAttacking() {
    if (inputAimAngles.containsKey(InputType.aimJoy) ||
        inputAimAngles.containsKey(InputType.tapClick) ||
        inputAimAngles.containsKey(InputType.mouseDrag)) return;
    _projectileWeapon?.endAttacking();
  }

  void handleKeyboardInputs(Set<LogicalKeyboardKey> keysPressed) {
    moveAngle.setZero();

    if (keysPressed.isEmpty) return;
    if (keysPressed.contains(LogicalKeyboardKey.keyD)) {
      moveAngle.x += maxSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyA)) {
      moveAngle.x -= maxSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyW)) {
      moveAngle.y -= maxSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyS)) {
      moveAngle.y += maxSpeed;
    }
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      jump(this);
    }
    moveVelocities[InputType.keyboard] = moveAngle;
  }

  Vector2 previousPulse = Vector2.zero();

  void startAttacking() {
    _projectileWeapon?.startAttacking();
  }

  void gestureEventEnd(InputType inputType, PositionInfo? info) async {
    switch (inputType) {
      case InputType.mouseMove:
        if (info == null) return;
        await loaded.whenComplete(() => null);
        inputAimPositions[InputType.mouseMove] =
            (info.eventPosition.game - center);
        inputAimAngles[InputType.mouseMove] =
            inputAimPositions[InputType.mouseMove]!.normalized();
        break;

      case InputType.aimJoy:
        inputAimAngles.remove(InputType.aimJoy);
        break;

      case InputType.moveJoy:
        moveVelocities.remove(InputType.moveJoy);
        break;
      case InputType.tapClick:
        inputAimAngles.remove(InputType.tapClick);
        break;

      case InputType.mouseDrag:
        inputAimAngles.remove(InputType.mouseDrag);
        break;

      default:
      // Code to handle unknown or unexpected input type
    }
    endAttacking();
  }

  void gestureEventStart(InputType inputType, PositionInfo info) {
    switch (inputType) {
      case InputType.mouseMove:
        inputAimPositions[InputType.mouseMove] =
            (info.eventPosition.game - center);
        inputAimAngles[InputType.mouseMove] =
            inputAimPositions[InputType.mouseMove]!.normalized();

        break;

      case InputType.aimJoy:
        final delta = game.aimJoystick.relativeDelta;
        if (delta.isZero()) return;
        inputAimAngles[InputType.aimJoy] = delta.normalized();

        break;

      case InputType.moveJoy:
        final delta = game.moveJoystick.relativeDelta;
        moveVelocities[InputType.moveJoy] = delta * maxSpeed;
        break;

      case InputType.tapClick:
        startAttacking();
        inputAimAngles[InputType.tapClick] =
            (info.eventPosition.game - center).normalized();
        break;

      case InputType.mouseDrag:
        inputAimPositions[InputType.mouseMove] =
            (info.eventPosition.game - center);
        inputAimPositions[InputType.mouseDrag] =
            inputAimPositions[InputType.mouseMove]!;
        inputAimAngles[InputType.mouseDrag] =
            inputAimPositions[InputType.mouseDrag]!.normalized();
        inputAimAngles[InputType.mouseMove] =
            inputAimAngles[InputType.mouseDrag]!.clone();

        break;
      case InputType.mouseDragStart:
        startAttacking();
        break;

      default:
      // Code to handle unknown or unexpected input type
    }
  }

  @override
  Future<void> onDeath() async {}

  @override
  Filter? filter = Filter()..maskBits = 0xFFFF - bulletCategory;

  @override
  double height = 15;

  @override
  double invincibiltyDuration = 1;

  @override
  double maxHealth = 20;

  @override
  double maxSpeed = 500;

  @override
  EntityType entityType = EntityType.player;
}

void jump(Player classRef) {
  if (classRef.isJumping) return;

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
  final jumpSizeUpEffect = ScaleEffect.by(
    Vector2(1.035, 1.035),
    controller,
  );
  final jumpMoveUpEffect = MoveEffect.by(
    Vector2(0, -1.9),
    controller,
  );

  classRef.spriteAnimationComponent.add(jumpSizeUpEffect);
  classRef.spriteAnimationComponent.add(jumpMoveUpEffect);
}
