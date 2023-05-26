import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:game_app/game/player.dart';
import '../functions/custom_joystick.dart';
import 'background.dart';
import 'characters.dart';
import 'hud.dart';

enum GameLevel { space, forest }

class GameplayGame extends Forge2DGame
    with
        KeyboardEvents,
        TapDetector,
        MouseMovementDetector,
        MultiTouchDragDetector {
  late final Player player;
  late final GameHud hud;
  late final BackgroundComponent backgroundComponent;

  Map<LogicalKeyboardKey, double> keyDurationPress = {};

  late CustomJoystickComponent joystick;
  @override
  Future<void> onLoad() async {
    joystick = CustomJoystickComponent(
      knob: CircleComponent(radius: 20),
      priority: 20,
      size: 200,
      knobRadius: 15,
      background:
          CircleComponent(radius: 40, paint: Paint()..color = Colors.blue),
      margin: const EdgeInsets.only(left: 40, bottom: 40),
    );

    player = Player(CharacterType.wizard);
    backgroundComponent = BackgroundComponent(player, GameLevel.forest);
    hud = GameHud(player);

    add(backgroundComponent);
    add(player);

    world.setGravity(Vector2.all(0));
    add(hud);
    hud.add(joystick);

    player.mounted.whenComplete(() => camera.followBodyComponent(player));

    return super.onLoad();
  }

  @override
  void update(double dt) {
    keyDurationPress.updateAll((key, value) => value += dt);
    super.update(dt);
  }

  @override
  KeyEventResult onKeyEvent(
    RawKeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    keyDurationPress.removeWhere((key, value) => !keysPressed.contains(key));
    for (LogicalKeyboardKey element in keysPressed) {
      keyDurationPress[element] ??= 0.0;
    }
    player.keyDurationPress = keyDurationPress;

    if (event.logicalKey == LogicalKeyboardKey.keyE && !world.isLocked) {
      add(Ball(Vector2.random() * 50));
    }

    return KeyEventResult.handled;
  }

  bool moveJoystickClicked = false;

  @override
  void onDragUpdate(int pointerId, DragUpdateInfo info) {
    player.onDrag(pointerId, info);
    if (moveJoystickClicked) {
      joystick.onDragUpdate(info);
    }
    super.onDragUpdate(pointerId, info);
  }

  void endJoystickControl() {
    if (moveJoystickClicked) {
      moveJoystickClicked = false;
      joystick.onDragCancel();
      player.isMoveJoystickControlled = false;
    }
  }

  @override
  void onDragEnd(int pointerId, DragEndInfo info) {
    player.onTapUp();
    endJoystickControl();
    super.onDragEnd(pointerId, info);
  }

  @override
  void onDragCancel(int pointerId) {
    player.onTapUp();
    endJoystickControl();

    super.onDragCancel(pointerId);
  }

  void doStartJoystick(Vector2 globalPos) {
    moveJoystickClicked = joystick.knob?.containsPoint(globalPos) ?? false;
    if (moveJoystickClicked) {
      player.isMoveJoystickControlled = moveJoystickClicked;
    }
  }

  @override
  void onDragStart(int pointerId, DragStartInfo info) {
    doStartJoystick(info.eventPosition.global);
    super.onDragStart(pointerId, info);
  }

  @override
  void onTapDown(TapDownInfo info) {
    doStartJoystick(info.eventPosition.global);
    player.onTapDown(info);

    super.onTapDown(info);
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    player.onMouseMove(info);
    super.onMouseMove(info);
  }

  @override
  void onTapUp(TapUpInfo info) {
    player.onTapUp();
    endJoystickControl();
    super.onTapUp(info);
  }
}
