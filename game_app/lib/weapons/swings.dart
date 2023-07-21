import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:uuid/uuid.dart';

import '../entities/entity.dart';
import '../entities/player.dart';
import '../resources/functions/vector_functions.dart';
import '../entities/enemy.dart';
import '../main.dart';
import '../resources/enums.dart';

class MeleeDetection extends BodyComponent<GameRouter> with ContactCallbacks {
  MeleeDetection(this.size, this.parentAttack, this.onHit);
  MeleeAttackHandler parentAttack;
  Function(HealthFunctionality) onHit;
  List<String> hitEnemiesId = [];
  final Vector2 size;
  late PolygonShape shape;
  int hitEnemies = 0;

  @override
  void beginContact(Object other, Contact contact) {
    print('contact');
    if (parentAttack.isDead) {
      return;
    }

    if (other is HealthFunctionality) {
      if (hitEnemiesId.contains(other.entityId)) {
        return;
      }
      if (hitEnemies > parentAttack.parentWeapon.pierce.parameter) {
        parentAttack.kill();
      }
      hitEnemiesId.add(other.entityId);
      other.hitCheck(
          parentAttack.meleeId, parentAttack.parentWeapon.calculateDamage);
      onHitFunctions(other);
      hitEnemies++;
    }

    super.beginContact(other, contact);
  }

  void onHitFunctions(HealthFunctionality other) {
    if (parentAttack.parentWeapon is AttributeWeaponFunctionsFunctionality) {
      final weapon =
          parentAttack.parentWeapon as AttributeWeaponFunctionsFunctionality;
      for (var element in weapon.onHitMelee) {
        element(other);
      }
    }

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
    if (parentAttack.parentWeapon.entityAncestor is Enemy) {
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
      position: parentAttack.activeSwings.last.swingPosition,
      angle: parentAttack.activeSwings.last.swingAngle,
      type: BodyType.kinematic,
    );
    renderBody = true;
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class MeleeAttack extends PositionComponent {
  MeleeAttack(SpriteAnimation? swingAnimation, Vector2 position, this.target,
      this.handler) {
    this.position = position;
    animationComponent = SpriteAnimationComponent(
        animation: swingAnimation,
        anchor: Anchor.topCenter,
        size: swingAnimation!.frames.first.sprite.srcSize
            .scaledToDimension(true, handler.parentWeapon.length));

    animationComponent?.animation = swingAnimation;
    if (handler.parentWeapon.entityAncestor!.flipped) {
      animationComponent?.flipHorizontallyAroundCenter();
    }
  }
  void removeSwing() {
    handler.removeSwing(this);
  }

  SpriteAnimationComponent? animationComponent;

  Entity target;

  void fadeOut() {
    animationComponent?.add(OpacityEffect.fadeOut(EffectController(
      duration: .4,
      curve: Curves.easeOut,
      onMax: () {
        removeSwing();
      },
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
      required this.parentWeapon}) {
    start = parentWeapon.attackHitboxPatterns[index];
    end = parentWeapon.attackHitboxPatterns[index + 1];
    duration = parentWeapon.attackTickRate.parameter;
    meleeId = const Uuid().v4();
  }

  bool isDead = false;

  List<MeleeAttack> activeSwings = [];
  Entity? target;

  late (Vector2, double) start;
  late (Vector2, double) end;

  late double duration;
  late String meleeId;

  int index;
  MeleeFunctionality parentWeapon;
  MeleeDetection? hitbox;
  Vector2 initPosition;
  double initAngle;

  void onHitFunction(HealthFunctionality other) {
    chain(other);
  }

  void chain(HealthFunctionality other) {
    if (parentWeapon.weaponCanChain &&
        hitbox!.hitEnemies < parentWeapon.maxChainingTargets.parameter &&
        !isDead) {
      List<Body> bodies = [
        ...gameRouter.world.bodies.where((element) {
          if (parentWeapon.entityAncestor is Player) {
            return element.userData is Enemy &&
                element.userData != other &&
                !hitbox!.hitEnemiesId
                    .contains((element.userData as Entity).entityId);
          } else {
            return element.userData is Player &&
                element.userData != other &&
                !hitbox!.hitEnemiesId.contains(other.entityId);
          }
        })
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

      initSwing(otherAngle,
          other.center - currentEnviroment!.gameCamera.viewfinder.position);
    }
  }

  void initSwing(double swingAngle, Vector2 swingPosition) {
    SpriteAnimation? spriteAnimation;
    if (parentWeapon.attackHitboxSpriteAnimations.isNotEmpty) {
      spriteAnimation =
          parentWeapon.attackHitboxSpriteAnimations[(index / 2).round()];
      spriteAnimation.stepTime = duration;
    }

    final rotatedStartPosition = rotateVector2(start.$1, swingAngle);
    final rotatedEndPosition = rotateVector2(end.$1, swingAngle);

    final newSwing =
        MeleeAttack(spriteAnimation!, swingPosition, target!, this);
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
    parentWeapon.activeSwings.add(this);
    parentWeapon.spriteVisibilityCheck();
    final hitboxSize = parentWeapon.attackHitboxSizes[(index / 2).round()];
    target = parentWeapon.entityAncestor;
    initSwing(initAngle, initPosition);
    hitbox = MeleeDetection(hitboxSize, this, onHitFunction);
    parentWeapon.entityAncestor?.gameEnviroment.physicsComponent.add(hitbox);

    return super.onLoad();
  }

  void kill() {
    for (var element in activeSwings) {
      element.fadeOut();
    }
    isDead = true;
  }

  void removeSwing([MeleeAttack? attack]) {
    activeSwings.remove(attack);
    if (activeSwings.isEmpty) {
      parentWeapon.activeSwings.remove(this);
      parentWeapon.spriteVisibilityCheck();
      hitbox?.removeFromParent();
    }
  }

  MeleeAttack get currentSwing => activeSwings.last;

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
