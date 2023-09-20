import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:game_app/game/enviroment_mixin.dart';
import 'package:game_app/resources/data_classes/player_data.dart';
import 'package:game_app/resources/game_state_class.dart';
import 'package:game_app/test.dart';

import '../player/player.dart';
import '../game/background.dart';

import 'dart:async';
import 'package:flame/components.dart';
import '../main.dart';
import '../resources/data_classes/system_data.dart';
import '../resources/enums.dart';
import '../menus/overlays.dart';
import '../resources/constants/priorities.dart';

abstract class Enviroment extends Component with HasGameRef<GameRouter> {
  abstract final GameLevel level;
  late final Forge2DComponent physicsComponent;

  PlayerData get playerData => gameRef.playerDataComponent.dataObject;
  SystemData get systemData => gameRef.systemDataComponent.dataObject;
  GameState get gameState => gameRef.gameStateComponent.gameState;
  Player? get getPlayer => (this as GameEnviroment).player;

  GameEnviroment? get gameEnviroment =>
      this is GameEnviroment ? this as GameEnviroment : null;

  Enviroment() {
    wrapper = MouseKeyboardCallbackWrapper();
  }
  Map<int, InputType> inputIdStates = {};
  late final World gameWorld;
  late CameraComponent gameCamera;

  int children2 = 0;
  void printChildren(var children) {
    for (Component element in children) {
      print(element);
      children2++;
      printChildren(element.children);
    }
  }

  void addWindowEventFunctionToWrapper(Function(String) func) {
    final previousFunc = wrapper.onWindowEvent;
    if (previousFunc != null) {
      wrapper.onWindowEvent = (windowEvent) {
        func(windowEvent);

        previousFunc(windowEvent);
      };
    } else {
      wrapper.onWindowEvent = (windowEvent) {
        func(windowEvent);
      };
    }
  }

  double seconds = 5;
  double time = 0;

  @override
  // ignore: unnecessary_overrides
  void update(double dt) {
    // time += dt;
    // if (time > seconds) {
    //   time = 0;
    //   printChildren(children);
    //   print(children2);
    //   children2 = 0;
    // }

    updateFunction(this, dt);
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
    wrapper.keyEvent = (event) => onKeyEvent(event);
    gameRef.mouseCallback.add(wrapper);
    super.onMount();
  }

  @override
  void onRemove() {
    gameRef.mouseCallback.remove(wrapper);

    super.onRemove();
  }

  void initializeWorld() {
    gameWorld = World();
    gameWorld.priority = worldPriority;
  }

  bool discernJoystate(int id, Vector2 eventPosition) {
    inputIdStates[id] = InputType.mouseDrag;
    return false;
  }

  @override
  FutureOr<void> onLoad() {
    children.register<CameraComponent>();
    priority = worldPriority;

    //World
    initializeWorld();
    super.add(gameWorld);

    //Camera
    gameCamera = CameraComponent(world: gameWorld);
    gameCamera.priority = -50000;
    gameCamera.viewfinder.zoom = 75;
    super.add(gameCamera);

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
        PauseOnFocusLost,
        BoundsFunctionality,
        // JoystickFunctionality,
        GameTimerFunctionality,
        CollisionEnviroment,
        HudFunctionality {
  late final GameDifficulty difficulty;

  @override
  Future<void> onLoad() async {
    difficulty = playerData.selectedDifficulty;

    super.onLoad();
  }

  @override
  void onKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.keyP ||
        event.logicalKey == LogicalKeyboardKey.escape) {
      gameState.pauseGame(pauseMenu.key);
    }
    super.onKeyEvent(event);
  }
}
