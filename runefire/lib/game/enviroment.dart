import 'dart:ui';
import 'dart:ui' as ui;

import 'package:flame/effects.dart';
import 'package:flame/flame.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/enviroment_interactables/interactable.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/custom_test.dart';
import 'package:runefire/weapons/projectile_class.dart';

import 'package:runefire/player/player.dart';
import 'package:runefire/game/background.dart';

import 'dart:async';
import 'package:flame/components.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/resources/constants/priorities.dart';

abstract class Enviroment extends Component with HasGameRef<GameRouter> {
  abstract final GameLevel level;
  Map<int, Forge2DComponent> priorityPhysicsComponents = {};

  double get zoom => gameCamera.viewfinder.zoom;

  //(int, double) is (priority, duration)
  Map<(int, double), List<Component>> physicsEntitiesToAddQueue = {};
  List<Component> tempAddingEntities = [];
  double durationNoAdd = 0;
  late final TimerComponent physicsEntityAdding = TimerComponent(
    period: 1,
    repeat: true,
    onTick: addPhysicsComponentTick,
  )..addToParent(this);

  void addTempComponent([Component? component]) {
    final temp = component ?? tempAddingEntities.first;
    if (!priorityPhysicsComponents.containsKey(temp.priority)) {
      priorityPhysicsComponents[temp.priority] = Forge2DComponent();
      priorityPhysicsComponents[temp.priority]!.priority = temp.priority;
      add(priorityPhysicsComponents[temp.priority]!);
    }

    temp.addToParent(priorityPhysicsComponents[temp.priority]!);
    if (component == null) {
      tempAddingEntities.remove(temp);
      durationNoAdd = 0;
    }
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
        tempAddingEntities.addAll(List<Component>.from(highestPriList));
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
        for (final element in [
          ...priorityPhysicsComponents.entries
              .where((element) => element.value.children.isEmpty),
        ]) {
          priorityPhysicsComponents.remove(element.key);
        }
      }
    }
  }

  List<TextComponent> enemyTexts = [];
  void addTextComponents(List<TextComponent> textComponents) {
    final activeCount = enemyTexts.length;
    final newCount = textComponents.length;

    if (newCount > enemyTextMaxActive) {
      for (final element in enemyTexts) {
        element.removeFromParent();
      }
      enemyTexts.clear();
      textComponents.removeRange(0, textComponents.length - enemyTextMaxActive);
      enemyTexts.addAll(textComponents);
      addPhysicsComponent(textComponents, instant: true);
    } else if (activeCount + newCount <= enemyTextMaxActive) {
      enemyTexts.addAll(textComponents);
      addPhysicsComponent(textComponents, instant: true);
    } else {
      final toRemove = activeCount + newCount - enemyTextMaxActive;
      for (var i = 0; i < toRemove; i++) {
        enemyTexts.removeAt(0).removeFromParent();
      }
      enemyTexts.addAll(textComponents);
      addPhysicsComponent(textComponents, instant: true);
    }
  }

  bool firstTick = false;
  void addPhysicsComponent(
    List<Component> components, {
    bool instant = false,
    double duration = .2,
    int priority = 0,
  }) {
    if (components.isEmpty) {
      return;
    }
    for (final element in components) {
      if (element is HasPaint) {
        element.setOpacity(.2);
      }
    }
    if (instant || components.length < 2) {
      addTempComponent(components.first);
    } else {
      if (priority > newestPriority) {
        newestPriority = priority;
      }
      physicsEntitiesToAddQueue[(priority, duration)]?.addAll(components);

      physicsEntitiesToAddQueue[(priority, duration)] ??=
          List<Component>.from([...components]);

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

  Enviroment();
  late final World gameWorld;
  late CameraComponent gameCamera;

  int children2 = 0;
  void printChildren(Iterable<Component> children) {
    for (final element in children) {
      children2++;
      if (element is TimerComponent) {
        print(element.parent);
      }
      // print(element);
      printChildren(element.children);
    }
  }

  void addWindowEventFunctionToWrapper(Function(String) newEventFunction) {
    final instance = InputManager();
    instance.onWindowEventList.add(newEventFunction);
  }

  double seconds = 5;
  double time = 0;

  @override
  void update(double dt) {
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

  @override
  void onMount() {
    final instance = InputManager();
    instance.onPointerMoveList.add(onMouseMove);
    instance.addGameActionListener(GameAction.primary, onPrimary);

    super.onMount();
  }

  @override
  void onRemove() {
    final instance = InputManager();
    instance.onPointerMoveList.remove(onMouseMove);
    instance.removeGameActionListener(GameAction.primary, onPrimary);

    super.onRemove();
  }

  void initializeWorld() {
    gameWorld = World();
    gameWorld.priority = worldPriority;
  }

  // bool discernJoystate(int id, Vector2 eventPosition) {
  //   inputIdStates[id] = InputType.mouseDrag;
  //   return false;
  // }

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

    // //Physics
    // _physicsComponent = Forge2DComponent();
    // _physicsComponent.priority = enemyPriority;
    // add(_physicsComponent);

    return super.onLoad();
  }

  void onPrimary(
    GameActionEvent gameAction,
    Set<GameAction> activeGameActions,
  ) {}
  void pauseGameAction(
    GameActionEvent gameAction,
    Set<GameAction> activeGameActions,
  ) {
    if (gameAction.pressState != PressState.pressed) {
      return;
    }

    if (this is! GameEnviroment) {
      return;
    }
    gameRef.gameStateComponent.gameState.pauseGame(
      pauseMenu.key,
    );
  }

  void onMouseMove(ExternalInputType type, Offset pos) {}
}

abstract class GameEnviroment extends Enviroment
    with
        PlayerFunctionality,
        PauseOnFocusLost,
        BoundsFunctionality,
        // JoystickFunctionality,
        GameTimerFunctionality,
        GodFunctionality,
        CollisionEnviroment,
        HudFunctionality {
  late final SpriteShadows entityShadow;
  late final Vignette vignette;
  late final GameDifficulty difficulty;
  late final EventManagement _eventManagement;
  EventManagement get eventManagement => _eventManagement;
  bool gameHasEnded = false;

  set setEventManagement(EventManagement eventManagement) {
    _eventManagement = eventManagement;
    addGod(eventManagement);
    addPlayer(eventManagement);
  }

  @override
  void onMount() {
    final instance = InputManager();
    instance.addGameActionListener(GameAction.pause, pauseGameAction);

    super.onMount();
  }

  @override
  void onRemove() {
    final instance = InputManager();
    instance.removeGameActionListener(GameAction.pause, pauseGameAction);

    super.onRemove();
  }

  @override
  Future<void> onLoad() async {
    difficulty = playerData.selectedDifficulty;
    await Flame.images.loadAll([
      ...ImagesAssetsMagic.allFilesFlame,
      ...ImagesAssetsProjectiles.allFilesFlame,
      ...ImagesAssetsEffects.allFilesFlame,
      ...ImagesAssetsWeapons.allFilesFlame,
    ]);

    await super.onLoad();

    if (!disableEnemies) {
      loaded.then((value) => add(eventManagement));
    }
    entityShadow = SpriteShadows(this);
    vignette = Vignette(gameCamera);
    add(vignette);
    add(entityShadow);
  }
}

class ExitArrowPainter extends SpriteAnimationComponent {
  ExitArrowPainter(this.gameEnviroment, this.exitVector) {
    player = gameEnviroment.player!;
    priority = playerOverlayPriority;
  }

  @override
  FutureOr<void> onLoad() async {
    final tempAnim = await spriteAnimations.exitArrow1;
    animation = tempAnim;
    size = tempAnim.frames.first.sprite.srcSize..scaledToHeight(player);
    anchor = Anchor.center;
    add(
      OpacityEffect.fadeIn(
        EffectController(
          duration: .5,
        ),
      ),
    );

    return super.onLoad();
  }

  bool fadeOut = false;
  @override
  void update(double dt) {
    angle = -radiansBetweenPoints(Vector2(0, 1), player.center - exitVector);
    if (player.center.distanceTo(exitVector) < 4 && !fadeOut) {
      fadeOut = true;
      add(
        OpacityEffect.fadeOut(
          EffectController(
            duration: .5,
            onMax: removeFromParent,
          ),
        ),
      );
    }
    super.update(dt);
  }

  final GameEnviroment gameEnviroment;
  late final Player player;
  late final Vector2 exitVector;
}
