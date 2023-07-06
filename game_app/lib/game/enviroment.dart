import 'dart:io';

import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide World;
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart'
    hide MoveEffect, ScaleEffect;
import 'package:game_app/functions/custom_mixins.dart';
import 'package:game_app/resources/physics_filter.dart';

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
import '../resources/enums.dart';
import '../resources/overlays.dart';
import '../resources/priorities.dart';
import 'package:window_manager/window_manager.dart';

import '../resources/visuals.dart';

abstract class GameEnviroment extends Component
    with
        HasGameRef<GameRouter>,
        // KeyboardHandler,
        WindowListener,
        DragCallbacks {
  CustomJoystickComponent? aimJoystick;
  CustomJoystickComponent? moveJoystick;
  abstract GameLevel level;
  late final Forge2DComponent physicsComponent;
  late final GameHud hud;
  late final Bounds bounds;
  Map<int, InputType> inputIdStates = {};
  late final Player player;

  late final World gameWorld;
  late CameraComponent gameCamera;

  @override
  bool containsLocalPoint(Vector2 point) {
    return true;
  }

  int levelUpQueue = 0;
  bool currentlyLevelingUp = false;
  TimerComponent? levelUpQueueTimer;

  void levelUp() {
    pauseGame(attributeSelection.key);
    currentlyLevelingUp = false;

    if (levelUpQueue == 0) {
      levelUpQueueTimer?.timer.stop();
      levelUpQueueTimer?.removeFromParent();
      levelUpQueueTimer = null;
    }
  }

  void preLevelUp() async {
    if (currentlyLevelingUp) {
      levelUpQueue++;
      levelUpQueueTimer ??= TimerComponent(
        period: .1,
        removeOnFinish: true,
        repeat: true,
        onTick: () {
          if (!currentlyLevelingUp && !player.isDead) {
            preLevelUp();
            levelUpQueue--;
          }
        },
      )..addToParent(this);
      return;
    }
    currentlyLevelingUp = true;
    const count = 3;
    for (var i = 0; i < count; i++) {
      final upArrow = CaTextComponent(
          position: Vector2(1, -.25),
          anchor: Anchor.center,
          priority: menuPriority,
          textRenderer:
              TextPaint(style: defaultStyle.copyWith(fontSize: 1 * (i + 1))),
          text: "^");
      final effectController = EffectController(
        duration: .3,
        curve: Curves.fastLinearToSlowEaseIn,
        onMax: () {
          if (i == count - 1) {
            levelUp();
          }
          upArrow.removeFromParent();
        },
      );

      upArrow.addAll([
        MoveEffect.by(
          Vector2(0, -1),
          effectController,
        ),
      ]);
      player.add(upArrow);
      await Future.delayed(.3.seconds);
    }
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

  late final MouseKeyboardCallbackWrapper wrapper;

  @override
  void onRemove() {
    gameRef.mouseCallback.remove(wrapper);
    windowManager.removeListener(this);

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
    wrapper = MouseKeyboardCallbackWrapper();
    wrapper.onMouseMove = onMouseMove;
    wrapper.onPrimaryDown = onTapDown;
    wrapper.onPrimaryUp = onTapUp;
    wrapper.onSecondaryDown = (_) => onSecondaryDown;
    wrapper.onSecondaryUp = (_) => onSecondaryUp;
    wrapper.onSecondaryCancel = () => onSecondaryUp;
    wrapper.keyEvent = (event) => onKeyEvent(event);
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
    gameCamera.priority = backgroundPriority;

    initJoysticks();

    player = Player(gameRef.playerDataComponent.dataObject,
        gameEnv: this, initPosition: Vector2.zero());
    hud = GameHud(this);
    physicsComponent = Forge2DComponent();
    bounds = Bounds();
    gameCamera.viewport.addAll([hud, moveJoystick!, aimJoystick!]);

    super.add(gameCamera);

    add(player);
    add(physicsComponent);
    add(bounds);

    player.mounted.whenComplete(() => gameCamera.viewfinder
        .add(CustomFollowBehavior(player, gameCamera.viewfinder)));

    gameCamera.viewfinder.zoom = 50;
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

  @override
  void onWindowBlur() {
    pauseGame(pauseMenu.key, wipeMovement: true);
    super.onWindowBlur();
  }

  void onKeyEvent(RawKeyEvent event) {
    if (event is! RawKeyDownEvent) return;
    if (event.logicalKey == LogicalKeyboardKey.keyP ||
        event.logicalKey == LogicalKeyboardKey.escape) {
      pauseGame(pauseMenu.key);
    }
  }
}

class Bounds extends BodyComponent {
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
