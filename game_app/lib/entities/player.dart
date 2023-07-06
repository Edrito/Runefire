import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/entities/player_mixin.dart';
import 'package:game_app/functions/functions.dart';
import 'package:game_app/resources/overlays.dart';
import 'package:game_app/resources/physics_filter.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../functions/vector_functions.dart';
import '../main.dart';
import '../pages/menu.dart';
import '../resources/area_effects.dart';
import '../resources/data_classes/player_data.dart';
import '../resources/enums.dart';

class Player extends Entity
    with
        ContactCallbacks,
        StaminaFunctionality,
        HealthFunctionality,
        AimFunctionality,
        AttackFunctionality,
        MovementFunctionality,
        JumpFunctionality,
        ExperienceFunctionality,
        DashFunctionality {
  Player(this.playerData,
      {required super.gameEnv, required super.initPosition});
  final PlayerData playerData;

  Set<PhysicalKeyboardKey> physicalKeysPressed = {};

  @override
  Future<void> loadAnimationSprites() async {
    idleAnimation = await buildSpriteSheet(10, 'sprites/idle.png', .1, true);
    jumpAnimation = await buildSpriteSheet(3, 'sprites/jump.png', .1, false);
    dashAnimation = await buildSpriteSheet(7, 'sprites/roll.png', .06, false);
    walkAnimation = await buildSpriteSheet(8, 'sprites/walk.png', .1, true);
    runAnimation = await buildSpriteSheet(8, 'sprites/run.png', .1, true);
    deathAnimation =
        await buildSpriteSheet(10, 'enemy_sprites/death.png', .1, false);
  }

  @override
  void onRemove() {
    physicalKeysPressed.clear();
    moveVelocities.clear();
    inputAimAngles.clear();
    inputAimPositions.clear();
    game.mouseCallback.remove(mouseCallbackWrapper);

    super.onRemove();
  }

  late MouseKeyboardCallbackWrapper mouseCallbackWrapper;
  @override
  Future<void> onLoad() async {
    initialWeapons.addAll(playerData.selectedWeapons.values);

    await loadAnimationSprites();

    mouseCallbackWrapper = MouseKeyboardCallbackWrapper();
    mouseCallbackWrapper.onSecondaryDown = (_) => startAltAttacking();
    mouseCallbackWrapper.onSecondaryUp = (_) => endAltAttacking();
    mouseCallbackWrapper.onSecondaryCancel = () => endAltAttacking();
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
    xpGrabRadius.radius = xpSensorRadius;
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
          ..maskBits = experienceCategory);

    final bodyDef = BodyDef(
      userData: this,
      position: initPosition,
      type: BodyType.dynamic,
      linearDamping: 12,
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
    if (!isDead && !isDashing) {
      moveCharacter();
    }
    super.update(dt);
  }

  void parseKeys(RawKeyEvent? event) {
    Vector2 moveAngle = Vector2.zero();
    try {
      if (event == null || isDead) return;

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

      if (gameIsPaused || event is! RawKeyDownEvent) return;

      if (event.physicalKey == (PhysicalKeyboardKey.space)) {
        setEntityStatus(EntityStatus.jump);
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

      if (event.physicalKey == (PhysicalKeyboardKey.keyH)) {
        gameEnv.physicsComponent.add(AreaEffect(
          sourceEntity: this,
          position: (inputAimPositions[InputType.mouseMove] ?? Vector2.zero()) +
              center,
          radius: 5,
          isInstant: false,
          duration: 5,
          onTick: (entity, areaId) {
            if (entity is HealthFunctionality) {
              entity.hitCheck(areaId, [
                DamageInstance(damageBase: .1, damageType: DamageType.fire)
              ]);
            }
          },
        ));
      }

      if (event.physicalKey == (PhysicalKeyboardKey.tab)) {
        swapWeapon();
      }
    } finally {
      if (moveAngle.isZero()) {
        moveVelocities.remove(InputType.keyboard);
      } else if (!gameIsPaused) {
        moveVelocities[InputType.keyboard] = moveAngle;
      }
    }
  }

  @override
  double dashCooldown = 1;
  void gestureEventEnd(InputType inputType, PositionInfo? info) async {
    switch (inputType) {
      case InputType.mouseMove:
        if (info == null) return;
        await loaded.whenComplete(() => null);
        inputAimPositions[InputType.mouseMove] =
            (info.eventPosition.game - center);
        inputAimAngles[InputType.mouseMove] =
            inputAimPositions[InputType.mouseMove]!.normalized();
        break;

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

  void gestureEventStart(InputType inputType, PositionInfo info) {
    switch (inputType) {
      case InputType.mouseMove:
        if (!isMounted) return;
        inputAimPositions[InputType.mouseMove] = vectorToGrid(
                info.eventPosition.viewport, gameEnv.gameCamera.viewport.size) /
            gameEnv.gameCamera.viewfinder.zoom;
        inputAimAngles[InputType.mouseMove] =
            inputAimPositions[InputType.mouseMove]!.normalized();

        break;

      case InputType.aimJoy:
        final delta = gameEnv.aimJoystick?.relativeDelta;
        if (delta == null || delta.isZero()) return;
        inputAimAngles[InputType.aimJoy] = delta.normalized();

        break;

      case InputType.moveJoy:
        final delta = gameEnv.moveJoystick?.relativeDelta;
        moveVelocities[InputType.moveJoy] =
            (delta ?? Vector2.zero()) * getMaxSpeed;
        break;

      case InputType.tapClick:
        inputAimAngles[InputType.tapClick] =
            (info.eventPosition.game - center).normalized();
        startAttacking();
        inputAimAngles.remove(InputType.tapClick);
        break;

      case InputType.mouseDrag:
        inputAimPositions[InputType.mouseMove] = vectorToGrid(
                info.eventPosition.viewport, gameEnv.gameCamera.viewport.size) /
            gameEnv.gameCamera.viewfinder.zoom;
        inputAimPositions[InputType.mouseDrag] =
            inputAimPositions[InputType.mouseMove]!;
        inputAimAngles[InputType.mouseDrag] =
            inputAimPositions[InputType.mouseDrag]!.normalized();
        inputAimAngles[InputType.mouseMove] =
            inputAimAngles[InputType.mouseDrag]!.clone();

        break;
      case InputType.mouseDragStart:
        startAttacking();
        break;
      case InputType.secondaryClick:
        startAltAttacking();
        break;
      default:
      // Code to handle unknown or unexpected input type
    }
  }

  void killPlayer(bool showDeathScreen) {
    setEntityStatus(EntityStatus.dead);

    Future.delayed(2.seconds).then(
      (value) {
        if (showDeathScreen) {
          pauseGame(deathScreen.key, wipeMovement: true);
        } else {
          changeMainMenuPage(MenuPages.startMenuPage, false);
        }
      },
    );
  }

  @override
  Filter? filter = Filter()
    ..maskBits = 0xFFFF
    ..categoryBits = playerCategory;

  @override
  double height = 1;

  @override
  double baseHealth = 50;

  @override
  double baseSpeed = .1;

  @override
  EntityType entityType = EntityType.player;

  @override
  SpriteAnimation? damageAnimation;

  @override
  SpriteAnimation? dashAnimation;

  @override
  SpriteAnimation? deathAnimation;

  @override
  late SpriteAnimation idleAnimation;

  @override
  SpriteAnimation? jumpAnimation;

  @override
  SpriteAnimation? runAnimation;

  @override
  SpriteAnimation? spawnAnimation;

  @override
  SpriteAnimation? walkAnimation;

  @override
  double baseInvincibilityDuration = 1;

  // @override
  // Map<DamageType, (double, double)> touchDamageLevels = {
  //   DamageType.regular: (4, 10)
  // };

  @override
  double baseStamina = 100;

  @override
  double baseDashDistance = 5;

  @override
  double baseDashCooldown = 2;
}
