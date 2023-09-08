import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:game_app/attributes/attributes_mixin.dart';
import 'package:game_app/attributes/attributes_structure.dart';
import 'package:game_app/enemies/enemy.dart';
import 'package:game_app/entities/entity_class.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/game/proximity_item.dart';
import 'package:game_app/player/player.dart';
import 'package:game_app/resources/constants/physics_filter.dart';
import 'package:game_app/resources/enums.dart';
import 'package:game_app/resources/functions/functions.dart';
import 'package:game_app/weapons/projectile_class.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

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
      linearDamping: 2,
      allowSleep: true,
      fixedRotation: true,
    );
    return world.createBody(bodyDef);
  }

  bool locked = true;

  void setTransform(Vector2 position, double angle) {
    bool hasMoveVelocities = this is MovementFunctionality
        ? (this as MovementFunctionality).hasMoveVelocities
        : false;
    locked = locked && !hasMoveVelocities;
    if ((body.bodyType == BodyType.static ||
                position.distanceTo(center) < .25) &&
            !hasMoveVelocities ||
        locked) {
      body.setTransform(position, angle);
      locked = true;
      return;
    }

    if (hasMoveVelocities) {
      return;
    } else {
      body.applyForce((position - center).normalized() *
          (position.distanceTo(center).clamp(3, 10) / 2) *
          (this is MovementFunctionality
              ? (this as MovementFunctionality).speed.parameter
              : 1));
    }
  }

  @override
  Future<void> onLoad() async {
    await loadAnimationSprites();
    return super.onLoad();
  }

  @override
  int? maxLevel = 5;
}

abstract class MovingSentry extends ChildEntity with MovementFunctionality {
  MovingSentry(
      {required super.initialPosition,
      required super.enviroment,
      super.distance = 2,
      required super.upgradeLevel,
      required super.parentEntity});

  abstract Body? target;

  abstract int maskBits;

  @override
  Body createBody() {
    final fixture = FixtureDef(CircleShape()..radius = height.parameter / 2,
        filter: Filter()
          ..maskBits = maskBits
          ..categoryBits = isPlayer ? playerCategory : enemyCategory,
        isSensor: true,
        density: 0.005);
    renderBody = false;
    return super.createBody()
      ..createFixture(fixture)
      ..setType(BodyType.dynamic);
  }

  void setTargetMovement() {
    if (target == null) {
      moveVelocities.remove(InputType.ai);
    } else {
      moveVelocities[InputType.ai] =
          (target!.position - body.position).normalized();
    }
  }

  @override
  Future<void> onLoad() {
    moveDeltaUpdater = TimerComponent(
      period: moveUpdateInterval,
      repeat: true,
      onTick: () {
        setTargetMovement();
      },
    );
    moveDeltaUpdater?.addToParent(this);
    return super.onLoad();
  }

  double moveUpdateInterval = .1;
  TimerComponent? moveDeltaUpdater;

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }
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
                (isPlayer
                    ? element.userData is Enemy
                    : element.userData is Player) &&
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

class RangedAttackSentry extends ChildEntity
    with
        AimFunctionality,
        AttackFunctionality,
        DumbShoot,
        AimControlFunctionality {
  RangedAttackSentry(
      {required super.initialPosition,
      required super.enviroment,
      super.distance = 2,
      required this.damageType,
      required super.upgradeLevel,
      required super.parentEntity}) {
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  DamageType damageType;

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_6.png', .3, true);

    entityAnimations[EntityStatus.attack] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, false);
  }

  // @override
  // double  distance = 5;

  @override
  double get shootInterval => 2;
  @override
  AimPattern aimPattern = AimPattern.closestEnemyToPlayer;
}

class GrabItemsSentry extends MovingSentry with ContactCallbacks {
  GrabItemsSentry(
      {required super.initialPosition,
      required super.enviroment,
      super.distance = 2,
      required super.upgradeLevel,
      required super.parentEntity});

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_6.png', .3, true);

    entityAnimations[EntityStatus.run] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, true);
  }

  TimerComponent? targetUpdater;
  double fetchInterval = 3;

  @override
  Body? target;

  @override
  Future<void> onLoad() {
    targetUpdater = TimerComponent(
      period: fetchInterval,
      repeat: true,
      onTick: () {
        findTarget();
      },
    );
    targetUpdater?.addToParent(this);
    return super.onLoad();
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is ProximityItem) {
      other.setTarget = parentEntity;
      target = null;
    }
    super.beginContact(other, contact);
  }

  void findTarget() {
    final bodies = world.bodies
        .where(
          (element) =>
              element.userData is ProximityItem &&
              element.worldCenter.distanceTo(parentEntity.center) < 10,
        )
        .toList();

    // final filteredBodies = bodies
    //     .where((element) =>
    //         element.userData is Enemy &&
    //         element.userData is AttributeFunctionality &&
    //         !(element.userData as HealthFunctionality).isMarked.parameter)
    //     .toList();
    if (bodies.isNotEmpty) {
      target = bodies.getRandomElement<Body>();
    } else {
      target = null;
    }
  }

  @override
  void update(double dt) {
    setTargetMovement();
    moveCharacter();
    super.update(dt);
  }

  // @override
  // double  distance = 5;

  @override
  int maskBits = proximityCategory;
}

class ElementalAttackSentry extends MovingSentry
    with ContactCallbacks, TouchDamageFunctionality {
  ElementalAttackSentry(
      {required super.initialPosition,
      required super.enviroment,
      super.distance = 2,
      required this.damageType,
      required super.upgradeLevel,
      required super.parentEntity}) {
    touchDamage.damageBase[damageType] ??= (1, 4);
  }

  DamageType damageType;

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_6.png', .3, true);

    entityAnimations[EntityStatus.run] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, true);
  }

  // @override
  // double  distance = 5;

  TimerComponent? targetUpdater;
  double fetchInterval = 3;
  bool shouldFetchNewTarget = true;

  @override
  Body? target;

  @override
  Future<void> onLoad() {
    targetUpdater = TimerComponent(
      period: fetchInterval,
      repeat: true,
      onTick: () {
        findTarget();
      },
    );
    targetUpdater?.addToParent(this);

    return super.onLoad();
  }

  @override
  void damageOther(Body other) {
    shouldFetchNewTarget = true;
    super.damageOther(other);
  }

  void deadCheck() {
    if (target != null && (target!.userData as Entity).isDead) {
      shouldFetchNewTarget = true;
    }
  }

  void findTarget() {
    deadCheck();
    if (!shouldFetchNewTarget) return;
    final bodies = world.bodies.where(
      (element) => element.userData is Entity,
    );

    final filteredBodies = bodies
        .where((element) =>
            (isPlayer
                ? element.userData is Enemy
                : element.userData is Player) &&
            target != element &&
            element.userData is HealthFunctionality &&
            element.worldCenter.distanceTo(parentEntity.center) < 10)
        .toList();

    if (filteredBodies.isNotEmpty) {
      target = filteredBodies.getRandomElement<Body>();

      shouldFetchNewTarget = false;
    } else {
      // if ((target?.userData as Entity).isDead) {
      target = null;
      // }
    }
  }

  @override
  int get maskBits => isPlayer ? enemyCategory : playerCategory;

  @override
  set maskBits(int maskBits) {}
}

class ElementalCaptureBulletSentry extends ChildEntity
    with
        ContactCallbacks,
        AimFunctionality,
        AttackFunctionality,
        AimControlFunctionality {
  ElementalCaptureBulletSentry(
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

    entityAnimations["absorb_projectile"] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_6.png', .05, false);

    entityAnimations[EntityStatus.attack] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, false);
  }

  // @override
  // double  distance = 5;

  TimerComponent? bulletFireCooldownTimer;
  TimerComponent? bulletFireDelayTimer;
  bool get isCoolingDown => bulletFireCooldownTimer != null;
  double bulletFireCooldown = 5;
  double bulletFireDelayCooldown = .5;

  Projectile? capturedBullet;

  @override
  Future<void> onLoad() {
    parentEntity.attributeFunctionsFunctionality?.onHitByProjectile
        .add(captureBulletAttempt);
    return super.onLoad();
  }

  @override
  void onRemove() {
    parentEntity.attributeFunctionsFunctionality?.onHitByProjectile
        .remove(captureBulletAttempt);
    super.onRemove();
  }

  bool captureBulletAttempt(DamageInstance damage) {
    if (capturedBullet != null ||
        isCoolingDown ||
        damage.sourceAttack is! Projectile) return false;

    var projectile = damage.sourceAttack as Projectile;

    if (!projectile.isMounted || projectile.isRemoved || projectile.isDead) {
      return false;
    }

    setEntityStatus(EntityStatus.custom,
        customAnimationKey: "absorb_projectile");

    projectile.killBullet(false);

    capturedBullet = damage.sourceAttack;

    target = damage.source.body;

    bulletFireDelayTimer = TimerComponent(
      period: bulletFireDelayCooldown,
      removeOnFinish: true,
      repeat: false,
      onTick: () {
        bulletFireDelayTimer = null;
        capturedBullet = null;
        target = null;
        currentWeapon?.standardAttack();
        setEntityStatus(EntityStatus.attack);
        addCooldown();
      },
    )..addToParent(this);

    return true;
  }

  void addCooldown() {
    bulletFireCooldownTimer = TimerComponent(
      period: bulletFireCooldown,
      removeOnFinish: true,
      onTick: () {
        bulletFireCooldownTimer = null;
      },
    );
    bulletFireCooldownTimer?.addToParent(this);
  }

  @override
  AimPattern aimPattern = AimPattern.target;
}

class MirrorOrbSentry extends ChildEntity
    with ContactCallbacks, AimFunctionality, AttackFunctionality {
  MirrorOrbSentry(
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

    entityAnimations[EntityStatus.attack] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, false);
  }

  void mirrorAttack() {
    if (parentEntity is! AttackFunctionality || currentWeapon == null) return;
    final parentAttackFunctionality = parentEntity as AttackFunctionality;
    final parentWeapon = parentAttackFunctionality.currentWeapon;

    // currentWeapon!.sourceAttackLocation = SourceAttackLocation.customOffset;
    // currentWeapon!.customOffset = center - parentAttackFunctionality.center;

    if (parentWeapon is MeleeFunctionality &&
        currentWeapon is MeleeFunctionality) {
      final melee = currentWeapon as MeleeFunctionality;
      melee.currentAttackIndex = parentWeapon.currentAttackIndex - 1;
      // print(parentWeapon.currentAttackIndex);
      // print(melee.currentAttackIndex);
    }

    double holdPercent = 1;
    if (currentWeapon! is SemiAutomatic) {
      holdPercent = (currentWeapon! as SemiAutomatic).holdDurationPercent;
    }
    isFlipped = parentAttackFunctionality.isFlipped;
    currentWeapon!.standardAttack(holdPercent);

    setEntityStatus(EntityStatus.attack);
  }

  void buildSentryWeapon(Weapon? previous, Weapon newWeapon) async {
    if (previous is AttributeWeaponFunctionsFunctionality) {
      previous.onAttack.remove(mirrorAttack);
    }
    if (newWeapon is AttributeWeaponFunctionsFunctionality) {
      newWeapon.onAttack.add(mirrorAttack);
    }

    final tempWeapon =
        newWeapon.weaponType.build(this, null, game, newWeapon.upgradeLevel);
    tempWeapon.weaponSize = tempWeapon.weaponSize / 2;
    tempWeapon.tipOffset = tempWeapon.tipOffset / 2;
    tempWeapon.weaponAttachmentPoints.forEach((key, value) {
      value.weaponSpriteAnimation?.flashSize =
          value.weaponSpriteAnimation!.flashSize / 2;
    });

    carriedWeapons[0] = tempWeapon;
    await setWeapon(tempWeapon);

    //  currentWeapon?.addToParent(this);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (parentEntity is AttackFunctionality) {
      final att = (parentEntity as AttackFunctionality);
      att.onWeaponSwap.add(buildSentryWeapon);
      final parentWeapon = att.currentWeapon;
      if (parentWeapon != null) {
        buildSentryWeapon(null, parentWeapon);
      }
    }

    if (parentEntity is AimFunctionality) {
      inputAimAngles = (parentEntity as AimFunctionality).inputAimAngles;
      inputAimPositions = (parentEntity as AimFunctionality).inputAimPositions;
    }
  }

  @override
  void onRemove() {
    if (parentEntity is AttackFunctionality) {
      (parentEntity as AttackFunctionality)
          .onWeaponSwap
          .remove(buildSentryWeapon);
    }
    super.onRemove();
  }

  @override
  void update(double dt) {
    //
    aimCharacter();
    super.update(dt);
  }
}

class ShieldSentry extends ChildEntity
    with ContactCallbacks, HealthFunctionality {
  ShieldSentry(
      {required super.initialPosition,
      required super.enviroment,
      super.distance = 2,
      required super.upgradeLevel,
      required super.parentEntity}) {
    height.baseParameter = 3;
    invincible.baseParameter = true;
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_6.png', .3, true);

    entityAnimations[EntityStatus.attack] = await loadSpriteAnimation(
        6, 'attribute_sprites/hovering_crystal_attack_6.png', .05, false);
  }

  @override
  createBody() {
    final fixture = FixtureDef(CircleShape()..radius = height.parameter / 3,
        filter: Filter()
          ..maskBits =
              attackCategory + (!isPlayer ? playerCategory : enemyCategory)
          ..categoryBits = isPlayer ? playerCategory : enemyCategory,
        userData: {'type': FixtureType.body, 'object': this},
        isSensor: false,
        density: 0.005);
    renderBody = false;
    return super.createBody()
      ..createFixture(fixture)
      ..setType(BodyType.static);
  }

  @override
  beginContact(Object other, Contact contact) {
    if (other is Projectile) {
      other.killBullet(false);
    } else if (other is MeleeAttackHandler) {
      other.kill();
    }
  }
}
