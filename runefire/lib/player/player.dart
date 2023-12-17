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
import 'package:flutter_animate/flutter_animate.dart'
    hide ShakeEffect, ScaleEffect;
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/entities/input_priorities.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/menus/overlays.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/data_classes/system_data.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';

import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/enviroment_interactables/interactable.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/data_classes/player_data.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/weapons/weapon_class.dart';

class Player extends Entity
    with
        // ContactCallbacks,
        StaminaFunctionality,
        HealthFunctionality,
        AimFunctionality,
        AttackFunctionality,
        AttributeFunctionality,
        AttributeCallbackFunctionality,
        MovementFunctionality,
        JumpFunctionality,
        ExperienceFunctionality,
        ExpendableFunctionality,
        DodgeFunctionality,
        DashFunctionality,
        HealthRegenFunctionality,
        PlayerStatistics,
        PlayerStatisticsRecorder {
  Player(
    this.playerData, {
    required this.isDisplay,
    required super.enviroment,
    required super.eventManagement,
    required super.initialPosition,
  }) {
    if (enviroment is GameEnviroment) {
      loaded.then((value) {
        updateRemainingAmmo(currentWeapon);
        gameEnviroment.hud.buildRemainingLives(this);
      });
      maxLives.addListener((parameter) {
        gameEnviroment.hud.buildRemainingLives(this);
      });
      onDeath.add((instance) {
        gameEnviroment.hud.buildRemainingLives(this);
      });

      onKillOtherEntity.add((instance) {
        for (final element in instance.damageMap.entries) {
          modifyElementalPower(
            element.key,
            (element.value.isFinite ? element.value : 100) / 20000,
          );
        }
      });
      playerData.selectedPlayer.applyBaseCharacterStats(this);
      initAttributes(playerData.unlockedPermanentAttributes);
      onSpentAttack.add(updateRemainingAmmo);
      onWeaponSwap.add((from, to) {
        updateRemainingAmmo(to);
      });
    }

    if (isDisplay) {
      add(
        TimerComponent(
          period: .05,
          repeat: true,
          onTick: () {
            var temp = center.clone();
            temp = Vector2(
              double.parse(temp.x.toStringAsFixed(2)),
              double.parse(temp.y.toStringAsFixed(2)),
            );
            addMoveVelocity(-temp.normalized(), aiInputPriority);
          },
        ),
      );
    }
  }

  List<AttributeType> attributesToGrabDebug = [];
  final PlayerData playerData;

  @override
  void levelUp() {
    endPrimaryAttacking();
    endSecondaryAttacking();
    super.levelUp();
  }

  @override
  Future<void> die(
    DamageInstance damage, [
    EndGameState endGameState = EndGameState.playerDeath,
  ]) {
    invincible.setIncrease('wingame', true);
    disableInput.setIncrease('wingame', true);
    clearWeapons();
    return super.die(damage, endGameState);
  }

  BoolParameterManager disableInput =
      BoolParameterManager(baseParameter: false);

  final ListQueue<InteractableComponent> _interactableComponents = ListQueue();

  void addCloseInteractableComponents(InteractableComponent newComponent) {
    if (_interactableComponents.isNotEmpty) {
      _interactableComponents.first.toggleDisplay(isOn: false);
    }
    newComponent.toggleDisplay();
    _interactableComponents.addFirst(newComponent);
  }

  void removeCloseInteractable(InteractableComponent newComponent) {
    if (_interactableComponents.isNotEmpty) {
      newComponent.toggleDisplay(isOn: false);
      _interactableComponents.remove(newComponent);

      if (_interactableComponents.isNotEmpty) {
        _interactableComponents.first.toggleDisplay();
      }
    }
  }

  @override
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

  void updateRemainingAmmo(Weapon? weapon) {
    if (enviroment is GameEnviroment) {
      gameEnviroment.hud.buildRemainingAmmo(this);
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
      GameAction.useExpendable,
      expendableAction,
    );
    instance.removeGameActionListener(GameAction.dash, dashAction);
    instance.removeGameActionListener(GameAction.jump, jumpAction);
    instance.removeGameActionListener(GameAction.primary, primaryAction);
    instance.removeGameActionListener(GameAction.secondary, secondaryAction);
    instance.removeGamepadEventListener(parseGamepadJoy);
    instance.removeKeyListener(onKeyEvent);
    instance.onPointerMoveList.remove(pointerMoveAction);

    super.onRemove();
  }

  late final CircleComponent circleComponent;

  void pointerMoveAction(ExternalInputType type, Offset pos) {
    if (type == ExternalInputType.mouseKeyboard && isLoaded) {
      final position = (shiftCoordinatesToCenter(
                pos.toVector2(),
                enviroment.gameCamera.viewport.size,
              ) /
              enviroment.zoom) -
          entityOffsetFromCameraCenter;

      addAimPosition(position, userInputPriority);
      addAimAngle((position - handJointOffset).normalized(), userInputPriority);
    }
  }

  @override
  void applyDamage(DamageInstance damage) {
    gameEnviroment.gameCamera.viewport.add(
      ShakeEffect(
        EffectController(duration: .1),
        intensity: (damage.isCrit ? 8 : 2),
      ),
    );

    InputManager().applyVibration(
      damage.damage == double.infinity ? 1 : .3,
      damage.isCrit ? .8 : .4,
    );

    super.applyDamage(damage);
  }

  void parseGamepadJoy(GamepadEvent event) {
    if (disableInput.parameter) {
      return;
    }
    var buttonToCheck = event.button;
    final swapJoys = game.systemDataComponent.dataObject.flipJoystickControl;

    if (swapJoys) {
      if (buttonToCheck == GamepadButtons.leftJoy) {
        buttonToCheck = GamepadButtons.rightJoy;
      } else if (buttonToCheck == GamepadButtons.rightJoy) {
        buttonToCheck = GamepadButtons.leftJoy;
      }
    }

    switch (buttonToCheck) {
      case GamepadButtons.leftJoy:
        if (event.pressState == PressState.released) {
          removeMoveVelocity(gamepadUserInputPriority);
        } else {
          final eventXY = event.xyValue.toVector2();
          final normalized = eventXY.normalized();
          addMoveVelocity(
            normalized * eventXY.length.clamp(0, 1),
            gamepadUserInputPriority,
            false,
          );
        }

        break;
      case GamepadButtons.rightJoy:
        if (event.pressState == PressState.released) {
          // removeAimAngle(gamepadUserInputPriority);
          // removeAimPosition(gamepadUserInputPriority);
        } else {
          addAimAngle(event.xyValue.toVector2(), userInputPriority);
          final newPos = InputManager().getGamepadCursorPosition?.toVector2();
          if (newPos != null) {
            final position = (shiftCoordinatesToCenter(
                      newPos,
                      enviroment.gameCamera.viewport.size,
                    ) /
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
    instance.addGamepadEventListener(parseGamepadJoy);
    instance.addKeyListener(onKeyEvent);
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

    xpGrabRadiusFixture = FixtureDef(
      xpGrabRadius,
      userData: {'type': FixtureType.sensor, 'object': this},
      isSensor: true,
      filter: Filter()
        ..categoryBits = playerCategory
        ..maskBits = proximityCategory,
    );

    return super.createBody()..createFixture(xpGrabRadiusFixture)
        // ..setBullet(true)
        ;
  }

  void onKeyEvent(KeyEvent event) {
    if (event is KeyUpEvent) {
      return;
    }
    if (event.logicalKey == (LogicalKeyboardKey.keyL)) {
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
    if (disableInput.parameter) {
      return;
    }
    final inputType = InputManager().externalInputType;
    final aimAssistStrength =
        game.systemDataComponent.dataObject.aimAssistStrength;
    if (aimAssistStrength == AimAssistStrength.none) {
      return;
    }

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
              clostestEnemyToMousePos.normalized(),
              aimAssistInputPriority,
            );

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
    var closestDistance = double.infinity;
    var closestDistanceMouse = double.infinity;

    final enemyList = world.physicsWorld.bodies.where(
      (element) =>
          element.userData is Enemy && !(element.userData! as Enemy).isDead,
    );
    var aimPosition = getAimPosition(userInputPriority);

    if (aimPosition != null) {
      aimPosition += enviroment.gameCamera.viewfinder.position;
    }

    for (final otherBody in enemyList) {
      if (otherBody.worldCenter.distanceTo(center) < closestDistance) {
        closestDistance = otherBody.worldCenter.distanceTo(center);
        closestEnemy = otherBody.userData! as Enemy;
      }

      if (aimPosition != null &&
          otherBody.worldCenter.distanceTo(aimPosition) <
              closestDistanceMouse) {
        closestDistanceMouse = otherBody.worldCenter.distanceTo(aimPosition);
        closestEnemyToMouse = otherBody.userData! as Enemy;
      }
    }
  }

  Vector2 tempMoveAngle = Vector2.zero();

  void onMoveAction(GameActionEvent _, Set<GameAction> activeGameActions) {
    if (disableInput.parameter) {
      return;
    }
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
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (disableInput.parameter || game.paused) {
      return;
    }
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
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (disableInput.parameter || game.paused) {
      return;
    }
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
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (gameActionEvent.pressState != PressState.pressed) {
      return;
    }
    if (disableInput.parameter) {
      return;
    }
    if (game.paused) {
      return;
    }
    swapWeapon();
  }

  void reloadWeaponAction(
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (gameActionEvent.pressState != PressState.pressed) {
      return;
    }
    if (disableInput.parameter) {
      return;
    }
    if (game.paused) {
      return;
    }
    if (currentWeapon is ReloadFunctionality) {
      final currentWeaponReload = currentWeapon! as ReloadFunctionality;
      if (currentWeaponReload.isReloading ||
          currentWeaponReload.spentAttacks == 0) {
        return;
      }

      currentWeaponReload.reload();
    }
  }

  void jumpAction(
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (gameActionEvent.pressState != PressState.pressed) {
      return;
    }
    if (disableInput.parameter) {
      return;
    }
    if (game.paused) {
      return;
    }

    jump();
  }

  void dashAction(
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (gameActionEvent.pressState != PressState.pressed) {
      return;
    }
    if (disableInput.parameter) {
      return;
    }
    if (game.paused) {
      return;
    }
    dash();
  }

  void interactAction(
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (gameActionEvent.pressState != PressState.pressed) {
      return;
    }
    if (disableInput.parameter) {
      return;
    }
    if (game.paused) {
      return;
    }
    if (_interactableComponents.isNotEmpty) {
      final itemToInteractWith = _interactableComponents.first;
      itemToInteractWith.interact();
      for (final element in interactableFunctions) {
        element(itemToInteractWith);
      }
    }
  }

  List<Function(InteractableComponent interactable)> interactableFunctions = [];

  void expendableAction(
    GameActionEvent gameActionEvent,
    Set<GameAction> activeGameActions,
  ) {
    if (gameActionEvent.pressState != PressState.pressed) {
      return;
    }
    if (disableInput.parameter) {
      return;
    }
    if (game.paused) {
      return;
    }
    useExpendable();
  }

  int debugCount = 0;

  @override
  Filter? filter = Filter()
    ..maskBits = 0xFFFF
    ..categoryBits = playerCategory;

  @override
  EntityType entityType = EntityType.player;

  List<EndGameExperienceEntry> buildEndGameEntries() {
    final returnList = <EndGameExperienceEntry>[
      (
        label: 'Total XP:',
        amount: experiencePointsGained + 5555222,
        damageType: null,
        isTotal: true,
        rating: 'SS'
      ),
      (
        label: 'Tota22:',
        amount: 53.00,
        damageType: null,
        isTotal: false,
        rating: null
      ),
      (
        label: 'Elemental Prowess Bonus:',
        amount: 1201,
        damageType: DamageType.fire,
        isTotal: false,
        rating: null
      ),
      (
        label: 'Weapon Pickup Bonus:',
        amount: 5555,
        damageType: null,
        isTotal: false,
        rating: null
      ),
    ];
    assert(returnList.where((element) => element.isTotal).length == 1);
    return returnList;
  }

  Future<void> winGame(
    ExitPortal portal,
  ) async {
    invincible.setIncrease('wingame', true);
    disableInput.setIncrease('wingame', true);

    clearWeapons();
    final portalOffset = Vector2(0, portal.spriteComponent.height / 3.65);
    body.linearDamping = 16;
    Future<void> followPortal(double dt) async {
      addMoveVelocity(
        ((portal.center + portalOffset) - center).normalized(),
        absoluteOverrideInputPriority,
      );

      if (center.distanceTo(portal.center + portalOffset) < .25) {
        onUpdate.remove(followPortal);
        addMoveVelocity(Vector2.zero(), absoluteOverrideInputPriority);

        await Future.delayed(.5.seconds);

        jump(true);

        collision.baseParameter = false;

        await Future.delayed((jumpDuration.parameter / 2).seconds);
        final ctr = EffectController(
          duration: jumpDuration.parameter / 2,
          curve: Curves.easeIn,
        );
        entityAnimationsGroup.add(OpacityEffect.fadeOut(ctr));
        entityAnimationsGroup.add(ScaleEffect.to(Vector2.all(0.2), ctr));
        await Future.delayed(2.seconds);

        GameState().pauseGame(
          gameWinDisplay.key,
        );
      }
    }

    onUpdate.add(followPortal);
  }
}

typedef EndGameExperienceEntry = ({
  String label,
  double amount,
  DamageType? damageType,
  bool isTotal,
  String? rating
});
