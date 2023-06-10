import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';

import '../resources/enums.dart';

enum MovementPattern { dumbFollow, dumbFollowRange }

enum AimPattern { player }

mixin AimControlFunctionality on AimFunctionality {
  abstract AimPattern aimPattern;
  late final Function updateFunction;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    switch (aimPattern) {
      case AimPattern.player:
        updateFunction = () {
          inputAimAngles[InputType.ai] =
              (ancestor.player.center - body.position).normalized();
        };

        break;
      default:
    }
  }

  @override
  void update(double dt) {
    updateFunction();
    super.update(dt);
  }
}

mixin MovementControlFunctionality on MovementFunctionality {
  abstract MovementPattern movementPattern;

  TimerComponent? targetUpdater;
  double targetUpdateFrequency = .3;
  double zoningDistance = 60;
  // late CircleComponent one;
  // late CircleComponent two;
  late CircleComponent three;
  late CircleComponent four;
  // late CircleComponent five;

  void _dumbFollowRangeTargetTick() {
    // three.position = (ancestor.player.center - body.position) -
    //     ((ancestor.player.center - body.position).normalized() *
    //         zoningDistance);

    // five.position = (body.position - ancestor.player.center);
    final newPosition = (ancestor.player.center - body.position) -
        ((ancestor.player.center - body.position).normalized() *
            zoningDistance);
    // four.position = (body.position - ancestor.player.center);
    // three.position = center;
    final dis = center.distanceTo(ancestor.player.center);

    if (dis < zoningDistance * 1.1 && dis > zoningDistance * .9) {
      moveVelocities[InputType.ai] = Vector2.zero();
      return;
    }

    moveVelocities[InputType.ai] = newPosition.normalized();
  }

  void _dumbFollowTargetTick() {
    // three.position = (ancestor.player.center - body.position) -
    //     ((ancestor.player.center - body.position).normalized() *
    //         zoningDistance);

    // five.position = (body.position - ancestor.player.center);
    final newPosition = (ancestor.player.center - body.position);
    // four.position = (body.position - ancestor.player.center);
    // three.position = center;

    moveVelocities[InputType.ai] = newPosition.normalized();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // one = CircleComponent(
    //     radius: .5, paint: Paint()..color = Colors.red, anchor: Anchor.center);
    // two = CircleComponent(
    //     radius: .5, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    three = CircleComponent(
        radius: .5,
        paint: Paint()..color = Colors.white,
        anchor: Anchor.center);
    four = CircleComponent(
        radius: .5,
        paint: Paint()..color = Colors.green,
        anchor: Anchor.center);
    // five = CircleComponent(
    //     radius: .5,
    //     paint: Paint()..color = Colors.yellow,
    //     anchor: Anchor.center);

    late final Function tick;
    switch (movementPattern) {
      case MovementPattern.dumbFollowRange:
        tick = _dumbFollowRangeTargetTick;
        break;
      case MovementPattern.dumbFollow:
        tick = _dumbFollowTargetTick;
        break;
      default:
    }

    targetUpdater = TimerComponent(
      period: targetUpdateFrequency,
      repeat: true,
      onTick: () => tick(),
    );

    add(targetUpdater!);
  }
}
