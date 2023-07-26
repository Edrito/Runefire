import 'dart:io';

import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/services.dart';
import 'package:game_app/entities/player.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:window_manager/window_manager.dart';

import '../game/hud.dart';

import 'dart:async';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../resources/functions/custom_follow_behavior.dart';
import '../resources/functions/custom_joystick.dart';
import '../main.dart';
import '../resources/enums.dart';
import '../overlays/overlays.dart';
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
  void onMouseMove(PointerHoverEvent info) {
    // test.position = info.localPosition.toVector2();
    if (Platform.isWindows) {
      player?.gestureEventStart(
          InputType.mouseMove, info.localPosition.toVector2());
    }
  }

  final test = PositionComponent();

  void addPlayer() {
    player = Player(gameRef.playerDataComponent.dataObject, false,
        gameEnviroment: this, initPosition: Vector2.zero());
    // player?.priority = playerPriority;

    // add(CustomFollowBehavior(player!, gameCamera.viewfinder));\
    player?.mounted.then(
        (value) => add(CustomFollowBehavior(player!, gameCamera.viewfinder)));
    // player?.priority = playerPriority;
    // add(test);
    // test.add(CircleComponent(radius: .1, paint: Paint()..color = Colors.red));
    // gameCamera.follow(test);

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
        (this as HudFunctionality).hud.timerText.text =
            convertSecondsToMinutesSeconds(timePassed.round());
      }
    }
    super.update(dt);
  }
}
