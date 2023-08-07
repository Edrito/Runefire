import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:game_app/entities/entity_class.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/resources/data_classes/base.dart';
import 'package:game_app/weapons/secondary_abilities.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:uuid/uuid.dart';
import '../resources/functions/custom_mixins.dart';

import '../resources/enums.dart';
import '../resources/constants/priorities.dart';

class PlayerAttachmentJointComponent extends PositionComponent
    with HasAncestor<Entity> {
  PlayerAttachmentJointComponent(
    this.jointPosition, {
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.nativeAngle,
    super.anchor,
    super.children,
    super.priority,
  });

  WeaponSpritePosition jointPosition;

  Weapon? weapon;
  PositionComponent? weaponTip;
  PositionComponent? weaponBase;
  PositionComponent? weaponTipCenter;
  WeaponSpriteAnimation? weaponSpriteAnimation;
  bool isFrontVisible = false;

  @override
  void update(double dt) {
    this;
    super.update(dt);
  }

  void removePreviousComponents() {
    weaponTip?.removeFromParent();
    weaponSpriteAnimation?.removeFromParent();
    weaponBase?.removeFromParent();
    weaponTipCenter?.removeFromParent();
    weapon = null;
    weaponBase = null;
    weaponTip = null;
    weaponTipCenter = null;
    weaponSpriteAnimation = null;
  }

  Future<void> addWeaponClass(Weapon newWeapon) async {
    removePreviousComponents();
    weapon = newWeapon;
    anchor = Anchor.center;
    weaponBase = PositionComponent(
        anchor: Anchor.center,
        position: Vector2(0, newWeapon.distanceFromPlayer));

    if (newWeapon.spirteComponentPositions.contains(jointPosition)) {
      weaponSpriteAnimation =
          await newWeapon.buildSpriteAnimationComponent(this);

      weaponTip = PositionComponent(
          anchor: Anchor.center, position: weaponSpriteAnimation!.tipOffset);
      weaponTipCenter = PositionComponent(
          anchor: Anchor.center,
          position: Vector2(0, weaponSpriteAnimation!.tipOffset.y));

      weaponSpriteAnimation?.addToParent(weaponBase!);
      weaponTipCenter?.addToParent(weaponBase!);
      weaponTip?.addToParent(weaponBase!);
    }
    if (weaponBase!.parent == null) {
      add(weaponBase!);
    }
    weapon!.weaponAttachmentPoints[jointPosition] = this;
  }
}

abstract class Weapon extends Component with UpgradeFunctions {
  Weapon(int? newUpgradeLevel, this.entityAncestor) {
    assert(
        this is! ProjectileFunctionality ||
            (this as ProjectileFunctionality).projectileType != null,
        "Projectile weapon types need a projectile type");

    maxLevel = weaponType.maxLevel;
    newUpgradeLevel ??= 0;
    changeLevel(newUpgradeLevel);
    weaponId = const Uuid().v4();
  }
  //META INFORMATION
  bool attackOnAnimationFinish = false;

  Weapon? get getSecondaryWeapon {
    if (this is SecondaryFunctionality) {
      return (this as SecondaryFunctionality).secondaryWeapon;
    }
    return null;
  }

  SecondaryWeaponAbility? get getSecondaryAbility {
    if (this is SecondaryFunctionality) {
      return (this as SecondaryFunctionality).secondaryWeaponAbility;
    }
    return null;
  }

  late String weaponId;

  ///String is the ID, for easy removal and addition
  ///Weapon is the weapon itself, preferably the weapon should not have reloadfunctionality
  final Map<String, Weapon> additionalWeapons = {};

  AttributeWeaponFunctionsFunctionality? get attributeFunctionsFunctionality =>
      this is AttributeWeaponFunctionsFunctionality
          ? this as AttributeWeaponFunctionsFunctionality
          : null;

  bool get hasAltAttack => this is SecondaryFunctionality;

  abstract WeaponType weaponType;

  AimFunctionality? entityAncestor;

  double get durationHeld;

  Vector2 baseOffset = Vector2.zero();
  Vector2 tipOffset = Vector2.zero();

  Random rng = Random();
  bool isSecondaryWeapon = false;

  bool get isReloading => this is ReloadFunctionality
      ? (this as ReloadFunctionality).reloadTimer != null
      : false;

  //WEAPON ATTRIBUTES
  final IntParameterManager baseAttackCount =
      IntParameterManager(baseParameter: 1);

  final IntParameterManager pierce = IntParameterManager(baseParameter: 0);

  final BoolParameterManager countIncreaseWithTime =
      BoolParameterManager(baseParameter: false);

  int get attackCount =>
      baseAttackCount.parameter + additionalDurationCountIncrease;

  int additionalDurationCountIncrease = 0;
  void additionalCountCheck() {
    if (countIncreaseWithTime.parameter) {
      additionalDurationCountIncrease = durationHeld.round().clamp(0, 6);
    }
  }

  DoubleParameterManager maxSpreadDegrees =
      DoubleParameterManager(baseParameter: 45);

  DoubleParameterManager knockBackAmount =
      DoubleParameterManager(baseParameter: 0.005);

  IntParameterManager maxChainingTargets =
      IntParameterManager(baseParameter: 0);
  bool get weaponCanChain => maxChainingTargets.parameter > 0;

  final DoubleParameterManager attackTickRate =
      DoubleParameterManager(baseParameter: 1, minParameter: 0.01);

  final DoubleParameterManager weaponRandomnessPercent = DoubleParameterManager(
      baseParameter: 0, minParameter: 0, maxParameter: 1);

  IntParameterManager maxHomingTargets = IntParameterManager(baseParameter: 0);
  bool get weaponCanHome => maxHomingTargets.parameter > 0;

  final DamageParameterManager baseDamage =
      DamageParameterManager(damageBase: {});

  DamageInstance get calculateDamage =>
      damageCalculations(entityAncestor!, baseDamage.damageBase,
          sourceWeapon: this, damageSource: baseDamage);

  //VISUAL
  abstract List<WeaponSpritePosition> spirteComponentPositions;
  FutureOr<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint);
  abstract double distanceFromPlayer;
  abstract double length;
  Map<WeaponSpritePosition, PlayerAttachmentJointComponent>
      weaponAttachmentPoints = {};
  bool removeSpriteOnAttack = false;

  @override
  FutureOr<void> onLoad() async {
    while (maxChainingTargets.parameter > pierce.parameter) {
      pierce.baseParameter++;
    }
    await super.onLoad();
    setWeaponStatus(weaponStatus);
  }

  //Weapon state info
  double get attackRateSecondComparison => 1 / attackTickRate.parameter;

  bool spritesHidden = false;

  bool get attacksAreActive => false;

  void startAltAttacking();
  void endAltAttacking();

  void startAttacking();
  void endAttacking() {
    additionalDurationCountIncrease = 0;
    spriteVisibilityCheck();
  }

  void weaponSwappedFrom() {}
  void weaponSwappedTo() {
    setWeaponStatus(WeaponStatus.spawn);
  }

  @mustCallSuper
  void standardAttack([double holdDurationPercent = 1]) {
    for (var element in additionalWeapons.entries) {
      element.value.standardAttack(holdDurationPercent);
    }
  }

  /// Returns true if an attack occured, otherwise false.
  void attackAttempt([double holdDurationPercent = 1]) {
    if (entityAncestor?.isDead ?? false) return;
    standardAttack(holdDurationPercent);
  }

  void spriteVisibilityCheck() {
    if (removeSpriteOnAttack) {
      if (attacksAreActive && !spritesHidden) {
        entityAncestor?.backJoint.weaponSpriteAnimation?.opacity = 0;
        entityAncestor?.handJoint.weaponSpriteAnimation?.opacity = 0;
        spritesHidden = true;
      } else if (!attacksAreActive && spritesHidden) {
        // final controller = EffectController(duration: .1, curve: Curves.easeIn);

        // entityAncestor?.backJoint.weaponSpriteAnimation
        //     ?.add(OpacityEffect.fadeIn(controller));

        // entityAncestor?.handJoint.weaponSpriteAnimation
        //     ?.add(OpacityEffect.fadeIn(controller));

        entityAncestor?.backJoint.weaponSpriteAnimation?.opacity = 1;
        entityAncestor?.handJoint.weaponSpriteAnimation?.opacity = 1;
        spritesHidden = false;
      }
    }
  }

  WeaponStatus weaponStatus = WeaponStatus.idle;

  ///Sets the current status of the weapon, i.e. idle, shooting, reloading
  Future<void> setWeaponStatus(WeaponStatus weaponStatus) async {
    this.weaponStatus = weaponStatus;
    List<Future> futures = [];
    for (var element in weaponAttachmentPoints.entries) {
      if (element.value.weaponSpriteAnimation == null) continue;

      futures.add(element.value.weaponSpriteAnimation!
          .setWeaponStatus(this.weaponStatus));
    }
    await Future.wait(futures);
  }
}

abstract class PlayerWeapon extends Weapon
    with AttributeWeaponFunctionsFunctionality, SecondaryFunctionality {
  PlayerWeapon(super.newUpgradeLevel, super.entityAncestor);
  @override
  late int? maxLevel;
}

abstract class EnemyWeapon extends Weapon
    with AttributeWeaponFunctionsFunctionality {
  EnemyWeapon(super.newUpgradeLevel, super.entityAncestor);
  @override
  late int? maxLevel;
}

///Custom SpriteAnimation that attaches to each joint on an entity that is defined
///within the current weapon parameters
///
///Based on the current action of the weapon, this will display different kinds
///of animations.
class WeaponSpriteAnimation extends SpriteAnimationComponent {
  WeaponSpriteAnimation(this.spriteOffset, this.tipOffset,
      {required this.weaponAnimations,
      required this.weapon,
      this.flashSize = 2.0,
      this.idleOnly = false,
      required this.parentJoint}) {
    animation = weaponAnimations[WeaponStatus.idle];
    anchor = Anchor.topCenter;
    size = animation!.frames.first.sprite.srcSize.scaled(
        parentJoint.weapon!.length / animation!.frames.first.sprite.srcSize.y);
    priority = attackPriority;
    position = spriteOffset;
  }

  Vector2 spriteOffset;
  Vector2 tipOffset;
  Weapon weapon;
  double flashSize;
  WeaponStatus currentStatus = WeaponStatus.idle;

  Map<dynamic, SpriteAnimation> weaponAnimations;

  PlayerAttachmentJointComponent parentJoint;
  bool idleOnly;
  WeaponStatus? statusQueue;
  SpriteAnimation? animationQueue;

  bool tempAnimationPlaying = false;

  void applyAnimation(SpriteAnimation? animation) {
    this.animation = animation?.clone();
    initTicker();
  }

  void initTicker() {
    tempAnimationPlaying = true;
    animationTicker?.onComplete = tickerComplete;
  }

  void tickerComplete() {
    tempAnimationPlaying = false;
    currentStatus = statusQueue ?? currentStatus;
    animation = animationQueue ?? weaponAnimations[WeaponStatus.idle];
  }

  SpriteAnimationComponent? muzzleFlashComponent;
  void addMuzzleFlash() {
    if (!weaponAnimations.containsKey('muzzle_flash')) return;
    SpriteAnimation muzzleFlash = weaponAnimations['muzzle_flash']!;
    muzzleFlashComponent = SpriteAnimationComponent(
        animation: muzzleFlash,
        // position: Vector2(0, 0),
        size: muzzleFlash.frames.first.sprite.srcSize
            .scaled(flashSize / muzzleFlash.frames.first.sprite.srcSize.y),
        // size: Vector2.all(),
        anchor: Anchor.topCenter,
        priority: attackPriority);
    parentJoint.weaponTip?.add(muzzleFlashComponent!);
    final previousComponent = muzzleFlashComponent;

    previousComponent?.animationTicker?.onComplete = () {
      previousComponent.removeFromParent();
    };
  }

  @override
  void update(double dt) {
    if (!isAnimationPlaying) {
      setWeaponStatus(WeaponStatus.idle);
    }
    super.update(dt);
  }

  bool get isAnimationPlaying => !(animationTicker?.done() ?? true);

  Future<void> weaponCharging() async {
    if (!weaponAnimations.containsKey(WeaponStatus.charge)) return;
    double chargeDuration = weapon.attackTickRate.parameter;
    final chargeAnim = weaponAnimations[WeaponStatus.charge]!;
    applyAnimation(
        chargeAnim..stepTime = (chargeDuration / chargeAnim.frames.length));

    animationQueue = weaponAnimations[WeaponStatus.chargeIdle];
  }

  Future<void> setWeaponStatus(WeaponStatus newWeaponStatus,
      [dynamic key]) async {
    SpriteAnimation? newAnimation =
        weaponAnimations[key] ?? weaponAnimations[newWeaponStatus];

    if (newWeaponStatus == currentStatus &&
        [WeaponStatus.idle].contains(newWeaponStatus)) return;

    if (tempAnimationPlaying) {
      statusQueue = newWeaponStatus;
      animationQueue = newAnimation ?? weaponAnimations[WeaponStatus.idle];
    } else {
      animationQueue = null;
      currentStatus = newWeaponStatus;
    }

    if (newAnimation != null) {
      switch (newWeaponStatus) {
        case WeaponStatus.spawn:
          assert(!newAnimation.loop, "Temp animations must not loop");
          applyAnimation(newAnimation);

          break;
        case WeaponStatus.attack:
          addMuzzleFlash();
          assert(!newAnimation.loop, "Temp animations must not loop");
          applyAnimation(newAnimation);
          break;
        case WeaponStatus.reload:
          if (parentJoint.weapon is! ReloadFunctionality) break;

          assert(!newAnimation.loop, "Temp animations must not loop");
          newAnimation.stepTime =
              (parentJoint.weapon as ReloadFunctionality).reloadTime.parameter /
                  newAnimation.frames.length;
          applyAnimation(newAnimation);

          break;
        case WeaponStatus.idle:
          animation = newAnimation;

          break;
        case WeaponStatus.charge:
          animation = newAnimation;

          break;
        default:
          animation = newAnimation;
      }
    }

    if (!(animation?.loop ?? false)) {
      await animationTicker?.completed;
    }
  }
}
