import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:runefire/attributes/attributes_mixin.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/entity_mixin.dart';
import 'package:runefire/entities/input_priorities.dart';
import 'package:runefire/enviroment_interactables/proximity_item.dart';
import 'package:runefire/main.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/resources/constants/physics_filter.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/melee_swing_manager.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/enemies/enemy_mixin.dart';
import 'package:runefire/resources/functions/custom.dart';

///Class of Entity that is attached to the Player or Enemy as a form of
///weapon, armor, or other attribute
///it should not be considered its own entity, rather an extension of
///the parent entity such as a Weapon is held in the hand, this entity
///follows, hovers, or is attached to the parent entity
abstract class ChildEntity extends Entity with UpgradeFunctions {
  ChildEntity({
    required super.initialPosition,
    required this.parentEntity,
    required int upgradeLevel,
  }) : super(
          eventManagement: parentEntity.eventManagement,
          enviroment: parentEntity.enviroment,
        ) {
    this.upgradeLevel = upgradeLevel;
    applyUpgrade();
  }

  Entity parentEntity;

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
      isAwake: false,
      linearDamping: 2,
      fixedRotation: true,
    );
    return world.createBody(bodyDef);
  }

  bool locked = true;

  void setTransform(Vector2 position, double angle) {
    final hasMoveVelocities = this is MovementFunctionality
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
      body.applyForce(
        (position - center).normalized() *
            (position.distanceTo(center).clamp(3, 10) / 2) *
            (this is MovementFunctionality
                ? (this as MovementFunctionality).speed.parameter
                : 1),
      );
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

abstract class AttachedToBodyChildEntity extends ChildEntity {
  AttachedToBodyChildEntity({
    required super.initialPosition,
    required super.parentEntity,
    required super.upgradeLevel,
    this.distance = 1,
    this.rotationSpeed = 1,
  });

  double rotationSpeed;
  double distance;
}

class SummonedSwordEntityTest extends SummonedChildEntity {
  SummonedSwordEntityTest({
    required super.initialPosition,
    required super.parentEntity,
    required super.upgradeLevel,
    super.onHitOtherEntity,
    super.damageBase,
  });
  @override
  AimPattern get aimPattern => AimPattern.mouse;
}

class SummonedChildEntity extends ChildEntity
    with MovementFunctionality, TouchDamageFunctionality, SimpleFollowAI {
  SummonedChildEntity({
    required super.initialPosition,
    required super.parentEntity,
    required super.upgradeLevel,
    List<Function(Entity other)>? onHitOtherEntity,
    Map<DamageType, (double, double)>? damageBase,
  }) {
    if (onHitOtherEntity != null) {
      onTouchTick.addAll(onHitOtherEntity);
    }
    onTouchTick = onHitOtherEntity ?? [];
    touchDamage.damageBase = damageBase ?? {};

    speed.baseParameter = 15;
  }

  @override
  Body createBody() {
    final fixture = FixtureDef(
      CircleShape()..radius = spriteHeight / 2,
      filter: Filter()
        ..maskBits = !isPlayer ? playerCategory : enemyCategory
        ..categoryBits = isPlayer ? playerCategory : enemyCategory,
      isSensor: true,
      userData: {'type': FixtureType.body, 'object': this},
      density: .8,
    );
    renderBody = false;
    return super.createBody()
      ..createFixture(fixture)
      ..setType(BodyType.dynamic)
      ..linearDamping = 12;
  }

  @override
  void update(double dt) {
    moveCharacter();
    super.update(dt);
  }

  @override
  AimPattern aimPattern = AimPattern.randomEnemy;

  @override
  late final List<Function(Entity other)> onTouchTick;

  @override
  Future<void> onLoad() {
    onTouchTick.length = 0;
    return super.onLoad();
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.energyElementalIdle1;
    entityAnimations[EntityStatus.run] =
        await spriteAnimations.energyElementalRun1;
  }
}

abstract class MovingSentry extends AttachedToBodyChildEntity
    with MovementFunctionality {
  MovingSentry({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  });

  abstract Body? target;

  abstract int maskBits;

  @override
  Body createBody() {
    final fixture = FixtureDef(
      CircleShape()..radius = spriteHeight / 2,
      filter: Filter()
        ..maskBits = maskBits
        ..categoryBits = isPlayer ? playerCategory : enemyCategory,
      isSensor: true,
      userData: {'type': FixtureType.body, 'object': this},
      density: .95,
    );
    renderBody = false;
    return super.createBody()
      ..createFixture(fixture)
      ..setType(BodyType.dynamic);
  }

  void setTargetMovement() {
    if (target == null) {
      removeMoveVelocity(aiInputPriority);
    } else {
      addMoveVelocity(target!.position - body.position, aiInputPriority);
    }
  }

  @override
  Future<void> onLoad() {
    moveDeltaUpdater = TimerComponent(
      period: moveUpdateInterval,
      repeat: true,
      onTick: setTargetMovement,
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

class TeslaCrystal extends AttachedToBodyChildEntity
    with
        AimFunctionality,
        AttackFunctionality,
        SimpleShoot,
        AimControlFunctionality {
  TeslaCrystal({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  }) {
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.energyElementalIdle1;

    entityAnimations[EntityStatus.attack] =
        await spriteAnimations.hoveringCrystalAttack1;
  }

  // @override
  // double  distance = 5;

  @override
  double get shootInterval => .1;
  @override
  AimPattern aimPattern = AimPattern.closestEnemyToPlayer;
}

class MarkEnemySentry extends AttachedToBodyChildEntity {
  MarkEnemySentry({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  });

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.hoveringCrystalIdle1;

    entityAnimations[EntityStatus.run] =
        await spriteAnimations.hoveringCrystalAttack1;
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
    final bodies = world.physicsWorld.bodies.where(
      (element) => element.userData is Entity,
    );

    switch (aimPattern) {
      case AimPattern.randomEnemy:
        final filteredBodies = bodies
            .where(
              (element) =>
                  (isPlayer
                      ? element.userData is Enemy
                      : element.userData is AttributeFunctionality) &&
                  element.userData is AttributeFunctionality &&
                  !(element.userData! as HealthFunctionality)
                      .isMarked
                      .parameter,
            )
            .toList();
        if (filteredBodies.isNotEmpty) {
          target = filteredBodies.random().userData! as Enemy;
        }
        break;
      default:
    }
  }

  void markTarget() {
    if (target == null) {
      return;
    }
    final attr = target! as AttributeFunctionality;
    setEntityAnimation(EntityStatus.attack);

    attr.addAttribute(
      AttributeType.marked,
      perpetratorEntity: parentEntity,
      isTemporary: true,
      duration: markerDuration,
    );
  }

  // @override
  // double  distance = 5;

  double shootInterval = 8;
  double markerDuration = 4;

  AimPattern aimPattern = AimPattern.randomEnemy;
}

class RangedAttackSentry extends AttachedToBodyChildEntity
    with
        AimFunctionality,
        AttackFunctionality,
        SimpleShoot,
        AimControlFunctionality {
  RangedAttackSentry({
    required super.initialPosition,
    required this.damageType,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  }) {
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final previousDamageEntry =
        currentWeapon?.baseDamage.damageBase.entries.firstOrNull;
    currentWeapon?.baseDamage.damageBase.clear();
    if (previousDamageEntry != null) {
      currentWeapon?.baseDamage.damageBase[damageType] =
          previousDamageEntry.value;
    } else {
      currentWeapon?.baseDamage.damageBase[damageType] = (1, 4);
    }
  }

  DamageType damageType;

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.hoveringCrystalIdle1;

    entityAnimations[EntityStatus.run] =
        await spriteAnimations.hoveringCrystalAttack1;
  }

  // @override
  // double  distance = 5;

  @override
  double get shootInterval => 2;
  @override
  AimPattern aimPattern = AimPattern.closestEnemyToPlayer;
}

class GrabItemsSentry extends MovingSentry with ContactCallbacks {
  GrabItemsSentry({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  });

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.hoveringCrystalIdle1;

    entityAnimations[EntityStatus.run] =
        await spriteAnimations.hoveringCrystalAttack1;
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
      onTick: findTarget,
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
    final bodies = world.physicsWorld.bodies
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
      target = bodies.random();
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
  ElementalAttackSentry({
    required super.initialPosition,
    required this.damageType,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  }) {
    touchDamage.damageBase[damageType] ??= (1, 4);
  }

  DamageType damageType;

  @override
  Future<void> loadAnimationSprites() async {
    if (damageType == DamageType.energy) {
      entityAnimations[EntityStatus.idle] =
          await spriteAnimations.energyElementalIdle1;

      entityAnimations[EntityStatus.run] =
          await spriteAnimations.energyElementalRun1;
    } else {
      entityAnimations[EntityStatus.idle] =
          await spriteAnimations.hoveringCrystalIdle1;

      entityAnimations[EntityStatus.run] =
          await spriteAnimations.hoveringCrystalAttack1;
    }
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
      onTick: findTarget,
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
    if (target != null && (target!.userData! as Entity).isDead) {
      shouldFetchNewTarget = true;
    }
  }

  void findTarget() {
    deadCheck();
    if (!shouldFetchNewTarget) {
      return;
    }
    final bodies = world.physicsWorld.bodies.where(
      (element) => element.userData is Entity,
    );

    final filteredBodies = bodies
        .where(
          (element) =>
              (isPlayer
                  ? element.userData is Enemy
                  : element.userData is AttributeFunctionality) &&
              target != element &&
              element.userData is HealthFunctionality &&
              element.worldCenter.distanceTo(parentEntity.center) < 10,
        )
        .toList();

    if (filteredBodies.isNotEmpty) {
      target = filteredBodies.random();

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

class ElementalCaptureBulletSentry extends AttachedToBodyChildEntity
    with
        ContactCallbacks,
        AimFunctionality,
        AttackFunctionality,
        AimControlFunctionality {
  ElementalCaptureBulletSentry({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  }) {
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations['absorb_projectile'] =
        await spriteAnimations.elementalAbsorb1;

    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.hoveringCrystalIdle1;

    entityAnimations[EntityStatus.attack] =
        await spriteAnimations.hoveringCrystalAttack1;
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
        damage.sourceAttack is! Projectile) {
      return false;
    }

    final projectile = damage.sourceAttack as Projectile;

    if (!projectile.isMounted ||
        projectile.isRemoved ||
        projectile.projectileHasExpired) {
      return false;
    }

    setEntityAnimation('absorb_projectile');

    projectile.killBullet();

    capturedBullet = projectile;

    target = damage.source.body;

    bulletFireDelayTimer = TimerComponent(
      period: bulletFireDelayCooldown,
      removeOnFinish: true,
      onTick: () {
        bulletFireDelayTimer = null;
        capturedBullet = null;
        target = null;
        currentWeapon?.standardAttack(const AttackConfiguration());
        setEntityAnimation(EntityStatus.attack);
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

class MirrorOrbSentry extends AttachedToBodyChildEntity
    with ContactCallbacks, AimFunctionality, AttackFunctionality {
  MirrorOrbSentry({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2,
  }) {
    initialWeapons.add(WeaponType.blankProjectileWeapon);
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.hoveringCrystalIdle1;

    entityAnimations[EntityStatus.attack] =
        await spriteAnimations.hoveringCrystalAttack1;
  }

  void mirrorAttack(AttackConfiguration attackConfiguration, Weapon weapon) {
    if (parentEntity is! AttackFunctionality || currentWeapon == null) {
      return;
    }
    final parentAttackFunctionality = parentEntity as AttackFunctionality;
    final parentWeapon = parentAttackFunctionality.currentWeapon;
    if (parentWeapon is MeleeFunctionality &&
        currentWeapon is MeleeFunctionality) {
      final melee = currentWeapon! as MeleeFunctionality;
      melee.currentAttackIndex = parentWeapon.currentAttackIndex - 1;
    }

    isFlipped = parentAttackFunctionality.isFlipped;
    currentWeapon!.standardAttack(attackConfiguration);

    setEntityAnimation(EntityStatus.attack);
  }

  Future<void> buildSentryWeapon(Weapon? previous, Weapon newWeapon) async {
    if (previous is AttributeWeaponFunctionsFunctionality) {
      previous.onAttack.remove(mirrorAttack);
    }
    if (newWeapon is AttributeWeaponFunctionsFunctionality) {
      newWeapon.onAttack.add(mirrorAttack);
    }

    final tempWeapon = newWeapon.weaponType.build(
      ancestor: this,
      customWeaponLevel: newWeapon.upgradeLevel,
    );
    tempWeapon.weaponScale.baseParameter =
        tempWeapon.weaponScale.baseParameter / 2;
    tempWeapon.weaponAttachmentPoints.forEach((key, value) {
      value.weaponSpriteAnimation?.flashSize =
          value.weaponSpriteAnimation!.flashSize / 2;
    });

    carriedWeapons.add(tempWeapon);

    swapWeapon(currentWeapon);
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    if (parentEntity is AttackFunctionality) {
      final att = parentEntity as AttackFunctionality;
      att.onWeaponSwap.add(buildSentryWeapon);
      final parentWeapon = att.currentWeapon;
      if (parentWeapon != null) {
        buildSentryWeapon(null, parentWeapon);
      }
    }

    if (parentEntity is AimFunctionality) {
      addAimAngle(aimVector, userInputPriority);
      final aimPos = aimPosition;
      if (aimPos != null) {
        addAimPosition(aimPos, userInputPriority);
      }
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
    aimHandJoint(false);
    super.update(dt);
  }
}

class ShieldSentry extends AttachedToBodyChildEntity
    with ContactCallbacks, HealthFunctionality {
  ShieldSentry({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 1.25,
  }) {
    height.baseParameter = 3;
    invincible.baseParameter = true;
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.hoveringCrystalIdle1;

    entityAnimations[EntityStatus.attack] =
        await spriteAnimations.hoveringCrystalAttack1;
  }

  @override
  Body createBody() {
    final fixture = FixtureDef(
      CircleShape()..radius = spriteHeight / 3,
      filter: Filter()
        ..maskBits = projectileCategory
        ..categoryBits = isPlayer ? playerCategory : enemyCategory,
      userData: {'type': FixtureType.body, 'object': this},
      density: 0.005,
    );
    renderBody = false;
    return super.createBody()
      ..createFixture(fixture)
      ..setType(BodyType.static);
  }

  @override
  beginContact(Object other, Contact contact) {
    if (other is Projectile) {
      other.killBullet();
    } else if (other is MeleeAttackHandler) {
      other.kill();
    }
  }
}

class SwordSentry extends AttachedToBodyChildEntity
    with ContactCallbacks, HealthFunctionality, TouchDamageFunctionality {
  SwordSentry({
    required super.initialPosition,
    required super.upgradeLevel,
    required super.parentEntity,
    super.distance = 2.5,
    super.rotationSpeed = .5,
  }) {
    rotationSpeed = rotationSpeed * upgradeLevel;

    height.baseParameter = 2;
    invincible.baseParameter = true;
    touchDamage.damageBase[DamageType.physical] = (1, 4);
  }

  @override
  Future<void> loadAnimationSprites() async {
    entityAnimations[EntityStatus.idle] =
        await spriteAnimations.energyElementalIdle1;
  }

  @override
  Body createBody() {
    final fixture = FixtureDef(
      CircleShape()..radius = spriteHeight / 3,
      filter: Filter()
        ..maskBits = (!isPlayer ? playerCategory : enemyCategory)
        ..categoryBits = swordCategory,
      userData: {'type': FixtureType.body, 'object': this},
      isSensor: true,
      density: 0.9,
    );
    renderBody = false;
    return super.createBody()
      ..createFixture(fixture)
      ..setType(BodyType.static);
  }
}
