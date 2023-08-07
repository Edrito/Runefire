import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/entities/entity_class.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/functions/functions.dart';

import '../enemies/enemy_mixin.dart';
import '../resources/functions/custom_mixins.dart';

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
