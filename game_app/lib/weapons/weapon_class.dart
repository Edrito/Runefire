import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../functions/functions.dart';
import '../resources/enums.dart';

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
  }

  Future<void> addWeaponClass(Weapon newWeapon) async {
    removePreviousComponents();
    weapon = newWeapon;
    anchor = Anchor.center;
    var tipPositionPercent = newWeapon.tipPositionPercent.clamp(-.5, .5);
    weaponBase = PositionComponent(
        anchor: Anchor.center,
        position: Vector2(0, newWeapon.distanceFromPlayer));

    if (newWeapon.spirteComponentPositions.contains(jointPosition)) {
      weaponSpriteAnimation =
          await newWeapon.buildSpriteAnimationComponent(this);
      weaponTip = PositionComponent(
          anchor: Anchor.center,
          position: Vector2(weaponSpriteAnimation!.size.x * tipPositionPercent,
              weaponSpriteAnimation!.size.y));
      // weaponTip!.add(CircleComponent(
      //     radius: .1,
      //     paint: BasicPalette.white.paint(),
      //     anchor: Anchor.center));
      weaponTipCenter = PositionComponent(
          anchor: Anchor.center,
          position: Vector2(0, weaponSpriteAnimation!.size.y));
      // weaponTipCenter!.add(CircleComponent(
      //     radius: .1,
      //     paint: BasicPalette.lightRed.paint(),
      //     anchor: Anchor.center));
      weaponBase?.add(weaponSpriteAnimation!);
      weaponBase?.add(weaponTipCenter!);
      weaponBase?.add(weaponTip!);
    }

    add(weaponBase!);
    weapon!.parents[jointPosition] = this;
  }
}

abstract class Weapon extends Component {
  Weapon(int? newUpgradeLevel, this.entityAncestor) {
    assert(
        this is! ProjectileFunctionality ||
            (this as ProjectileFunctionality).projectileType != null,
        "Projectile weapon types need a projectile type");
    entityAncestor?.add(this);

    newUpgradeLevel ??= 1;
    newUpgradeLevel = upgradeLevel.clamp(1, weaponType.maxLevel);

    applyWeaponUpgrade(newUpgradeLevel);
  }
  //META INFORMATION
  bool attackOnAnimationFinish = false;

  bool get hasAltAttack => this is SecondaryFunctionality;

  abstract WeaponType weaponType;

  int upgradeLevel = 0;

  AimFunctionality? entityAncestor;

  double get durationHeld;

  Random rng = Random();
  bool isSecondaryWeapon = false;
  bool get isReloading => this is ReloadFunctionality
      ? (this as ReloadFunctionality).reloadTimer != null
      : false;

  //WEAPON ATTRIBUTES
  abstract final int baseAttackCount;
  int get attackCount =>
      baseAttackCount +
      additionalCountIncrease +
      additionalDurationCountIncrease;

  bool get countIncreaseWithTime => boolAbilityDecipher(
      baseCountIncreaseWithTime, countIncreaseWithTimeIncrease);
  abstract final bool baseCountIncreaseWithTime;
  List<bool> countIncreaseWithTimeIncrease = [];

  int additionalDurationCountIncrease = 0;
  int additionalCountIncrease = 0;

  void additionalCountCheck() {
    if (countIncreaseWithTime) {
      additionalDurationCountIncrease = durationHeld.round();
    }
  }

  double get maxSpreadDegrees =>
      baseMaxSpreadDegrees * maxSpreadDegreesIncrease;
  abstract final double baseMaxSpreadDegrees;
  double maxSpreadDegreesIncrease = 0;

  bool get weaponCanChain => maxChainingTargets > 0;

  int get maxChainingTargets =>
      baseMaxChainingTargets + maxChainingTargetsIncrease;
  abstract final int baseMaxChainingTargets;
  int maxChainingTargetsIncrease = 0;

  abstract final double baseAttackTickRate;
  double attackTickRateIncrease = 0;
  double get attackTickRate =>
      (baseAttackTickRate - attackTickRateIncrease).clamp(0, double.infinity);

  double get weaponRandomnessPercent =>
      baseWeaponRandomnessPercent * weaponRandomnessPercentIncrease;
  abstract double baseWeaponRandomnessPercent;
  double weaponRandomnessPercentIncrease = 0;

  bool get isHoming => boolAbilityDecipher(baseIsHoming, isHomingIncrease);
  abstract final bool baseIsHoming;
  List<bool> isHomingIncrease = [];

  int get homingPower => baseHomingPower + homingPowerIncrease;
  final int baseHomingPower = 1;
  int homingPowerIncrease = 0;

  //DAMAGE increase flat
  //DamageType, min, max
  ///Min damage is added to min damage calculation, same with max
  Map<DamageType, (double, double)> damageIncrease = {};

  //DamageType, min, max
  abstract Map<DamageType, (double, double)> baseDamageLevels;

  List<DamageInstance> get damage => damageCalculations(
      baseDamageLevels, damageIncrease, entityAncestor?.damageDuration);

  //ATTRIBUTES

  //VISUAL
  abstract List<WeaponSpritePosition> spirteComponentPositions;
  FutureOr<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint);
  abstract double distanceFromPlayer;
  abstract double tipPositionPercent;
  abstract double length;
  Map<WeaponSpritePosition, PlayerAttachmentJointComponent> parents = {};
  bool removeSpriteOnAttack = false;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    setWeaponStatus(weaponStatus);
  }

  //Weapon state info
  double get attackRateSecondComparison => 1 / attackTickRate;

  void applyWeaponUpgrade(int newUpgradeLevel) {
    newUpgradeLevel = upgradeLevel.clamp(1, weaponType.maxLevel);
  }

  //Event functions that are modified from attributes
  List<Function(Weapon, Entity)> onKillProjectile = [];
  List<Function(Weapon, Entity)> onHitProjectile = [];
  List<Function(Weapon, Entity)> onKillMelee = [];
  List<Function(Weapon, Entity)> onHitMelee = [];
  List<Function(Weapon)> onFireProjectile = [];
  List<Function(Weapon)> onFireMelee = [];
  List<Function(Weapon)> onReload = [];
  List<Function(Weapon from, Weapon to)> onSwapWeapon = [];

  bool spritesHidden = false;

  bool get attacksAreActive => false;

  void removeWeaponUpgrade() {}

  void startAltAttacking();
  void endAltAttacking();

  void startAttacking();
  void endAttacking() {
    spriteVisibilityCheck();
  }

  void weaponSwappedFrom() {}
  void weaponSwappedTo() {}

  /// Returns true if an attack occured, otherwise false.
  void attackAttempt() {}

  void spriteVisibilityCheck() {
    if (removeSpriteOnAttack) {
      if (attacksAreActive && !spritesHidden) {
        entityAncestor?.backJoint.weaponSpriteAnimation?.opacity = 0;
        entityAncestor?.handJoint.weaponSpriteAnimation?.opacity = 0;
        spritesHidden = true;
      } else if (!attacksAreActive && spritesHidden) {
        final controller = EffectController(duration: .1, curve: Curves.easeIn);
        entityAncestor?.backJoint.weaponSpriteAnimation
            ?.add(OpacityEffect.fadeIn(controller));
        entityAncestor?.handJoint.weaponSpriteAnimation
            ?.add(OpacityEffect.fadeIn(controller));
        spritesHidden = false;
      }
    }
  }

  WeaponStatus weaponStatus = WeaponStatus.idle;

  ///Sets the current status of the weapon, i.e. idle, shooting, reloading
  Future<void> setWeaponStatus(WeaponStatus weaponStatus) async {
    this.weaponStatus = weaponStatus;
    List<Future> futures = [];
    for (var element in parents.entries) {
      if (element.value.weaponSpriteAnimation == null) continue;

      futures.add(element.value.weaponSpriteAnimation!
          .setWeaponStatus(this.weaponStatus));
    }
    await Future.wait(futures);
  }
}

///Custom SpriteAnimation that attaches to each joint on an entity that is defined
///within the current weapon parameters
///
///Based on the current action of the weapon, this will display different kinds
///of animations.
class WeaponSpriteAnimation extends SpriteAnimationComponent {
  WeaponSpriteAnimation(
      {required this.idleAnimation,
      this.attackAnimation,
      this.chargeAnimation,
      this.reloadAnimation,
      this.spawnAnimation,
      this.idleOnly = false,
      required this.parentJoint}) {
    animation = idleAnimation;
    anchor = Anchor.topCenter;
    size = animation!.frames.first.sprite.srcSize.scaled(
        parentJoint.weapon!.length / animation!.frames.first.sprite.srcSize.y);
  }
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

  bool tempAnimationPlaying = false;

  void applyAnimation(SpriteAnimation? animation) {
    this.animation = animation;
    initTicker();
  }

  void initTicker() {
    tempAnimationPlaying = true;
    animationTicker?.onComplete = tickerComplete;
  }

  void tickerComplete() {
    tempAnimationPlaying = false;
    currentStatus = statusQueue ?? currentStatus;
    animation = animationQueue;
  }

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

    switch (newWeaponStatus) {
      case WeaponStatus.spawn:
        if (spawnAnimation == null) break;
        assert(!spawnAnimation!.loop, "Temp animations must not loop");
        applyAnimation(spawnAnimation);

        break;
      case WeaponStatus.attack:
        if (attackAnimation == null) break;
        assert(!attackAnimation.loop, "Temp animations must not loop");
        applyAnimation(attackAnimation);

        break;
      case WeaponStatus.reload:
        if (parentJoint.weapon is! ReloadFunctionality ||
            reloadAnimation == null) break;

        assert(!reloadAnimation!.loop, "Temp animations must not loop");
        reloadAnimation?.stepTime =
            (parentJoint.weapon as ReloadFunctionality).reloadTime /
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

    if (tempAnimationPlaying) {
      statusQueue = newWeaponStatus;
      animationQueue = animation;
    } else {
      currentStatus = newWeaponStatus;
    }

    await animationTicker?.completed;
  }
}
