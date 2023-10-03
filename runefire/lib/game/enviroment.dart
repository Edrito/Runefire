import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/test.dart';

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
  late final Forge2DComponent _physicsComponent;

  double get zoom => gameCamera.viewfinder.zoom;

  //(int, double) is (priority, duration)
  Map<(int, double), List<dynamic>> physicsEntitiesToAddQueue = {};
  List<Component> tempAddingEntities = [];
  double durationNoAdd = 0;
  late final TimerComponent physicsEntityAdding = TimerComponent(
    period: 1,
    repeat: true,
    onTick: () {
      addPhysicsComponentTick();
    },
  )..addToParent(this);

  void addTempComponent() {
    tempAddingEntities.first.addToParent(_physicsComponent);
    tempAddingEntities.removeAt(0);
    durationNoAdd = 0;
  }

  int currentPriority = 0;
  int newestPriority = 0;

  void addPhysicsComponentTick() {
    if (tempAddingEntities.isNotEmpty && newestPriority <= currentPriority) {
      addTempComponent();
    } else if (physicsEntitiesToAddQueue.isNotEmpty) {
      final highestPri = physicsEntitiesToAddQueue.keys.toList();
      highestPri.sort((b, a) => a.$1.compareTo(b.$1));
      final key = highestPri.first;
      final highestPriList = physicsEntitiesToAddQueue[key];

      if (highestPriList != null && highestPriList.isNotEmpty) {
        tempAddingEntities.addAll(highestPriList as List<Component>);
        tempAddingEntities = [...tempAddingEntities.reversed];
        physicsEntityAdding.timer.limit = key.$2 / tempAddingEntities.length;
        addTempComponent();
        currentPriority = key.$1;
        if (highestPriList.length >= 2) {
          newestPriority = key.$1;
        }
      }
      physicsEntitiesToAddQueue.remove(key);
    } else {
      durationNoAdd += physicsEntityAdding.timer.limit;
      if (durationNoAdd > 1) {
        physicsEntityAdding.timer.stop();
        durationNoAdd = 0;
      }
    }
  }

  bool firstTick = false;
  void addPhysicsComponent(List<Component> components,
      {bool instant = false, double duration = .2, int priority = 0}) {
    if (instant || components.length < 2) {
      _physicsComponent.addAll(components);
    } else {
      if (priority > newestPriority) {
        newestPriority = priority;
      }
      physicsEntitiesToAddQueue[(priority, duration)]?.addAll(components);

      physicsEntitiesToAddQueue[(priority, duration)] ??= components;

      if (!physicsEntityAdding.timer.isRunning() || !firstTick) {
        physicsEntityAdding.timer.start();
        physicsEntityAdding.timer.onTick?.call();
        firstTick = true;
      }
    }
  }

  PlayerData get playerData => gameRef.playerDataComponent.dataObject;
  SystemData get systemData => gameRef.systemDataComponent.dataObject;
  GameState get gameState => gameRef.gameStateComponent.gameState;
  Player? get getPlayer => (this as GameEnviroment).player;

  List<Entity> activeEntites = [];

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
      children2++;
      if (element is TimerComponent) {
        print(element.parent);
      }
      // print(element);
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
    _physicsComponent = Forge2DComponent();
    _physicsComponent.priority = enemyPriority;
    add(_physicsComponent);

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
    await Flame.images.loadAll([
      ...ImagesAssetsMagic.allFilesFlame,
      ...ImagesAssetsProjectiles.allFilesFlame,
      ...ImagesAssetsEffects.allFilesFlame,
      ...ImagesAssetsWeapons.allFilesFlame
    ]);
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
