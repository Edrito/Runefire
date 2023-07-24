import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:game_app/game/enviroment_mixin.dart';

import '../game/background.dart';

import 'dart:async';
import 'package:flame/components.dart';
import '../main.dart';
import '../resources/enums.dart';
import '../overlays/overlays.dart';
import '../resources/constants/priorities.dart';
import 'package:window_manager/window_manager.dart';

abstract class Enviroment extends Component
    with HasGameRef<GameRouter>, WindowListener {
  late final Forge2DComponent physicsComponent;
  Enviroment() {
    wrapper = MouseKeyboardCallbackWrapper();
  }
  Map<int, InputType> inputIdStates = {};
  late final World gameWorld;
  late CameraComponent gameCamera;

  void printChildren(var children) {
    for (var element in children) {
      print(element);
      printChildren(element.children);
    }
  }

  @override
  // ignore: unnecessary_overrides
  void update(double dt) {
    super.update(dt);
  }

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

  bool discernJoystate(int id, Vector2 eventPosition) {
    inputIdStates[id] = InputType.mouseDrag;
    return false;
  }

  @override
  FutureOr<void> onLoad() {
    windowManager.addListener(this);
    children.register<CameraComponent>();
    priority = worldPriority;
    //World
    gameWorld = World();
    gameWorld.priority = worldPriority;

    //Camera
    gameCamera = CameraComponent(world: gameWorld);
    gameCamera.priority = -50000;
    gameCamera.viewfinder.zoom = 75;
    super.add(gameCamera);
    super.add(gameWorld);
    // gameCamera.viewfinder.angle = radians(180);
    //Physics
    physicsComponent = Forge2DComponent();
    physicsComponent.priority = enemyPriority;
    add(physicsComponent);

    return super.onLoad();
  }

  void onTapDown(PointerDownEvent info) {}

  void onMouseMove(PointerHoverEvent info) {}

  void onTapUp(PointerUpEvent info) {}

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
