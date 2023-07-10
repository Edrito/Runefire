import 'package:flame/events.dart';
import 'package:flutter/services.dart';
import 'package:game_app/game/enviroment_mixin.dart';

import '../game/background.dart';

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import '../main.dart';
import '../resources/enums.dart';
import '../overlays/overlays.dart';
import '../resources/constants/priorities.dart';
import 'package:window_manager/window_manager.dart';

abstract class Enviroment extends Component
    with HasGameRef<GameRouter>, WindowListener, DragCallbacks {
  late final Forge2DComponent physicsComponent;

  Map<int, InputType> inputIdStates = {};
  late final World gameWorld;
  late CameraComponent gameCamera;

  @override
  bool containsLocalPoint(Vector2 point) {
    return true;
  }

  @override
  FutureOr<void> add(Component component) {
    return gameWorld.add(component);
  }

  late final MouseKeyboardCallbackWrapper wrapper;

  @override
  void onMount() {
    wrapper = MouseKeyboardCallbackWrapper();
    wrapper.onMouseMove = onMouseMove;
    wrapper.onPrimaryDown = onTapDown;
    wrapper.onPrimaryUp = onTapUp;
    // wrapper.onSecondaryDown = (_) => onSecondaryDown;
    // wrapper.onSecondaryUp = (_) => onSecondaryUp;
    // wrapper.onSecondaryCancel = () => onSecondaryUp;
    wrapper.keyEvent = (event) => onKeyEvent(event);
    gameRef.mouseCallback.add(wrapper);
    super.onMount();
  }

  @override
  void onRemove() {
    gameRef.mouseCallback.remove(wrapper);

    super.onRemove();
  }

  bool discernJoystate(int id, PositionInfo globalPos) {
    inputIdStates[id] = InputType.mouseDrag;
    return false;
  }

  @override
  FutureOr<void> onLoad() {
    windowManager.addListener(this);
    children.register<CameraComponent>();

    //World
    gameWorld = World();
    gameWorld.priority = worldPriority;
    super.add(gameWorld);

    //Camera
    gameCamera = CameraComponent(world: gameWorld);
    gameCamera.priority = backgroundPriority;
    gameCamera.viewfinder.zoom = 75;
    super.add(gameCamera);

    //Physics
    physicsComponent = Forge2DComponent();
    physicsComponent.priority = enemyPriority;
    add(physicsComponent);

    return super.onLoad();
  }

  void onTapDown(TapDownInfo info) {}

  void onMouseMove(PointerHoverInfo info) {}

  void onTapUp(TapUpInfo info) {}

  void onKeyEvent(RawKeyEvent event) {}
}

abstract class GameEnviroment extends Enviroment
    with
        PlayerFunctionality,
        // JoystickFunctionality,
        PauseOnFocusLost,
        BoundsFunctionality,
        HudFunctionality {
  abstract GameLevel level;

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.keyP ||
        event.logicalKey == LogicalKeyboardKey.escape) {
      pauseGame(pauseMenu.key);
    }
    super.onKeyEvent(event);
  }
}
