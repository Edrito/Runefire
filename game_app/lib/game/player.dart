import 'dart:async';

import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/main_game.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/weapons/weapons.dart';

import '../functions/vector_functions.dart';
import 'characters.dart';

class Player extends Entity with ContactCallbacks {
  Player(this.characterType,
      {required super.ancestor,
      super.file = "",
      required super.initPosition,
      super.id = "111"}) {
    file = characterType.getFilename();
  }

  final CharacterType characterType;

  @override
  Future<void> onLoad() async {
    initialWeapons.addAll([
      Sword.create,
      Bow.create,
      Shotgun.create,
    ]);

    // add(KeyboardListenerComponent(

// keyDown: {LogicalKeyboardKey.keyS:(key) {

// }}

//     ));

    await super.onLoad();
  }

  Set<PhysicalKeyboardKey> keysPressed = {};

  void handleKeyboardInputs(RawKeyEvent event) {
    Vector2 moveAngle = Vector2.zero();
    if (!event.repeat) {
      if (keysPressed.contains(event.physicalKey)) {
        keysPressed.remove(event.physicalKey);
      } else {
        keysPressed.add(event.physicalKey);
      }
    }
    try {
      if (keysPressed.isEmpty) return;

      if (keysPressed.contains(PhysicalKeyboardKey.keyD)) {
        moveAngle.x += 1;
      }
      if (keysPressed.contains(PhysicalKeyboardKey.keyA)) {
        moveAngle.x -= 1;
      }
      if (keysPressed.contains(PhysicalKeyboardKey.keyW)) {
        moveAngle.y -= 1;
      }
      if (keysPressed.contains(PhysicalKeyboardKey.keyS)) {
        moveAngle.y += 1;
      }

      if (event.physicalKey == (PhysicalKeyboardKey.space) &&
          keysPressed.contains(PhysicalKeyboardKey.space)) {
        jump();
      }

      if (event.physicalKey == (PhysicalKeyboardKey.shiftLeft) &&
          keysPressed.contains(PhysicalKeyboardKey.shiftLeft)) {
        dash();
      }
    } finally {
      if (moveAngle.isZero()) {
        moveVelocities.remove(InputType.keyboard);
      } else {
        moveVelocities[InputType.keyboard] = moveAngle;
      }
    }
  }

  @override
  double dashCooldown = 1;
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
    if (inputAimAngles.containsKey(InputType.aimJoy) ||
        inputAimAngles.containsKey(InputType.tapClick) ||
        inputAimAngles.containsKey(InputType.mouseDrag)) return;
    endAttacking();
  }

  void gestureEventStart(InputType inputType, PositionInfo info) {
    switch (inputType) {
      case InputType.mouseMove:
        if (!isMounted) return;
        inputAimPositions[InputType.mouseMove] = vectorToGrid(
                info.eventPosition.viewport,
                ancestor.gameCamera.viewport.size) /
            ancestor.gameCamera.viewfinder.zoom;
        inputAimAngles[InputType.mouseMove] =
            inputAimPositions[InputType.mouseMove]!.normalized();

        break;

      case InputType.aimJoy:
        final delta = ancestor.aimJoystick?.relativeDelta;
        if (delta == null || delta.isZero()) return;
        inputAimAngles[InputType.aimJoy] = delta.normalized();

        break;

      case InputType.moveJoy:
        final delta = ancestor.moveJoystick?.relativeDelta;
        moveVelocities[InputType.moveJoy] =
            (delta ?? Vector2.zero()) * maxSpeed;
        break;

      case InputType.tapClick:
        inputAimAngles[InputType.tapClick] =
            (info.eventPosition.game - center).normalized();
        startAttacking();
        inputAimAngles.remove(InputType.tapClick);
        break;

      case InputType.mouseDrag:
        inputAimPositions[InputType.mouseMove] = vectorToGrid(
                info.eventPosition.viewport,
                ancestor.gameCamera.viewport.size) /
            ancestor.gameCamera.viewfinder.zoom;
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
  Filter? filter = Filter()
    ..maskBits = 0xFFFF
    ..categoryBits = playerCategory;

  @override
  double height = 15;

  @override
  double invincibiltyDuration = 1;

  @override
  double maxHealth = 50;

  @override
  double maxSpeed = 1000;

  @override
  EntityType entityType = EntityType.player;
}
