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
  Weapon? weaponClass;
  PositionComponent? weaponTip;
  PositionComponent? weaponBase;
  PositionComponent? weaponTipCenter;
  SpriteComponent? spriteComponent;
  bool isFrontVisible = false;

  void removePreviousComponents() {
    weaponTip?.removeFromParent();
    spriteComponent?.removeFromParent();
    weaponBase?.removeFromParent();
    weaponTipCenter?.removeFromParent();
    weaponClass = null;
  }

  Future<void> addWeaponClass(Weapon newWeapon) async {
    removePreviousComponents();
    weaponClass = newWeapon;
    anchor = Anchor.center;
    var tipPositionPercent = newWeapon.tipPositionPercent.clamp(-.5, .5);
    weaponBase = PositionComponent(
        anchor: Anchor.center,
        position: Vector2(0, newWeapon.distanceFromPlayer));
    if (newWeapon.spirtePositions.contains(jointPosition)) {
      spriteComponent = await newWeapon.buildSpriteComponent(jointPosition);
      weaponTip = PositionComponent(
          anchor: Anchor.center,
          position: Vector2(spriteComponent!.size.x * tipPositionPercent,
              spriteComponent!.size.y));
      weaponTipCenter = PositionComponent(
          anchor: Anchor.center, position: Vector2(0, spriteComponent!.size.y));
      weaponBase?.add(spriteComponent!);
      weaponBase?.add(weaponTipCenter!);
      weaponBase?.add(weaponTip!);
    }

    priority = 0;

    add(weaponBase!);
    weaponClass!.parents[jointPosition] = this;
  }
}

abstract class Weapon extends Component {
  Weapon(int newUpgradeLevel, this.entityAncestor) {
    assert(
        this is! ProjectileFunctionality ||
            (this as ProjectileFunctionality).projectileType != null,
        "Projectile weapon types need a projectile type");
    entityAncestor.gameRef.add(this);
    newUpgradeLevel = upgradeLevel.clamp(0, maxLevel);
    applyWeaponUpgrade(newUpgradeLevel);
  }
  Random rng = Random();

  bool isSecondaryWeapon = false;

  bool get isReloading => this is ReloadFunctionality
      ? (this as ReloadFunctionality).reloadTimer != null
      : false;

  //META INFORMATION

  bool get hasAltAttack => this is SecondaryFunctionality;

  int upgradeLevel = 0;
  int maxLevel = 5;

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
          damage: ((rng.nextDouble() * max - min) + min),
          damageType: element.key,
          duration: entityAncestor.damageDuration));
    }

    return returnList;
  }

  //ATTRIBUTES
  bool get isChaining => chainingTargets > 0;

  int chainingTargets = 0;
  abstract double baseAttackRate; //every X second
  double attackRateIncrease = 0;

  double get attackRate => baseAttackRate -= attackRateIncrease;
  abstract double weaponRandomnessPercent;

  //VISUAL
  abstract List<WeaponSpritePosition> spirtePositions;
  FutureOr<SpriteComponent> buildSpriteComponent(WeaponSpritePosition position);
  abstract double distanceFromPlayer;
  abstract double tipPositionPercent;
  abstract double length;
  Map<WeaponSpritePosition, PlayerAttachmentJointComponent> parents = {};
  bool removeSpriteOnAttack = false;
  bool allowRapidClicking = false;

  bool isHoming = false;

  //Weapon state info
  double get attackRateSecondComparison => 1 / attackRate;

  void applyWeaponUpgrade(int newUpgradeLevel) {
    upgradeLevel = newUpgradeLevel;
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
      entityAncestor.backJoint.spriteComponent?.opacity = 0;
      entityAncestor.handJoint.spriteComponent?.opacity = 0;
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

///Reloads the weapon and mag dumps at a firerate of approx 10x original
class RapidFire extends SecondaryWeaponAbility {
  RapidFire(super.weapon, super.cooldown, {this.attackRateIncrease = 10});
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
