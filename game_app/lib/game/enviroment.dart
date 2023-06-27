import 'dart:io';

import 'package:flame/events.dart';
import 'package:flutter/services.dart';

import '../game/background.dart';
import '../game/hud.dart';

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/player.dart';
import '../functions/custom_follow_behavior.dart';
import '../functions/custom_joystick.dart';
import '../main.dart';
import '../resources/data_classes/player_data.dart';
import '../resources/enums.dart';
import '../resources/priorities.dart';
import 'package:window_manager/window_manager.dart';

abstract class GameEnviroment extends Component
    with
        HasGameRef<GameRouter>,
        KeyboardHandler,
        WindowListener,
        DragCallbacks {
  CustomJoystickComponent? aimJoystick;
  CustomJoystickComponent? moveJoystick;
  abstract GameLevel level;
  late final Forge2DComponent physicsComponent;
  late final GameHud hud;
  Map<int, InputType> inputIdStates = {};
  late final Player player;

  late final World gameWorld;
  late CameraComponent gameCamera;

  @override
  bool containsLocalPoint(Vector2 point) {
    return true;
  }

  void onMouseMove(PointerHoverInfo info) {
    if (Platform.isWindows) {
      player.gestureEventStart(InputType.mouseMove, info);
    }
  }

  @override
  FutureOr<void> add(Component component) {
    return gameWorld.add(component);
  }

  @override
  void onGameResize(Vector2 size) {
    moveJoystick?.position = Vector2(50, size.y - 50);
    aimJoystick?.position = Vector2(size.x - 50, size.y - 50);
    super.onGameResize(size);
  }

  late final MouseCallbackWrapper wrapper;

  @override
  void onRemove() {
    gameRef.mouseCallback.remove(wrapper);
    super.onRemove();
  }

  onSecondaryDown(TapDownInfo info) {
    player.gestureEventStart(InputType.secondaryClick, info);
  }

  onSecondaryUp(TapUpInfo info) {
    player.gestureEventEnd(InputType.secondaryClick, info);
  }

  onSecondaryCancel() {
    player.gestureEventEnd(InputType.secondaryClick, null);
  }

  @override
  void onMount() {
    wrapper = MouseCallbackWrapper();
    wrapper.onMouseMove = onMouseMove;
    wrapper.onPrimaryDown = onTapDown;
    wrapper.onPrimaryUp = onTapUp;
    wrapper.onSecondaryDown = (_) => onSecondaryDown;
    wrapper.onSecondaryUp = (_) => onSecondaryUp;
    wrapper.onSecondaryCancel = () => onSecondaryUp;
    gameRef.mouseCallback.add(wrapper);

    super.onMount();
  }

  @override
  FutureOr<void> onLoad() {
    windowManager.addListener(this);
    children.register<CameraComponent>();
    gameWorld = World();
    super.add(gameWorld);
    gameCamera = CameraComponent(world: gameWorld);

    moveJoystick = CustomJoystickComponent(
      knob: CircleComponent(radius: 15),
      priority: foregroundPriority,
      knobRadius: 15,
      position: Vector2(50, gameCamera.viewport.size.y - 50),
      background:
          CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
      // margin: const EdgeInsets.only(left: 30, bottom: 30),
    );
    aimJoystick = CustomJoystickComponent(
      knob: CircleComponent(radius: 15),
      priority: foregroundPriority,
      position: Vector2(
          gameCamera.viewport.size.x - 30, gameCamera.viewport.size.y - 30),
      knobRadius: 15,
      background:
          CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
      // margin: const EdgeInsets.only(right: 30, bottom: 30),
    );

    player = Player(PlayerData(), ancestor: this, initPosition: Vector2.zero());
    hud = GameHud(this);
    physicsComponent = Forge2DComponent();
    gameCamera.viewport.addAll([hud, moveJoystick!, aimJoystick!]);
    super.add(gameCamera);
    add(player);
    add(physicsComponent);

    player.mounted.whenComplete(() => gameCamera.viewfinder
        .add(CustomFollowBehavior(player, gameCamera.viewfinder)));
    gameCamera.viewfinder.zoom = 10;
    return super.onLoad();
  }

  void transmitDragInfo(int pointerId, DragUpdateInfo info) {
    switch (inputIdStates[pointerId]) {
      case InputType.aimJoy:
        aimJoystick?.onDragUpdate(info);
        player.gestureEventStart(InputType.aimJoy, info);

        break;
      case InputType.moveJoy:
        moveJoystick?.onDragUpdate(info);
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
          aimJoystick?.onDragCancel();
          player.gestureEventEnd(InputType.aimJoy, null);

          break;
        case InputType.moveJoy:
          moveJoystick?.onDragCancel();
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
    final moveEnabled = moveJoystick?.background
            ?.containsPoint(globalPos.eventPosition.global) ??
        false;
    final aimEnabled = aimJoystick?.background
            ?.containsPoint(globalPos.eventPosition.global) ??
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
  void onDragCancel(DragCancelEvent event) {
    endIdState(event.pointerId);
    super.onDragCancel(event);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    endIdState(event.pointerId);
    super.onDragEnd(event);
  }

  @override
  void onDragStart(DragStartEvent event) {
    discernJoystate(event.pointerId, event.asInfo(game));
    player.gestureEventStart(InputType.mouseDragStart, event.asInfo(game));
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    transmitDragInfo(event.pointerId, event.asInfo(game));
    super.onDragUpdate(event);
  }

  void onTapDown(TapDownInfo info) {
    if (Platform.isWindows && !discernJoystate(-1, info)) {
      player.gestureEventStart(InputType.tapClick, info);
    }
  }

  void onTapUp(TapUpInfo info) {
    endIdState(-1);
    player.gestureEventEnd(InputType.tapClick, info);
  }

  //TODO: REFINE
  @override
  void onWindowBlur() {
    pauseGame();
    super.onWindowBlur();
  }

  void pauseGame() {
    game.overlays.add('PauseMenu');
    player.physicalKeysPressed.clear();
    player.parseKeys(null);
    game.pauseEngine();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.keyP) ||
        keysPressed.contains(LogicalKeyboardKey.escape)) {
      pauseGame();
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
