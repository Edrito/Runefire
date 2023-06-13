import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/experience.dart';

import '../resources/enums.dart';

enum AimPattern { player }

mixin DropExperienceFunctionality on HealthFunctionality {
  ///Large - Medium
  abstract (double, double) xpRate;

  @override
  Future<void> onDeath() {
    late ExperienceAmount experienceAmount;

    double chance = Random().nextDouble();

    if (chance < xpRate.$1) {
      experienceAmount = ExperienceAmount.large;
    } else if (chance < xpRate.$2) {
      experienceAmount = ExperienceAmount.medium;
    } else {
      experienceAmount = ExperienceAmount.small;
    }

    ancestor.add(ExperienceItem(experienceAmount, body.position));
    return super.onDeath();
  }
}

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

mixin DumbFollowAI on MovementFunctionality {
  TimerComponent? targetUpdater;
  double targetUpdateFrequency = .3;

  void _dumbFollowTargetTick() {
    final newPosition = (ancestor.player.center - body.position);
    moveVelocities[InputType.ai] = newPosition.normalized();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    targetUpdater = TimerComponent(
      period: targetUpdateFrequency,
      repeat: true,
      onTick: _dumbFollowTargetTick,
    );
    add(targetUpdater!);
  }
}

mixin DumbFollowRangeAI on MovementFunctionality {
  TimerComponent? targetUpdater;
  double targetUpdateFrequency = .3;
  double zoningDistance = 60;

  void _dumbFollowRangeTargetTick() {
    final newPosition = (ancestor.player.center - body.position) -
        ((ancestor.player.center - body.position).normalized() *
            zoningDistance);

    final dis = center.distanceTo(ancestor.player.center);

    if (dis < zoningDistance * 1.1 && dis > zoningDistance * .9) {
      moveVelocities[InputType.ai] = Vector2.zero();
      return;
    }

    moveVelocities[InputType.ai] = newPosition.normalized();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    targetUpdater = TimerComponent(
      period: targetUpdateFrequency,
      repeat: true,
      onTick: _dumbFollowRangeTargetTick,
    );

    add(targetUpdater!);
  }
}

mixin DumbFollowScaredAI on MovementFunctionality, HealthFunctionality {
  TimerComponent? targetUpdater;
  double targetUpdateFrequency = .3;
  bool inverse = false;

  void _dumbFollowTargetTick() {
    final newPosition = (ancestor.player.center - body.position);

    moveVelocities[InputType.ai] =
        newPosition.normalized() * (inverse ? -1 : 1);
  }

  TimerComponent? inverseTimer;

  @override
  void processDamage(String id, double damage) {
    inverse = true;
    targetUpdater?.onTick();
    if (inverseTimer == null) {
      speedIncreasePercent += 1;
      inverseTimer ??= TimerComponent(
        period: 3,
        onTick: () {
          inverse = false;
          inverseTimer = null;
          speedIncreasePercent -= 1;
        },
      );
      add(inverseTimer!);
    } else {
      inverseTimer?.timer.reset();
    }

    super.processDamage(id, damage);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    targetUpdater = TimerComponent(
      period: targetUpdateFrequency,
      repeat: true,
      onTick: _dumbFollowTargetTick,
    );

    add(targetUpdater!);
  }
}
