import 'package:flame/components.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/entities/experience.dart';
import 'package:game_app/main.dart';

import '../resources/enums.dart';

enum AimPattern { player }

mixin DropExperienceFunctionality on HealthFunctionality {
  ///If an [rng.double] is smaller than $1 then large experience is dropped
  ///If an [rng.double] is smaller than $2 then medium experience is dropped
  abstract (double, double) xpRate;

  //Random value between the two ints is chosen
  final (int, int) amountPerDrop = (1, 1);

  @override
  void deadStatus() {
    late ExperienceAmount experienceAmount;

    final amountCalculated = amountPerDrop.$1 == amountPerDrop.$2
        ? amountPerDrop.$1
        : rng.nextInt(amountPerDrop.$2 - amountPerDrop.$1) + amountPerDrop.$1;
    final spread = amountCalculated / 5;
    for (var i = 0; i < amountCalculated; i++) {
      double chance = rng.nextDouble();

      if (chance < xpRate.$1) {
        experienceAmount = ExperienceAmount.large;
      } else if (chance < xpRate.$2) {
        experienceAmount = ExperienceAmount.medium;
      } else {
        experienceAmount = ExperienceAmount.small;
      }

      Future.delayed(rng.nextDouble().seconds).then((value) =>
          gameEnviroment.add(ExperienceItem(
              experienceAmount,
              body.position +
                  ((Vector2.random() * spread) - Vector2.all(spread / 2)))));
    }

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
              (gameEnviroment.player.center - body.position).normalized();
        };

        break;
      default:
    }
  }

  @override
  void update(double dt) {
    updateFunction();
    aimCharacter();
    super.update(dt);
  }
}

mixin DumbFollowAI on MovementFunctionality {
  TimerComponent? targetUpdater;
  double targetUpdateFrequency = .3;

  void _dumbFollowTargetTick() {
    final newPosition = (gameEnviroment.player.center - body.position);
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
  double zoningDistance = 6;

  void _dumbFollowRangeTargetTick() {
    final newPosition = (gameEnviroment.player.center - body.position) -
        ((gameEnviroment.player.center - body.position).normalized() *
            zoningDistance);

    final dis = center.distanceTo(gameEnviroment.player.center);

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
    final newPosition = (gameEnviroment.player.center - body.position);

    moveVelocities[InputType.ai] =
        newPosition.normalized() * (inverse ? -1 : 1);
  }

  TimerComponent? inverseTimer;

  @override
  bool takeDamage(String id, DamageInstance damage,
      [bool applyStatusEffect = true]) {
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

    return super.takeDamage(id, damage, applyStatusEffect);
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

mixin HopFollowAI on MovementFunctionality, JumpFunctionality {
  TimerComponent? targetUpdater;
  double targetUpdateFrequency = 1.5;

  void _dumbFollowTargetTick() {
    final newPosition = (gameEnviroment.player.center - body.position);
    moveVelocities[InputType.ai] = newPosition.normalized();
    setEntityStatus(EntityStatus.jump);
  }

  @override
  void moveCharacter() {
    if (!isJumping) return;
    super.moveCharacter();
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
