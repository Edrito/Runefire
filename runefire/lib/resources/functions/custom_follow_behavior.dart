import 'dart:math';

import 'package:flame/components.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/resources/enums.dart';

class CustomFollowBehavior extends Component {
  CustomFollowBehavior(this.player, this.camera, this.gameEnviroment) {
    priority = 2000;
  }
  double timerDuration = 2;
  TimerComponent? disableTimer;
  TimerComponent? enableTimer;
  GameEnviroment gameEnviroment;
  void disable() {
    isDisabled = true;
    disableTimer = TimerComponent(
      period: timerDuration,
      removeOnFinish: true,
    )..addToParent(this);
  }

  void enable() {
    isDisabled = false;
    disableTimer = null;
    enableTimer = TimerComponent(
      period: timerDuration,
      removeOnFinish: true,
      onTick: () {
        enableTimer = null;
      },
    )..addToParent(this);
  }

  double distance = 0;
  double distanceIncrease = 0;
  Vector2 shiftCameraPositionBecauseOfMouse() {
    final position = player.inputAimPositions[InputType.mouseMove];
    distance = position?.distanceTo(Vector2.zero()) ?? 0;
    distanceIncrease = (distance - 4) / 25;
    distanceIncrease = distanceIncrease.clamp(0, 1);
    distanceIncrease = pow(distanceIncrease, 2).toDouble();
    distanceIncrease = distanceIncrease.clamp(0, 1);
    if (position != null) {
      return (position * distanceIncrease);
    }
    return Vector2.zero();
  }

  double getPercentTimerComplete(TimerComponent timer) {
    return timer.timer.current / timerDuration;
  }

  bool isDisabled = false;
  Player player;
  CameraComponent camera;
  Vector2 target = Vector2.zero();
  double interpolationAmount = 1.0;
  String formatedNumber = "";

  void followTarget() async {
    target.setFrom(player.center);
    target += shiftCameraPositionBecauseOfMouse();

    interpolationAmount = 1.0;
    if (disableTimer != null) {
      interpolationAmount = 1 - getPercentTimerComplete(disableTimer!);
    } else if (enableTimer != null) {
      interpolationAmount = getPercentTimerComplete(enableTimer!);
    }

    formatedNumber = interpolationAmount.toStringAsFixed(2);
    interpolationAmount = double.parse(formatedNumber);
    if (interpolationAmount == 0 ||
        (disableTimer != null && !disableTimer!.timer.isRunning())) return;

    target = (camera.viewfinder.position +
        ((target - camera.viewfinder.position) * interpolationAmount));
    target.clamp(-Vector2(maxX, maxY), Vector2(maxX, maxY));

    camera.viewfinder.position = target;
  }

  double get maxY =>
      gameEnviroment.boundsDistanceFromCenter -
      ((camera.viewport.size.y / 2) / camera.viewfinder.zoom);
  double get maxX =>
      gameEnviroment.boundsDistanceFromCenter -
      ((camera.viewport.size.x / 2) / camera.viewfinder.zoom);

  @override
  void update(double dt) {
    if (player.isMounted) {
      followTarget();
    }
    super.update(dt);
  }
}
