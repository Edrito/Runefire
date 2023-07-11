import 'dart:io';

import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:game_app/entities/player.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:window_manager/window_manager.dart';

import '../resources/functions/custom_follow_behavior.dart';
import '../game/hud.dart';

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import '../resources/functions/custom_joystick.dart';
import '../main.dart';
import '../resources/enums.dart';
import '../overlays/overlays.dart';
import '../resources/constants/priorities.dart';

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
  FutureOr<void> onLoad() {
    super.onLoad();
    initJoysticks();
    gameCamera.viewport.addAll([moveJoystick!, aimJoystick!]);
  }

  @override
  void transmitDragInfo(int pointerId, DragUpdateInfo info) {
    switch (inputIdStates[pointerId]) {
      case InputType.aimJoy:
        aimJoystick?.onDragUpdate(info);
        player?.gestureEventStart(InputType.aimJoy, info);

        break;
      case InputType.moveJoy:
        moveJoystick?.onDragUpdate(info);
        player?.gestureEventStart(InputType.moveJoy, info);
        break;
      case InputType.mouseDrag:
        player?.gestureEventStart(InputType.mouseDrag, info);

      default:
    }
  }

  @override
  void endIdState(int id) {
    if (inputIdStates.containsKey(id)) {
      switch (inputIdStates[id]) {
        case InputType.aimJoy:
          aimJoystick?.onDragCancel();
          player?.gestureEventEnd(InputType.aimJoy, null);

          break;
        case InputType.moveJoy:
          moveJoystick?.onDragCancel();
          player?.gestureEventEnd(InputType.moveJoy, null);
          break;
        case InputType.mouseDrag:
          player?.gestureEventEnd(InputType.mouseDrag, null);

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

mixin BoundsFunctionality on Enviroment {
  late final Bounds bounds;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();

    bounds = Bounds();
    add(bounds);
  }
}

class Bounds extends BodyComponent<GameRouter> {
  late ChainShape bounds;
  final double maxArea = 70;
  @override
  Body createBody() {
    bounds = ChainShape();
    bounds.createLoop([
      Vector2(-maxArea, maxArea),
      Vector2(-maxArea, -maxArea),
      Vector2(maxArea, -maxArea),
      Vector2(maxArea, maxArea),
    ]);
    renderBody = false;

    final fixtureDef = FixtureDef(bounds,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 1,
        filter: Filter()..maskBits = playerCategory);

    final bodyDef = BodyDef(
      userData: this,
      position: Vector2.zero(),
      type: BodyType.static,
      linearDamping: 12,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

mixin PauseOnFocusLost on Enviroment {
  @override
  void onRemove() {
    windowManager.removeListener(this);

    super.onRemove();
  }

  @override
  void onWindowBlur() {
    pauseGame(pauseMenu.key, wipeMovement: true);
    super.onWindowBlur();
  }
}

mixin PlayerFunctionality on Enviroment {
  bool get playerAdded => player != null;

  Player? player;

  @override
  FutureOr<void> onLoad() {
    super.onLoad();
    addPlayer();
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    if (Platform.isWindows) {
      player?.gestureEventStart(InputType.mouseMove, info);
    }
  }

  void addPlayer() {
    player = Player(gameRef.playerDataComponent.dataObject, false,
        gameEnviroment: this, initPosition: Vector2.zero());
    player?.priority = playerPriority;
    player?.mounted.whenComplete(
        () => add(CustomFollowBehavior(player!, gameCamera.viewfinder)));
    add(player!);
  }

  void transmitDragInfo(int pointerId, DragUpdateInfo info) {
    switch (inputIdStates[pointerId]) {
      case InputType.mouseDrag:
        player?.gestureEventStart(InputType.mouseDrag, info);

      default:
    }
  }

  void endIdState(int id) {
    if (inputIdStates.containsKey(id)) {
      switch (inputIdStates[id]) {
        case InputType.mouseDrag:
          player?.gestureEventEnd(InputType.mouseDrag, null);

          break;
        default:
      }
      inputIdStates.remove(id);
    }
  }

  @override
  void onTapDown(TapDownInfo info) {
    if (Platform.isWindows && !discernJoystate(-1, info)) {
      player?.gestureEventStart(InputType.tapClick, info);
    }
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
    player?.gestureEventStart(InputType.mouseDragStart, event.asInfo(game));
    super.onDragStart(event);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    transmitDragInfo(event.pointerId, event.asInfo(game));
    super.onDragUpdate(event);
  }

  @override
  void onTapUp(TapUpInfo info) {
    endIdState(-1);
    player?.gestureEventEnd(InputType.tapClick, info);
  }
}
