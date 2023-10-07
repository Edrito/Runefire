// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import '../enemies/enemy.dart';
import '../enviroment_interactables/interactable.dart';
import '../resources/functions/vector_functions.dart';
import '../main.dart';
import '../resources/data_classes/player_data.dart';
import '../resources/enums.dart';
import '../attributes/attributes_mixin.dart';
import '../enviroment_interactables/expendables.dart';
import '../weapons/weapon_class.dart';

class Player extends Entity
    with
        // ContactCallbacks,
        StaminaFunctionality,
        HealthFunctionality,
        AimFunctionality,
        AttackFunctionality,
        AttributeFunctionality,
        AttributeFunctionsFunctionality,
        MovementFunctionality,
        JumpFunctionality,
        ExperienceFunctionality,
        ExpendableFunctionality,
        DodgeFunctionality,
        DashFunctionality,
        HealthRegenFunctionality,
        PlayerStatistics,
        PlayerStatisticsRecorder {
  Player(this.playerData, this.isDisplay,
      {required super.enviroment,
      required super.eventManagement,
      required super.initialPosition}) {
    // if (!isDisplay) {
    playerData.selectedPlayer.applyBaseCharacterStats(this);
    initAttributes(playerData.unlockedPermanentAttributes);
    // }
    onAttack.add(updateRemainingAmmo);
    onReloadComplete.add(updateRemainingAmmo);
    onReload.add(updateRemainingAmmo);

    if (isDisplay) {
      // height.setParameterPercentValue('display', .5);
      add(TimerComponent(
        period: .05,
        repeat: true,
        onTick: () {
          var temp = center.clone();
          temp = Vector2(double.parse(temp.x.toStringAsFixed(2)),
              double.parse(temp.y.toStringAsFixed(2)));
          moveVelocities[InputType.ai] = -temp.normalized();
        },
      ));
    }
  }
  final PlayerData playerData;

  final ListQueue<InteractableComponent> _interactableComponents = ListQueue();

  void addCloseInteractableComponents(InteractableComponent newComponent) {
    if (_interactableComponents.isNotEmpty) {
      _interactableComponents.first.toggleDisplay(false);
    }
    newComponent.toggleDisplay(true);
    _interactableComponents.addFirst(newComponent);
  }

  void removeCloseInteractable(InteractableComponent newComponent) {
    if (_interactableComponents.isNotEmpty) {
      newComponent.toggleDisplay(false);
      _interactableComponents.remove(newComponent);

      if (_interactableComponents.isNotEmpty) {
        _interactableComponents.first.toggleDisplay(true);
      }
    }
  }

  @override
  // TODO: implement handJointOffset
  Vector2 get handJointOffset => Vector2(0, .1);

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.playerCharacterOneIdle1;
    entityAnimations[EntityStatus.jump] =
        await spriteAnimations.playerCharacterOneJump1;
    entityAnimations[EntityStatus.dash] =
        await spriteAnimations.playerCharacterOneDash1;
    entityAnimations[EntityStatus.walk] =
        await spriteAnimations.playerCharacterOneRun1;
    entityAnimations[EntityStatus.run] =
        await spriteAnimations.playerCharacterOneRun1;
    entityAnimations[EntityStatus.dead] =
        await spriteAnimations.playerCharacterOneDead1;
    entityAnimations[EntityStatus.damage] =
        await spriteAnimations.playerCharacterOneHit1;
  }

  @override
  Future<void> swapWeapon() async {
    await super.swapWeapon();
    updateRemainingAmmo(null);
  }

  void updateRemainingAmmo(Weapon? weapon) {
    if (enviroment is GameEnviroment) {
      gameEnviroment.hud.buildRemainingAmmoText(this);
    }
  }

  bool isDisplay;
  @override
  void onRemove() {
    moveVelocities.clear();
    inputAimAngles.clear();
    inputAimPositions.clear();
    final instance = InputManager();

    instance.removeGameActionListener(GameAction.moveDown, onMoveAction);
    instance.removeGameActionListener(GameAction.moveUp, onMoveAction);
    instance.removeGameActionListener(GameAction.moveLeft, onMoveAction);
    instance.removeGameActionListener(GameAction.moveRight, onMoveAction);
    instance.removeGameActionListener(GameAction.swapWeapon, swapWeaponAction);
    instance.removeGameActionListener(GameAction.reload, reloadWeaponAction);
    instance.removeGameActionListener(GameAction.interact, interactAction);
    instance.removeGameActionListener(
        GameAction.useExpendable, expendableAction);
    instance.removeGameActionListener(GameAction.dash, dashAction);
    instance.removeGameActionListener(GameAction.jump, jumpAction);
    instance.removeGameActionListener(GameAction.primary, primaryAction);
    instance.removeGameActionListener(GameAction.secondary, secondaryAction);
    instance.keyEventList.remove(onKeyEvent);
    instance.onPointerMoveList.remove(pointerMoveAction);

    super.onRemove();
  }

  late final CircleComponent circleComponent;

  void pointerMoveAction(MovementType type, PointerMoveEvent event) {
    if (type == MovementType.mouse && isLoaded) {
      final position = (shiftCoordinatesToCenter(
              event.localPosition.toVector2(),
              enviroment.gameCamera.viewport.size) /
          enviroment.zoom);
      inputAimPositions[InputType.mouse] = position;
      buildDeltaFromMousePosition();
    }
  }

  @override
  Future<void> onLoad() async {
    final instance = InputManager();
    instance.addGameActionListener(GameAction.moveDown, onMoveAction);
    instance.addGameActionListener(GameAction.moveUp, onMoveAction);
    instance.addGameActionListener(GameAction.moveLeft, onMoveAction);
    instance.addGameActionListener(GameAction.moveRight, onMoveAction);
    instance.addGameActionListener(GameAction.swapWeapon, swapWeaponAction);
    instance.addGameActionListener(GameAction.reload, reloadWeaponAction);
    instance.addGameActionListener(GameAction.interact, interactAction);
    instance.addGameActionListener(GameAction.useExpendable, expendableAction);
    instance.addGameActionListener(GameAction.dash, dashAction);
    instance.addGameActionListener(GameAction.jump, jumpAction);
    instance.addGameActionListener(GameAction.primary, primaryAction);
    instance.addGameActionListener(GameAction.secondary, secondaryAction);
    instance.keyEventList.add(onKeyEvent);
    instance.onPointerMoveList.add(pointerMoveAction);

    initialWeapons.addAll(playerData.selectedWeapons.values);

    priority = playerPriority;

    await loadAnimationSprites();

    cloestEnemyTimer = TimerComponent(
      period: .5,
      onTick: () {
        findClosestEnemy();
      },
    );
    await super.onLoad();
  }

  late final FixtureDef xpGrabRadiusFixture;

  @override
  Body createBody() {
    late CircleShape xpGrabRadius;
    xpGrabRadius = CircleShape();
    xpGrabRadius.radius = xpSensorRadius.parameter;
    renderBody = false;

    xpGrabRadiusFixture = FixtureDef(xpGrabRadius,
        userData: {"type": FixtureType.sensor, "object": this},
        isSensor: true,
        filter: Filter()
          ..categoryBits = playerCategory
          ..maskBits = proximityCategory);

    return super.createBody()..createFixture(xpGrabRadiusFixture)
        // ..setBullet(true)
        ;
  }

  void onKeyEvent(KeyEvent event) {
    if (KeyEvent is KeyUpEvent) return;
    if (event.physicalKey == (PhysicalKeyboardKey.keyL)) {
      levelUp();
    }
  }

  @override
  void update(double dt) {
    // if (!isDisplay) {
    moveCharacter();
    // }
    aimCharacter();
    super.update(dt);
  }

  Enemy? closestEnemy;
  late TimerComponent cloestEnemyTimer;

  void findClosestEnemy() {
    double closestDistance = double.infinity;

    for (var otherBody in world.physicsWorld.bodies.where((element) =>
        element.userData is Enemy && !(element.userData as Enemy).isDead)) {
      if (otherBody.worldCenter.distanceTo(center) < closestDistance) {
        closestDistance = otherBody.worldCenter.distanceTo(center);
        closestEnemy = otherBody.userData as Enemy;
      }
    }
  }

  Vector2 tempMoveAngle = Vector2.zero();

  void onMoveAction(GameActionEvent _, List<GameAction> activeGameActions) {
    tempMoveAngle.setZero();

    if (activeGameActions.contains(GameAction.moveRight)) {
      tempMoveAngle.x += 1;
    }
    if (activeGameActions.contains(GameAction.moveLeft)) {
      tempMoveAngle.x -= 1;
    }
    if (activeGameActions.contains(GameAction.moveUp)) {
      tempMoveAngle.y -= 1;
    }
    if (activeGameActions.contains(GameAction.moveDown)) {
      tempMoveAngle.y += 1;
    }

    if (tempMoveAngle.isZero() || isDead) {
      moveVelocities.remove(InputType.general);
    } else {
      moveVelocities[InputType.general] = tempMoveAngle.normalized();
    }
  }

  void primaryAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (gameActionEvent.isDownEvent) {
      startPrimaryAttacking();
    } else {
      endPrimaryAttacking();
    }
  }

  void secondaryAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (gameActionEvent.isDownEvent) {
      startSecondaryAttacking();
    } else {
      endSecondaryAttacking();
    }
  }

  void swapWeaponAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (!gameActionEvent.isDownEvent) return;
    swapWeapon();
  }

  void reloadWeaponAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (!gameActionEvent.isDownEvent) return;
    if (currentWeapon is ReloadFunctionality) {
      final currentWeaponReload = currentWeapon as ReloadFunctionality;
      if (currentWeaponReload.isReloading ||
          currentWeaponReload.spentAttacks == 0) return;

      currentWeaponReload.reload();
    }
  }

  void jumpAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (!gameActionEvent.isDownEvent) return;
    setEntityStatus(EntityStatus.jump);
  }

  void dashAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (!gameActionEvent.isDownEvent) return;
    setEntityStatus(EntityStatus.dash);
  }

  void interactAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (!gameActionEvent.isDownEvent) return;
    if (_interactableComponents.isNotEmpty) {
      _interactableComponents.first.interact();
    }
  }

  void expendableAction(
      GameActionEvent gameActionEvent, List<GameAction> activeGameActions) {
    if (!gameActionEvent.isDownEvent) return;
    useExpendable();
  }

  int debugCount = 0;

  @override
  Filter? filter = Filter()
    ..maskBits = 0xFFFF
    ..categoryBits = playerCategory;

  @override
  EntityType entityType = EntityType.player;
}
