import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:game_app/resources/functions/functions.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:uuid/uuid.dart';

import '../entities/entity_class.dart';
import '../entities/player.dart';
import '../resources/functions/vector_functions.dart';
import '../enemies/enemy.dart';
import '../main.dart';
import '../resources/enums.dart';

class MeleeAttackHitbox extends BodyComponent<GameRouter>
    with ContactCallbacks {
  MeleeAttackHitbox(this.size, this.meleeAttackAncestor, this.onHit);
  MeleeAttackHandler meleeAttackAncestor;
  Function(HealthFunctionality) onHit;
  List<String> hitEnemiesId = [];
  final Vector2 size;
  late PolygonShape shape;
  int hitEnemies = 0;

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) async {
    if (other is HealthFunctionality) {
      other.applyHitAnimation(
          await loadSpriteAnimation(
              4, 'weapons/melee/small_slash_effect.png', .05, false),
          oldManifold.localNormal,
          2);
    }
    super.preSolve(other, contact, oldManifold);
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (meleeAttackAncestor.isDead) {
      return;
    }

    if (other is HealthFunctionality) {
      if (hitEnemiesId.contains(other.entityId) || other.isDead) {
        return;
      }
      if (hitEnemies > meleeAttackAncestor.weaponAncestor.pierce.parameter) {
        meleeAttackAncestor.kill();
        return;
      }

      bodyContact(other);
    }

    super.beginContact(other, contact);
  }

  void bodyContact(HealthFunctionality other) {
    hitEnemiesId.add(other.entityId);
    other.hitCheck(meleeAttackAncestor.meleeId,
        meleeAttackAncestor.weaponAncestor.calculateDamage);
    onHitFunctions(other);
    applyHitSpriteEffects(other);
    hitEnemies++;
  }

  void applyHitSpriteEffects(HealthFunctionality other) async {
    switch (meleeAttackAncestor.weaponAncestor.meleeType) {
      case MeleeType.crush:
        // other.applyHitAnimation(
        //     await buildSpriteSheet(
        //         4, 'weapons/melee/small_crush_effect.png', .1, false),
        //     center,
        //     1);
        break;
      case MeleeType.slash:
        break;
      case MeleeType.stab:
        break;
    }
    other.applyHitAnimation(
        await loadSpriteAnimation(
            4, 'weapons/melee/small_slash_effect.png', .05, false),
        center,
        1);
  }

  void onHitFunctions(HealthFunctionality other) {
    if (meleeAttackAncestor.weaponAncestor
        is AttributeWeaponFunctionsFunctionality) {
      final weapon = meleeAttackAncestor.weaponAncestor
          as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onHitMelee) {
        element(other);
      }
    }

    meleeAttackAncestor
        .weaponAncestor.entityAncestor?.attributeFunctionsFunctionality
        ?.onHitFunctions(other);
    onHit(other);
  }

  @override
  Body createBody() {
    shape = PolygonShape();

    shape.set([
      Vector2(-size.x / 2, 0),
      Vector2(size.x / 2, 0),
      Vector2(size.x / 2, size.y),
      Vector2(-size.x / 2, size.y),
    ]);

    final swordFilter = Filter();
    if (meleeAttackAncestor.weaponAncestor.entityAncestor is Enemy) {
      swordFilter.maskBits = playerCategory;
    } else {
      swordFilter.maskBits = enemyCategory;
    }
    swordFilter.categoryBits = swordCategory;
    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0,
        isSensor: true,
        filter: swordFilter);
//  activeSwings.last.swingPosition, activeSwings.last.swingAngle
    final bodyDef = BodyDef(
      userData: this,
      allowSleep: false,
      position: meleeAttackAncestor.activeSwings.last.swingPosition,
      angle: meleeAttackAncestor.activeSwings.last.swingAngle,
      type: BodyType.kinematic,
    );
    renderBody = false;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class MeleeAttackSprite extends PositionComponent {
  MeleeAttackSprite(SpriteAnimation? swingAnimation, Vector2 position,
      this.target, this.handler) {
    this.position = position;
    animationComponent = SpriteAnimationComponent(
        animation: swingAnimation,
        anchor: Anchor.topCenter,
        size: swingAnimation!.frames.first.sprite.srcSize
            .scaledToDimension(true, handler.weaponAncestor.length));

    animationComponent?.animation = swingAnimation;
    if (handler.weaponAncestor.entityAncestor!.isFlipped) {
      animationComponent?.flipHorizontallyAroundCenter();
    }
  }
  void removeSwing() {
    handler.removeSwing(this);
  }

  SpriteAnimationComponent? animationComponent;

  Entity target;

  void fadeOut() {
    removeSwing();
    animationComponent?.add(OpacityEffect.fadeOut(EffectController(
      duration: .4,
      curve: Curves.easeOut,
    )));
  }

  Vector2 get swingPosition => animationComponent!.position + target.center;
  double get swingAngle => animationComponent!.angle;

  @override
  void update(double dt) {
    position = (target.center);
    super.update(dt);
  }

  MeleeAttackHandler handler;
  TimerComponent? swingTimer;

  @override
  FutureOr<void> onLoad() {
    swingTimer = TimerComponent(
      period: handler.duration,
      onTick: () {
        fadeOut();
      },
    );
    add(swingTimer!);
    add(animationComponent!);
    return super.onLoad();
  }
}

class MeleeAttackHandler extends Component {
  MeleeAttackHandler(
      {required this.initPosition,
      required this.initAngle,
      required this.index,
      required this.chargeAmount,
      required this.weaponAncestor}) {
    start = weaponAncestor.attackHitboxPatterns[index];
    end = weaponAncestor.attackHitboxPatterns[index + 1];
    duration = weaponAncestor.attackTickRate.parameter;
    meleeId = const Uuid().v4();
  }

  bool isDead = false;

  bool disableChaining = false;

  List<MeleeAttackSprite> activeSwings = [];
  Entity? target;
  double chargeAmount;
  late (Vector2, double) start;
  late (Vector2, double) end;

  late double duration;
  late String meleeId;

  int index;
  MeleeFunctionality weaponAncestor;
  MeleeAttackHitbox? hitbox;
  Vector2 initPosition;
  double initAngle;

  void onHitFunction(HealthFunctionality other) {
    chain(other);
  }

  void chain(HealthFunctionality other) {
    if (!disableChaining &&
        weaponAncestor.weaponCanChain &&
        hitbox!.hitEnemies < weaponAncestor.maxChainingTargets.parameter &&
        !isDead) {
      List<Body> bodies = [
        ...weaponAncestor.entityAncestor?.gameRef.world.bodies.where((element) {
              if (weaponAncestor.entityAncestor is Player) {
                return element.userData is Enemy &&
                    element.userData != other &&
                    !hitbox!.hitEnemiesId
                        .contains((element.userData as Entity).entityId);
              } else {
                return element.userData is Player &&
                    element.userData != other &&
                    !hitbox!.hitEnemiesId.contains(other.entityId);
              }
            }) ??
            []
      ];
      if (bodies.isEmpty) {
        return;
      }
      bodies.sort((a, b) => (a.position - other.center)
          .length2
          .compareTo((b.position - other.center).length2));

      final delta = (other.center - bodies.first.position);

      final otherAngle = -radiansBetweenPoints(
        Vector2(0, -1),
        delta,
      );
      target = other;

      initSwing(
          otherAngle,
          other.center -
              weaponAncestor.entityAncestor!.gameEnviroment.gameCamera
                  .viewfinder.position);
    }
  }

  void initSwing(double swingAngle, Vector2 swingPosition) {
    SpriteAnimation? spriteAnimation;
    if (weaponAncestor.attackHitboxSpriteAnimations.isNotEmpty) {
      spriteAnimation =
          weaponAncestor.attackHitboxSpriteAnimations[(index / 2).round()];
      spriteAnimation.stepTime = duration;
    }

    final rotatedStartPosition = rotateVector2(start.$1, swingAngle);
    final rotatedEndPosition = rotateVector2(end.$1, swingAngle);

    final newSwing =
        MeleeAttackSprite(spriteAnimation!, swingPosition, target!, this);
    final startAngle = radians(start.$2) + swingAngle;
    newSwing.animationComponent?.angle = startAngle;
    newSwing.animationComponent?.position += rotatedStartPosition;
    // newSwing.position += rotatedStartPosition;
    // newSwing.angle = startAngle;
    final totalAngle = end.$2 - start.$2;

    final effectController = EffectController(
      duration: duration * 2,
      curve: Curves.easeInOutCubicEmphasized,
    );
    final rotateEffect = RotateEffect.by(
      radians(totalAngle),
      effectController,
    );

    final moveEffect = MoveEffect.to(
      rotatedEndPosition,
      effectController,
    );

    newSwing.animationComponent?.addAll([rotateEffect, moveEffect]);
    activeSwings.add(newSwing);
    newSwing.addToParent(this);
  }

  @override
  Future<void> onLoad() async {
    weaponAncestor.activeSwings.add(this);
    weaponAncestor.spriteVisibilityCheck();
    final hitboxSize = weaponAncestor.attackHitboxSizes[(index / 2).round()];
    target = weaponAncestor.entityAncestor;
    initSwing(initAngle, initPosition);
    hitbox = MeleeAttackHitbox(hitboxSize, this, onHitFunction);
    weaponAncestor.entityAncestor?.enviroment.physicsComponent.add(hitbox!);

    return super.onLoad();
  }

  void kill() {
    for (var element in activeSwings) {
      element.fadeOut();
    }
    isDead = true;
  }

  void removeSwing([MeleeAttackSprite? attack]) {
    activeSwings.remove(attack);
    if (activeSwings.isEmpty) {
      weaponAncestor.activeSwings.remove(this);
      weaponAncestor.spriteVisibilityCheck();
      hitbox?.removeFromParent();
      removeFromParent();
    }
  }

  MeleeAttackSprite get currentSwing => activeSwings.last;

  void updatePosition() {
    if (activeSwings.isEmpty) return;
    hitbox?.body.setTransform(
        activeSwings.last.swingPosition, activeSwings.last.swingAngle);
  }

  @override
  void update(double dt) {
    if (hitbox?.isLoaded ?? false) {
      updatePosition();
    }
    super.update(dt);
  }
}
