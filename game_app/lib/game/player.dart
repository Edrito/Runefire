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
import 'package:game_app/game/weapons.dart';
import 'package:game_app/game/weapon_class.dart';

import 'characters.dart';

class Player extends Entity with ContactCallbacks {
  Player(this.characterType)
      : super(
          file: characterType.getFilename(),
          position: Vector2.zero(),
        );

  final CharacterType characterType;

  Map<InputType, Vector2> inputAimAngles = {};
  Map<InputType, Vector2> inputAimPositions = {};
  double invinciblePercent = .5;
  bool isJumping = false;
  bool isJumpingInvincible = false;
  double jumpDuration = .5;
  Map<LogicalKeyboardKey, double> keyDurationPress = {};
  Vector2 moveAngle = Vector2.zero();
  Map<InputType, Vector2> moveVelocities = {};
  late PolygonShape shape;
  bool shooting = false;
  // bool singleRenderComplete = true;
  bool singleShot = false;

  Weapon? _projectileWeapon;

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
    aimingAnglePosition.add(_projectileWeapon!);
  }

  // @override
  // void flipSprites() {

  //   flipSpriteCheck([_projectileWeapon, spriteComponent])
  //   final degree = -degrees(aimingAnglePosition.angle);
  //   if (degree < 180 &&
  //       !(_projectileWeapon?.isFlippedHorizontally ?? false) &&
  //       !spriteComponent.isFlippedHorizontally) {
  //     _projectileWeapon?.flipHorizontallyAroundCenter();
  //     spriteComponent.flipHorizontallyAroundCenter();
  //   } else if (degree >= 180 &&
  //       (_projectileWeapon?.isFlippedHorizontally ?? true) &&
  //       spriteComponent.isFlippedHorizontally) {
  //     _projectileWeapon?.flipHorizontallyAroundCenter();
  //     spriteComponent.flipHorizontallyAroundCenter();
  //   }
  // }

  @override
  Future<void> onLoad() async {
    _projectileWeapon = Pistol();

    // add(rectangleComponent);
    await super.onLoad();
    aimingAnglePosition.mounted
        .whenComplete(() => aimingAnglePosition.add(_projectileWeapon!));
    testCircle = CircleComponent(radius: 1, anchor: Anchor.center);
    add(testCircle);
  }

  late CircleComponent testCircle;

  @override
  void render(Canvas canvas) {}

  @override
  void update(double dt) {
    handleKeyboardInputs();
    flipSpriteCheck();
    moveCharacter();
    canShootGun();
    shoot(dt);

    if (inputAimPositions.containsKey(InputType.mouseMove)) {
      testCircle.position = inputAimPositions[InputType.mouseMove]!;
    }

    super.update(dt);
  }

  @override
  void moveCharacter({Vector2? delta}) {
    previousPulse = moveVelocities[InputType.moveJoy] ??
        moveVelocities[InputType.keyboard] ??
        Vector2.zero();
    super.moveCharacter(delta: previousPulse.normalized());
  }

  @override
  void aimCharacter({Vector2? delta}) {
    final delta = (inputAimAngles[InputType.aimJoy] ??
        inputAimAngles[InputType.tapClick] ??
        inputAimAngles[InputType.mouseDrag] ??
        inputAimAngles[InputType.mouseMove] ??
        lastAimingPosition);

    super.aimCharacter(delta: delta);
  }

  void canShootGun() {
    if (inputAimAngles.containsKey(InputType.aimJoy)) {
      startShooting();
    } else if (inputAimAngles.containsKey(InputType.tapClick)) {
      startShooting();
    } else if (inputAimAngles.containsKey(InputType.mouseDrag)) {
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

  Vector2 previousPulse = Vector2.zero();

  void onAimCancel() {
    inputAimAngles.remove(InputType.aimJoy);
  }

  void onAimJoy(Vector2 normalizedDelta) {
    if (normalizedDelta.isZero()) return;
    inputAimAngles[InputType.aimJoy] = normalizedDelta.normalized();
  }

  void onMouseDrag(DragUpdateInfo info) {
    inputAimPositions[InputType.mouseMove] = (info.eventPosition.game - center);
    inputAimPositions[InputType.mouseDrag] =
        inputAimPositions[InputType.mouseMove]!;
    inputAimAngles[InputType.mouseDrag] =
        inputAimPositions[InputType.mouseDrag]!.normalized();
    inputAimAngles[InputType.mouseMove] =
        inputAimAngles[InputType.mouseDrag]!.clone();
  }

  void onMouseDragCancel() {
    inputAimAngles.remove(InputType.mouseDrag);
  }

  void onMouseMove(PointerHoverInfo info) async {
    await loaded.whenComplete(() => null);

    inputAimPositions[InputType.mouseMove] = (info.eventPosition.game - center);
    inputAimAngles[InputType.mouseMove] =
        inputAimPositions[InputType.mouseMove]!.normalized();
  }

  void onMoveCancel() {
    moveVelocities.remove(InputType.moveJoy);
  }

  void onMoveJoy(Vector2 normalizedDelta) {
    moveVelocities[InputType.moveJoy] = normalizedDelta * maxSpeed;
  }

  void onTapDown(TapDownInfo info) {
    inputAimAngles[InputType.tapClick] =
        (info.eventPosition.game - center).normalized();
  }

  void onTapUp() {
    inputAimAngles.remove(InputType.tapClick);
  }

  void shoot(double dt) {
    if (shooting) {
      _projectileWeapon?.shootCheck(dt);
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

  @override
  EntityType entityType = EntityType.player;
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
