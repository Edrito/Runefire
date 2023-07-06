import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/experience.dart';
import 'package:game_app/main.dart';

import '../resources/enums.dart';

enum AimPattern { player }

mixin DropExperienceFunctionality on HealthFunctionality {
  ///Large - Medium
  abstract (double, double) xpRate;

  @override
  void deadStatus() {
    late ExperienceAmount experienceAmount;

    double chance = Random().nextDouble();

    if (chance < xpRate.$1) {
      experienceAmount = ExperienceAmount.large;
    } else if (chance < xpRate.$2) {
      experienceAmount = ExperienceAmount.medium;
    } else {
      experienceAmount = ExperienceAmount.small;
    }

    gameEnv.add(ExperienceItem(experienceAmount, body.position));
    super.deadStatus();
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
              (gameEnv.player.center - body.position).normalized();
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
    final newPosition = (gameEnv.player.center - body.position);
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

mixin AimAtPlayerFunctionality on AimFunctionality {
  @override
  void update(double dt) {
    inputAimAngles[InputType.ai] =
        (currentGameEnviroment!.player.center - center).normalized();
    super.update(dt);
  }
}

mixin DumbShoot on AttackFunctionality {
  TimerComponent? shooter;
  double interval = 2;
  @override
  Future<void> onLoad() {
    shooter = TimerComponent(
        period: interval,
        onTick: () {
          startAttacking();
          endAttacking();
        },
        repeat: true)
      ..addToParent(this);
    return super.onLoad();
  }
}

mixin DumbFollowRangeAI on MovementFunctionality {
  TimerComponent? targetUpdater;
  double targetUpdateFrequency = .1;
  double zoningDistance = 10;

  void _dumbFollowRangeTargetTick() {
    final newPosition = (gameEnv.player.center - body.position) -
        ((gameEnv.player.center - body.position).normalized() * zoningDistance);

    final dis = center.distanceTo(gameEnv.player.center);

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
    final newPosition = (gameEnv.player.center - body.position);

    moveVelocities[InputType.ai] =
        newPosition.normalized() * (inverse ? -1 : 1);
  }

  TimerComponent? inverseTimer;

  @override
  bool takeDamage(String id, List<DamageInstance> damage) {
    inverse = true;
    targetUpdater?.onTick();
    if (inverseTimer == null) {
      inverseTimer ??= TimerComponent(
        period: 3,
        onTick: () {
          inverse = false;
          inverseTimer = null;
        },
      );
      add(inverseTimer!);
    } else {
      inverseTimer?.timer.reset();
    }

    return super.takeDamage(id, damage);
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
