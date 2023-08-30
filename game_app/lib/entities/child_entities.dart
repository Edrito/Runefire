import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/entities/entity_class.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/functions/functions.dart';

import '../enemies/enemy_mixin.dart';
import '../resources/functions/custom.dart';

///Class of Entity that is attached to the Player or Enemy as a form of
///weapon, armor, or other attribute
///it should not be considered its own entity, rather an extension of
///the parent entity such as a Weapon is held in the hand, this entity
///follows, hovers, or is attached to the parent entity
abstract class ChildEntity extends Entity with UpgradeFunctions {
  ChildEntity({
    required super.initialPosition,
    required super.enviroment,
    required this.parentEntity,
    required int upgradeLevel,
    this.distance = 1,
  }) {
    this.upgradeLevel = upgradeLevel;
    applyUpgrade();
  }

  Entity parentEntity;
  double distance;

  @override
  EntityType entityType = EntityType.child;

  @override
  Filter? filter;

  @override
  void onMount() {
    parentEntity.childrenEntities[entityId] = this;
    super.onMount();
  }

  @override
  void onRemove() {
    parentEntity.childrenEntities.remove(entityId);
    super.onRemove();
  }

  @override
  Body createBody() {
    final bodyDef = BodyDef(
      position: initialPosition,
      userData: this,
      type: BodyType.static,
      isAwake: false,
      allowSleep: true,
      fixedRotation: true,
    );
    return world.createBody(bodyDef);
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    return super.onLoad();
  }

  @override
  int? maxLevel = 5;
}

class TeslaCrystal extends ChildEntity
    with
        AimFunctionality,
        AttackFunctionality,
        DumbShoot,
        AimControlFunctionality {
  TeslaCrystal(
      {required super.initialPosition,
      required super.enviroment,
      super.distance = 2,
      required super.upgradeLevel,
      required super.parentEntity}) {
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_6.png', .3, true);
  }

  // @override
  // double  distance = 5;

  @override
  double get shootInterval => .1;
  @override
  AimPattern aimPattern = AimPattern.closestEnemyToPlayer;
}

class MarkEnemySentry extends ChildEntity {
  MarkEnemySentry(
      {required super.initialPosition,
      required super.enviroment,
      super.distance = 2,
      required super.upgradeLevel,
      required super.parentEntity});

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_6.png', .1, true);

    entityAnimations[EntityStatus.attack] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, false);
  }

  TimerComponent? targetUpdater;
  Entity? target;

  @override
  Future<void> onLoad() {
    targetUpdater = TimerComponent(
      period: shootInterval,
      repeat: true,
      onTick: () {
        findTarget();
        markTarget();
      },
    );
    targetUpdater?.addToParent(this);
    return super.onLoad();
  }

  void findTarget() {
    final bodies = world.bodies.where(
      (element) => element.userData is Entity,
    );

    switch (aimPattern) {
      case AimPattern.randomEnemy:
        final filteredBodies = bodies
            .where((element) =>
                element.userData is Enemy &&
                element.userData is AttributeFunctionality &&
                !(element.userData as HealthFunctionality).isMarked.parameter)
            .toList();
        if (filteredBodies.isNotEmpty) {
          target = filteredBodies.getRandomElement<Body>().userData as Enemy;
        }
        break;
      default:
    }
  }

  void markTarget() {
    if (target == null) return;
    final attr = target as AttributeFunctionality;
    setEntityStatus(EntityStatus.attack);

    attr.addAttribute(AttributeType.marked,
        perpetratorEntity: parentEntity,
        isTemporary: true,
        duration: markerDuration);
  }

  // @override
  // double  distance = 5;

  double shootInterval = 8;
  double markerDuration = 4;

  AimPattern aimPattern = AimPattern.randomEnemy;
}
