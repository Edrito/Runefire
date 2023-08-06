import 'dart:io';

import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/resources/constants/physics_filter.dart';

import 'event_management.dart';
import '../game/hud.dart';

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../resources/functions/custom_follow_behavior.dart';
import '../resources/functions/custom_joystick.dart';
import '../main.dart';
import '../resources/enums.dart';
import '../resources/constants/priorities.dart';

import '../resources/functions/functions.dart';
import 'enviroment.dart';

mixin JoystickFunctionality on PlayerFunctionality {
  CustomJoystickComponent? aimJoystick;
  CustomJoystickComponent? moveJoystick;

  void initJoysticks() {
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
  }

  @override
  bool discernJoystate(int id, Vector2 eventPosition) {
    final moveEnabled =
        moveJoystick?.background?.containsPoint(eventPosition) ?? false;
    final aimEnabled =
        aimJoystick?.background?.containsPoint(eventPosition) ?? false;

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
  FutureOr<void> onLoad() {
    super.onLoad();
    initJoysticks();
    gameCamera.viewport.addAll([moveJoystick!, aimJoystick!]);
  }

  @override
  void transmitDragInfo(int pointerId, PointerMoveEvent info) {
    switch (inputIdStates[pointerId]) {
      case InputType.aimJoy:
        aimJoystick?.onDragUpdate(info.localDelta.toVector2());
        player?.gestureEventStart(
            InputType.aimJoy, info.localPosition.toVector2());

        break;
      case InputType.moveJoy:
        moveJoystick?.onDragUpdate(info.localDelta.toVector2());
        player?.gestureEventStart(
            InputType.moveJoy, info.localPosition.toVector2());
        break;
      case InputType.mouseDrag:
        player?.gestureEventStart(
            InputType.mouseDrag, info.localPosition.toVector2());

      default:
    }
  }

  @override
  void endIdState(int id) {
    if (inputIdStates.containsKey(id)) {
      switch (inputIdStates[id]) {
        case InputType.aimJoy:
          aimJoystick?.onDragCancel();
          player?.gestureEventEnd(InputType.aimJoy);

          break;
        case InputType.moveJoy:
          moveJoystick?.onDragCancel();
          player?.gestureEventEnd(InputType.moveJoy);
          break;
        case InputType.mouseDrag:
          player?.gestureEventEnd(InputType.mouseDrag);

          break;
        default:
      }
      inputIdStates.remove(id);
    }
  }

  @override
  void onGameResize(Vector2 size) {
    moveJoystick?.position = Vector2(50, size.y - 50);
    aimJoystick?.position = Vector2(size.x - 50, size.y - 50);
    super.onGameResize(size);
  }
}

mixin HudFunctionality on Enviroment {
  late final GameHud hud;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    hud = GameHud(this);
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

  void resizeBossBounds(String windowEvent) async {
    if (bossBounds == null) return;
    if (!bossBounds!.isMounted ||
        bossBounds!.isCircle ||
        bossBounds!.scope != BossBoundsScope.viewportSize) return;

    if (windowEvent.contains("maximize")) await Future.delayed(.2.seconds);

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
  void createBossBounds(bool isCircle, EnemyEvent boss) async {
    assert(boss.boundsScope != BossBoundsScope.customSize ||
        boss.bossBoundsSize != null);
    await boss.enemies.first.loaded;

    bossBounds = Bounds(
        boundsSize: boss.boundsScope == BossBoundsScope.viewportSize
            ? getViewportSize()
            : (boss.bossBoundsSize!
              ..x += boss.enemies.first.center.distanceTo(getPlayer!.center)),
        position: Vector2.zero(),
        isCircle: isCircle,
        scope: boss.boundsScope);
    this.boss = boss;
    physicsComponent.add(bossBounds!);
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
                : boss!.enemies.first.initPosition,
            0);
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
        scope: BossBoundsScope.customSize);
    physicsComponent.add(mainGameBorder);
  }
}

class Bounds extends BodyComponent<GameRouter> {
  Bounds(
      {required this.boundsSize,
      required this.position,
      required this.isCircle,
      required this.scope});
  BossBoundsScope scope;
  Vector2 boundsSize;
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
  void onMount() {
    hasLoaded = true;
    super.onMount();
  }

  @override
  Body createBody() {
    currentBounds = createBounds();

    renderBody = true;

    final fixtureDef = FixtureDef(currentBounds,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 1,
        filter: Filter()..maskBits = playerCategory);

    final bodyDef = BodyDef(
      userData: this,
      position: position,
      type: BodyType.static,
      linearDamping: 12,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

mixin PauseOnFocusLost on Enviroment {
  @override
  void onMount() {
    addWindowEventFunctionToWrapper((windowEvent) {
      if (windowEvent == "blur") {
        onWindowBlur();
      }
    });
    super.onMount();
  }

  void onWindowBlur() {
    // gameState.pauseGame(pauseMenu.key, wipeMovement: true);
  }
}

mixin PlayerFunctionality on Enviroment {
  bool get playerAdded => player != null;

  Player? player;
  late CustomFollowBehavior customFollow;
  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    addPlayer();
  }

  @override
  void onMouseMove(PointerHoverEvent info) {
    if (Platform.isWindows) {
      player?.gestureEventStart(
          InputType.mouseMove, info.localPosition.toVector2());
    }
  }

  final test = PositionComponent();

  void addPlayer() {
    player = Player(playerData, false,
        enviroment: this, initPosition: Vector2.zero());

    if (this is GameEnviroment) {
      customFollow =
          CustomFollowBehavior(player!, gameCamera, this as GameEnviroment);
      player?.mounted.then((value) => add(customFollow));
    }

    add(player!);
  }

  void transmitDragInfo(int pointerId, PointerMoveEvent info) {
    switch (inputIdStates[pointerId]) {
      case InputType.mouseDrag:
        player?.gestureEventStart(
            InputType.mouseDrag, info.localPosition.toVector2());

      default:
    }
  }

  void endIdState(int id) {
    if (inputIdStates.containsKey(id)) {
      switch (inputIdStates[id]) {
        case InputType.mouseDrag:
          player?.gestureEventEnd(InputType.mouseDrag);

          break;
        default:
      }
      inputIdStates.remove(id);
    }
  }

  // @override
  // void onDragCancel(DragCancelEvent event) {
  //   endIdState(event.pointerId);
  //   super.onDragCancel(event);
  // }

  // @override
  // void onDragEnd(DragEndEvent event) {
  //   endIdState(event.pointerId);
  //   super.onDragEnd(event);
  // }

  // @override
  // void onDragStart(DragStartEvent event) {
  //   super.onDragStart(event);
  // }

  @override
  void onTapDown(PointerDownEvent info) {
    if (Platform.isWindows &&
        !discernJoystate(-1, info.localPosition.toVector2())) {
      player?.gestureEventStart(
          InputType.tapClick, info.localPosition.toVector2());
    }
  }

  void onTapMove(PointerMoveEvent event) {
    transmitDragInfo(event.pointer, event);
    discernJoystate(event.pointer, event.localPosition.toVector2());
    // player?.gestureEventStart(
    //     InputType.mouseDragStart, event.localPosition.toVector2());
  }

  @override
  void onTapUp(PointerUpEvent info) {
    endIdState(info.pointer);
    player?.gestureEventEnd(InputType.tapClick);
  }
}

mixin GameTimerFunctionality on Enviroment {
  double timePassed = 0;
  bool isPaused = false;

  void pauseGame() {
    if (isPaused) {
      return;
    }
    isPaused = true;
  }

  void unPauseGame() {
    if (!isPaused) {
      return;
    }
    isPaused = false;
  }

  @override
  void update(double dt) {
    if (!isPaused) {
      timePassed += dt;
      if (this is HudFunctionality) {
        final hud = (this as HudFunctionality);
        if (hud.hud.isLoaded) {
          hud.hud.timerText.text =
              convertSecondsToMinutesSeconds(timePassed.round());
        }
      }
    }
    super.update(dt);
  }
}
