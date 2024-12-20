import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/entities/input_priorities.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/enviroment_interactables/proximity_item.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/resources/enums.dart';

enum AimPattern {
  player,
  closestEnemyToPlayer,
  mouse,
  randomEntity,
  randomEnemy,
  target,
  enemy
}

mixin DropItemFunctionality on HealthFunctionality {
  ///If an [rng.double] is smaller than the respective key then experienceType is dropped

  abstract Map<ExperienceAmount, double> experienceRate;

  Map<ExpendableType, double> expendableRate = {
    ...ExpendableType.values
        .where((element) => element != ExpendableType.weapon)
        .toList()
        .asMap()
        .map(
          (key, value) => MapEntry(value, 0.005),
        ),
  };

  //Random value between the two ints is chosen
  final (int, int) experiencePerDrop = (1, 1);

  List<Component> _calculateExperienceDrop() {
    ExperienceAmount? experienceAmount;

    final experienceAmounts = <ExperienceItem>[];

    final amountCalculated =
        rng.nextInt((experiencePerDrop.$2 - experiencePerDrop.$1) + 1) +
            experiencePerDrop.$1;
    final spread = amountCalculated / 5;

    for (var i = 0; i < amountCalculated; i++) {
      final chance = rng.nextDouble();

      final entryList = experienceRate.entries.toList();
      entryList.sort((a, b) => a.value.compareTo(b.value));

      for (final element in entryList) {
        if (element.value > chance) {
          experienceAmount = element.key;
          break;
        }
      }
      if (experienceAmount == null) {
        continue;
      }

      experienceAmounts.add(
        ExperienceItem(
          experienceAmount: experienceAmount,
          originPosition: body.position +
              ((Vector2.random() * spread) - Vector2.all(spread / 2)),
        ),
      );
    }
    return experienceAmounts;
  }

  Component? _calculateExpendableDrop() {
    final chance = rng.nextDouble();
    final entryList = expendableRate.entries.toList();
    entryList.sort((a, b) => rng.nextInt(2));
    entryList.sort((a, b) => a.value.compareTo(b.value));
    ExpendableType? expendableType;
    for (final element in entryList) {
      if (element.value > chance) {
        expendableType = element.key;
        break;
      }
    }

    if (expendableType != null) {
      return expendableType.buildInteractable(
        initialPosition:
            body.position + ((Vector2.random() * 1) - Vector2.all(1 / 2)),
        gameEnviroment: gameEnviroment,
      );
    }
    return null;
  }

  bool? _calculateDeathDrops(DamageInstance instance) {
    if (!instance.source.isPlayer) {
      return false;
    }
    final temp = _calculateExperienceDrop();
    gameEnviroment.addPhysicsComponent(temp);
    final tempTwo = _calculateExpendableDrop();
    if (tempTwo != null) {
      gameEnviroment.addPhysicsComponent([tempTwo]);
    }
    return false;
  }

  @override
  Future<void> onLoad() {
    onPermanentDeath.add(_calculateDeathDrops);
    return super.onLoad();
  }
}

mixin AimControlFunctionality on AimFunctionality {
  abstract AimPattern aimPattern;
  late final Function() updateFunction;

  Body? target;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    switch (aimPattern) {
      case AimPattern.player:
        updateFunction = () {
          final direction =
              (gameEnviroment.player!.center - body.position).normalized();

          addAimAngle(direction, aiInputPriority);
        };

        break;
      case AimPattern.closestEnemyToPlayer:
        updateFunction = () {
          final direction =
              ((gameEnviroment.player!.closestEnemy?.center ?? Vector2.zero()) -
                      body.position)
                  .normalized();
          addAimAngle(direction, aiInputPriority);
        };

        break;
      case AimPattern.target:
        updateFunction = () {
          final direction = ((target?.worldCenter ??
                      gameEnviroment.player!.closestEnemy?.center ??
                      Vector2.zero()) -
                  body.position)
              .normalized();
          addAimAngle(direction, aiInputPriority);
        };

        break;
      default:
    }
  }

  @override
  void update(double dt) {
    updateFunction.call();
    aimHandJoint(false);
    super.update(dt);
  }
}

mixin SimpleFollowAI on MovementFunctionality {
  double targetUpdateFrequency = .25;
  AimPattern aimPattern = AimPattern.player;

  Future<void> _dumbFollowTargetTick() async {
    await loaded;

    Vector2 newPosition;
    switch (aimPattern) {
      case AimPattern.player:
        newPosition = gameEnviroment.player!.center - body.position;
        break;
      case AimPattern.enemy:
        final closeEnemy = gameEnviroment.player!.closestEnemy;
        if (closeEnemy == null) {
          newPosition = gameEnviroment.player!.center - body.position;
        } else {
          newPosition = closeEnemy.center - body.position;
        }
      case AimPattern.randomEnemy:
        final enemies =
            gameEnviroment.activeEntites.whereType<Enemy>().toList();
        if (enemies.isEmpty) {
          newPosition = gameEnviroment.player!.center - body.position;
        } else {
          newPosition = enemies.random().center - body.position;
        }
      case AimPattern.mouse:
        newPosition = (gameEnviroment.player!.aimPosition ?? Vector2.zero()) +
            gameEnviroment.player!.center -
            body.position;

        break;

      default:
        newPosition = gameEnviroment.player!.center - body.position;
    }

    addMoveVelocity(newPosition, aiInputPriority);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
      (
        function: _dumbFollowTargetTick,
        id: '${entityId}SimpleFollowAI',
        time: targetUpdateFrequency,
      ),
    );
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
      id: '${entityId}SimpleFollowAI',
    );
    super.onRemove();
  }
}

mixin SimpleShoot on AttackFunctionality {
  double shootInterval = 2;

  bool attackOnAnimationFinish = false;

  Future<void> onTick() async {
    if (aimVector.isZero()) {
      return;
    }
    if (attackOnAnimationFinish) {
      await setEntityAnimation(EntityStatus.attack);
    } else {
      setEntityAnimation(EntityStatus.attack);
    }
    startPrimaryAttacking();
    endPrimaryAttacking();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
      (
        function: onTick,
        id: '${entityId}SimpleShoot',
        time: shootInterval,
      ),
    );
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
      id: '${entityId}SimpleShoot',
    );
    super.onRemove();
  }
}

mixin SimpleFollowRangeAI on MovementFunctionality {
  double targetUpdateFrequency = 1.5;
  double zoningDistance = 7;

  void _dumbFollowRangeTargetTick() {
    final newPosition = (gameEnviroment.player!.center - body.position) -
        ((gameEnviroment.player!.center - body.position).normalized() *
            zoningDistance);

    final dis = center.distanceTo(gameEnviroment.player!.center);

    if (dis < zoningDistance * 1.1 && dis > zoningDistance * .9) {
      addMoveVelocity(Vector2.zero(), aiInputPriority);
      return;
    }
    addMoveVelocity(newPosition, aiInputPriority);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
      (
        function: _dumbFollowRangeTargetTick,
        id: '${entityId}SimpleFollowRangeAI',
        time: targetUpdateFrequency,
      ),
    );
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
      id: '${entityId}SimpleFollowRangeAI',
    );
    super.onRemove();
  }
}

mixin SimpleFollowScaredAI on MovementFunctionality, HealthFunctionality {
  double targetUpdateFrequency = .3;
  bool inverse = false;

  void _dumbFollowTargetTick() {
    final newPosition = gameEnviroment.player!.center - body.position;

    addMoveVelocity(
      newPosition.normalized() * (inverse ? -1 : 1),
      aiInputPriority,
    );
  }

  TimerComponent? inverseTimer;

  @override
  bool takeDamage(
    String id,
    DamageInstance damage, [
    bool applyStatusEffect = true,
  ]) {
    inverse = true;
    _dumbFollowTargetTick();
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

    eventManagement.addAiTimer(
      (
        function: _dumbFollowTargetTick,
        id: '${entityId}SimpleFollowScaredAI',
        time: targetUpdateFrequency,
      ),
    );
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
      id: '${entityId}SimpleFollowScaredAI',
    );
    super.onRemove();
  }
}

mixin HopFollowAI on MovementFunctionality, JumpFunctionality {
  double targetUpdateFrequency = 1.5;

  void _dumbFollowTargetTick() {
    final newPosition = gameEnviroment.player!.center - body.position;
    removeMoveVelocity(absoluteOverrideInputPriority);
    addMoveVelocity(newPosition.normalized(), aiInputPriority);
    jump();
  }

  @override
  void moveCharacter() {
    if (!isJumping) {
      addMoveVelocity(Vector2.zero(), absoluteOverrideInputPriority);
    }
    super.moveCharacter();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
      (
        function: _dumbFollowTargetTick,
        id: '${entityId}hop_follow',
        time: targetUpdateFrequency,
      ),
    );
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
      id: '${entityId}hop_follow',
    );
    super.onRemove();
  }
}

mixin FollowThenSuicideAI on MovementFunctionality, HealthFunctionality {
  double targetUpdateFrequency = .3;
  double distanceThreshold = 2;

  Future<void> _dumbFollowTargetTick() async {
    if (isDead) {
      eventManagement.removeAiTimer(
        id: '${entityId}follow_then_suicide',
      );
      return;
    }
    final newPosition = gameEnviroment.player!.center - body.position;
    addMoveVelocity(newPosition.normalized(), aiInputPriority);
    if (center.distanceTo(gameEnviroment.player!.center) < distanceThreshold) {
      await die(
        DamageInstance(
          damageMap: {},
          source: this,
          victim: this,
          sourceAttack: this,
        ),
      );
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
      (
        function: _dumbFollowTargetTick,
        id: '${entityId}follow_then_suicide',
        time: targetUpdateFrequency,
      ),
    );
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
      id: '${entityId}follow_then_suicide',
    );
    super.onRemove();
  }
}
