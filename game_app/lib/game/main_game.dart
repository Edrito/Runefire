import 'dart:async';
import 'dart:io';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:game_app/game/enemies.dart';
import 'package:game_app/game/player.dart';
import '../functions/custom_follow_behavior.dart';
import '../functions/custom_joystick.dart';
import '../functions/vector_functions.dart';
import '../main.dart';
import 'background.dart';
import 'characters.dart';
import 'hud.dart';

extension PositionProvider on Player {
  Vector2 get position => body.worldCenter;
}

enum GameLevel { space, forest }

enum InputType {
  keyboard,
  mouseMove,
  aimJoy,
  moveJoy,
  tapClick,
  mouseDrag,
  mouseDragStart,
  ai,
}

class MainGame extends Component
    with HasGameRef<GameRouter>, KeyboardHandler, TapCallbacks, DragCallbacks {
  CustomJoystickComponent? aimJoystick;
  CustomJoystickComponent? moveJoystick;

  late final BackgroundComponent backgroundComponent;
  late EnemyManagement enemyManagement;
  late final GameHud hud;
  Map<int, InputType> inputIdStates = {};
  late final Player player;

  late final World gameWorld;
  late CameraComponent gameCamera;

  @override
  bool containsLocalPoint(Vector2 point) {
    return true;
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

  @override
  Future<void> onLoad() async {
    gameRef.mouseCallback = onMouseMove;
    children.register<CameraComponent>();
    gameWorld = World();
    super.add(gameWorld);
    gameCamera = CameraComponent(world: gameWorld);
    // moveJoystick = CustomJoystickComponent(
    //   knob: CircleComponent(radius: 15),
    //   priority: 20,
    //   knobRadius: 15,
    //   position: Vector2(50, canvasSize.y - 50),
    //   background:
    //       CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
    //   // margin: const EdgeInsets.only(left: 30, bottom: 30),
    // );
    // aimJoystick = CustomJoystickComponent(
    //   knob: CircleComponent(radius: 15),
    //   priority: 20,
    //   position: Vector2(
    //       gameCamera.viewport.size.x - 30, gameCamera.viewport.size.y - 30),
    //   knobRadius: 15,
    //   background:
    //       CircleComponent(radius: 38, paint: Paint()..color = Colors.blue),
    //   // margin: const EdgeInsets.only(right: 30, bottom: 30),
    // );

    player = Player(CharacterType.rogue,
        ancestor: this, initPosition: Vector2.zero());
    enemyManagement = EnemyManagement(this);
    hud = GameHud(this);
    backgroundComponent = BackgroundComponent(this, GameLevel.forest);

    gameCamera.viewport.addAll([
      hud,
      //  moveJoystick!, aimJoystick!
    ]);
    super.add(gameCamera);
    // gameCamera.viewfinder.anchor = Anchor.center;
    add(player);
    add(enemyManagement);
    add(backgroundComponent);

    player.mounted.whenComplete(() => gameCamera.viewfinder
        .add(CustomFollowBehavior(player, gameCamera.viewfinder)));

    gameCamera.viewfinder.zoom = 10;

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

  @override
  void onTapDown(TapDownEvent event) {
    if (Platform.isWindows &&
        !discernJoystate(event.pointerId, event.asInfo(game))) {
      player.gestureEventStart(InputType.tapClick, event.asInfo(game));
    }
    super.onTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    endIdState(event.pointerId);
    player.gestureEventEnd(InputType.tapClick, event.asInfo(game));
    super.onTapUp(event);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    player.handleKeyboardInputs(event);

    if (keysPressed.contains(LogicalKeyboardKey.keyE)) {
      add(Ball(generateRandomGamePositionUsingViewport(true, this)));
    }

    if (keysPressed.contains(LogicalKeyboardKey.tab)) {
      player.swapWeapon();
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyP) ||
        keysPressed.contains(LogicalKeyboardKey.escape)) {
      game.overlays.add('PauseMenu');
      game.pauseEngine();
    }

    return super.onKeyEvent(event, keysPressed);
  }
}
