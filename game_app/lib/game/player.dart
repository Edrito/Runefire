import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/physics_filter.dart';
import 'package:game_app/game/projectile_weapons.dart';
import 'package:game_app/game/ranged_weapon.dart';

import '../functions/functions.dart';
import 'characters.dart';

class Player extends Entity with ContactCallbacks {
  Player(this.characterType)
      : super(
          file: characterType.getFilename(),
          entityType: EntityType.player,
          position: Vector2.zero(),
        );

  final CharacterType characterType;

  Map<InputType, Vector2> aimAngles = {};
  late PositionComponent handParentAnglePosition;
  double invinciblePercent = .5;
  bool isJumping = false;
  bool isJumpingInvincible = false;
  double jumpDuration = .5;
  Map<LogicalKeyboardKey, double> keyDurationPress = {};
  Vector2 lastAimingPosition = Vector2.zero();
  Vector2 moveAngle = Vector2.zero();
  Map<InputType, Vector2> moveVelocities = {};
  late PolygonShape shape;
  bool shooting = false;
  // bool singleRenderComplete = true;
  bool singleShot = false;

  ProjectileWeapon? _projectileWeapon;

  void swapWeapon() {
    _projectileWeapon?.removeFromParent();
    bool isFlipped = _projectileWeapon?.isFlippedHorizontally ?? false;
    if (_projectileWeapon is Pistol) {
      _projectileWeapon = null;
      _projectileWeapon = Shotgun();
    } else {
      _projectileWeapon = null;
      _projectileWeapon = Pistol();
    }
    if (_projectileWeapon?.isFlippedHorizontally != isFlipped) {
      _projectileWeapon?.flipHorizontallyAroundCenter();
    }
    handParentAnglePosition.add(_projectileWeapon!);
  }

  @override
  void flipSpriteCheck() {
    final degree = -degrees(handParentAnglePosition.angle);
    if (degree < 180 &&
        !(_projectileWeapon?.isFlippedHorizontally ?? false) &&
        !spriteComponent.isFlippedHorizontally) {
      _projectileWeapon?.flipHorizontallyAroundCenter();
      spriteComponent.flipHorizontallyAroundCenter();
    } else if (degree >= 180 &&
        (_projectileWeapon?.isFlippedHorizontally ?? true) &&
        spriteComponent.isFlippedHorizontally) {
      _projectileWeapon?.flipHorizontallyAroundCenter();
      spriteComponent.flipHorizontallyAroundCenter();
    }
  }

  late RectangleComponent rectangleComponent;

  @override
  Future<void> onLoad() async {
    handParentAnglePosition =
        PositionComponent(anchor: Anchor.center, size: Vector2.zero());

    rectangleComponent = RectangleComponent(
      anchor: Anchor.center,
      size: Vector2(.5, 150),
    );
    add(handParentAnglePosition);
    _projectileWeapon = Pistol();

    handParentAnglePosition.mounted.whenComplete(
      () => handParentAnglePosition.addAll([_projectileWeapon!]),
    );
    // add(rectangleComponent);
    return super.onLoad();
  }

  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {
    handleKeyboardInputs();
    flipSpriteCheck();
    moveCharacter(dt);
    aimCharacter();
    canShootGun();
    shoot(dt);
    rectangleComponent.angle = handParentAnglePosition.angle;
    super.update(dt);
  }

  void aimCharacter() {
    final delta = (aimAngles[InputType.aimJoy] ??
        aimAngles[InputType.tapClick] ??
        aimAngles[InputType.mouseDrag] ??
        aimAngles[InputType.mouseMove] ??
        lastAimingPosition);

    handParentAnglePosition.position =
        ((delta) * (_projectileWeapon?.distanceFromPlayer ?? 5.0));

    handParentAnglePosition.angle = -radiansBetweenPoints(
      Vector2(0, 0.000001),
      delta,
    );

    lastAimingPosition = delta;
  }

  void canShootGun() {
    if (aimAngles.containsKey(InputType.aimJoy)) {
      startShooting();
    } else if (aimAngles.containsKey(InputType.tapClick)) {
      startShooting();
    } else if (aimAngles.containsKey(InputType.mouseDrag)) {
      startShooting();
    } else if (shooting) {
      endShooting();
    }
  }

  void endShooting() {
    shooting = false;
  }

  void handleKeyboardInputs() {
    moveAngle.setZero();

    if (keyDurationPress.isNotEmpty) {
      moveAngle.x +=
          keyDurationPress[LogicalKeyboardKey.keyD] != null ? maxSpeed : 0;
      moveAngle.x -=
          keyDurationPress[LogicalKeyboardKey.keyA] != null ? maxSpeed : 0;

      moveAngle.y -=
          keyDurationPress[LogicalKeyboardKey.keyW] != null ? maxSpeed : 0;
      moveAngle.y +=
          keyDurationPress[LogicalKeyboardKey.keyS] != null ? maxSpeed : 0;

      moveVelocities[InputType.keyboard] = moveAngle;
    }

    jump(keyDurationPress[LogicalKeyboardKey.space], this);
  }

  void moveCharacter(double dt) {
    final newPulse = moveVelocities[InputType.moveJoy] ??
        moveVelocities[InputType.keyboard] ??
        Vector2.zero();
    if (newPulse.isZero()) return;
    body.applyForce(newPulse);
  }

  void onAimCancel() {
    aimAngles.remove(InputType.aimJoy);
  }

  void onAimJoy(Vector2 normalizedDelta) {
    if (normalizedDelta.isZero()) return;
    aimAngles[InputType.aimJoy] = normalizedDelta.normalized();
  }

  void onMouseDrag(DragUpdateInfo info) {
    aimAngles[InputType.mouseDrag] =
        (info.eventPosition.game - center).normalized();
    aimAngles[InputType.mouseMove] = aimAngles[InputType.mouseDrag]!.clone();
  }

  void onMouseDragCancel() {
    aimAngles.remove(InputType.mouseDrag);
  }

  void onMouseMove(PointerHoverInfo info) async {
    await loaded.whenComplete(() => null);
    aimAngles[InputType.mouseMove] =
        (info.eventPosition.game - center).normalized();
  }

  void onMoveCancel() {
    moveVelocities.remove(InputType.moveJoy);
  }

  void onMoveJoy(Vector2 normalizedDelta) {
    moveVelocities[InputType.moveJoy] = normalizedDelta * maxSpeed;
  }

  void onTapDown(TapDownInfo info) {
    aimAngles[InputType.tapClick] =
        (info.eventPosition.game - center).normalized();
  }

  void onTapUp() {
    aimAngles.remove(InputType.tapClick);
  }

  void shoot(double dt) {
    if (shooting) {
      _projectileWeapon?.shoot(dt);
    }
  }

  void startShooting() {
    shooting = true;
  }

  @override
  Future<void> onDeath() async {}

  @override
  Filter? filter = Filter()..maskBits = 0xFFFF - bulletCategory;

  @override
  double height = 15;

  @override
  double invincibiltyDuration = 1;

  @override
  double maxHealth = 20;

  @override
  double maxSpeed = 500;
}

void jump(double? previousTime, Player classRef) {
  if (previousTime == null || classRef.isJumping) return;

  double jumpDuration = classRef.jumpDuration;
  double invinciblePercent = classRef.invinciblePercent;

  classRef.isJumping = true;

  double elapsed = 0;
  double min = (jumpDuration / 2) - jumpDuration * (invinciblePercent / 2);
  double max = (jumpDuration / 2) + jumpDuration * (invinciblePercent / 2);

  final controller = EffectController(
    duration: jumpDuration,
    curve: Curves.ease,
    reverseDuration: jumpDuration,
    reverseCurve: Curves.ease,
  );
  Future.doWhile(
      () => Future.delayed(const Duration(milliseconds: 25)).then((value) {
            elapsed += .025;

            classRef.isJumpingInvincible = elapsed > min && elapsed < max;

            return !(elapsed >= jumpDuration || controller.completed);
          })).then((_) {
    classRef.isJumping = false;
  });
  final jumpSizeUpEffect = ScaleEffect.by(
    Vector2(1.035, 1.035),
    controller,
  );
  final jumpMoveUpEffect = MoveEffect.by(
    Vector2(0, -1.9),
    controller,
  );

  classRef.spriteComponent.add(jumpSizeUpEffect);
  classRef.spriteComponent.add(jumpMoveUpEffect);
}
