import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';

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
  // static const double maxDistance = 8;
  static const double distanceStart = 0;
  static const double increase = 2.5;
  Vector2 shiftCameraPositionBecauseOfMouse() {
    final position = player.aimPosition;
    final zoom = camera.viewfinder.zoom;
    final distanceToCorner = hypotenuse(
      camera.viewport.size.x / zoom,
      camera.viewport.size.y / zoom,
    );

    final cutoff = (distanceToCorner / 2);

    distance = position?.distanceTo(Vector2.zero()) ?? 0;
    distanceIncrease = (distance - distanceStart) / cutoff;
    distanceIncrease = distanceIncrease.clamp(0, 1);
    distanceIncrease = Curves.easeIn.transform(distanceIncrease);
    // distanceIncrease = distanceIncrease.clamp(0, 1);a
    if (position != null) {
      return (position.normalized() * increase * distanceIncrease);
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

  late final InputManager inputManagerInstance = InputManager();

  void followTarget() async {
    target.setFrom(player.center);
    if (inputManagerInstance.externalInputType ==
        ExternalInputType.mouseKeyboard) {
      target += shiftCameraPositionBecauseOfMouse();
    }

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
