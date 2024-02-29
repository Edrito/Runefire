import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/extensions.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flame_forge2d/flame_forge2d.dart' hide Timer;
import 'package:flutter/material.dart';
import 'package:runefire/entities/hidden_child_entities/child_entities.dart';
import 'package:runefire/attributes/attributes_structure.dart';
import 'package:runefire/enemies/enemy.dart';
import 'package:runefire/entities/entity_class.dart';
import 'package:runefire/entities/input_priorities.dart';
import 'package:runefire/enviroment_interactables/expendables.dart';
import 'package:runefire/game/enviroment.dart';
import 'package:runefire/game/hud.dart';
import 'package:runefire/input_manager.dart';
import 'package:runefire/player/player.dart';
import 'package:runefire/player/player_mixin.dart';
import 'package:runefire/resources/constants/damage_values.dart';
import 'package:runefire/resources/functions/custom.dart';
import 'package:runefire/resources/game_state_class.dart';
import 'package:runefire/resources/visuals.dart';
import 'package:runefire/weapons/melee_swing_manager.dart';
import 'package:runefire/weapons/projectile_class.dart';
import 'package:runefire/weapons/weapon_mixin.dart';
import 'package:flutter_animate/flutter_animate.dart'
    show NumDurationExtensions;
import 'package:runefire/resources/damage_type_enum.dart';

import 'package:runefire/resources/data_classes/base.dart';
import 'package:runefire/resources/functions/functions.dart';
import 'package:runefire/resources/functions/vector_functions.dart';
import 'package:runefire/main.dart';
import 'package:runefire/resources/enums.dart';
import 'package:runefire/resources/constants/priorities.dart';
import 'package:runefire/weapons/weapon_class.dart';
import 'package:runefire/attributes/attributes_mixin.dart';

//when back from shower
//rework everything to the new bool system
//rework everything to the base/increase system
//rework everything to the new priority system
//break functions up as much as possible to allow for easy overriding

// final bool baseCollisionWhileDashing = false;
// List<bool> collisionWhileDashingIncrease = [];
// bool get collisionWhileDashing => boolAbilityDecipher(
//     baseCollisionWhileDashing, collisionWhileDashingIncrease);
mixin ElementalPower {
  final Map<DamageType, double> _elementalPower = {};
  final Map<DamageType, Map<double, bool>> _forceElementalAttribute = {};

  Map<DamageType, double> get elementalPower => _elementalPower;

  ///Positive to increase, negative to decrease
  ///out of 1
  ///.1 == 10% increase to a max of 100%
  void modifyElementalPower(DamageType type, double amount) {
    _elementalPower[type] = ((_elementalPower[type] ?? 0) + amount).clamp(0, 1);
    _forceElementalAttribute[type] ??= {};
    checkIfAutoAssignElementalAttribute();
    final newPower = _elementalPower[type]!;
    if (newPower > 0) {
      if (newPower < .25) {
        return;
      } else if (newPower < .5) {
        _forceElementalAttribute[type]![.25] ??= true;
      } else if (newPower < .75) {
        _forceElementalAttribute[type]![.5] ??= true;
      } else if (newPower < 1.0) {
        _forceElementalAttribute[type]![.75] ??= true;
      } else if (newPower == 1.0) {
        _forceElementalAttribute[type]![1.0] ??= true;
      }
    }
  }

  void checkIfAutoAssignElementalAttribute() {
    if (this is! AttributeFunctionality && this is! Entity) {
      return;
    }
    final toAdd = AttributeType.values.where((element) {
      final isAutoAssign = element.autoAssigned;
      final isNotAssigned =
          !(this as AttributeFunctionality).hasAttribute(element);
      final isEligible = element.isEligible(this as Entity);

      return isAutoAssign && isEligible && isNotAssigned;
    });

    for (final element in toAdd) {
      (this as AttributeFunctionality).addAttribute(
        element,
      );
    }
  }

  DamageType? shouldForceElementalAttributeSelection() {
    for (final element in _forceElementalAttribute.entries) {
      for (final damageTypeEntry in element.value.entries) {
        if (damageTypeEntry.value) {
          element.value[damageTypeEntry.key] = false;
          return element.key;
        }
      }
    }

    return null;
  }
}

mixin BaseAttributes {
  late final DoubleParameterManager areaDamagePercentIncrease;
  late final IntParameterManager attackCount;
  late final DoubleParameterManager critDamage;
  late final DoubleParameterManager damagePercentIncrease;
  late final DamagePercentParameterManager damageTypeDamagePercentIncrease;
  late final DoubleParameterManager essenceSteal;
  late final DoubleParameterManager knockBackIncreaseParameter;
  late final IntParameterManager maxLives;
  late final DoubleParameterManager meleeDamagePercentIncrease;
  late final DoubleParameterManager projectileDamagePercentIncrease;
  late final DoubleParameterManager spellDamagePercentIncrease;
  late final BoolParameterManager staminaSteal;
  late final StatusEffectPercentParameterManager statusEffectsPercentIncrease;
  late final DoubleParameterManager tickDamageIncrease;

  final BoolParameterManager affectsAllEntities = BoolParameterManager(
    baseParameter: false,
    frequencyDeterminesTruth: false,
  );

  ///Multiply this with area effect spells etc
  late final DoubleParameterManager areaSizePercentIncrease;

  //Collision
  late final BoolParameterManager collision = BoolParameterManager(
    baseParameter: true,
    customParameterFunction: (values, baseParameter) {
      return !values.contains(false);
    },
  );

  ///Multiply this with area effect spells etc
  late final DoubleParameterManager critChance;

  ///1 = 100% damage
  ///0 = Take no damage
  ///2 = Take double damage
  late final DamagePercentParameterManager damageTypeResistance;

  final IntParameterManager deathCount =
      IntParameterManager(baseParameter: 0, minParameter: 0);
  //Duration
  late final DoubleParameterManager durationPercentIncrease;
  //Duration
  late final DoubleParameterManager durationPercentReduction;
  //Movement
  late final BoolParameterManager movementEnabled;

  //Movement
  late final BoolParameterManager isStunned;

  ///Good if a specfic damage type has been added to attacks
  ///maybe fire?
  late final DamageParameterManager flatDamageIncrease;

  //Height
  final IntParameterManager height = IntParameterManager(baseParameter: 1);

  //Invincible
  late final BoolParameterManager invincible;

  bool isDead = false;

  bool get isChildEntity => this is ChildEntity;
  bool get isDashing => false;
  bool get isInvincible => invincible.parameter;
  bool get isJumping => false;
  int get remainingLives => maxLives.parameter - deathCount.parameter;

  void forceInitializeParameters() {
    invincible = BoolParameterManager(
      baseParameter: false,
      frequencyDeterminesTruth: false,
    );
    movementEnabled = BoolParameterManager(
      baseParameter: true,
      customParameterFunction: (values, baseParameter) {
        return !values.contains(false);
      },
    );
  }

  @mustCallSuper
  void initializeChildEntityParameters(ChildEntity childEntity) {
    flatDamageIncrease = childEntity.parentEntity.flatDamageIncrease;
    attackCount = childEntity.parentEntity.attackCount;
    durationPercentIncrease = childEntity.parentEntity.durationPercentIncrease;
    durationPercentReduction =
        childEntity.parentEntity.durationPercentReduction;
    tickDamageIncrease = childEntity.parentEntity.tickDamageIncrease;
    areaSizePercentIncrease = childEntity.parentEntity.areaSizePercentIncrease;
    critChance = childEntity.parentEntity.critChance;
    critDamage = childEntity.parentEntity.critDamage;
    damageTypeDamagePercentIncrease =
        childEntity.parentEntity.damageTypeDamagePercentIncrease;
    damageTypeResistance = childEntity.parentEntity.damageTypeResistance;
    areaDamagePercentIncrease =
        childEntity.parentEntity.areaDamagePercentIncrease;
    maxLives = childEntity.parentEntity.attackCount;
    essenceSteal = childEntity.parentEntity.essenceSteal;
    statusEffectsPercentIncrease =
        childEntity.parentEntity.statusEffectsPercentIncrease;
    damagePercentIncrease = childEntity.parentEntity.damagePercentIncrease;
    knockBackIncreaseParameter =
        childEntity.parentEntity.knockBackIncreaseParameter;
    meleeDamagePercentIncrease =
        childEntity.parentEntity.meleeDamagePercentIncrease;
    projectileDamagePercentIncrease =
        childEntity.parentEntity.projectileDamagePercentIncrease;
    spellDamagePercentIncrease =
        childEntity.parentEntity.spellDamagePercentIncrease;
    staminaSteal = childEntity.parentEntity.staminaSteal;
    isStunned = childEntity.parentEntity.isStunned;
  }

  void initializeParameterManagers() {
    if (isChildEntity) {
      initializeChildEntityParameters(this as ChildEntity);
    } else {
      initializeParentParameters();
    }
    forceInitializeParameters();
  }

  @mustCallSuper
  void initializeParentParameters() {
    attackCount = IntParameterManager(baseParameter: 0);
    durationPercentIncrease = DoubleParameterManager(baseParameter: 1);
    durationPercentReduction = DoubleParameterManager(baseParameter: 1);
    tickDamageIncrease = DoubleParameterManager(baseParameter: 1);
    areaSizePercentIncrease = DoubleParameterManager(baseParameter: 1);
    critChance = DoubleParameterManager(
      baseParameter: 0.05,
      maxParameter: 1,
    );
    critDamage = DoubleParameterManager(baseParameter: 1.4, minParameter: 1);
    flatDamageIncrease = DamageParameterManager(damageBase: {});
    damageTypeDamagePercentIncrease =
        DamagePercentParameterManager(damagePercentBase: {});
    damageTypeResistance = DamagePercentParameterManager(
      damagePercentBase: {},
    );
    areaDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    staminaSteal = BoolParameterManager(
      baseParameter: false,
      frequencyDeterminesTruth: false,
    );
    maxLives = IntParameterManager(baseParameter: 1);
    essenceSteal = DoubleParameterManager(baseParameter: 0);
    statusEffectsPercentIncrease =
        StatusEffectPercentParameterManager(statusEffectPercentBase: {});
    damagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    knockBackIncreaseParameter = DoubleParameterManager(baseParameter: 1);
    meleeDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    projectileDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    spellDamagePercentIncrease = DoubleParameterManager(baseParameter: 1);
    isStunned = BoolParameterManager(
      baseParameter: false,
      frequencyDeterminesTruth: false,
    );
  }
}

mixin MovementFunctionality on Entity {
  final List<int> _currentMoveVelocityPriorities = [];

  ///Priority, higher is more important
  ///Then detla
  final Map<int, Vector2> _moveVelocities = {};

  Map<String, Entity> entitiesFeared = {};
  //Speed
  late final DoubleParameterManager speed;

  Vector2 get currentMoveDelta {
    if (entitiesFeared.isNotEmpty) {
      final fearTarget = entitiesFeared.values.fold<Vector2>(
        Vector2.zero(),
        (previousValue, element) => previousValue + element.center,
      );
      return (center - fearTarget).normalized();
    }

    return _moveVelocities[_currentMoveVelocityPriorities.firstOrNull] ??
        Vector2.zero();
  }

  void applyKnockback({
    ///2000 is what would be expected for a strong knockback from a weapon
    ///dealing 30 ish damage
    required double amount,
    required Vector2 direction,
  }) {
    body.applyLinearImpulse(direction * amount);
  }

  bool get hasMoveVelocities => _moveVelocities.isNotEmpty;

  void addMoveVelocity(
    Vector2 direction,
    int priority, [
    bool normalize = true,
  ]) {
    if (normalize) {
      direction = direction.normalized();
    }
    _moveVelocities[priority] = direction;
    if (!_currentMoveVelocityPriorities.contains(priority)) {
      _currentMoveVelocityPriorities.add(priority);
      _currentMoveVelocityPriorities.sort((a, b) => b.compareTo(a));
    }
  }

  void moveCharacter() {
    final pulse = currentMoveDelta;

    if (isDead || !movementEnabled.parameter || pulse.isZero()) {
      setEntityAnimation(EntityStatus.idle);
      return;
    }
    spriteFlipCheck();

    // body.setTransform(center + (pulse * speed.parameter), 0);
    if (isPlayer && !isChildEntity) {
      body.applyForce(
        pulse *
            speed.parameter *
            ((this as Player).isDisplay
                ? center.distanceTo(Vector2.zero()).clamp(0, 1)
                : 1),
      );
    } else {
      body.applyForce(pulse * speed.parameter);
    }

    // body.linearVelocity = pulse;
    // gameEnviroment.test.position += pulse * speed.parameter;
    moveFunctionsCall();

    setEntityAnimation(
      body.linearVelocity.length > 1 ? EntityStatus.run : EntityStatus.walk,
    );
  }

  void moveFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onMove.isNotEmpty) {
      for (final element in attr.onMove) {
        element();
      }
    }
  }

  void removeMoveVelocity(int priority) {
    _moveVelocities.remove(priority);
    _currentMoveVelocityPriorities.remove(priority);
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    if (childEntity.parentEntity is MovementFunctionality) {
      speed = DoubleParameterManager(
        baseParameter: 500,
        parentParameterManager:
            (childEntity.parentEntity as MovementFunctionality).speed,
      );
    } else {
      speed = DoubleParameterManager(baseParameter: 500);
    }
    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    speed = DoubleParameterManager(baseParameter: 1000);
    super.initializeParentParameters();
  }
}

mixin AimFunctionality on Entity {
  final Map<int, Vector2> _aimAngles = {};
  final Map<int, Vector2> _aimPositions = {};
  final List<int> _currentAimAnglePriorities = [];
  final List<int> _currentAimPositionPriorities = [];

  DoubleParameterManager aimingInterpolationAmount =
      DoubleParameterManager(baseParameter: .065);

  double distanceIncrease = 1;
  Vector2 handAngleTarget = Vector2.zero();
  late PlayerAttachmentJointComponent handJoint;
  double handPositionFromBody = .1;
  Vector2 lastAimingDelta = Vector2.zero();
  Vector2 lastAimingPosition = Vector2.zero();
  Vector2 previousHandJointPosWithoutOffset = Vector2.zero();
  bool weaponBehind = false;

  PlayerAttachmentJointComponent? backJoint;
  PlayerAttachmentJointComponent? mouseJoint;

  Vector2? get aimPosition {
    if (isDead) {
      return lastAimingPosition;
    }

    final returnVal = _aimPositions[_currentAimPositionPriorities.firstOrNull];
    return returnVal;
  }

  Vector2 get aimVector {
    if (isDead) {
      return lastAimingDelta;
    }
    final returnVal =
        _aimAngles[_currentAimAnglePriorities.firstOrNull] ?? Vector2.zero();
    lastAimingDelta = returnVal;
    return returnVal;
  }

  Vector2 get backJointOffset => Vector2.zero();
  Vector2 get handJointAimDelta {
    return handJoint.position.normalized();
  }

  Vector2 get handJointOffset => Vector2.zero();

  void addAimAngle(Vector2 direction, int priority) {
    _aimAngles[priority] = direction;
    if (!_currentAimAnglePriorities.contains(priority)) {
      _currentAimAnglePriorities.add(priority);
      _currentAimAnglePriorities.sort((a, b) => b.compareTo(a));
    }
  }

  void addAimPosition(Vector2 direction, int priority) {
    _aimPositions[priority] = direction;
    if (!_currentAimPositionPriorities.contains(priority)) {
      _currentAimPositionPriorities.add(priority);
      _currentAimPositionPriorities.sort((a, b) => b.compareTo(a));
    }
  }

  void aimHandJoint([bool smoothFollow = true]) {
    final previousNormal = previousHandJointPosWithoutOffset.normalized();
    final handAngleTarget = aimVector.normalized();
    final interpAmount = aimingInterpolationAmount.parameter;
    Vector2 angle;
    if (smoothFollow) {
      angle = (previousNormal
            ..moveToTarget(
              handAngleTarget,
              interpAmount * previousNormal.distanceTo(handAngleTarget),
            ))
          .normalized();
    } else {
      angle = handAngleTarget.clone();
    }

    // if (isPlayer) {
    //   const distance = 5.0;
    //   final newDistance = (Curves.easeInOutCubic.transform(
    //               (mousePositionWithPlayerCenterOffset.length / distance)
    //                   .clamp(0, 1)) *
    //           distance)
    //       .clamp(0, distance);
    //   distanceIncrease =
    //       lerpDouble(distanceIncrease, newDistance, interpAmount)!;
    // }

    handJoint.position = angle * handPositionFromBody * distanceIncrease;

    handJoint.angle = -radiansBetweenPoints(
      Vector2(0, 1),
      angle,
    );

    previousHandJointPosWithoutOffset.setFrom(handJoint.position);
    handJoint.position += handJointOffset;
  }

  void aimMouseJoint() {
    mouseJoint?.position = aimPosition ?? Vector2.zero();
  }

  void checkSpriteAngles() {
    if (!movementEnabled.parameter) {
      return;
    }

    handJointBehindBodyCheck();
    spriteFlipCheck();
  }

  Vector2? getAimPosition(int priority) {
    return _aimPositions[priority];
  }

  void handJointBehindBodyCheck() {
    final deg = degrees(
      radiansBetweenPoints(
        Vector2(1, 0),
        aimVector,
      ),
    );

    if ((deg >= 0 && deg < 180 && !weaponBehind) ||
        (deg <= 360 && deg >= 180 && weaponBehind)) {
      weaponBehind = !weaponBehind;
      handJoint.priority = weaponBehind ? -1 : 1;
    }
  }

  void removeAimAngle(int priority) {
    _aimAngles.remove(priority);
    _currentAimAnglePriorities.remove(priority);
  }

  void removeAimPosition(int priority) {
    _aimPositions.remove(priority);
    _currentAimPositionPriorities.remove(priority);
  }

  @override
  void flipSprite() {
    handJoint.flipHorizontallyAroundCenter();
    backJoint?.flipHorizontallyAroundCenter();
    super.flipSprite();
  }

  @override
  Future<void> onLoad() {
    handJoint = PlayerAttachmentJointComponent(
      WeaponSpritePosition.hand,
      anchor: Anchor.center,
      position: handJointOffset,
      size: Vector2.zero(),
    );
    if (isPlayer) {
      mouseJoint = PlayerAttachmentJointComponent(
        WeaponSpritePosition.mouse,
        anchor: Anchor.center,
        size: Vector2.zero(),
      );
      // mouseJoint?.debugColor = Colors.transparent;
      backJoint = PlayerAttachmentJointComponent(
        WeaponSpritePosition.back,
        position: backJointOffset,
        anchor: Anchor.center,
        size: Vector2.zero(),
        priority: playerBackPriority,
      );
      add(backJoint!);
      add(mouseJoint!);
    }

    add(handJoint);

    return super.onLoad();
  }

  @override
  void spriteFlipCheck() {
    final degree = -degrees(handJoint.angle);
    if ((degree < 180 && !isFlipped) || (degree >= 180 && isFlipped)) {
      flipSprite();
    }
  }

  @override
  void update(double dt) {
    checkSpriteAngles();
    super.update(dt);
  }
}

mixin AttackFunctionality on AimFunctionality {
  List<Weapon> carriedWeapons = [];
  List<WeaponType> initialWeapons = [];
  bool isAltAttacking = false;
  bool isAttacking = false;
  int weaponIndex = 0;
  bool weaponsInitialized = false;

  List<Function(Weapon? from, Weapon to)> onWeaponSwap = [];

  Weapon? get currentWeapon {
    return carriedWeapons.elementAtOrNull(weaponIndex);
  }

  void clearWeapons() {
    weaponsInitialized = false;
    handJoint.removePreviousComponents();
    mouseJoint?.removePreviousComponents();
    backJoint?.removePreviousComponents();
    carriedWeapons.forEach((value) {
      value.removeFromParent();
    });
    carriedWeapons.clear();
    weaponIndex = 0;
  }

  Future<void> endPrimaryAttacking() async {
    if (!isAttacking) {
      return;
    }
    isAttacking = false;
    currentWeapon?.endAttacking();
  }

  Future<void> endSecondaryAttacking() async {
    if (!isAltAttacking) {
      return;
    }
    isAltAttacking = false;
    currentWeapon?.endAltAttacking();
  }

  void incrementWeaponIndex() {
    weaponIndex++;
    if (weaponIndex >= carriedWeapons.length) {
      weaponIndex = 0;
    }
  }

  void initializeWeapons() {
    if (isPlayer && !isChildEntity && (this as Player).isDisplay) {
      return;
    }
    clearWeapons();

    if (isPlayer && !isChildEntity) {
      final player = this as Player;
      final playerData = player.playerData;
      for (var i = 0; i < player.playerData.selectedWeapons.length; i++) {
        final element = playerData.selectedWeapons[i]!;
        carriedWeapons.add(
          element.build(
            ancestor: this,
            secondaryWeaponType: player.playerData.selectedSecondaries[i],
            playerData: player.playerData,
          ),
        );
      }
    } else {
      for (final element in initialWeapons) {
        carriedWeapons.add(
          element.build(
            ancestor: this,
            customWeaponLevel: 1,
          ),
        );
      }
    }
    if (currentWeapon != null) {
      _setWeapon(currentWeapon!);
    }
    weaponsInitialized = true;
  }

  Future<void> startPrimaryAttacking() async {
    if (isAttacking || isDead || isStunned.parameter) {
      return;
    }
    isAttacking = true;
    currentWeapon?.startAttacking();
  }

  Future<void> startSecondaryAttacking() async {
    if (isAltAttacking || isDead || isStunned.parameter) {
      return;
    }
    isAltAttacking = true;
    currentWeapon?.startAltAttacking();
  }

  Future<void> swapWeapon([Weapon? weapon]) async {
    if ((carriedWeapons.isEmpty || carriedWeapons.length == 1) &&
        weapon == null) {
      return;
    }
    final previousWeapon = currentWeapon;
    if (isAttacking) {
      previousWeapon?.endAttacking();
    }
    if (isAltAttacking) {
      previousWeapon?.endAltAttacking();
    }
    previousWeapon?.weaponSwappedFrom();

    if (weapon == null) {
      incrementWeaponIndex();
    }
    final newWeapon = weapon ?? currentWeapon;

    await _setWeapon(newWeapon!);

    newWeapon.weaponSwappedTo();

    if (onWeaponSwap.isNotEmpty) {
      for (final element in onWeaponSwap) {
        element(previousWeapon, newWeapon);
      }
    }

    if (isAttacking) {
      newWeapon.startAttacking();
    }
    if (isAltAttacking) {
      newWeapon.startAltAttacking();
    }
    newWeapon.spriteVisibilityCheck();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    height.addListener((value) {
      // handJoint.weaponSpriteAnimation?.resize();
      // mouseJoint?.weaponSpriteAnimation?.resize();
      // backJoint?.weaponSpriteAnimation?.resize();
      if (currentWeapon != null) {
        _setWeapon(currentWeapon!)
            .then((value) => currentWeapon?.spriteVisibilityCheck());
      }
    });
    initializeWeapons();
    onDeath.add((_) {
      endPrimaryAttacking();
      return null;
    });
  }

  @override
  void onRemove() {
    carriedWeapons.forEach((value) => value.removeFromParent());
    super.onRemove();
  }

  @override
  Future<void> permanentlyDisableEntity() async {
    endPrimaryAttacking();
    endSecondaryAttacking();
    final weapon = currentWeapon;
    if (weapon != null) {
      for (final element in weapon.weaponAttachmentPoints.values) {
        element.weaponSpriteAnimation?.removeFromParent();
      }
    }

    super.permanentlyDisableEntity();
  }

  Future<void> _setWeapon(Weapon weapon) async {
    weapon.spritesHidden = false;
    await handJoint.loaded.whenComplete(() => handJoint.addWeaponClass(weapon));
    if (enviroment is GameEnviroment && isPlayer) {
      await enviroment.loaded;
      gameEnviroment.hud.toggleStaminaColor(weapon.weaponType.attackType);
      await mouseJoint?.loaded
          .whenComplete(() => mouseJoint?.addWeaponClass(weapon));
      await backJoint?.loaded
          .whenComplete(() => backJoint?.addWeaponClass(weapon));
    }
  }
}

mixin StaminaFunctionality on Entity {
  late final DoubleParameterManager stamina;
  late final DoubleParameterManager staminaRegen;

  bool isForbiddenMagic = false;
  double staminaUsed = 0;

  /// Amount of stamina regenerated per second
  double get increaseStaminaRegenSpeed =>
      (remainingStamina / stamina.parameter) + .5;

  double get remainingStamina => stamina.parameter - staminaUsed;

  bool hasEnoughStamina(double cost) {
    return isForbiddenMagic && this is HealthFunctionality
        ? (this as HealthFunctionality).remainingHealth >= cost.abs()
        : remainingStamina >= cost;
  }

  ///5 = 5 more stamina, -5 = 5 less stamina, to use
  void modifyStamina(double amount, [bool regen = false]) {
    if (isForbiddenMagic && this is HealthFunctionality && amount < 0) {
      final health = this as HealthFunctionality;

      health.applyDamage(
        DamageInstance(
          damageMap: {
            DamageType.magic: amount.abs(),
          },
          source: this,
          victim: health,
          sourceAttack: this,
        ),
      );
    } else {
      staminaUsed = (staminaUsed -= amount).clamp(0, stamina.parameter);
      staminaModifiedFunctions(amount);
      if (!regen &&
          isPlayer &&
          !isChildEntity &&
          enviroment is GameEnviroment) {
        gameEnviroment.hud.barFlash(BarType.staminaBar);
      }
    }
  }

  void staminaModifiedFunctions(double stamina) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onStaminaModified.isNotEmpty) {
      for (final element in attr.onStaminaModified) {
        element(stamina);
      }
    }
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    stamina = (childEntity.parentEntity as StaminaFunctionality).stamina;
    staminaRegen =
        (childEntity.parentEntity as StaminaFunctionality).staminaRegen;

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    stamina = DoubleParameterManager(baseParameter: 100);
    staminaRegen = DoubleParameterManager(baseParameter: 12.5);

    super.initializeParentParameters();
  }

  @override
  void update(double dt) {
    // modifyStamina(staminaRegen.parameter * dt * increaseStaminaRegenSpeed);
    modifyStamina(
      staminaRegen.parameter * dt * increaseStaminaRegenSpeed,
      true,
    );
    super.update(dt);
  }
}

mixin HealthRegenFunctionality on HealthFunctionality {
  late final DoubleParameterManager healthRegen;

  /// Amount of health regenerated per second
  double get increaseHealthRegenSpeed =>
      (remainingHealth / maxHealth.parameter) + .5;

  ///Requires a positive value to increase the amount of health
  ///5 = 5 more health, -5 = 5 less health
  void modifyHealth(double amount) =>
      damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    healthRegen =
        (childEntity.parentEntity as HealthRegenFunctionality).healthRegen;

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    healthRegen = DoubleParameterManager(baseParameter: .35);
    // healthRegen = DoubleParameterManager(baseParameter: 1);

    super.initializeParentParameters();
  }

  @override
  void update(double dt) {
    modifyHealth(healthRegen.parameter * dt * increaseHealthRegenSpeed);

    super.update(dt);
  }
}

mixin HealthFunctionality on Entity {
  late final BoolParameterManager isMarked;
  late final DoubleParameterManager maxHealth;

  //HEALTH
  Map<DamageType, (TextComponent, double)> damageTexts = {};

  List<DamageInstance> damageInstancesRecieved = [];
  double damageTaken = 0;
  double damageTextLifespan = 2;
  Map<DamageType, double> damageTextsTimer = {};
  Map<String, double> hitSourceInvincibility = {};
  double iFrameDuration = 0;
  //health
  late final DoubleParameterManager invincibilityDuration;

  int maxTargetsHomingEntity = 5;
  double recentDamage = 0;
  double sameDamageSourceDuration = .5;
  int targetsHomingEntity = 0;

  Vector2? baseSize;
  Vector2? baseTextSize;
  ColorEffect? currentColorEffect;
  SizeEffect? currentScaleEffect;

  bool get canBeHit => !isInvincible && !isDead;
  double get healthPercentage => remainingHealth / maxHealth.parameter;
  double get remainingHealth => maxHealth.parameter - damageTaken;

  void addDamageEffects(Color color) {
    final reversedController = EffectController(
      duration: .2,
      reverseDuration: .1,
      onMin: () {
        currentScaleEffect?.removeFromParent();
        currentColorEffect?.removeFromParent();
        currentScaleEffect = null;
        currentColorEffect = null;
      },
    );

    baseSize ??= entityAnimationsGroup.size;

    currentScaleEffect?.controller.setToStart();
    currentColorEffect?.controller.setToStart();

    currentScaleEffect ??= SizeEffect.to(
      baseSize! * (1 + (.25 * rng.nextDouble() * color.opacity)),
      reversedController,
    )..addToParent(entityAnimationsGroup);

    currentColorEffect ??= ColorEffect(
      color,
      reversedController,
      opacityTo: color.opacity,
    )..addToParent(entityAnimationsGroup);
  }

  void addFloatingText(DamageInstance damage, [String? customText]) {
    if (!game.systemDataComponent.dataObject.showDamageText) {
      return;
    }
    final newTexts = <TextComponent>[];
    final pos = Vector2(entityAnimationsGroup.width / 3, 0);
    // if (!isPlayer) {
    //   pos += center;
    // }

    for (final element in damage.damageMap.entries) {
      final color = element.key.color;
      final fontSize = .45 * (damage.isCrit ? 1.3 : 1);

      final textRenderer = colorPalette.buildTextPaint(
        fontSize,
        ShadowStyle.lightGame,
        damage.isCrit ? Colors.red : color.brighten(.2),
      );

      damageTextsTimer[element.key] = damageTextLifespan;
      final previousText = damageTexts[element.key];

      if (previousText != null) {
        final newVal = previousText.$2 + element.value;

        final damageString =
            _buildTextFromDamage(element.key, newVal, customText);
        previousText.$1.text = damageString;
        previousText.$1.textRenderer = textRenderer;
        previousText.$1.position = pos;
        damageTexts[element.key] = (previousText.$1, newVal);
        previousText.$1.add(
          ScaleEffect.to(
            Vector2(1.1, 1.1),
            EffectController(
              duration: .2,
              reverseDuration: .1,
              // curve: Curves.easeOut,
            ),
          ),
        );
      } else {
        final damageString =
            _buildTextFromDamage(element.key, element.value, customText);
        final tempText = TextComponent(
          text: damageString,
          // anchor: Anchor.center,
          textRenderer: textRenderer,
          priority: foregroundPriority,
          position: pos,
        );

        final moveBy = (Vector2.random() * .5) * (damage.isCrit ? 3 : 1);
        tempText.add(
          MoveEffect.by(
            Vector2(moveBy.x, -moveBy.y),
            EffectController(
              duration: damageTextLifespan,
              curve: Curves.easeOut,
            ),
          ),
        );

        damageTexts[element.key] = (tempText, element.value);

        newTexts.add(tempText);
      }
    }
    newTexts.shuffle();

    // if (isPlayer) {
    addAll(newTexts);
    // } else {
    //   gameEnviroment.addTextComponents(newTexts);
    // }
  }

  Future<void> addOpacityFlashEffect(double duration) async {
    late final OpacityEffect flashEffect;
    final previousOpacity = entityAnimationsGroup.opacity;
    entityAnimationsGroup.add(
      flashEffect = OpacityEffect.by(
        .5,
        InfiniteEffectController(SineEffectController(period: .2)),
      ),
    );
    await game.gameAwait(duration);
    entityAnimationsGroup.opacity = previousOpacity;
    flashEffect.removeFromParent();
  }

  void applyDamage(DamageInstance damage) {
    damageTaken += damage.damage;
    // recentDamage += damage.damage;
    damageTaken.clamp(0, maxHealth.parameter);
    if (isPlayer && !isChildEntity) {
      gameEnviroment.hud.barFlash(BarType.healthBar);
    }

    damageInstancesRecieved.add(damage);
  }

  void applyEssenceSteal(DamageInstance instance) {
    final amount = essenceSteal.parameter * instance.damage;
    if (amount == 0 || !amount.isFinite) {
      return;
    }
    if (staminaSteal.parameter && this is StaminaFunctionality) {
      final stamina = this as StaminaFunctionality;
      stamina.modifyStamina(amount);
    } else {
      damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);
    }
    // addFloatingText(
    //   DamageInstance(
    //     damageMap: {DamageType.healing: amount},
    //     source: this,
    //     victim: this,
    //     sourceAttack: this,
    //   ),
    // );
    addDamageEffects(DamageType.healing.color.withOpacity(.35));
  }

  void applyHealing(DamageInstance damage) {
    if (damage.damageMap.containsKey(DamageType.healing)) {
      damageTaken -= damage.damageMap[DamageType.healing]!;
      damageTaken.clamp(0, maxHealth.parameter);
      damage.damageMap.remove(DamageType.healing);
    }
  }

  void applyIFrameTimer(String id) {
    hitSourceInvincibility[id] = sameDamageSourceDuration;

    iFrameDuration = invincibilityDuration.parameter;
  }

  void applyKnockbackFromDamageInstance(DamageInstance damage) {
    if (this is MovementFunctionality) {
      final move = this as MovementFunctionality;
      final amount = (damage.damage / 30).clamp(0, 1);
      final impulse = damage.source.knockBackIncreaseParameter.parameter *
          amount *
          (damage.sourceWeapon?.knockBackAmount.parameter ?? 0);
      move.applyKnockback(
        amount: impulse,
        direction: (center - damage.source.center).normalized(),
      );
    }
  }

  void applyStatusEffectFromDamageChecker(
    DamageInstance damage,
  ) {
    if (this is! AttributeFunctionality) {
      return;
    }

    final attr = this as AttributeFunctionality;
    for (final element in damage.statusEffectChance.entries) {
      final chance = element.value;
      final statusEffect = element.key;

      if (chance <= rng.nextDouble()) {
        continue;
      }

      attr.addAttribute(
        statusEffect.getCorrospondingAttribute,
        // level: 1,
        // duration: 3,
        perpetratorEntity: damage.source,
        damageType: damage.damageMap.keys.first,
        isTemporary: true,
      );
    }
  }

  void callOtherWeaponOnKillFunctions(DamageInstance damage) {
    final weaponFunctions =
        damage.sourceWeapon is AttributeWeaponFunctionsFunctionality;
    if (weaponFunctions) {
      final weapon =
          damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality;

      for (final element in weapon.onKill) {
        element(this);
      }
    }
    final other = damage.source;
    final otherFunctions = other.attributeFunctionsFunctionality;
    if (this is AttributeFunctionality) {
      final attr = this as AttributeFunctionality;
    }
    if (otherFunctions != null) {
      for (final element in otherFunctions.onKillOtherEntity) {
        element(damage);
      }
    }
  }

  bool consumeMark() {
    final isMarked = this.isMarked.parameter;
    if (isMarked && this is AttributeFunctionality) {
      final attr = this as AttributeFunctionality;
      attr.removeAttribute(AttributeType.marked);
    }
    return isMarked;
  }

  void deathChecker(DamageInstance damage) {
    if ((remainingHealth <= 0 || !remainingHealth.isFinite) && !isDead) {
      final remainingLives = this.remainingLives;
      deathCount.setParameterFlatValue(entityId, deathCount.parameter + 1);

      callOtherWeaponOnKillFunctions(damage);
      if (_preDeathFunctionsCall(damage)) {
        deathCount.setParameterFlatValue(entityId, deathCount.parameter - 1);
        dieThenRevive();
      } else if (remainingLives > 1) {
        dieThenRevive();
      } else {
        die(damage);
      }
      _deadFunctionsCall(damage);
    }
  }

  Future<void> die(
    DamageInstance damage, [
    EndGameState endGameState = EndGameState.playerDeath,
  ]) async {
    isDead = true;
    permanentlyDisableEntity();
    entityStatusWrapper.removeAllAnimations();
    setEntityAnimation(EntityStatus.dead, finalAnimation: true).then((value) {
      entityAnimationsGroup.add(
        OpacityEffect.fadeOut(
          EffectController(
            startDelay: rng.nextDouble() * .5,
            duration: 1.0,
            onMax: removeFromParent,
            curve: Curves.easeIn,
          ),
        ),
      );
      if (this is Player) {
        game.gameStateComponent.gameState
            .killPlayer(endGameState, this as Player, damage);
      }
    });

    _permanentDeathFunctionsCall(damage);
  }

  Future<void> dieThenRevive() async {
    // entityStatusWrapper.removeAllAnimations();

    if (isPlayer) {
      final player = this as Player;
      player.disableInput.setIncrease('revive', true);
    }
    invincible.setIncrease('revive', true);

    if (this is MovementFunctionality) {
      final move = (this as MovementFunctionality)
        ..movementEnabled.setIncrease('revive', false);
      move.addMoveVelocity(Vector2.zero(), absoluteOverrideInputPriority);
    }

    await setEntityAnimation(EntityStatus.dead);
    await game.gameAwait(.5);
    await setEntityAnimation(EntityStatus.spawn);

    if (isPlayer) {
      final player = this as Player;
      player.disableInput.removeIncrease('revive');
    }

    if (this is MovementFunctionality) {
      final move = (this as MovementFunctionality)
        ..movementEnabled.removeIncrease('revive');
      move.removeMoveVelocity(absoluteOverrideInputPriority);
      move.removeMoveVelocity(userInputPriority);
      move.removeMoveVelocity(gamepadUserInputPriority);
    }

    await addOpacityFlashEffect(3.0);
    invincible.removeIncrease('revive');
    heal(damageTaken);
  }

  void doOtherEntityOnDamageFunctions(DamageInstance damage) {
    final other = damage.source.isChildEntity
        ? (damage.source as ChildEntity).parentEntity
        : damage.source;
    final otherFunctions = other.attributeFunctionsFunctionality;
    if (otherFunctions != null) {
      for (final element in otherFunctions.onPostDamageOtherEntity) {
        element(damage);
      }
    }

    if (damage.sourceWeapon is AttributeWeaponFunctionsFunctionality) {
      (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
          .onDamage
          .forEach((element) {
        element(damage);
      });
      switch (damage.sourceWeapon?.weaponType.attackType) {
        case AttackType.melee:
          (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
              .onDamageMelee
              .forEach((element) {
            element(damage);
          });
          break;
        case AttackType.guns:
          (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
              .onDamageProjectile
              .forEach((element) {
            element(damage);
          });
          break;
        case AttackType.magic:
          (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
              .onDamageMagic
              .forEach((element) {
            element(damage);
          });
          break;
        default:
      }
    }
  }

  void doOtherEntityOnHitFunctions(DamageInstance damage) {
    final other = damage.source.isChildEntity
        ? (damage.source as ChildEntity).parentEntity
        : damage.source;

    final otherFunctions = other.attributeFunctionsFunctionality;
    if (otherFunctions != null) {
      for (final element in otherFunctions.onHitOtherEntity) {
        element(damage);
      }
    }

    if (damage.sourceWeapon is AttributeWeaponFunctionsFunctionality) {
      (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
          .onHit
          .forEach((element) {
        element(damage);
      });

      switch (damage.sourceWeapon?.weaponType.attackType) {
        case AttackType.melee:
          (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
              .onHitMelee
              .forEach((element) {
            element(damage);
          });
          break;
        case AttackType.guns:
          (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
              .onHitProjectile
              .forEach((element) {
            element(damage);
          });
          break;
        case AttackType.magic:
          (damage.sourceWeapon! as AttributeWeaponFunctionsFunctionality)
              .onHitMagic
              .forEach((element) {
            element(damage);
          });
          break;
        default:
      }
    }
  }

  ///Heal the attacker if they have the essence steal attribute
  void essenceStealChecker(DamageInstance damage) {
    final isHealth = damage.source is HealthFunctionality;
    if (isHealth) {
      (damage.source as HealthFunctionality).applyEssenceSteal(damage);
    }
  }

  MapEntry<DamageType, double> fetchLargestDamageType(DamageInstance instance) {
    var largestEntry = instance.damageMap.entries.first;

    for (final element in instance.damageMap.entries) {
      if (element.value > largestEntry.value) {
        largestEntry = element;
      }
    }
    return largestEntry;
  }

  void heal(double amount) {
    damageTaken = (damageTaken -= amount).clamp(0, maxHealth.parameter);
    addFloatingText(
      DamageInstance(
        damageMap: {DamageType.healing: amount},
        source: this,
        victim: this,
        sourceAttack: this,
      ),
    );
    addDamageEffects(DamageType.healing.color);
  }

  bool hitCheck(
    String id,
    DamageInstance damage, [
    bool applyStatusEffect = true,
  ]) {
    doOtherEntityOnHitFunctions(damage);

    if (hitSourceInvincibility.containsKey(id)) {
      return false;
    }

    if (!canBeHit) {
      return false;
    }

    if (damage.damageMap.isEmpty ||
        damage.damage == 0 ||
        onHitByOtherFunctionsCall(damage)) {
      return false;
    }

    if (damage.source is AttributeCallbackFunctionality) {
      if ((damage.source as AttributeCallbackFunctionality)
          .onPreDamageOtherEntityFunctions
          .call(damage)) {
        return false;
      }
    }

    return takeDamage(id, damage, applyStatusEffect);
  }

  void onHealFunctions(DamageInstance damage) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onHeal.isNotEmpty) {
      for (final element in attr.onHeal) {
        element(damage);
      }
    }
  }

  ///Returning true means cancel the damage
  bool onHitByOtherFunctionsCall(DamageInstance damage) {
    final attr = attributeFunctionsFunctionality;
    if (attr == null) {
      return false;
    }

    var cancelDamage = false;
    if (attr.onHitByOtherEntity.isNotEmpty) {
      for (final element in attr.onHitByOtherEntity) {
        cancelDamage = cancelDamage || element(damage);
      }
    }
    if (attr.onHitByProjectile.isNotEmpty &&
        damage.sourceAttack is Projectile) {
      for (final element in attr.onHitByProjectile) {
        cancelDamage = cancelDamage || element(damage);
      }
    }
    return cancelDamage;
  }

  bool takeDamage(
    String id,
    DamageInstance damage, [
    bool applyStatusEffect = true,
  ]) {
    applyIFrameTimer(id);

    final largestEntry = fetchLargestDamageType(damage);

    addFloatingText(damage);
    addDamageEffects(largestEntry.key.color);

    if (largestEntry.value.isFinite) {
      damage.applyResistances(this);
      if (applyStatusEffect) {
        applyStatusEffectFromDamageChecker(damage);
      }
      essenceStealChecker(damage);
    }

    doOtherEntityOnDamageFunctions(damage);

    onDamageTakenFunctions(damage);

    applyDamage(damage);
    setEntityAnimation(EntityStatus.damage);
    applyKnockbackFromDamageInstance(damage);
    deathChecker(damage);
    return true;
  }

  void onDamageTakenFunctions(DamageInstance instance) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onDamageTaken.isNotEmpty) {
      for (final element in attr.onDamageTaken) {
        element(instance);
      }
    }
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    invincibilityDuration =
        (childEntity.parentEntity as HealthFunctionality).invincibilityDuration;
    maxHealth = (childEntity.parentEntity as HealthFunctionality).maxHealth;
    isMarked = (childEntity.parentEntity as HealthFunctionality).isMarked;

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    invincibilityDuration = DoubleParameterManager(baseParameter: .2);
    maxHealth = DoubleParameterManager(baseParameter: 50, minParameter: 1);
    isMarked = BoolParameterManager(
      baseParameter: false,
      frequencyDeterminesTruth: false,
    );
    super.initializeParentParameters();
  }

  @override
  bool get isInvincible => super.isInvincible || iFrameDuration > 0;

  @override
  void update(double dt) {
    for (final element in [...hitSourceInvincibility.keys]) {
      if (hitSourceInvincibility[element]! <= dt) {
        hitSourceInvincibility.remove(element);
        continue;
      }
      hitSourceInvincibility[element] = hitSourceInvincibility[element]! - dt;
    }
    for (final element in [...damageTextsTimer.keys]) {
      damageTextsTimer[element] = damageTextsTimer[element]! - dt;
      if (damageTextsTimer[element]! <= 0) {
        damageTextsTimer.remove(element);
        damageTexts[element]?.$1.removeFromParent();
        damageTexts.remove(element);
      }
    }
    if (iFrameDuration > 0) {
      iFrameDuration -= dt;
    }
    super.update(dt);
  }

  String _buildTextFromDamage(
    DamageType damageType,
    double damage,
    String? customText,
  ) {
    var damageString = '';

    if (customText != null) {
      damageString = customText;
    } else {
      damageString = !damage.isFinite ? 'X' : damage.ceil().toString();

      if (damageType == DamageType.healing) {
        damageString = '+ $damageString';
      }
    }
    return damageString;
  }

  bool _deadFunctionsCall(DamageInstance instance) {
    final attr = attributeFunctionsFunctionality;
    var shouldLive = false;
    if (attr != null && onDeath.isNotEmpty) {
      for (final element in onDeath) {
        shouldLive = shouldLive || (element.call(instance) ?? false);
      }
    }
    return shouldLive;
  }

  bool _preDeathFunctionsCall(DamageInstance instance) {
    final attr = attributeFunctionsFunctionality;
    var shouldLive = false;
    if (attr != null && onPreDeath.isNotEmpty) {
      for (final element in onPreDeath) {
        shouldLive = shouldLive || (element.call(instance) ?? false);
      }
    }
    return shouldLive;
  }

  bool _permanentDeathFunctionsCall(DamageInstance instance) {
    final attr = attributeFunctionsFunctionality;
    var shouldLive = false;
    if (attr != null && onPermanentDeath.isNotEmpty) {
      for (final element in onPermanentDeath) {
        shouldLive = shouldLive || (element.call(instance) ?? false);
      }
    }
    return shouldLive;
  }
}

mixin DodgeFunctionality on HealthFunctionality {
  late final DoubleParameterManager dodgeChance;

  int dodges = 0;

  void addDodgeText() {
    final test = TextPaint(
      style: defaultStyle.copyWith(
        fontSize: .3,
        fontWeight: FontWeight.bold,
        fontStyle: FontStyle.italic,
        shadows: const [
          BoxShadow(
            color: Colors.black26,
            offset: Offset(.05, .05),
            spreadRadius: 3,
            blurRadius: 3,
          ),
        ],
        color: Colors.grey.shade100,
      ),
    );
    final dodgeText = TextComponent(
      text: ['~', 'foo', 'dodge', 'swish'].random(),
      anchor: Anchor.bottomLeft,
      textRenderer: test,
      position: Vector2(
        (rng.nextDouble() * .25) + .25,
        (-rng.nextDouble() * .25) - .5,
      ),
    );
    dodgeText.addAll([
      MoveEffect.by(
        Vector2(rng.nextDouble() * .25, -rng.nextDouble() * .25) * 2,
        EffectController(duration: 1, curve: Curves.easeIn),
      ),
      TimerComponent(
        period: 1,
        removeOnFinish: true,
        onTick: dodgeText.removeFromParent,
      ),
    ]);
    add(dodgeText);
  }

  void dodge(DamageInstance damage) {
    dodgeFunctions(damage);

    dodges++;
    applyIFrameTimer(damage.source.entityId);

    addDodgeText();
  }

  bool dodgeCheck(DamageInstance damage) {
    final random = rng.nextDouble();

    if (damage.damageMap.entries
            .any((element) => element.key == DamageType.physical) &&
        random < dodgeChance.parameter) {
      dodge(damage);
      return true;
    } else {
      return false;
    }
  }

  void dodgeFunctions(DamageInstance damage) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.onDodge.isNotEmpty) {
      for (final element in attr.onDodge) {
        element(damage);
      }
    }
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    dodgeChance = (childEntity.parentEntity as DodgeFunctionality).dodgeChance;

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    dodgeChance = DoubleParameterManager(
      baseParameter: .0,
      maxParameter: 1,
    );
    super.initializeParentParameters();
  }

  @override
  bool takeDamage(
    String id,
    DamageInstance damage, [
    bool applyStatusEffect = true,
  ]) {
    if (dodgeCheck(damage)) {
      damage.damageMap.remove(DamageType.physical);
      if (damage.damageMap.isEmpty) {
        return false;
      }
    }
    return super.takeDamage(id, damage, applyStatusEffect);
  }
}

mixin TouchDamageFunctionality on Entity, ContactCallbacks {
  late final DoubleParameterManager hitRate;
  late final DamageParameterManager touchDamage;

  List<Function(Entity other)> onTouchTick = [];
  Map<Entity, double> objectsHitting = {};

  DamageInstance calculateTouchDamage(
    HealthFunctionality victim,
    dynamic sourceAttack,
  ) =>
      damageCalculations(
        this,
        victim,
        touchDamage.damageBase,
        sourceAttack: sourceAttack,
        damageSource: touchDamage,
      );

  ///Time interval between damage ticks

  void damageOther(Body other) {
    if (touchDamage.damageBase.isEmpty || isDead) {
      return;
    }
    final otherReference = other.userData;
    if (otherReference is! HealthFunctionality) {
      return;
    }
    if ((isPlayer && otherReference is Enemy) ||
        (!isPlayer && otherReference is Player)) {
      otherReference.hitCheck(
        entityId,
        calculateTouchDamage(otherReference, this),
      );
    }
  }

  void initTouchParameters() {
    touchDamage = DamageParameterManager(damageBase: {});
    hitRate = DoubleParameterManager(
      baseParameter: 1,
      maxParameter: double.infinity,
    );
  }

  @override
  void beginContact(Object other, Contact contact) {
    final shouldCalculate = !isDead &&
        other is Entity &&
        ((contact.fixtureA.userData! as Map)['type'] == FixtureType.body &&
            (contact.fixtureB.userData! as Map)['type'] == FixtureType.body);
    if (shouldCalculate) {
      if ((isPlayer && other is Enemy) || (!isPlayer && other is Player)) {
        objectsHitting[other] = 0.0;
        _onTick(other);
      }
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Entity) {
      objectsHitting.remove(other);
    }

    super.endContact(other, contact);
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    final parentIsTouch = childEntity.parentEntity is TouchDamageFunctionality;
    if (parentIsTouch) {
      touchDamage =
          (childEntity.parentEntity as TouchDamageFunctionality).touchDamage;
      hitRate = (childEntity.parentEntity as TouchDamageFunctionality).hitRate;
    } else {
      initTouchParameters();
    }

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    initTouchParameters();
    super.initializeParentParameters();
  }

  @override
  void update(double dt) {
    final hitRateParameter = hitRate.parameter;

    if (hitRateParameter > 0) {
      objectsHitting.forEach((key, value) {
        objectsHitting[key] = value + dt;
        if (value >= hitRateParameter) {
          _onTick(key);
          objectsHitting[key] = 0;
        }
      });
    } else {
      objectsHitting.forEach((key, value) {
        _onTick(key);
      });
    }

    super.update(dt);
  }

  void _onTick(Entity entity) {
    damageOther(entity.body);
    onTouchTick.forEach((element) {
      element(entity);
    });
  }
}

mixin DashFunctionality on StaminaFunctionality {
  bool _isDashing = false;

  late final DoubleParameterManager dashDistance;
  late final DoubleParameterManager dashDuration;
  late final DoubleParameterManager dashStaminaCost;
  late final BoolParameterManager teleportDash;

  // late final BoolParameterManager invincibleWhileDashing;
  late final BoolParameterManager collisionWhileDashing;

  //DASH COOLDOWN
  late final DoubleParameterManager dashCooldown;

  //STATUS
  TimerComponent? dashTimerCooldown;

  List<Vector2 Function()> customTeleportDestinations = [];

  double dashedDistance = 0;
  bool triggerFunctions = true;

  Vector2? dashDelta;
  double? dashDistanceGoal;

  bool get canDash => !(dashTimerCooldown != null ||
      isJumping ||
      isDead ||
      isDashing ||
      !movementEnabled.parameter ||
      !hasEnoughStamina(dashStaminaCost.parameter));

  Future<void> applyGroundAnimationDash() async {
    final attr = this as AttributeFunctionality;
    final shouldApplyGroundAnimation = this is! AttributeFunctionality ||
        !attr.hasAnyAttribute([
          AttributeType.gravityDash,
          AttributeType.teleportDash,
          AttributeType.explosiveDash,
        ]);

    if (!shouldApplyGroundAnimation) {
      return;
    }

    applyGroundAnimation(
      await spriteAnimations.dashEffect1,
      false,
      spriteHeight * .1,
      true,
    );
  }

  Future<void> beginDash({
    double? power,
    bool weaponSource = false,
    bool triggerFunctions = true,
  }) async {
    if (!weaponSource) {
      modifyStamina(-dashStaminaCost.parameter);
    }
    this.triggerFunctions = triggerFunctions;
    power ??= 1;

    var clampDisance = true;

    applyGroundAnimationDash();
    dashDistanceGoal = dashDistance.parameter * power;
    _isDashing = true;
    //If dash is caused by a weapon, the direction is already set
    if (weaponSource) {
      if (this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).lastAimingDelta;
      }
      if (dashDelta?.isZero() ?? true && this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).currentMoveDelta *
            dashDistance.parameter;
      }
      //if teleporting
    } else if (teleportDash.parameter) {
      //if a custom teleport location function has been set
      if (customTeleportDestinations.isNotEmpty) {
        final destination = customTeleportDestinations.random().call();
        dashDelta = (destination - center).normalized();
        dashDistanceGoal = center.distanceTo(destination);
        clampDisance = false;
        //otherwise use the aim or movement direction
      } else if (this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).aimPosition;

        dashDistanceGoal =
            dashDelta?.length ?? (dashDistance.parameter * power);
      }
      if (dashDelta?.isZero() ?? true && this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).currentMoveDelta;
      }
    } else {
      if (this is MovementFunctionality) {
        dashDelta = (this as MovementFunctionality).currentMoveDelta;
      }
      if (dashDelta?.isZero() ?? true && this is AimFunctionality) {
        dashDelta = (this as AimFunctionality).aimVector;
      }
    }

    dashDelta = dashDelta!.normalized();
    final max = (dashDistance.parameter * power).abs();
    if (clampDisance) {
      dashDistanceGoal = dashDistanceGoal?.clamp(
        -max,
        max,
      );
    }
    if (!weaponSource) {
      dashTimerCooldown = TimerComponent(
        period: dashCooldown.parameter,
        removeOnFinish: true,
        onTick: () {
          dashTimerCooldown?.timer.stop();
          dashTimerCooldown?.removeFromParent();
          dashTimerCooldown = null;
        },
      );

      add(dashTimerCooldown!);
      if (teleportDash.parameter) {
        _teleport();
      }
      _dashBeginFunctionsCall();
    }
  }

  void dash() {
    if (!_dashCheck()) {
      return;
    }
    final dashAnimation = entityAnimationsGroup.animations?[EntityStatus.dash];
    entityAnimationsGroup.animations?[EntityStatus.dash]?.stepTime =
        dashDuration.parameter / (dashAnimation?.frames.length ?? 1) * 2;
    setEntityAnimation(EntityStatus.dash);
  }

  void dashMove(double dt) {
    final absDashDistanceGoal = dashDistanceGoal!.abs();
    final distance = ((dashDistanceGoal! / dashDuration.parameter) * dt)
        .clamp(-absDashDistanceGoal, absDashDistanceGoal);
    body.setTransform(body.position + (dashDelta! * distance), 0);
    dashedDistance += distance.abs();
    _dashOngoingFunctionsCall();
  }

  void dashMoveCheck(double dt) {
    if (isDashing && dashDelta != null) {
      if (dashedDistance > dashDistanceGoal!.abs()) {
        _finishDash();
        return;
      }
      dashMove(dt);
    }
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    dashCooldown = (childEntity.parentEntity as DashFunctionality).dashCooldown;
    // invincibleWhileDashing =
    //     (childEntity.parentEntity as DashFunctionality).invincibleWhileDashing;
    collisionWhileDashing =
        (childEntity.parentEntity as DashFunctionality).collisionWhileDashing;
    teleportDash = (childEntity.parentEntity as DashFunctionality).teleportDash;
    dashDistance = (childEntity.parentEntity as DashFunctionality).dashDistance;
    dashDuration = (childEntity.parentEntity as DashFunctionality).dashDuration;
    dashStaminaCost =
        (childEntity.parentEntity as DashFunctionality).dashStaminaCost;

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    dashCooldown = DoubleParameterManager(baseParameter: 2);

    // invincibleWhileDashing = BoolParameterManager(baseParameter: false);
    collisionWhileDashing = BoolParameterManager(baseParameter: false);
    teleportDash = BoolParameterManager(
      baseParameter: false,
      frequencyDeterminesTruth: false,
    );

    dashDistance = DoubleParameterManager(baseParameter: 1);
    dashDuration = DoubleParameterManager(baseParameter: .2);
    dashStaminaCost = DoubleParameterManager(baseParameter: 28);
    super.initializeParentParameters();
  }

  @override
  bool get isDashing => _isDashing;

  @override
  bool get isInvincible => super.isInvincible || isDashing;

  @override
  void update(double dt) {
    dashMoveCheck(dt);
    super.update(dt);
  }

  void _dashBeginFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null &&
        attr.dashBeginFunctions.isNotEmpty &&
        triggerFunctions) {
      for (final element in attr.dashBeginFunctions) {
        element();
      }
    }
  }

  bool _dashCheck() {
    if (!canDash) {
      return false;
    }

    beginDash();

    return true;
  }

  void _dashEndFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.dashEndFunctions.isNotEmpty && triggerFunctions) {
      for (final element in attr.dashEndFunctions) {
        element();
      }
    }
  }

  void _dashOngoingFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null &&
        attr.dashOngoingFunctions.isNotEmpty &&
        triggerFunctions) {
      for (final element in attr.dashOngoingFunctions) {
        element();
      }
    }
  }

  void _finishDash() {
    _dashEndFunctionsCall();
    dashDelta = null;
    _isDashing = false;
    dashedDistance = 0;
    // collision.removeKey(entityId);
  }

  void _teleport() {
    body.setTransform(
      body.position + (dashDelta!.normalized() * dashDistanceGoal!),
      0,
    );
    _finishDash();
  }
}

mixin JumpFunctionality on Entity, AttributeCallbackFunctionality {
  bool _isJumping = false;

  late final DoubleParameterManager jumpDuration;
  late final DoubleParameterManager jumpStaminaCost;
  late final DoubleParameterManager jumpingInvinciblePercent;

  bool allowJumpingInvincible = true;
  bool isJumpingInvincible = false;
  double jumpHeight = .5;

  bool get cantJump =>
      isJumping ||
      isDashing ||
      !movementEnabled.parameter ||
      isDead ||
      (this is StaminaFunctionality
          ? !(this as StaminaFunctionality)
              .hasEnoughStamina(jumpStaminaCost.parameter)
          : false);

  Future<void> jump([bool forceJump = false]) async {
    if (!_jumpCheck(forceJump)) {
      return;
    }
    applyGroundAnimation(
      await spriteAnimations.jumpEffect1,
      false,
      spriteHeight * .2,
    );
    final jumpDurationPar = jumpDuration.parameter;

    final jumpAnimation = entityAnimationsGroup.animations?[EntityStatus.jump];

    entityAnimationsGroup.animations?[EntityStatus.jump]?.stepTime =
        jumpDurationPar / (1 + (jumpAnimation?.frames.length ?? 1));
    setEntityAnimation(EntityStatus.jump);
  }

  void jumpOngoingFunctionsCall(double percent) {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.jumpOngoingFunctions.isNotEmpty) {
      for (final element in attr.jumpOngoingFunctions) {
        element(percent);
      }
    }
  }

  @override
  void initializeChildEntityParameters(ChildEntity childEntity) {
    jumpDuration = (childEntity.parentEntity as JumpFunctionality).jumpDuration;
    jumpStaminaCost =
        (childEntity.parentEntity as JumpFunctionality).jumpStaminaCost;
    jumpingInvinciblePercent = (childEntity.parentEntity as JumpFunctionality)
        .jumpingInvinciblePercent;

    super.initializeChildEntityParameters(childEntity);
  }

  @override
  void initializeParentParameters() {
    jumpDuration = DoubleParameterManager(baseParameter: .6);
    jumpStaminaCost = DoubleParameterManager(baseParameter: 10);
    jumpingInvinciblePercent = DoubleParameterManager(
      baseParameter: .5,
      maxParameter: 1,
    );

    super.initializeParentParameters();
  }

  //JUMP

  @override
  bool get isJumping => _isJumping;

  void _jumpBeginFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.jumpBeginFunctions.isNotEmpty) {
      for (final element in attr.jumpBeginFunctions) {
        element();
      }
    }
  }

  bool _jumpCheck([bool forceJump = false]) {
    if (!forceJump && cantJump) {
      return false;
    }

    _jumpInit();

    return true;
  }

  void _jumpEndFunctionsCall() {
    final attr = attributeFunctionsFunctionality;
    if (attr != null && attr.jumpEndFunctions.isNotEmpty) {
      for (final element in attr.jumpEndFunctions) {
        element();
      }
    }
  }

  Future<void> _jumpInit() async {
    if (this is StaminaFunctionality) {
      (this as StaminaFunctionality).modifyStamina(-jumpStaminaCost.parameter);
    }
    final jumpDurationPar = jumpDuration.parameter;

    _isJumping = true;
    var elapsed = 0.0;
    final min = (jumpDurationPar / 2) -
        jumpDurationPar * (jumpingInvinciblePercent.parameter / 2);
    final max = (jumpDurationPar / 2) +
        jumpDurationPar * (jumpingInvinciblePercent.parameter / 2);

    final controller = EffectController(
      duration: jumpDurationPar * 1.5,
      curve: Curves.easeOut,
      reverseDuration: jumpDurationPar * 1,
      reverseCurve: Curves.ease,
    );

    if (allowJumpingInvincible) {
      void onUpdateTick(double dt) {
        elapsed += dt;

        isJumpingInvincible = elapsed > min && elapsed < max;
        jumpOngoingFunctionsCall(
          (elapsed / jumpDurationPar).clamp(0, 1),
        );

        if (elapsed >= jumpDurationPar || controller.completed) {
          onUpdate.remove(onUpdateTick);
          _isJumping = false;
          _jumpEndFunctionsCall();
        }
      }

      onUpdate.add(onUpdateTick);
    }

    entityAnimationsGroup.add(
      ScaleEffect.by(
        Vector2(1.025, 1.025),
        controller,
      ),
    );
    entityAnimationsGroup.add(
      MoveEffect.by(
        Vector2(0, -jumpHeight),
        controller,
      ),
    );
    if (this is AimFunctionality && isPlayer) {
      (this as AimFunctionality).backJoint?.add(
            MoveEffect.by(
              Vector2(0, -jumpHeight),
              controller,
            ),
          );
    }

    _jumpBeginFunctionsCall();
  }
}

mixin ExpendableFunctionality on Entity {
  Expendable? currentExpendable;

  void onExpendableFunctions(Expendable expendable) {
    if (this is AttributeCallbackFunctionality) {
      final attr = this as AttributeCallbackFunctionality;
      for (final element in attr.onExpendableUsed) {
        element.call(expendable);
      }
    }
  }

  void pickupExpendable(Expendable groundExpendable) {
    if (this is AttributeCallbackFunctionality) {
      final attr = this as AttributeCallbackFunctionality;
      for (final element in attr.onItemPickup) {
        element.call(groundExpendable);
      }
    }

    if (groundExpendable.instantApply) {
      groundExpendable.applyExpendable();
      onExpendableFunctions(groundExpendable);
      return;
    }

    currentExpendable = groundExpendable;
    gameEnviroment.hud.currentExpendable = groundExpendable;
  }

  void useExpendable() {
    if (currentExpendable != null && currentExpendable!.applyExpendable()) {
      onExpendableFunctions(currentExpendable!);
      currentExpendable = null;
      if (enviroment is GameEnviroment) {
        gameEnviroment.hud.currentExpendable = null;
      }
    }
  }
}
