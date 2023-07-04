import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_app/entities/entity.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

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
      weaponTipCenter = PositionComponent(
          anchor: Anchor.center,
          position: Vector2(0, weaponSpriteAnimation!.size.y));
      weaponBase?.add(weaponSpriteAnimation!);
      weaponBase?.add(weaponTipCenter!);
      weaponBase?.add(weaponTip!);
    }

    add(weaponBase!);
    weapon!.parents[jointPosition] = this;
  }
}

abstract class Weapon extends Component {
  Weapon(int newUpgradeLevel, this.entityAncestor) {
    assert(
        this is! ProjectileFunctionality ||
            (this as ProjectileFunctionality).projectileType != null,
        "Projectile weapon types need a projectile type");
    entityAncestor.add(this);
    newUpgradeLevel = upgradeLevel.clamp(0, weaponType.maxLevel);
    applyWeaponUpgrade(newUpgradeLevel);
  }
  Random rng = Random();

  bool isSecondaryWeapon = false;

  bool get isReloading => this is ReloadFunctionality
      ? (this as ReloadFunctionality).reloadTimer != null
      : false;

  //META INFORMATION

  bool get hasAltAttack => this is SecondaryFunctionality;

  abstract WeaponType weaponType;

  int upgradeLevel = 0;

  AimFunctionality entityAncestor;

  double get durationHeld;

  //DAMAGE increase flat
  //DamageType, min, max
  ///Min damage is added to min damage calculation, same with max
  Map<DamageType, (double, double)> damageIncrease = {};

  //DamageType, min, max
  abstract Map<DamageType, (double, double)> baseDamageLevels;

  List<DamageInstance> get damage {
    List<DamageInstance> returnList = [];

    for (var element in baseDamageLevels.entries) {
      var min = element.value.$1;
      var max = element.value.$2;
      if (damageIncrease.containsKey(element.key)) {
        min += damageIncrease[element.key]?.$1 ?? 0;
        max += damageIncrease[element.key]?.$2 ?? 0;
      }
      returnList.add(DamageInstance(
          damageBase: ((rng.nextDouble() * max - min) + min),
          damageType: element.key,
          duration: entityAncestor.damageDuration));
    }

    return returnList;
  }

  //ATTRIBUTES
  bool get weaponCanChain => maxChainingTargets > 0;

  int maxChainingTargets = 0;

  abstract final double baseAttackRate;

  double attackRateIncrease = 0;

  double get attackRate => baseAttackRate - attackRateIncrease;

  abstract double weaponRandomnessPercent;

  //VISUAL
  abstract List<WeaponSpritePosition> spirteComponentPositions;
  FutureOr<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint);
  abstract double distanceFromPlayer;
  abstract double tipPositionPercent;
  abstract double length;
  Map<WeaponSpritePosition, PlayerAttachmentJointComponent> parents = {};
  bool removeSpriteOnAttack = false;

  bool isHoming = false;

  @override
  FutureOr<void> onLoad() async {
    await super.onLoad();
    setWeaponStatus(weaponStatus);
  }

  //Weapon state info
  double get attackRateSecondComparison => 1 / attackRate;

  void applyWeaponUpgrade(int newUpgradeLevel) {
    newUpgradeLevel = upgradeLevel.clamp(0, weaponType.maxLevel);
  }

  void removeWeaponUpgrade() {}

  void startAltAttacking();
  void endAltAttacking();

  void startAttacking();
  void endAttacking() {}

  void weaponSwappedFrom() {}
  void weaponSwappedTo() {}

  /// Returns true if an attack occured, otherwise false.
  void attackAttempt() {
    if (removeSpriteOnAttack) {
      entityAncestor.backJoint.weaponSpriteAnimation?.opacity = 0;
      entityAncestor.handJoint.weaponSpriteAnimation?.opacity = 0;
    }
  }

  WeaponStatus weaponStatus = WeaponStatus.idle;

  ///Sets the current status of the weapon, i.e. idle, shooting, reloading
  void setWeaponStatus(WeaponStatus weaponStatus) {
    this.weaponStatus = weaponStatus;
    for (var element in parents.entries) {
      element.value.weaponSpriteAnimation?.setWeaponStatus(this.weaponStatus);
    }
  }
}

abstract class SecondaryWeaponAbility extends Component {
  SecondaryWeaponAbility(this.weapon, this.cooldown);

  Weapon weapon;
  double cooldown;
  TimerComponent? cooldownTimer;
  ReloadAnimation? reloadAnimation;
  bool get isCoolingDown => cooldownTimer != null;

  void removeReloadAnimation() {
    reloadAnimation?.removeFromParent();
    reloadAnimation = null;
  }

  void startAttacking() {
    if (isCoolingDown) return;
    reloadAnimation = ReloadAnimation(cooldown, weapon.entityAncestor, true)
      ..addToParent(weapon.entityAncestor);

    cooldownTimer = TimerComponent(
      period: cooldown,
      removeOnFinish: true,
      onTick: () {
        cooldownTimer = null;
      },
    )..addToParent(this);
  }

  void endAttacking();
}

///Reloads the weapon and mag dumps at a firerate of approx 5x original
class RapidFire extends SecondaryWeaponAbility {
  RapidFire(super.weapon, super.cooldown, {this.attackRateIncrease = 5});
  TimerComponent? rapidFireTimer;
  bool get isCurrentlyRunning => rapidFireTimer != null;
  double attackRateIncrease;
  @override
  void endAttacking() {}

  @override
  void startAttacking() async {
    if (isCoolingDown || isCurrentlyRunning) return;

    double weaponAttackRate = weapon.attackRate;
    if (weapon is! ReloadFunctionality) {
      return;
    }

    final reload = weapon as ReloadFunctionality;

    if (reload.isReloading) {
      reload.stopReloading();
    } else {
      reload.spentAttacks = 0;
    }
    rapidFireTimer = TimerComponent(
      repeat: true,
      period: weaponAttackRate / attackRateIncrease,
      autoStart: true,
      onTick: () {
        if (weapon is SemiAutomatic) {
          (weapon as SemiAutomatic).durationHeld = weapon.attackRate / 2;
          weapon.attackAttempt();
          (weapon as SemiAutomatic).durationHeld = 0;
        } else {
          weapon.attackAttempt();
        }

        reload.reloadCheck();
        if (reload.isReloading) {
          rapidFireTimer?.timer.stop();
          rapidFireTimer?.removeFromParent();
          rapidFireTimer = null;
        }
      },
    );
    add(rapidFireTimer!);

    super.startAttacking();
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

  void setWeaponStatus(WeaponStatus newWeaponStatus,
      [SpriteAnimation? attackAnimation]) {
    if (newWeaponStatus == WeaponStatus.spawn) {
      animation = spawnAnimation ?? idleAnimation;
      currentStatus = newWeaponStatus;
      return;
    }

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
  }
}
