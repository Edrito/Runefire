// ignore_for_file: unnecessary_getters_setters

import 'dart:async';
import 'dart:collection';
import 'dart:ffi';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/entities/entity_class.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/enviroment.dart';
import 'package:game_app/player/player_mixin.dart';
import 'package:game_app/game/enviroment_mixin.dart';
import 'package:game_app/resources/functions/functions.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:game_app/resources/constants/priorities.dart';
import 'package:game_app/resources/game_state_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../enemies/enemy.dart';
import '../game/interactable.dart';
import '../resources/functions/vector_functions.dart';
import '../main.dart';
import '../resources/data_classes/player_data.dart';
import '../resources/enums.dart';
import '../attributes/attributes_mixin.dart';
import '../game/expendables.dart';
import '../weapons/weapon_class.dart';

class Player extends Entity
    with
        ContactCallbacks,
        StaminaFunctionality,
        HealthFunctionality,
        AimFunctionality,
        AttackFunctionality,
        AttributeFunctionality,
        AttributeFunctionsFunctionality,
        MovementFunctionality,
        JumpFunctionality,
        ExperienceFunctionality,
        DodgeFunctionality,
        DashFunctionality,
        HealthRegenFunctionality {
  Player(this.playerData, this.isDisplay,
      {required super.enviroment, required super.initialPosition}) {
    // if (!isDisplay) {
    playerData.selectedPlayer.applyBaseCharacterStats(this);
    initAttributes(playerData.unlockedPermanentAttributes);
    // }
    onAttack.add(updateRemainingAmmo);
    onReloadComplete.add(updateRemainingAmmo);

    if (isDisplay) {
      height.setParameterPercentValue('display', .5);
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

  Set<PhysicalKeyboardKey> physicalKeysPressed = {};

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

  Expendable? currentExpendable;

  void pickupExpendable(Expendable groundExpendable) {
    currentExpendable = groundExpendable;
    gameEnviroment.hud.currentExpendable = groundExpendable;
  }

  void useExpendable() {
    currentExpendable?.applyExpendable();
    currentExpendable = null;
    gameEnviroment.hud.currentExpendable = null;
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await loadSpriteAnimation(10, 'sprites/idle.png', .1, true);
    entityAnimations[EntityStatus.jump] =
        await loadSpriteAnimation(3, 'sprites/jump.png', .1, false);
    entityAnimations[EntityStatus.dash] =
        await loadSpriteAnimation(7, 'sprites/roll.png', .06, false);
    entityAnimations[EntityStatus.walk] =
        await loadSpriteAnimation(8, 'sprites/walk.png', .1, true);
    entityAnimations[EntityStatus.run] =
        await loadSpriteAnimation(8, 'sprites/run.png', .1, true);
    entityAnimations[EntityStatus.dead] =
        await loadSpriteAnimation(10, 'enemy_sprites/death.png', .1, false);
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
    physicalKeysPressed.clear();
    moveVelocities.clear();
    inputAimAngles.clear();
    inputAimPositions.clear();

    game.mouseCallback.remove(mouseCallbackWrapper);

    super.onRemove();
  }

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    if (!collision.parameter) {
      contact.setEnabled(false);
    }
    super.preSolve(other, contact, oldManifold);
  }

  late MouseKeyboardCallbackWrapper mouseCallbackWrapper;
  late final CircleComponent circleComponent;

  @override
  Future<void> onLoad() async {
    initialWeapons.addAll(playerData.selectedWeapons.values);
    // initialWeapons.add(WeaponType.blankMelee);
    // initialWeapons.add(WeaponType.shiv);
    priority = playerPriority;

    // circleComponent = CircleComponent(radius: .1, position: Vector2(0, 0));
    // add(circleComponent);

    await loadAnimationSprites();
    mouseCallbackWrapper = MouseKeyboardCallbackWrapper();
    // if (!isDisplay) {
    mouseCallbackWrapper.onSecondaryDown = (_) => startAltAttacking();
    mouseCallbackWrapper.onSecondaryUp = (_) => endAltAttacking();
    mouseCallbackWrapper.onSecondaryCancel = () => endAltAttacking();
    // }

    mouseCallbackWrapper.keyEvent = (event) => onKeyEvent(event);
    game.mouseCallback.add(mouseCallbackWrapper);

    await super.onLoad();
  }

  @override
  Body createBody() {
    late CircleShape shape;
    late CircleShape xpGrabRadius;
    shape = CircleShape();
    xpGrabRadius = CircleShape();
    shape.radius = spriteAnimationComponent.size.x / 2;
    xpGrabRadius.radius = xpSensorRadius.parameter;
    renderBody = false;

    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0.001,
        filter: filter);

    final xpGrabRadiusFixture = FixtureDef(xpGrabRadius,
        userData: {"type": FixtureType.sensor, "object": this},
        isSensor: true,
        filter: Filter()
          ..categoryBits = playerCategory
          ..maskBits = proximityCategory);

    final bodyDef = BodyDef(
      userData: this,
      position: initialPosition,
      type: BodyType.dynamic,
      linearDamping: 12,
      allowSleep: false,
      fixedRotation: true,
    );
    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..createFixture(xpGrabRadiusFixture);
  }

  void onKeyEvent(RawKeyEvent event) {
    if (event is RawKeyUpEvent) {
      physicalKeysPressed.remove(event.physicalKey);
    } else {
      physicalKeysPressed.add(event.physicalKey);
    }
    parseKeys(event);
  }

  @override
  void update(double dt) {
    // if (!isDisplay) {
    moveCharacter();
    // }
    aimCharacter();
    findClosestEnemy();
    super.update(dt);
  }

  Enemy? closestEnemy;

  void findClosestEnemy() {
    double closestDistance = double.infinity;

    for (var otherBody in world.bodies.where((element) =>
        element.userData is Enemy && !(element.userData as Enemy).isDead)) {
      if (otherBody.worldCenter.distanceTo(center) < closestDistance) {
        closestDistance = otherBody.worldCenter.distanceTo(center);
        closestEnemy = otherBody.userData as Enemy;
      }
    }
  }

  void parseKeys(RawKeyEvent? event) {
    Vector2 moveAngle = Vector2.zero();
    try {
      if (event == null || isDead) return;

      if (!isDisplay) {
        if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyD)) {
          moveAngle.x += 1;
        }
        if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyA)) {
          moveAngle.x -= 1;
        }
        if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyW)) {
          moveAngle.y -= 1;
        }
        if (physicalKeysPressed.contains(PhysicalKeyboardKey.keyS)) {
          moveAngle.y += 1;
        }
      }

      if (gameRef.gameStateComponent.gameState.gameIsPaused ||
          event is! RawKeyDownEvent) return;

      if (event.physicalKey == (PhysicalKeyboardKey.space)) {
        setEntityStatus(EntityStatus.jump);
      }

      if (event.physicalKey == (PhysicalKeyboardKey.keyQ)) {
        useExpendable();
      }

      if (event.physicalKey == (PhysicalKeyboardKey.keyE)) {
        if (_interactableComponents.isNotEmpty) {
          _interactableComponents.first.interact();
        }
      }

      if (event.physicalKey == (PhysicalKeyboardKey.shiftLeft)) {
        setEntityStatus(EntityStatus.dash);
      }
      if (event.physicalKey == (PhysicalKeyboardKey.keyR)) {
        if (currentWeapon is ReloadFunctionality) {
          final currentWeaponReload = currentWeapon as ReloadFunctionality;
          if (currentWeaponReload.isReloading ||
              currentWeaponReload.spentAttacks == 0) return;

          currentWeaponReload.reload();
        }
      }

      if (event.physicalKey == (PhysicalKeyboardKey.tab)) {
        swapWeapon();
      }

      // if (event.physicalKey == (PhysicalKeyboardKey.keyM)) {
      //   (carriedWeapons[1] as PlayerWeapon).setSecondaryFunctionality =
      //       carriedWeapons[0];
      //   carriedWeapons.remove(0);
      // }

      if (isDisplay) {
        return;
      }

      if (event.physicalKey == (PhysicalKeyboardKey.keyL)) {
        preLevelUp();
      }
    } finally {
      if (moveAngle.isZero()) {
        moveVelocities.remove(InputType.keyboard);
      } else if (!gameRef.gameStateComponent.gameState.gameIsPaused) {
        moveVelocities[InputType.keyboard] = moveAngle;
      }
    }
  }

  int debugCount = 0;

  void gestureEventEnd(InputType inputType) async {
    switch (inputType) {
      // case InputType.mouseMove:
      //   if (info == null) return;
      //   await loaded.whenComplete(() => null);
      //   inputAimPositions[InputType.mouseMove] =
      //       (info.eventPosition.game - center);
      //   inputAimAngles[InputType.mouseMove] =
      //       inputAimPositions[InputType.mouseMove]!.normalized();
      //   break;

      case InputType.aimJoy:
        inputAimAngles.remove(InputType.aimJoy);
        break;

      case InputType.moveJoy:
        moveVelocities.remove(InputType.moveJoy);
        break;
      case InputType.tapClick:
        inputAimAngles.remove(InputType.tapClick);
        break;

      case InputType.mouseDrag:
        inputAimAngles.remove(InputType.mouseDrag);
        break;
      case InputType.secondaryClick:
        endAltAttacking();
        break;

      default:
      // Code to handle unknown or unexpected input type
    }
    if (inputAimAngles.containsKey(InputType.aimJoy) ||
        inputAimAngles.containsKey(InputType.tapClick) ||
        inputAimAngles.containsKey(InputType.mouseDrag)) return;
    endAttacking();
  }

  void gestureEventStart(InputType inputType, Vector2 eventPosition) {
    // if (isDisplay && inputType != InputType.mouseMove) return;

    switch (inputType) {
      case InputType.mouseMove:
        if (!isMounted) return;
        final position = (shiftCoordinatesToCenter(
                eventPosition, enviroment.gameCamera.viewport.size) /
            enviroment.gameCamera.viewfinder.zoom);

        inputAimPositions[InputType.mouseMove] = position;
        buildDeltaFromMousePosition();

        break;

      case InputType.aimJoy:
        if (gameEnviroment is! JoystickFunctionality) return;

        final delta =
            (enviroment as JoystickFunctionality).aimJoystick?.relativeDelta;
        if (delta == null || delta.isZero()) return;
        inputAimAngles[InputType.aimJoy] = delta.normalized();
        startAttacking();

        break;

      case InputType.moveJoy:
        if (enviroment is! JoystickFunctionality) return;
        final delta =
            (enviroment as JoystickFunctionality).moveJoystick?.relativeDelta;
        moveVelocities[InputType.moveJoy] =
            (delta ?? Vector2.zero()) * speed.parameter;
        break;

      case InputType.tapClick:
        inputAimPositions[InputType.tapClick] = shiftCoordinatesToCenter(
                eventPosition, enviroment.gameCamera.viewport.size) /
            enviroment.gameCamera.viewfinder.zoom;
        // inputAimAngles[InputType.mouseMove] =
        //     inputAimPositions[InputType.mouseMove]!.normalized();
        // inputAimAngles[InputType.tapClick] =
        //     (info.eventPosition.game - center).normalized();
        startAttacking();
        inputAimAngles.remove(InputType.tapClick);
        break;

      case InputType.mouseDrag:
        inputAimPositions[InputType.mouseMove] = shiftCoordinatesToCenter(
                eventPosition, enviroment.gameCamera.viewport.size) /
            enviroment.gameCamera.viewfinder.zoom;
        inputAimPositions[InputType.mouseDrag] =
            inputAimPositions[InputType.mouseMove]!;
        inputAimAngles[InputType.mouseDrag] =
            inputAimPositions[InputType.mouseDrag]!.normalized();
        inputAimAngles[InputType.mouseMove] =
            inputAimAngles[InputType.mouseDrag]!.clone();
        startAttacking();

        break;
      // case InputType.mouseDragStart:
      //   if (!inputAimAngles.containsKey(InputType.mouseMove)) return;
      //   startAttacking();
      //   break;
      // case InputType.secondaryClick:
      //   startAltAttacking();
      //   break;
      default:
      // Code to handle unknown or unexpected input type
    }
  }

  @override
  Filter? filter = Filter()
    ..maskBits = 0xFFFF
    ..categoryBits = playerCategory;

  @override
  EntityType entityType = EntityType.player;
}
