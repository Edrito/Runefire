import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/game/enemies.dart';
import 'package:game_app/game/player.dart';
import '../functions/custom_joystick.dart';
import 'background.dart';
import 'characters.dart';
import 'hud.dart';

enum GameLevel { space, forest }

enum InputType {
  keyboard,
  mouseMove,
  aimJoy,
  moveJoy,
  tapClick,
  mouseDrag,
  mouseDragStart
}

class GameplayGame extends Forge2DGame
    with
        KeyboardEvents,
        MultiTouchTapDetector,
        MouseMovementDetector,
        MultiTouchDragDetector {
  late CustomJoystickComponent aimJoystick;
  late final BackgroundComponent backgroundComponent;
  late EnemyManagement enemyManagement;
  late final GameHud hud;
  Map<int, InputType> inputIdStates = {};
  late CustomJoystickComponent moveJoystick;
  late final Player player;

  @override
  Future<void> onLoad() async {
    moveJoystick = CustomJoystickComponent(
      knob: CircleComponent(radius: 15),
      priority: 20,
      knobRadius: 15,
      background:
          CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
      margin: const EdgeInsets.only(left: 30, bottom: 30),
    );
    aimJoystick = CustomJoystickComponent(
      knob: CircleComponent(radius: 15),
      priority: 20,
      knobRadius: 15,
      background:
          CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
      margin: const EdgeInsets.only(right: 30, bottom: 30),
    );

    player = Player(CharacterType.wizard);
    backgroundComponent = BackgroundComponent(player, GameLevel.forest);
    hud = GameHud(player);
    enemyManagement = EnemyManagement();

    // add(backgroundComponent);
    add(player);
    add(enemyManagement);

    world.setGravity(Vector2.all(0));
    camera.zoom = 7;
    add(hud);
    hud.add(moveJoystick);
    hud.add(aimJoystick);

    player.mounted.whenComplete(() => camera.followBodyComponent(player));
    return super.onLoad();
  }

  void transmitDragInfo(int pointerId, DragUpdateInfo info) {
    switch (inputIdStates[pointerId]) {
      case InputType.aimJoy:
        aimJoystick.onDragUpdate(info);
        player.gestureEventStart(InputType.aimJoy, info);

        break;
      case InputType.moveJoy:
        moveJoystick.onDragUpdate(info);
        player.gestureEventStart(InputType.moveJoy, info);
        break;
      case InputType.mouseDrag:
        player.gestureEventStart(InputType.mouseDrag, info);

      default:
    }
  }

  void endIdState(int id) {
    if (inputIdStates.containsKey(id)) {
      switch (inputIdStates[id]) {
        case InputType.aimJoy:
          aimJoystick.onDragCancel();
          player.gestureEventEnd(InputType.aimJoy, null);

          break;
        case InputType.moveJoy:
          moveJoystick.onDragCancel();
          player.gestureEventEnd(InputType.moveJoy, null);
          break;
        case InputType.mouseDrag:
          player.gestureEventEnd(InputType.mouseDrag, null);

          break;
        default:
      }
      inputIdStates.remove(id);
    }
  }

  bool discernJoystate(int id, PositionInfo globalPos) {
    final moveEnabled = moveJoystick.background
            ?.containsPoint(globalPos.eventPosition.global) ??
        false;
    final aimEnabled =
        aimJoystick.background?.containsPoint(globalPos.eventPosition.global) ??
            false;

    if (moveEnabled) {
      inputIdStates[id] = InputType.moveJoy;
    }
    if (aimEnabled) {
      inputIdStates[id] = InputType.aimJoy;
    }

    if (!moveEnabled && !aimEnabled) {
      inputIdStates[id] = InputType.mouseDrag;
    }

    return moveEnabled || aimEnabled;
  }

  @override
  void onDragCancel(int pointerId) {
    endIdState(pointerId);
    super.onDragCancel(pointerId);
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    endIdState(pointerId);
    super.onDragEnd(pointerId, info);
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    discernJoystate(pointerId, info);
    player.gestureEventEnd(InputType.tapClick, info);
    player.gestureEventStart(InputType.mouseDragStart, info);
    super.onDragStart(pointerId, info);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    transmitDragInfo(pointerId, info);
    super.onDragUpdate(pointerId, info);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (Platform.isWindows) {
      player.gestureEventStart(InputType.mouseMove, info);
    }
    super.onMouseMove(info);
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (Platform.isWindows && !discernJoystate(pointerId, info)) {
      player.gestureEventStart(InputType.tapClick, info);
    }

    super.onTapDown(pointerId, info);
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    endIdState(pointerId);
    player.gestureEventEnd(InputType.tapClick, info);
    super.onTapUp(pointerId, info);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    player.handleKeyboardInputs(keysPressed);

    if (keysPressed.contains(LogicalKeyboardKey.keyE) && !world.isLocked) {
      add(Ball(Vector2.random() * 50));
    }

    if (keysPressed.contains(LogicalKeyboardKey.tab)) {
      player.swapWeapon();
      print('ua');
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyP) ||
        keysPressed.contains(LogicalKeyboardKey.escape)) {
      overlays.add('PauseMenu');
      pauseEngine();
    }

    return KeyEventResult.handled;
  }
}
