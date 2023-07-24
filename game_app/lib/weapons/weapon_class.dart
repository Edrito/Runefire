import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flutter/widgets.dart';
import 'package:game_app/entities/entity.dart';
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

    newUpgradeLevel ??= 0;
    changeLevel(newUpgradeLevel, weaponType.maxLevel);
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

  List<DamageInstance> get calculateDamage => damageCalculations(
        baseDamage,
        entityAncestor!,
        sourceWeapon: this,
        duration: entityAncestor?.durationPercentIncrease.parameter,
      );

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
  void weaponSwappedTo() {}

  @mustCallSuper
  void attack([double holdDurationPercent = 1]) {}

  /// Returns true if an attack occured, otherwise false.
  void attackAttempt([double holdDurationPercent = 1]) {
    if (entityAncestor?.isDead ?? false) return;
    attack(holdDurationPercent);
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
  PlayerWeapon(super.newUpgradeLevel, super.entityAncestor) {
    maxLevel = weaponType.maxLevel;
  }
  @override
  late int maxLevel;
}

///Custom SpriteAnimation that attaches to each joint on an entity that is defined
///within the current weapon parameters
///
///Based on the current action of the weapon, this will display different kinds
///of animations.
class WeaponSpriteAnimation extends SpriteAnimationComponent {
  WeaponSpriteAnimation(this.spriteOffset, this.tipOffset, this.idleAnimation,
      {this.attackAnimation,
      this.chargeAnimation,
      this.reloadAnimation,
      this.muzzleFlash,
      this.spawnAnimation,
      this.idleOnly = false,
      required this.parentJoint}) {
    animation = idleAnimation;
    anchor = Anchor.topCenter;
    size = animation!.frames.first.sprite.srcSize.scaled(
        parentJoint.weapon!.length / animation!.frames.first.sprite.srcSize.y);
    priority = attackPriority;
    position = spriteOffset;
  }

  Vector2 spriteOffset;
  Vector2 tipOffset;

  WeaponStatus currentStatus = WeaponStatus.idle;
  PlayerAttachmentJointComponent parentJoint;
  bool idleOnly;
  WeaponStatus? statusQueue;
  SpriteAnimation? animationQueue;

  SpriteAnimation idleAnimation;
  SpriteAnimation? spawnAnimation;
  SpriteAnimation? reloadAnimation;
  SpriteAnimation? attackAnimation;
  SpriteAnimation? chargeAnimation;
  SpriteAnimation? muzzleFlash;

  bool tempAnimationPlaying = false;

  void applyAnimation(SpriteAnimation? animation) {
    this.animation = animation?.clone();
    initTicker();
  }

  void initTicker() {
    tempAnimationPlaying = true;
    animationTicker?.onComplete = tickerComplete;
  }

  void addMuzzleFlash() {
    if (muzzleFlash == null || muzzleFlash!.loop) return;
    final muzzleFlashComponent = SpriteAnimationComponent(
        animation: muzzleFlash,
        size: muzzleFlash!.frames.first.sprite.srcSize.scaled(
                parentJoint.weapon!.length /
                    muzzleFlash!.frames.first.sprite.srcSize.y) /
            2,
        anchor: Anchor.topCenter,
        priority: attackPriority);
    parentJoint.weaponTip?.add(muzzleFlashComponent);
    muzzleFlashComponent.animationTicker?.onComplete = () {
      muzzleFlashComponent.removeFromParent();
    };
  }

  void tickerComplete() {
    tempAnimationPlaying = false;
    currentStatus = statusQueue ?? currentStatus;
    animation = animationQueue ?? idleAnimation;
  }

  @override
  void update(double dt) {
    if (!isAnimationPlaying) {
      animation = idleAnimation;
    }
    super.update(dt);
  }

  bool get isAnimationPlaying => !(animationTicker?.done() ?? true);

  Future<void> setWeaponStatus(WeaponStatus newWeaponStatus,
      [SpriteAnimation? attackAnimation]) async {
    if (newWeaponStatus == WeaponStatus.spawn) {
      animation = spawnAnimation ?? idleAnimation;
      currentStatus = newWeaponStatus;
      return;
    }
    attackAnimation ??= this.attackAnimation;
    if (newWeaponStatus == currentStatus &&
        [WeaponStatus.idle].contains(newWeaponStatus)) return;

    if (tempAnimationPlaying) {
      statusQueue = newWeaponStatus;
      animationQueue = animation;
    } else {
      animationQueue = null;
      currentStatus = newWeaponStatus;
    }

    switch (newWeaponStatus) {
      case WeaponStatus.spawn:
        if (spawnAnimation == null) break;
        assert(!spawnAnimation!.loop, "Temp animations must not loop");
        applyAnimation(spawnAnimation);

        break;
      case WeaponStatus.attack:
        addMuzzleFlash();
        if (attackAnimation == null) break;
        assert(!attackAnimation.loop, "Temp animations must not loop");
        applyAnimation(attackAnimation);
        break;
      case WeaponStatus.reload:
        if (parentJoint.weapon is! ReloadFunctionality ||
            reloadAnimation == null) break;

        assert(!reloadAnimation!.loop, "Temp animations must not loop");
        reloadAnimation?.stepTime =
            (parentJoint.weapon as ReloadFunctionality).reloadTime.parameter /
                reloadAnimation!.frames.length;
        applyAnimation(reloadAnimation);

        break;
      case WeaponStatus.idle:
        animation = idleAnimation;

        break;
      case WeaponStatus.charge:
        animation = chargeAnimation;

        break;
      default:
        animation = idleAnimation;
    }
    animation ??= idleAnimation;

    if (!(animation?.loop ?? false)) {
      await animationTicker?.completed;
    }
  }
}
