import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:runefire/attributes/attributes_perpetrator.dart';
import 'package:runefire/attributes/attributes_status_effect.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/events/event_management.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/constants.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/constants/routes.dart';
import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/extensions.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/main.dart';
import 'package:uuid/uuid.dart';

import 'package:runefire/game/enviroment_mixin.dart';
import 'package:runefire/resources/enums.dart';
// ignore: unused_import
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/entities/entity_mixin.dart';

abstract class Entity extends BodyComponent<GameRouter>
    with
        BaseAttributes,
        ContactCallbacks,
        ElementalPower,
        UpdateFunctionsThenRemove {
  Entity({
    required this.initialPosition,
    required this.eventManagement,
    required this.enviroment,
  }) {
    initializeParameterManagers();
    entityId = const Uuid().v4();
    animationPaused.addListener((parameter) {
      entityAnimationsGroup.animationTicker?.paused = parameter;
    });
  }

  final List<Function(double dt)> onUpdate = [];
  final List<Function(bool isFlipped)> onBodyFlip = [];
  final List<Function(Entity entity, Set<Entity> currentEntities)>
      onBodySensorContact = [];

  final List<Function(Entity entity, Set<Entity> currentEntities)>
      onBodySensorEndContact = [];

  final List<Function(Object object, Set<Object> currentObjects)>
      onObjectSensorContact = [];

  final List<Function(Object object, Set<Object> currentObjects)>
      onObjectSensorEndContact = [];

  bool get isIncapacitated {
    return isDead ||
        isStunned.parameter ||
        statusEffects.contains(StatusEffects.frozen);
  }

  final Map<dynamic, ChildEntity> childrenEntities = {};
  final Set<Entity> closeSensorBodies = {};
  final Set<Object> closeSensorObjects = {};
  final Set<Projectile> closeSensorProjectiles = {};
  final Map<dynamic, SpriteAnimation> entityAnimations = {};
  late final SpriteAnimationGroupComponent entityAnimationsGroup;
  late final String entityId;
  late final EntityVisualEffectsWrapper entityVisualEffectsWrapper;
  final Enviroment enviroment;
  final EventManagement eventManagement;
  final Vector2 initialPosition;
  final List<bool? Function(DamageInstance instance)> onPermanentDeath = [];
  final List<bool? Function(DamageInstance instance)> onPreDeath = [];
  final List<
          Function(Projectile projectile, Set<Projectile> currentProjectiles)>
      onProjectileSensorContact = [];

  final List<
          Function(Projectile projectile, Set<Projectile> currentProjectiles)>
      onProjectileSensorEndContact = [];

  bool collisionOnDeath = false;
  dynamic entityAnimationStatus = EntityStatus.spawn;
  dynamic entityAnimationStatusQueue;
  abstract EntityType entityType;
  bool finalAnimationDone = false;
  bool isFlipped = false;

  BoolParameterManager animationPaused = BoolParameterManager(
    baseParameter: false,
    frequencyDeterminesTruth: false,
  );

  ///Return true if shouldnt die
  final List<bool? Function(DamageInstance instance)> onDeath = [];

  late Vector2 spriteSize = getSpriteSize;
  dynamic statusPrevious;
  bool temporaryAnimationPlaying = false;

  abstract Filter? filter;

  static const dupeStatusCheckerList = [
    EntityStatus.run,
    EntityStatus.walk,
    EntityStatus.idle,
  ];

  double get hitboxRadius => entityAnimationsGroup.size.x / 2.4;

  void applyHeightToSprite() {
    spriteSize = getSpriteSize;
    entityAnimationsGroup.size = spriteSize;
    if (isLoaded) {
      body.fixtures
          .firstWhere(
            (element) => (element.userData! as Map)['type'] == FixtureType.body,
          )
          .shape = CircleShape()..radius = hitboxRadius;
    }
  }

  void flipSprite() {
    entityAnimationsGroup.flipHorizontallyAroundCenter();

    isFlipped = !isFlipped;
    for (final element in onBodyFlip) {
      element.call(isFlipped);
    }
  }

  Iterable<Weapon> getAllWeaponItems(
    bool includeSecondaries,
    bool includeAdditionalPrimaries,
  ) {
    Iterable<Weapon> returnList = [];
    // await loaded;
    if (this is! AttackFunctionality) {
      return returnList;
    }

    final attackFunctionality = this as AttackFunctionality;
    for (final element in attackFunctionality.carriedWeapons) {
      returnList = [...returnList, element];
      if (includeSecondaries) {
        final secondary = element.getSecondaryWeapon;
        if (secondary != null) {
          returnList = [...returnList, secondary];
        }
      }
      if (includeAdditionalPrimaries) {
        for (final element in element.additionalWeapons.entries) {
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

  Future<void> setEntityAnimation(
    dynamic key, {
    bool finalAnimation = false,
  }) async {
    //If the new key is contained in the dupe status checker list, and the current animation is the same as the new key, return
    if ((entityAnimationsGroup.current == key &&
            dupeStatusCheckerList.contains(key)) ||
        animationPaused.parameter ||
        finalAnimationDone) {
      return;
    }
    if (entityAnimationsGroup.animations?.containsKey(key) == false) {
      return;
    }
    final newAnimationIsLoop =
        entityAnimationsGroup.animations?[key]?.loop == true;

    if (!temporaryAnimationPlaying || !newAnimationIsLoop) {
      entityAnimationsGroup.current = key;
    } else {
      entityAnimationStatusQueue = key;
      return;
    }
    if (entityAnimationsGroup.animation?.loop == false) {
      temporaryAnimationPlaying = true;
      entityAnimationsGroup.animationTicker?.reset();
      if (!finalAnimation) {
        entityAnimationsGroup.animationTicker?.onComplete = tickerComplete;
      } else {
        entityAnimationStatusQueue = null;
        finalAnimationDone = true;
      }
    }
    if (temporaryAnimationPlaying) {
      await entityAnimationsGroup.animationTicker?.completed;
    }
  }

  void spriteFlipCheck() {
    final movement = body.linearVelocity.x;
    if ((movement > 0 && !isFlipped) || (movement <= 0 && isFlipped)) {
      flipSprite();
    }
  }

  void tickerComplete() {
    temporaryAnimationPlaying = false;

    setEntityAnimation(
      entityAnimationStatusQueue ?? statusPrevious ?? EntityStatus.idle,
    );

    statusPrevious = null;
    entityAnimationStatusQueue = null;
  }

  @override
  void beginContact(Object other, Contact contact) {
    final otherObject = other is Map ? other['object'] as Object : other;
    if ((contact.fixtureA.userData! as Map)['type'] == FixtureType.sensor ||
        (contact.fixtureB.userData! as Map)['type'] == FixtureType.sensor) {
      if (otherObject is Entity) {
        closeSensorBodies.add(otherObject);
        onBodySensorContact.forEach((element) {
          element.call(otherObject, closeSensorBodies);
        });
      } else if (otherObject is Projectile) {
        closeSensorProjectiles.add(otherObject);
        onProjectileSensorContact.forEach((element) {
          element.call(otherObject, closeSensorProjectiles);
        });
      } else {
        closeSensorObjects.add(otherObject);
        onObjectSensorContact.forEach((element) {
          element.call(otherObject, closeSensorObjects);
        });
      }
    }
    super.beginContact(other, contact);
  }

  @override
  Body createBody() {
    late CircleShape shape;
    shape = CircleShape();
    shape.radius = hitboxRadius;
    renderBody = false;
    final fixtureDef = FixtureDef(
      shape,
      userData: {'type': FixtureType.body, 'object': this},
      density: 0.8,
      filter: filter,
    );
    final closeBodySensor = FixtureDef(
      CircleShape()..radius = closeBodiesSensorRadius,
      userData: {'type': FixtureType.sensor, 'object': this},
      isSensor: true,
      density: .8,
      filter: Filter()
        ..categoryBits = sensorCategory
        ..maskBits = 0xFFFF,
    );

    final bodyDef = BodyDef(
      position: initialPosition,
      userData: this,
      type: BodyType.dynamic,
      allowSleep: false,
      linearDamping: 15,
      fixedRotation: true,
    );

    return world.createBody(bodyDef)
      ..createFixture(fixtureDef)
      ..createFixture(closeBodySensor);
  }

  @override
  void endContact(Object other, Contact contact) {
    final otherObject = other is Map ? other['object'] as Object : other;
    if ((contact.fixtureA.userData! as Map)['type'] == FixtureType.sensor ||
        (contact.fixtureB.userData! as Map)['type'] == FixtureType.sensor) {
      if (otherObject is Entity) {
        closeSensorBodies.remove(otherObject);
        onBodySensorEndContact.forEach((element) {
          element.call(otherObject, closeSensorBodies);
        });
      } else if (otherObject is Projectile) {
        closeSensorProjectiles.remove(otherObject);
        onProjectileSensorEndContact.forEach((element) {
          element.call(otherObject, closeSensorProjectiles);
        });
      } else {
        closeSensorObjects.remove(otherObject);
        onObjectSensorEndContact.forEach((element) {
          element.call(otherObject, closeSensorObjects);
        });
      }
    }
    super.endContact(other, contact);
  }

  @override
  Future<void> onLoad() async {
    entityAnimationsGroup = SpriteAnimationGroupComponent(
      anchor: Anchor.center,
      position: spriteOffset,
      animations: entityAnimations,
    );

    setEntityAnimation(
      entityAnimations.containsKey(EntityStatus.spawn)
          ? EntityStatus.spawn
          : EntityStatus.idle,
    );
    applyHeightToSprite();

    // spriteWrapper = PositionComponent(
    //     size: spriteAnimationComponent.size, anchor: Anchor.center);
    entityAnimationsGroup.flipHorizontallyAroundCenter();
    add(entityAnimationsGroup);
    enviroment.activeEntites.add(this);
    entityVisualEffectsWrapper = EntityVisualEffectsWrapper(entity: this);
    height.addListener((value) {
      applyHeightToSprite();
    });
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
            (contact.fixtureA.userData! as Map)['object'] is Bounds ||
        contact.fixtureB.userData is Map &&
            (contact.fixtureB.userData! as Map)['object'] is Bounds) {
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

extension EntityClassGetterrs on Entity {
  AttributeCallbackFunctionality? get attributeFunctionsFunctionality {
    final thisIsAttr = this is AttributeCallbackFunctionality;

    if (thisIsAttr) {
      return this as AttributeCallbackFunctionality;
    }
    final thisIsChildEntity = this is ChildEntity;

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

  PlayerFunctionality get playerFunctionality =>
      enviroment as PlayerFunctionality;

  double get spriteHeight => spriteSize.y;
  Vector2 get spriteOffset => Vector2.zero();

  void clearStatusEffects() {
    if (isChildEntity) {
      (this as ChildEntity).parentEntity.clearStatusEffects();
      return;
    }
    final thisIsAttr = this is AttributeFunctionality;
    if (thisIsAttr) {
      for (final element in statusEffects) {
        final currentAttributes = this as AttributeFunctionality;
        print(element);
        currentAttributes.removeAttribute(element.getCorrospondingAttribute);
      }
    }
  }

  Set<StatusEffects> get statusEffects {
    if (isChildEntity) {
      return (this as ChildEntity).parentEntity.statusEffects;
    }

    final thisIsAttr = this is AttributeFunctionality;
    if (thisIsAttr) {
      final currentAttributes =
          (this as AttributeFunctionality).currentAttributeTypes;
      final returnSet = currentAttributes
          .where(
            (element) => element.territory == AttributeTerritory.statusEffect,
          )
          .toSet()
          .map(
            (e) => StatusEffects.values
                .firstWhere((element) => e.name == element.name),
          )
          .toSet();

      return returnSet;
    }

    return {};
  }
}
