// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_animate/flutter_animate.dart' hide ShakeEffect;
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/entities/input_priorities.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/functions/custom.dart';
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
          addMoveVelocity(-temp.normalized(), aiInputPriority);
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
  Vector2 get handJointOffset => Vector2(0, 1);

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
    instance.gamepadEventList.remove(parseGamepadJoy);
    instance.keyEventList.remove(onKeyEvent);
    instance.onPointerMoveList.remove(pointerMoveAction);

    super.onRemove();
  }

  late final CircleComponent circleComponent;

  void pointerMoveAction(ExternalInputType type, Offset pos) {
    if (type == ExternalInputType.mouseKeyboard && isLoaded) {
      final position = (shiftCoordinatesToCenter(
                  pos.toVector2(), enviroment.gameCamera.viewport.size) /
              enviroment.zoom) -
          entityOffsetFromCameraCenter;

      addAimPosition(position, userInputPriority);
      addAimAngle((position - handJointOffset).normalized(), userInputPriority);
    }
  }

  @override
  void applyDamage(DamageInstance damage) {
    gameEnviroment.gameCamera.viewport.add(ShakeEffect(
        EffectController(duration: .1),
        intensity: (damage.isCrit ? 8 : 2)));

    InputManager().applyVibration(
        damage.damage == double.infinity ? 1 : .3, damage.isCrit ? .8 : .4);

    super.applyDamage(damage);
  }

  void parseGamepadJoy(GamepadEvent event) {
    GamepadButtons buttonToCheck = event.button;
    bool swapJoys = game.systemDataComponent.dataObject.flipJoystickControl;

    if (swapJoys) {
      if (buttonToCheck == GamepadButtons.leftJoy) {
        buttonToCheck = GamepadButtons.rightJoy;
      } else if (buttonToCheck == GamepadButtons.rightJoy) {
        buttonToCheck = GamepadButtons.leftJoy;
      }
    }

    switch (event.button) {
      case GamepadButtons.leftJoy:
        if (event.pressState == PressState.released) {
          removeMoveVelocity(gamepadUserInputPriority);
        } else {
          final eventXY = event.xyValue.toVector2();
          final normalized = eventXY.normalized();
          addMoveVelocity(normalized * eventXY.length.clamp(0, 1),
              gamepadUserInputPriority, false);
        }

        break;
      case GamepadButtons.rightJoy:
        if (event.pressState == PressState.released) {
          // removeAimAngle(gamepadUserInputPriority);
          // removeAimPosition(gamepadUserInputPriority);
        } else {
          addAimAngle(event.xyValue.toVector2(), userInputPriority);
          print(event.xyValue);
          final newPos = InputManager().getGamepadCursorPosition?.toVector2();
          if (newPos != null) {
            final position = (shiftCoordinatesToCenter(
                        newPos, enviroment.gameCamera.viewport.size) /
                    enviroment.zoom) -
                entityOffsetFromCameraCenter;

            addAimPosition(position, userInputPriority);
          }
        }

        break;
      default:
    }
  }

  Vector2 previousGamepadAimPosition = Vector2.zero();

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
    instance.gamepadEventList.add(parseGamepadJoy);
    instance.keyEventList.add(onKeyEvent);
    instance.onPointerMoveList.add(pointerMoveAction);

    initialWeapons.addAll(playerData.selectedWeapons.values);

    priority = playerPriority;

    await loadAnimationSprites();

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
    if (event is KeyUpEvent) return;
    if (event.physicalKey == (PhysicalKeyboardKey.keyL)) {
      levelUp();
    }
  }

  @override
  void update(double dt) {
    moveCharacter();
    applyAimAssist();
    aimHandJoint();
    aimMouseJoint();
    if (closeEnemyCheckTimer > closeEnemyCheckInterval) {
      findClosestEnemy();
      closeEnemyCheckTimer = 0;
    } else {
      closeEnemyCheckTimer += dt;
    }

    super.update(dt);
  }

  double closeEnemyCheckInterval = .1;
  double closeEnemyCheckTimer = 0;

  Enemy? closestEnemy;
  Enemy? closestEnemyToMouse;
  Enemy? aimAssistEnemy;

  void applyAimAssist() {
    ExternalInputType inputType = InputManager().externalInputType;
    AimAssistStrength aimAssistStrength =
        game.systemDataComponent.dataObject.aimAssistStrength;
    if (aimAssistStrength == AimAssistStrength.none) return;

    switch (inputType) {
      case ExternalInputType.mouseKeyboard:
        final aimPos = getAimPosition(userInputPriority);
        var clostestEnemyToMousePos = closestEnemyToMouse?.center;
        if (aimPos != null && clostestEnemyToMousePos != null) {
          clostestEnemyToMousePos -= enviroment.gameCamera.viewfinder.position +
              entityOffsetFromCameraCenter +
              handJointOffset;
          if (aimPos.distanceTo(clostestEnemyToMousePos) <
              aimAssistStrength.threshold) {
            addAimAngle(
                clostestEnemyToMousePos.normalized(), aimAssistInputPriority);

            // addAimPosition(clostestEnemyToMousePos, aimAssistInputPriority);
          } else {
            // removeAimPosition(aimAssistInputPriority);
            removeAimAngle(aimAssistInputPriority);
          }
        }

        break;
      default:
    }
  }

  void findClosestEnemy() {
    double closestDistance = double.infinity;
    double closestDistanceMouse = double.infinity;

    final enemyList = world.physicsWorld.bodies.where((element) =>
        element.userData is Enemy && !(element.userData as Enemy).isDead);
    var aimPosition = getAimPosition(userInputPriority);

    if (aimPosition != null) {
      aimPosition += enviroment.gameCamera.viewfinder.position;
    }

    for (var otherBody in enemyList) {
      if (otherBody.worldCenter.distanceTo(center) < closestDistance) {
        closestDistance = otherBody.worldCenter.distanceTo(center);
        closestEnemy = otherBody.userData as Enemy;
      }

      if (aimPosition != null &&
          otherBody.worldCenter.distanceTo(aimPosition) <
              closestDistanceMouse) {
        closestDistanceMouse = otherBody.worldCenter.distanceTo(aimPosition);
        closestEnemyToMouse = otherBody.userData as Enemy;
      }
    }
  }

  Vector2 tempMoveAngle = Vector2.zero();

  void onMoveAction(GameActionEvent _, Set<GameAction> activeGameActions) {
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
      removeMoveVelocity(userInputPriority);
    } else {
      addMoveVelocity(tempMoveAngle, userInputPriority);
    }
  }

  void primaryAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    switch (gameActionEvent.pressState) {
      case PressState.pressed:
        startPrimaryAttacking();
        break;
      case PressState.released:
        endPrimaryAttacking();

        break;
      default:
    }
  }

  void secondaryAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    switch (gameActionEvent.pressState) {
      case PressState.pressed:
        startSecondaryAttacking();
        break;
      case PressState.released:
        endSecondaryAttacking();

        break;
      default:
    }
  }

  void swapWeaponAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    if (gameActionEvent.pressState != PressState.pressed) return;
    swapWeapon();
  }

  void reloadWeaponAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    if (gameActionEvent.pressState != PressState.pressed) return;
    if (currentWeapon is ReloadFunctionality) {
      final currentWeaponReload = currentWeapon as ReloadFunctionality;
      if (currentWeaponReload.isReloading ||
          currentWeaponReload.spentAttacks == 0) return;

      currentWeaponReload.reload();
    }
  }

  void jumpAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    if (gameActionEvent.pressState != PressState.pressed) return;
    setEntityStatus(EntityStatus.jump);
  }

  void dashAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    if (gameActionEvent.pressState != PressState.pressed) return;
    setEntityStatus(EntityStatus.dash);
  }

  void interactAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    if (gameActionEvent.pressState != PressState.pressed) return;
    if (_interactableComponents.isNotEmpty) {
      _interactableComponents.first.interact();
    }
  }

  void expendableAction(
      GameActionEvent gameActionEvent, Set<GameAction> activeGameActions) {
    if (gameActionEvent.pressState != PressState.pressed) return;
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
