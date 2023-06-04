import 'dart:async';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/input.dart';
import 'package:game_app/main.dart';
import '../functions/custom_joystick.dart';
import 'buttons.dart';
import '/resources/routes.dart' as routes;

class MainMenu extends PositionComponent
    with TapCallbacks, HasGameRef<GameRouter> {
  CustomJoystickComponent? aimJoystick;
  CustomJoystickComponent? moveJoystick;

  // @override
  // FutureOr<void> add(Component component) {
  //   return gameWorld.add(component);
  // }

  @override
  bool containsLocalPoint(Vector2 point) {
    return startButtonComponent.button?.containsLocalPoint(point) ?? false;
  }

  @override
  void onGameResize(Vector2 size) {
    moveJoystick?.position = Vector2(50, size.y - 50);
    aimJoystick?.position = Vector2(size.x - 50, size.y - 50);
    super.onGameResize(size);
  }

  late ButtonComponent startButtonComponent;

  @override
  Future<void> onLoad() async {
    startButtonComponent = ButtonComponent(
      button: StartButton(false),
      buttonDown: StartButton(true),
      anchor: Anchor.center,
      onReleased: () {
        game.router.pushNamed(routes.gameplay);
      },
    );

    add(startButtonComponent);
    return super.onLoad();
  }

  @override
  void onLongTapDown(TapDownEvent event) {
    if (startButtonComponent.button!.containsLocalPoint(event.localPosition)) {
      startButtonComponent.onLongTapDown(event);
    }
    super.onLongTapDown(event);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (startButtonComponent.button!.containsLocalPoint(event.localPosition)) {
      startButtonComponent.onTapUp(event);
    }
    super.onTapUp(event);
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    {
      startButtonComponent.onTapCancel(event);
      super.onTapCancel(event);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    if (startButtonComponent.button!.containsLocalPoint(event.localPosition)) {
      startButtonComponent.onTapDown(event);
    }
    super.onTapDown(event);
  }
}
