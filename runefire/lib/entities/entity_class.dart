import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_status_effect.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/child_entities.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/constants/routes.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/main.dart';
import 'package:uuid/uuid.dart';

import '../game/enviroment_mixin.dart';
import '../resources/enums.dart';
// ignore: unused_import
import '../resources/constants/priorities.dart';
import '../attributes/attributes_mixin.dart';
import 'entity_mixin.dart';

abstract class Entity extends BodyComponent<GameRouter>
    with BaseAttributes, ContactCallbacks {
  static const dupeStatusCheckerList = [
    EntityStatus.run,
    EntityStatus.walk,
    EntityStatus.idle
  ];

  Entity(
      {required this.initialPosition,
      required this.eventManagement,
      required this.enviroment}) {
    initializeParameterManagers();
    entityId = const Uuid().v4();
  }

  List<Function(bool isFlipped)> onBodyFlip = [];
  //POSITIONING

  Map<dynamic, ChildEntity> childrenEntities = {};
  Set<Projectile> closeProjectiles = {};
  Set<Entity> closeSensorBodies = {};
  bool collisionOnDeath = false;
  int currentHitAnimations = 0;
  Map<dynamic, SpriteAnimation> entityAnimations = {};
  late SpriteAnimationGroupComponent entityAnimationsGroup;
  late String entityId;
  dynamic entityStatus = EntityStatus.spawn;
  late EntityStatusEffectsWrapper entityStatusWrapper;
  abstract EntityType entityType;
  Enviroment enviroment;
  EventManagement eventManagement;
  //STATUS
  Vector2 initialPosition;

  // late PositionComponent spriteWrapper;
  // late Shadow3DDecorator shadow3DDecorator;

  bool isFlipped = false;

  late Vector2 spriteSize = getSpriteSize;
  dynamic statusPrevious;
  dynamic statusQueue;
  bool temporaryAnimationPlaying = false;

  abstract Filter? filter;

  AttributeFunctionsFunctionality? get attributeFunctionsFunctionality {
    bool thisIsAttr = this is AttributeFunctionsFunctionality;

    if (thisIsAttr) {
      return this as AttributeFunctionsFunctionality;
    }
    bool thisIsChildEntity = this is ChildEntity;

    if (thisIsChildEntity) {
      return (this as ChildEntity).parentEntity.attributeFunctionsFunctionality;
    }
    return null;
  }

  Vector2 get entityOffsetFromCameraCenter =>
      center - enviroment.gameCamera.viewfinder.position;

  double get entityStatusHeight => (spriteHeight / 2) + (spriteHeight / 4);
  GameEnviroment get gameEnviroment => enviroment as GameEnviroment;
  Vector2 get getSpriteSize => (entityAnimations[EntityStatus.idle]
          ?.frames
          .first
          .sprite
          .srcSize
          .clone() ??
      Vector2.all(1))
    ..scaledToHeight(this);

  bool get isPlayer =>
      EntityType.player == entityType ||
      (isChildEntity && (this as ChildEntity).parentEntity.isPlayer);

  bool get isStunned {
    if (isChildEntity) {
      return (this as ChildEntity).parentEntity.isStunned;
    }
    return statusEffects.contains(StatusEffects.stun);
  }

  PlayerFunctionality get playerFunctionality =>
      enviroment as PlayerFunctionality;

  double get spriteHeight => spriteSize.y;
  Vector2 get spriteOffset => Vector2.zero();
  Set<StatusEffects> get statusEffects {
    if (isChildEntity) {
      return (this as ChildEntity).parentEntity.statusEffects;
    }

    bool thisIsAttr = this is AttributeFunctionality;
    if (thisIsAttr) {
      return (this as AttributeFunctionality)
          .currentAttributes
          .values
          .whereType<StatusEffectAttribute>()
          .map((e) => e.statusEffect)
          .toSet();
    }

    return {};
  }

  Future<void> applyGroundAnimation(
      SpriteAnimation animation, bool followEntity, double yOffset,
      [bool moveDirection = false]) async {
    final size = animation.frames.first.sprite.srcSize;

    size.scaledToHeight(this);

    final sprite = SpriteAnimationComponent(
        anchor: Anchor.center, size: size, animation: animation);
    if ((!(isFlipped) && !moveDirection) ||
        (moveDirection && body.linearVelocity.x < 0)) {
      sprite.flipHorizontallyAroundCenter();
    }
    if (followEntity) {
      sprite.position = Vector2(0, yOffset);
    } else {
      enviroment.add(sprite);

      sprite.position = Vector2(center.x, center.y + yOffset);
    }
    sprite.animationTicker?.completed
        .then((value) => sprite.removeFromParent());
  }

  void applyHeightToSprite() {
    spriteSize = getSpriteSize;
    entityAnimationsGroup.size = spriteSize;
    if (isLoaded) {
      body.fixtures
          .firstWhere((element) =>
              (element.userData! as Map)['type'] == FixtureType.body)
          .shape = CircleShape()..radius = entityAnimationsGroup.size.x / 2.4;
    }
  }

  Future<void> applyHitAnimation(
      SpriteAnimation animation, Vector2 sourcePosition,
      [Color? color]) async {
    if (animation.loop || currentHitAnimations > hitAnimationLimit) return;
    currentHitAnimations++;
    final hitSize = animation.frames.first.sprite.srcSize;
    hitSize.scaledToHeight(this);
    final thisHeight = spriteHeight;
    final sprite = SpriteAnimationComponent(
        anchor: Anchor.center, size: hitSize, animation: animation);
    if (color != null) {
      sprite.paint = colorPalette.buildProjectile(
          color: color,
          projectileType: ProjectileType.paintBullet,
          lighten: false);
    }
    sprite.position = Vector2(
        (rng.nextDouble() * thisHeight / 3) - thisHeight / 6,
        ((sourcePosition - center).y).clamp(thisHeight * -.5, thisHeight * .5));

    add(sprite);
    sprite.animationTicker?.completed.then((value) {
      sprite.removeFromParent();

      currentHitAnimations--;
    });
  }

  void attackStatus() {
    // applyTempAnimation();
  }

  void customStatus() {
    // applyTempAnimation(customAnimation);
  }

  bool damageStatus() {
    return true;
  }

  bool dashStatus() {
    return true;
  }

  bool deadStatus(DamageInstance instance) {
    return true;
  }

  bool dodgeStatus() {
    return true;
  }

  void flipSprite() {
    entityAnimationsGroup.flipHorizontallyAroundCenter();

    isFlipped = !isFlipped;
    for (var element in onBodyFlip) {
      element.call(isFlipped);
    }
  }

  Iterable<Weapon> getAllWeaponItems(
      bool includeSecondaries, bool includeAdditionalPrimaries) {
    Iterable<Weapon> returnList = [];
    // await loaded;
    if (this is! AttackFunctionality) return returnList;

    final attackFunctionality = this as AttackFunctionality;
    for (var element in attackFunctionality.carriedWeapons.values) {
      returnList = [...returnList, element];
      if (includeSecondaries) {
        final secondary = element.getSecondaryWeapon;
        if (secondary != null) {
          returnList = [...returnList, secondary];
        }
      }
      if (includeAdditionalPrimaries) {
        for (var element in element.additionalWeapons.entries) {
          returnList = [...returnList, element.value];
        }
      }
    }
    return returnList;
  }

  bool jumpStatus() {
    return true;
  }

  Future<void> loadAnimationSprites();

  void permanentlyDisableEntity() {}

  Future<void> setEntityStatus(EntityStatus newEntityStatus,
      {dynamic customAnimationKey,
      bool playAnimation = true,
      DamageInstance? instance}) async {
    if (entityStatus == EntityStatus.dead) return;

    if (newEntityStatus == entityStatus &&
        entityAnimationsGroup.current == newEntityStatus &&
        dupeStatusCheckerList.contains(newEntityStatus)) return;

    bool statusResult = true;
    switch (newEntityStatus) {
      case EntityStatus.spawn:
        spawnStatus();
        break;
      case EntityStatus.attack:
        attackStatus();
        break;
      case EntityStatus.jump:
        statusResult = jumpStatus();
        break;
      case EntityStatus.dash:
        statusResult = dashStatus();
        break;

      case EntityStatus.dead:
        if (instance != null) {
          statusResult = deadStatus(instance);
        }
        break;
      case EntityStatus.custom:
        customStatus();
        break;
      case EntityStatus.damage:
        statusResult = damageStatus();

        break;
      case EntityStatus.dodge:
        statusResult = dodgeStatus();
        break;
      default:
    }

    if (!statusResult) return;

    ///If a temporary animation is playing, queue the animation
    if (temporaryAnimationPlaying && newEntityStatus != EntityStatus.dead) {
      statusQueue = customAnimationKey ?? newEntityStatus;
    } else {
      entityStatus = customAnimationKey ?? newEntityStatus;

      if (entityAnimationsGroup.animations!.containsKey(entityStatus)) {
        entityAnimationsGroup.current = entityStatus;
      } else {
        tickerComplete();
      }

      entityAnimationsGroup.animationTicker?.reset();

      if (!(entityAnimationsGroup.animation?.loop ?? true) &&
          newEntityStatus != EntityStatus.dead) {
        temporaryAnimationPlaying = true;

        entityAnimationsGroup.animationTicker?.onComplete = () {
          entityAnimationsGroup.animationTicker?.reset();
          tickerComplete();
        };
      }
    }

    if (temporaryAnimationPlaying) {
      await entityAnimationsGroup.animationTicker?.completed;
    }
  }

  void spawnStatus() {
    // applyTempAnimation(entityAnimations[EntityStatus.spawn]);
    statusQueue = EntityStatus.idle;
  }

  void spriteFlipCheck() {
    final movement = body.linearVelocity.x;
    if ((movement > 0 && !isFlipped) || (movement <= 0 && isFlipped)) {
      flipSprite();
    }
  }

  void tickerComplete() {
    temporaryAnimationPlaying = false;
    entityStatus = statusQueue ?? statusPrevious ?? EntityStatus.idle;
    entityAnimationsGroup.current = entityStatus;

    statusPrevious = null;
    statusQueue = null;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Entity) {
      if ((contact.fixtureA.userData as Map)['type'] == FixtureType.sensor ||
          (contact.fixtureB.userData as Map)['type'] == FixtureType.sensor) {
        closeSensorBodies.add(other);
      }
    } else if (other is Projectile) {
      if ((contact.fixtureA.userData as Map)['type'] == FixtureType.sensor ||
          (contact.fixtureB.userData as Map)['type'] == FixtureType.sensor) {
        closeProjectiles.add(other);
      }
    }
    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    //     final verts = <Vector2>[
    //   Vector2(-(entityAnimationsGroup.size.x / 2) + padding,
    //       -entityAnimationsGroup.size.y + (padding * 2)),
    //   Vector2((entityAnimationsGroup.size.x / 2) - padding,
    //       -entityAnimationsGroup.size.y + (padding * 2)),
    //   Vector2((entityAnimationsGroup.size.x / 2) - padding,
    //       entityAnimationsGroup.size.y - (padding * 2)),
    //   Vector2(-(entityAnimationsGroup.size.x / 2) + padding,
    //       entityAnimationsGroup.size.y - (padding * 2)),
    // ];
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = entityAnimationsGroup.size.x / 2.4;
    renderBody = false;
    final fixtureDef = FixtureDef(shape,
        userData: {"type": FixtureType.body, "object": this},
        restitution: 0,
        friction: 0,
        density: 0,
        filter: filter);
    final closeBodySensor =
        FixtureDef(CircleShape()..radius = closeBodiesSensorRadius,
            userData: {"type": FixtureType.sensor, "object": this},
            restitution: 0,
            friction: 0,
            isSensor: true,
            density: .8,
            filter: Filter()
              ..categoryBits = sensorCategory
              ..maskBits =
                  // enemyCategory + playerCategory +
                  projectileCategory);

    final bodyDef = BodyDef(
      position: initialPosition,
      userData: this,
      type: BodyType.dynamic,
      allowSleep: false,
      active: true,
      linearDamping: 15,
      fixedRotation: true,
    );

    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..createFixture(closeBodySensor);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Entity) {
      if ((contact.fixtureA.userData as Map)['type'] == FixtureType.sensor ||
          (contact.fixtureB.userData as Map)['type'] == FixtureType.sensor) {
        closeSensorBodies.remove(other);
      }
    } else if (other is Projectile) {
      if ((contact.fixtureA.userData as Map)['type'] == FixtureType.sensor ||
          (contact.fixtureB.userData as Map)['type'] == FixtureType.sensor) {
        closeProjectiles.remove(other);
      }
    }

    super.endContact(other, contact);
  }

  @override
  Future<void> onLoad() async {
    entityAnimationsGroup = SpriteAnimationGroupComponent(
        anchor: Anchor.center,
        position: spriteOffset,
        animations: entityAnimations);

    setEntityStatus(EntityStatus.spawn);
    applyHeightToSprite();

    // spriteWrapper = PositionComponent(
    //     size: spriteAnimationComponent.size, anchor: Anchor.center);
    entityAnimationsGroup.flipHorizontallyAroundCenter();
    add(entityAnimationsGroup);
    enviroment.activeEntites.add(this);
    entityStatusWrapper = EntityStatusEffectsWrapper(entity: this);

    return super.onLoad();
  }

  @override
  void onRemove() {
    enviroment.activeEntites.remove(this);
    if (!game.router.currentRoute.maintainState) {
      super.onRemove();
    }
  }

  @override
  void preSolve(Object other, Contact contact, Manifold oldManifold) {
    if (other is Bounds ||
        other is Map && other['object'] is Bounds ||
        contact.fixtureA.userData is Map &&
            (contact.fixtureA.userData as Map)['object'] is Bounds ||
        contact.fixtureB.userData is Map &&
            (contact.fixtureB.userData as Map)['object'] is Bounds) {
      contact.setEnabled(true);
      return super.preSolve(other, contact, oldManifold);
    }

    if (isDead) {
      contact.setEnabled(collisionOnDeath);
      return super.preSolve(other, contact, oldManifold);
    }
    if (!collision.parameter || isDashing) {
      contact.setEnabled(false);
      return super.preSolve(other, contact, oldManifold);
    }

    super.preSolve(other, contact, oldManifold);
  }
}
