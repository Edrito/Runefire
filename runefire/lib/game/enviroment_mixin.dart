import 'dart:io';

import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/events/event_entity.dart';
import 'package:runefire/events/event_types.dart';
import 'package:runefire/game/hexed_forest_game.dart';
import 'package:runefire/game/menu_game.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/assets/assets.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/game_state_class.dart';

import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/game/hud.dart';

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runefire/resources/functions/custom_follow_behavior.dart';
import 'package:runefire/resources/functions/custom_joystick.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/priorities.dart';

import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/game/enviroment.dart';

// mixin JoystickFunctionality on PlayerFunctionality {
//   CustomJoystickComponent? aimJoystick;
//   CustomJoystickComponent? moveJoystick;

//   void initJoysticks() {
//     moveJoystick = CustomJoystickComponent(
//       knob: CircleComponent(radius: 15),
//       priority: foregroundPriority,
//       knobRadius: 15,
//       position: Vector2(50, gameCamera.viewport.size.y - 50),
//       background:
//           CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
//       // margin: const EdgeInsets.only(left: 30, bottom: 30),
//     );
//     aimJoystick = CustomJoystickComponent(
//       knob: CircleComponent(radius: 15),
//       priority: foregroundPriority,
//       position: Vector2(
//           gameCamera.viewport.size.x - 30, gameCamera.viewport.size.y - 30),
//       knobRadius: 15,
//       background:
//           CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
//       // margin: const EdgeInsets.only(right: 30, bottom: 30),
//     );
//   }

//   bool isMoveJoyClicked(Vector2 pos) {
//     return moveJoystick?.background?.containsPoint(pos) ?? false;
//   }

//   bool isAimJoyClicked(Vector2 pos) {
//     return (aimJoystick?.background?.containsPoint(pos) ?? false);
//   }

//   @override
//   bool discernJoystate(int id, Vector2 eventPosition) {
//     if (inputIdStates[id] == InputType.moveJoy) return true;
//     if (inputIdStates[id] == InputType.aimJoy) return true;

//     final moveEnabled = isMoveJoyClicked(eventPosition);
//     final aimEnabled = isAimJoyClicked(eventPosition);

//     if (moveEnabled) {
//       inputIdStates[id] = InputType.moveJoy;
//     }
//     if (aimEnabled) {
//       inputIdStates[id] = InputType.aimJoy;
//     }

//     if (!moveEnabled && !aimEnabled) {
//       inputIdStates[id] = InputType.mouseDrag;
//     }

//     return moveEnabled || aimEnabled;
//   }

//   @override
//   FutureOr<void> onLoad() {
//     super.onLoad();
//     initJoysticks();
//     gameCamera.viewport.addAll([moveJoystick!, aimJoystick!]);
//   }

//   @override
//   void transmitDragInfo(int pointerId, PointerMoveEvent info) {
//     switch (inputIdStates[pointerId]) {
//       case InputType.aimJoy:
//         aimJoystick?.onDragUpdate(info.localDelta.toVector2());
//         player?.gestureEventStart(
//             InputType.aimJoy, info.localPosition.toVector2());

//         break;
//       case InputType.moveJoy:
//         moveJoystick?.onDragUpdate(info.localDelta.toVector2());
//         player?.gestureEventStart(
//             InputType.moveJoy, info.localPosition.toVector2());
//         break;
//       // case InputType.mouseDrag:
//       //   player?.gestureEventStart(
//       //       InputType.mouseDrag, info.localPosition.toVector2());

//       default:
//     }
//   }

//   @override
//   void endIdState(int id) {
//     if (inputIdStates.containsKey(id)) {
//       switch (inputIdStates[id]) {
//         case InputType.aimJoy:
//           aimJoystick?.onDragCancel();
//           player?.gestureEventEnd(InputType.aimJoy);

//           break;
//         case InputType.moveJoy:
//           moveJoystick?.onDragCancel();
//           player?.gestureEventEnd(InputType.moveJoy);
//           break;
//         // case InputType.mouseDrag:
//         //   player?.gestureEventEnd(InputType.mouseDrag);

//         // break;
//         default:
//       }
//       inputIdStates.remove(id);
//     }
//   }

//   @override
//   void onGameResize(Vector2 size) {
//     moveJoystick?.position = Vector2(50, size.y - 50);
//     aimJoystick?.position = Vector2(size.x - 50, size.y - 50);
//     super.onGameResize(size);
//   }
// }

mixin HudFunctionality on Enviroment {
  late GameHud hud;
  @override
  GameEnviroment get gameEnviroment => this as GameEnviroment;
  Future<void> rebuildHud() async {
    hud.removeFromParent();
    hud = GameHud(gameEnviroment);
    gameCamera.viewport.addAll([hud]);
    if (gameEnviroment.playerAdded) {
      await hud.loaded;
      hud.buildRemainingLives(gameEnviroment.player!);
      hud.buildRemainingAmmo(gameEnviroment.player!);
    }
  }

  @override
  void onRemove() {
    gameRef.onSystemDataChange.remove((data) {
      rebuildHud();
    });
    super.onRemove();
  }

  @override
  FutureOr<void> onLoad() async {
    super.onLoad();
    gameRef.onSystemDataChange.add((data) {
      rebuildHud();
    });
    await Flame.images.loadAll([
      ...ImagesAssetsUi.allFilesFlame,
      ...ImagesAssetsAmmo.allFilesFlame,
    ]);
    assert(this is GameEnviroment);
    hud = GameHud(gameEnviroment);
    gameCamera.viewport.addAll([hud]);
  }
}

enum BossBoundsType {
  onViewport,
  onBoss,
}

enum BossBoundsScope { viewportSize, customSize }

mixin BoundsFunctionality on Enviroment {
  late final Bounds mainGameBorder;
  Bounds? bossBounds;
  final double boundsDistanceFromCenter = 70;

  Future<void> resizeBossBounds(String windowEvent) async {
    if (bossBounds == null) {
      return;
    }
    if (!bossBounds!.isMounted ||
        bossBounds!.isCircle ||
        bossBounds!.scope != BossBoundsScope.viewportSize) {
      return;
    }

    if (windowEvent.contains('maximize')) {
      await game.gameAwait(.2);
    }

    bossBounds?.boundsSize = getViewportSize();
    bossBounds?.createBounds();
    final playerPos =
        getPlayer!.center - gameCamera.viewfinder.position.clone();

    //If player is outside of bounds, bring them inside
    if (playerPos.x.abs() > bossBounds!.boundsSize.x ||
        playerPos.y.abs() > bossBounds!.boundsSize.y) {
      getPlayer?.body.setTransform(gameCamera.viewfinder.position.clone(), 0);
    }
  }

  @override
  void onMount() {
    addWindowEventFunctionToWrapper(resizeBossBounds);
    super.onMount();
  }

  Vector2 getViewportSize() {
    final x = gameCamera.viewport.size.x / 2 / gameCamera.viewfinder.zoom;
    final y = gameCamera.viewport.size.y / 2 / gameCamera.viewfinder.zoom;
    return Vector2(x, y);
  }

  EnemyEvent? boss;
  Future<void> createBossBounds(bool isCircle, EnemyEvent boss) async {
    assert(
      boss.boundsScope != BossBoundsScope.customSize ||
          boss.bossBoundsSize != null,
    );
    await boss.enemies.first.loaded;

    bossBounds = Bounds(
      boundsSize: boss.boundsScope == BossBoundsScope.viewportSize
          ? getViewportSize()
          : (boss.bossBoundsSize!
            ..x += boss.enemies.first.center.distanceTo(getPlayer!.center)),
      position: Vector2.zero(),
      isCircle: isCircle,
      scope: boss.boundsScope,
    );
    this.boss = boss;
    addPhysicsComponent([bossBounds!], instant: true);
  }

  void removeBossBounds() {
    bossBounds?.removeFromParent();
    bossBounds = null;
  }

  @override
  void update(double dt) {
    if (bossBounds != null) {
      if (bossBounds?.scope == BossBoundsScope.viewportSize) {
        bossBounds?.body.setTransform(gameCamera.viewfinder.position, 0);
      } else {
        bossBounds?.body.setTransform(
          boss?.enemies.first.isLoaded == true
              ? boss!.enemies.first.center
              : boss!.enemies.first.initialPosition,
          0,
        );
      }
    }
    super.update(dt);
  }

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    mainGameBorder = Bounds(
      boundsSize: Vector2.all(boundsDistanceFromCenter),
      position: Vector2.zero(),
      isCircle: false,
      scope: BossBoundsScope.customSize,
    );
    addPhysicsComponent([mainGameBorder], instant: true);
  }
}

class Bounds extends BodyComponent<GameRouter> with ContactCallbacks {
  Bounds({
    required this.boundsSize,
    required this.position,
    required this.isCircle,
    required this.scope,
  });
  BossBoundsScope scope;
  Vector2 boundsSize;
  @override
  final Vector2 position;
  final bool isCircle;
  bool hasLoaded = false;
  late final Shape currentBounds;

  Shape createBounds() {
    ChainShape shape;
    if (hasLoaded) {
      shape = body.fixtures.first.shape as ChainShape;
      if (shape.vertices.isNotEmpty) {
        shape.clear();
      }
    } else {
      shape = ChainShape();
    }
    if (isCircle) {
      shape.createLoop(getCirclePoints(boundsSize.x, 40));
    } else {
      shape.createLoop([
        Vector2(-boundsSize.x, boundsSize.y),
        Vector2(-boundsSize.x, -boundsSize.y),
        Vector2(boundsSize.x, -boundsSize.y),
        Vector2(boundsSize.x, boundsSize.y),
      ]);
    }

    return shape;
  }

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    contact.setEnabled(true);
    super.preSolve(other, contact, oldManifold);
  }

  @override
  void onMount() {
    hasLoaded = true;
    super.onMount();
  }

  @override
  Body createBody() {
    currentBounds = createBounds();

    renderBody = false;

    final fixtureDef = FixtureDef(
      currentBounds,
      userData: {'type': FixtureType.body, 'object': this},
      density: 1,
      filter: Filter()..maskBits = playerCategory,
    );

    final bodyDef = BodyDef(
      userData: this,
      position: position,
      linearDamping: 12,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

mixin CollisionEnviroment on Enviroment {
  // @override
  // void initializeWorld() {
  //   gameWorld = CustomCollisionWorld();
  //   gameWorld.priority = worldPriority;
  // }
}

mixin PauseOnFocusLost on Enviroment {
  @override
  void onMount() {
    addWindowEventFunctionToWrapper((windowEvent) {
      if (windowEvent == 'blur') {
        onWindowBlur();
      }
    });
    super.onMount();
  }

  void onWindowBlur() {
    if (this is GameEnviroment) {
      // gameState.pauseGame(pauseMenu.key, wipeMovement: true);
    }
  }
}

mixin GodFunctionality on Enviroment {
  bool get godAdded => god != null;

  GodEntity? god;

  void addGod(EventManagement eventManagement) {
    god = GodEntity(
      eventManagement: eventManagement,
      enviroment: this,
    );
    addPhysicsComponent([god!]);
  }
}

mixin PlayerFunctionality on Enviroment {
  bool get playerAdded => player != null;

  Player? player;
  late CustomFollowBehavior customFollow;

  // @override
  // void onMouseMove(MovementType type, PointerMoveEvent info) {
  //   if (type == MovementType.mouse) {
  //     player?.gestureEventStart(
  //         InputType.mouse, info.localPosition.toVector2());
  //   }
  // }

  // final test = PositionComponent();

  void addPlayer(EventManagement? eventManagement) {
    final isMenuGame = this is MenuGame;
    player = Player(
      playerData,
      isDisplay: isMenuGame,
      eventManagement:
          isMenuGame ? MenuGameEventManagement(this) : eventManagement!,
      enviroment: this,
      initialPosition: Vector2.zero(),
    );

    if (this is GameEnviroment) {
      customFollow =
          CustomFollowBehavior(player!, gameCamera, this as GameEnviroment);
      player?.mounted.then((value) => add(customFollow));
    }
    addPhysicsComponent([player!], instant: true);
  }
//
  // void transmitDragInfo(int pointerId, PointerMoveEvent info) {}

  // void endIdState(int id) {}

  // @override
  // void onRemove() {
  //   final instance = InputManager();
  //   instance.onPointerMoveList.remove(onPrimaryMove);

  //   super.onRemove();
  // }

  // @override
  // void onMount() {
  //   final instance = InputManager();
  // instance.onPointerMoveList.add(onPrimaryMove);

  //   super.onMount();
  // }

  // void onPrimaryDown(
  //     GameActionEvent gameAction, List<GameActionEvent> activeGameActions) {
  // final instance = InputManager();
  // bool check() {
  //   final joy = this as JoystickFunctionality;
  //   return joy.isAimJoyClicked(info.localPosition.toVector2()) ||
  //       joy.isMoveJoyClicked(info.localPosition.toVector2());
  // }

  // bool moveOrAimClicked = this is JoystickFunctionality ? check() : false;
  // if (Platform.isWindows && !moveOrAimClicked) {

  // }

  // player?.gestureEventStart(
  //     InputType.primary);
  // }

  // void onPrimaryMove(MovementType type, PointerMoveEvent event) {
  //   transmitDragInfo(event.pointer, event);
  //   discernJoystate(event.pointer, event.localPosition.toVector2());
  // }

  // @override
  // void onPrimaryUp(PointerUpEvent info) {
  //   endIdState(info.pointer);
  //   player?.gestureEventEnd(InputType.primary);
  // }
}

mixin GameTimerFunctionality on Enviroment {
  double timePassed = 0;
  bool isGameTimerPaused = false;

  void pauseGameTimer() {
    if (isGameTimerPaused) {
      return;
    }
    isGameTimerPaused = true;
  }

  void unPauseGameTimer() {
    if (!isGameTimerPaused) {
      return;
    }
    isGameTimerPaused = false;
  }

  Map<String, double> pulsingTimeMap = {};

  ///+ [fullCycleDuration] indicates how long this value takes to reset
  ///+ [backAndForth] indicates if the value should go back and forth or just reset
  ///+ [maxValue] indicates the max value the value should reach
  ///+ [curve] indicates the curve the value should follow
  double getPulsingTime(
    double fullCycleDuration,
    bool backAndForth, {
    Curve? curve,
    double? maxValue,
  }) {
    curve = Curves.linear;

    //TODO POTENTIAL LAG
    final key = "pulsingTime$fullCycleDuration$backAndForth$curve$maxValue";

    if (pulsingTimeMap.containsKey(key)) {
      return pulsingTimeMap[key]!;
    }
    double returnVal;
    if (backAndForth) {
      returnVal =
          ((timePassed % fullCycleDuration) - (fullCycleDuration / 2)).abs() *
              (maxValue ?? fullCycleDuration / (fullCycleDuration / 2));
    } else {
      returnVal = (timePassed % fullCycleDuration) /
          (fullCycleDuration / (maxValue ?? fullCycleDuration));
    }

    pulsingTimeMap[key] = returnVal;
    return returnVal;
  }

  @override
  void update(double dt) {
    if (!isGameTimerPaused) {
      timePassed += dt;
      if (this is HudFunctionality) {
        final hud = this as HudFunctionality;
        if (hud.hud.isLoaded) {
          hud.hud.timerText.text =
              convertSecondsToMinutesSeconds(timePassed.round());
        }
      }
    }
    super.update(dt);
  }
}
