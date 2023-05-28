import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
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

enum InputType { keyboard, mouseMove, aimJoy, moveJoy, tapClick, mouseDrag }

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
  Map<LogicalKeyboardKey, double> keyDurationPress = {};
  late CustomJoystickComponent moveJoystick;
  late final Player player;

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
    enableDragStates(pointerId, info.eventPosition.global);
    player.onTapUp();
    super.onDragStart(pointerId, info);
  }

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    transmitDragInfo(pointerId, info);

    super.onDragUpdate(pointerId, info);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    keyDurationPress.removeWhere((key, value) => !keysPressed.contains(key));
    for (LogicalKeyboardKey element in keysPressed) {
      keyDurationPress[element] ??= 0.0;
    }
    player.keyDurationPress = keyDurationPress;

    if (event.logicalKey == LogicalKeyboardKey.keyE && !world.isLocked) {
      add(Ball(Vector2.random() * 50));
    }

    return KeyEventResult.handled;
  }

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

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (Platform.isWindows) {
      player.onMouseMove(info);
    }
    super.onMouseMove(info);
  }

  @override
  void onTapDown(int pointerId, TapDownInfo info) {
    if (Platform.isWindows &&
        !enableDragStates(pointerId, info.eventPosition.global)) {
      player.onTapDown(info);
    }

    super.onTapDown(pointerId, info);
  }

  @override
  void onTapUp(int pointerId, TapUpInfo info) {
    endIdState(pointerId);
    player.onTapUp();
    super.onTapUp(pointerId, info);
  }

  @override
  void update(double dt) {
    if (keyDurationPress[LogicalKeyboardKey.keyP] != null ||
        keyDurationPress[LogicalKeyboardKey.escape] != null) {
      overlays.add('PauseMenu');
      pauseEngine();
    }

    if (keyDurationPress[LogicalKeyboardKey.tab] == 0.0) {
      player.swapWeapon();
    }

    keyDurationPress.updateAll((key, value) => value += dt);

    super.update(dt);
  }

  void transmitDragInfo(int pointerId, DragUpdateInfo info) {
    switch (inputIdStates[pointerId]) {
      case InputType.aimJoy:
        aimJoystick.onDragUpdate(info);
        player.onAimJoy(aimJoystick.relativeDelta);

        break;
      case InputType.moveJoy:
        moveJoystick.onDragUpdate(info);

        player.onMoveJoy(moveJoystick.relativeDelta);
        break;
      case InputType.mouseDrag:
        player.onMouseDrag(info);

      default:
    }
  }

  void endIdState(int id) {
    if (inputIdStates.containsKey(id)) {
      switch (inputIdStates[id]) {
        case InputType.aimJoy:
          aimJoystick.onDragCancel();
          player.onAimCancel();

          break;
        case InputType.moveJoy:
          moveJoystick.onDragCancel();
          player.onMoveCancel();
          break;
        case InputType.mouseDrag:
          player.onMouseDragCancel();
          break;
        default:
      }
      inputIdStates.remove(id);
    }
  }

  bool enableDragStates(int id, Vector2 globalPos) {
    final moveEnabled =
        moveJoystick.background?.containsPoint(globalPos) ?? false;
    final aimEnabled =
        aimJoystick.background?.containsPoint(globalPos) ?? false;

    if (moveEnabled) {
      inputIdStates[id] = InputType.moveJoy;
    }
    if (aimEnabled) {
      inputIdStates[id] = InputType.aimJoy;
    }
    if (Platform.isWindows && !moveEnabled && !aimEnabled) {
      inputIdStates[id] = InputType.mouseDrag;
    }

    return moveEnabled || aimEnabled;
  }
}
