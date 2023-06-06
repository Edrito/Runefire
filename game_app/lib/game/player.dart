import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/main_game.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/weapons/weapons.dart';

import '../functions/vector_functions.dart';
import 'characters.dart';

class Player extends Entity with ContactCallbacks, KeyboardHandler {
  Player(this.characterType,
      {required super.ancestor,
      super.file = "",
      required super.initPosition,
      super.id = "111"}) {
    file = characterType.getFilename();
  }

  final CharacterType characterType;

  Future<SpriteAnimation> buildSpriteSheet(
      int width, String source, double stepTime, bool loop) async {
    final sprite = (await Sprite.load(source));
    return SpriteSheet(
            image: sprite.image,
            srcSize: Vector2(sprite.srcSize.x / width, sprite.srcSize.y))
        .createAnimation(
            row: 0, stepTime: stepTime, loop: loop, to: loop ? null : width);
  }

  Future<void> loadAnimationSprites() async {
    idleAnimation = await buildSpriteSheet(10, 'sprites/idle.png', .1, true);
    jumpAnimation = await buildSpriteSheet(3, 'sprites/jump.png', .1, false);
    dashAnimation = await buildSpriteSheet(7, 'sprites/roll.png', .06, false);
    walkAnimation = await buildSpriteSheet(8, 'sprites/walk.png', .1, true);
    runAnimation = await buildSpriteSheet(8, 'sprites/run.png', .1, true);
  }

  @override
  Future<void> onLoad() async {
    initialWeapons.addAll([
      Sword.create,
      Pistol.create,
      Shotgun.create,
    ]);
    await loadAnimationSprites();

    await super.onLoad();
  }

  Set<PhysicalKeyboardKey> physicalKeysPressed = {};
  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    Vector2 moveAngle = Vector2.zero();
    if (!event.repeat) {
      if (physicalKeysPressed.contains(event.physicalKey)) {
        physicalKeysPressed.remove(event.physicalKey);
      } else {
        physicalKeysPressed.add(event.physicalKey);
      }
    }
    try {
      if (physicalKeysPressed.isEmpty) super.onKeyEvent(event, keysPressed);

      if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyD)) {
        moveAngle.x += 1;
      }
      if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyA)) {
        moveAngle.x -= 1;
      }
      if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyW)) {
        moveAngle.y -= 1;
      }
      if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyS)) {
        moveAngle.y += 1;
      }

      if (event.physicalKey == (PhysicalKeyboardKey.space) &&
          physicalKeysPressed.contains(PhysicalKeyboardKey.space)) {
        jump();
      }

      if (event.physicalKey == (PhysicalKeyboardKey.shiftLeft) &&
          physicalKeysPressed.contains(PhysicalKeyboardKey.shiftLeft)) {
        dash();
      }

      if (event.physicalKey == (PhysicalKeyboardKey.tab) &&
          physicalKeysPressed.contains(PhysicalKeyboardKey.tab)) {
        swapWeapon();
      }
    } finally {
      if (moveAngle.isZero()) {
        moveVelocities.remove(InputType.keyboard);
      } else {
        moveVelocities[InputType.keyboard] = moveAngle;
      }
    }

    return super.onKeyEvent(event, keysPressed);
  }

  void handleKeyboardInputs(RawKeyEvent event) {}

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

  @override
  SpriteAnimation? damageAnimation;

  @override
  SpriteAnimation? dashAnimation;

  @override
  SpriteAnimation? deathAnimation;

  @override
  late SpriteAnimation idleAnimation;

  @override
  SpriteAnimation? jumpAnimation;

  @override
  SpriteAnimation? runAnimation;

  @override
  SpriteAnimation? spawnAnimation;

  @override
  SpriteAnimation? walkAnimation;
}
