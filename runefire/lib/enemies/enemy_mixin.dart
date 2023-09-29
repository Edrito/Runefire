import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/enviroment_interactables/proximity_item.dart';
import 'package:runefire/main.dart';

import '../resources/enums.dart';

enum AimPattern {
  player,
  closestEnemyToPlayer,
  randomEntity,
  randomEnemy,
  target
}

mixin DropItemFunctionality on HealthFunctionality {
  ///If an [rng.double] is smaller than the respective key then experienceType is dropped

  abstract Map<ExperienceAmount, double> experienceRate;

  Map<ExpendableType, double> expendableRate = {
    ExpendableType.experienceAttractRune: 0,
    ExpendableType.fearEnemiesRunes: 0,
    ExpendableType.teleportRune: 0,
    ExpendableType.stunRune: 0,
    ExpendableType.healingRune: 0,
  };

  //Random value between the two ints is chosen
  final (int, int) experiencePerDrop = (1, 1);

  List<Component> calculateExperienceDrop() {
    ExperienceAmount? experienceAmount;

    List<ExperienceItem> experienceAmounts = [];

    final amountCalculated =
        rng.nextInt((experiencePerDrop.$2 - experiencePerDrop.$1) + 1) +
            experiencePerDrop.$1;
    final spread = amountCalculated / 5;

    for (var i = 0; i < amountCalculated; i++) {
      double chance = rng.nextDouble();

      final entryList = experienceRate.entries.toList();
      entryList.sort((a, b) => a.value.compareTo(b.value));

      for (var element in entryList) {
        if (element.value > chance) {
          experienceAmount = element.key;
          break;
        }
      }
      if (experienceAmount == null) continue;

      experienceAmounts.add(ExperienceItem(
          experienceAmount: experienceAmount,
          originPosition: body.position +
              ((Vector2.random() * spread) - Vector2.all(spread / 2))));
    }
    return experienceAmounts;
  }

  Component? calculateExpendableDrop() {
    double chance = rng.nextDouble();
    final entryList = expendableRate.entries.toList();
    entryList.sort((a, b) => rng.nextInt(2));
    entryList.sort((a, b) => a.value.compareTo(b.value));
    ExpendableType? expendableType;
    for (var element in entryList) {
      if (element.value > chance) {
        expendableType = element.key;
        break;
      }
    }

    if (expendableType != null) {
      return expendableType.buildInteractable(
          initialPosition:
              body.position + ((Vector2.random() * 1) - Vector2.all(1 / 2)),
          gameEnviroment: gameEnviroment);
    }
    return null;
  }

  @override
  bool deadStatus(DamageInstance instance) {
    gameEnviroment.physicsComponent.addAll(calculateExperienceDrop());
    calculateExpendableDrop()?.addToParent(gameEnviroment.physicsComponent);

    return super.deadStatus(instance);
  }
}

mixin AimControlFunctionality on AimFunctionality {
  abstract AimPattern aimPattern;
  late final Function updateFunction;

  Body? target;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    switch (aimPattern) {
      case AimPattern.player:
        updateFunction = () {
          inputAimAngles[InputType.ai] =
              (gameEnviroment.player!.center - body.position).normalized();
        };

        break;
      case AimPattern.closestEnemyToPlayer:
        updateFunction = () {
          inputAimAngles[InputType.ai] =
              ((gameEnviroment.player!.closestEnemy?.center ?? Vector2.zero()) -
                      body.position)
                  .normalized();
        };

        break;
      case AimPattern.target:
        updateFunction = () {
          inputAimAngles[InputType.ai] = ((target?.worldCenter ??
                      gameEnviroment.player!.closestEnemy?.center ??
                      Vector2.zero()) -
                  body.position)
              .normalized();
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

mixin DumbFollowAI on Enemy, MovementFunctionality {
  double targetUpdateFrequency = .3;

  void _dumbFollowTargetTick() {
    final newPosition = (gameEnviroment.player!.center - body.position);
    moveVelocities[InputType.ai] = newPosition.normalized();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
    super.onRemove();
  }
}

mixin DumbShoot on AttackFunctionality {
  double shootInterval = 2;

  void onTick() {
    if (entityInputsAimAngle.isZero()) return;
    startAttacking();
    setEntityStatus(EntityStatus.attack);
    endAttacking();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(onTick, entityId, shootInterval);
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(onTick, entityId, shootInterval);
    super.onRemove();
  }
}

mixin DumbFollowRangeAI on MovementFunctionality {
  double targetUpdateFrequency = .2;
  double zoningDistance = 6;

  void _dumbFollowRangeTargetTick() {
    final newPosition = (gameEnviroment.player!.center - body.position) -
        ((gameEnviroment.player!.center - body.position).normalized() *
            zoningDistance);

    final dis = center.distanceTo(gameEnviroment.player!.center);

    if (dis < zoningDistance * 1.1 && dis > zoningDistance * .9) {
      moveVelocities[InputType.ai] = Vector2.zero();
      return;
    }

    moveVelocities[InputType.ai] = newPosition.normalized();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
        _dumbFollowRangeTargetTick, entityId, targetUpdateFrequency);
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
        _dumbFollowRangeTargetTick, entityId, targetUpdateFrequency);
    super.onRemove();
  }
}

mixin DumbFollowScaredAI on MovementFunctionality, HealthFunctionality {
  double targetUpdateFrequency = .3;
  bool inverse = false;

  void _dumbFollowTargetTick() {
    final newPosition = (gameEnviroment.player!.center - body.position);

    moveVelocities[InputType.ai] =
        newPosition.normalized() * (inverse ? -1 : 1);
  }

  TimerComponent? inverseTimer;

  @override
  bool takeDamage(String id, DamageInstance damage,
      [bool applyStatusEffect = true]) {
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
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
    super.onRemove();
  }
}

mixin HopFollowAI on MovementFunctionality, JumpFunctionality {
  double targetUpdateFrequency = 1.5;

  void _dumbFollowTargetTick() {
    final newPosition = (gameEnviroment.player!.center - body.position);
    moveVelocities[InputType.ai] = newPosition.normalized();
    setEntityStatus(EntityStatus.jump);
  }

  @override
  void moveCharacter() {
    if (!isJumping) {
      moveVelocities.clear();
    }
    super.moveCharacter();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
    super.onRemove();
  }
}

mixin FollowThenSuicideAI on MovementFunctionality {
  double targetUpdateFrequency = .3;
  double distanceThreshold = 2;

  void _dumbFollowTargetTick() async {
    if (isDead) {
      eventManagement.removeAiTimer(
          _dumbFollowTargetTick, entityId, targetUpdateFrequency);
      return;
    }
    final newPosition = (gameEnviroment.player!.center - body.position);
    moveVelocities[InputType.ai] = newPosition.normalized();
    if (center.distanceTo(gameEnviroment.player!.center) < distanceThreshold) {
      await setEntityStatus(EntityStatus.dead,
          instance: DamageInstance(
              damageMap: {},
              source: this,
              victim: this as HealthFunctionality,
              sourceAttack: this));
    }
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    eventManagement.addAiTimer(
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
  }

  @override
  void onRemove() {
    eventManagement.removeAiTimer(
        _dumbFollowTargetTick, entityId, targetUpdateFrequency);
    super.onRemove();
  }
}
