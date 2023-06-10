import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:game_app/entities/entity.dart';
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
    if (!newWeapon.spirtePositions.contains(jointPosition)) return;
    weaponClass = newWeapon;
    anchor = Anchor.center;
    var tipPositionPercent = newWeapon.tipPositionPercent.clamp(-.5, .5);
    weaponBase = PositionComponent(
        anchor: Anchor.center,
        position: Vector2(0, newWeapon.distanceFromPlayer));
    spriteComponent = await newWeapon.buildSpriteComponent(jointPosition);
    // spriteComponent!.priority = -100;
    // if (jointPosition == WeaponSpritePosition.hand) {
    //   spriteComponentFront =
    //       await newWeapon.buildSpriteComponent(jointPosition);
    //   spriteComponentFront!.priority = 100;
    //   weaponBase?.add(spriteComponentFront!);
    // }
    priority = 0;
    weaponTip = PositionComponent(
        anchor: Anchor.center,
        position: Vector2(spriteComponent!.size.x * tipPositionPercent,
            spriteComponent!.size.y));

    weaponTipCenter = PositionComponent(
        anchor: Anchor.center, position: Vector2(0, spriteComponent!.size.y));

    weaponBase?.add(weaponTipCenter!);
    weaponBase?.add(weaponTip!);
    weaponBase?.add(spriteComponent!);
    add(weaponBase!);
    weaponClass!.parents[jointPosition] = this;
  }
}

abstract class Weapon extends Component {
  Weapon(this.parentEntity) {
    assert(
        this is! ProjectileFunctionality ||
            (this as ProjectileFunctionality).projectileType != null,
        "Projectile weapon types need a projectile type");
    parentEntity?.gameRef.add(this);

    assert(minDamage <= maxDamage, "Min damage must be lower than max damage");
  }

  abstract int upgradeLevel;

  FutureOr<SpriteComponent> buildSpriteComponent(WeaponSpritePosition position);
  //Weapon attributes
  abstract double distanceFromPlayer;
  double damageIncrease = 1;
  abstract int count;
  abstract double minDamage;
  abstract double maxDamage;
  Random rng = Random();
  double get damage =>
      ((rng.nextDouble() * maxDamage - minDamage) + minDamage) * damageIncrease;
  abstract double baseFireRate; //every X second
  double fireRateIncrease = 1; //every X second

  double get fireRate => baseFireRate / fireRateIncrease;

  abstract bool holdAndRelease;
  abstract double maxSpreadDegrees;
  abstract int pierce;
  abstract double projectileVelocity;
  abstract double tipPositionPercent;
  abstract double weaponRandomnessPercent;
  abstract bool isHoming;
  abstract int chainingTargets;
  abstract List<WeaponSpritePosition> spirtePositions;
  Entity? parentEntity;
  Map<WeaponSpritePosition, PlayerAttachmentJointComponent> parents = {};

  //The longer the weapon is held, the more count
  abstract bool countIncreaseWithTime;
  int? additionalCount;
  bool removeBackSpriteOnAttack = false;

  //Sprites, types and things that bite

  abstract double length;

  //Weapon state info
  int attackTicks = 0;

  double get getHoldDuration => attackTicks * fireRate;

  // abstract bool followRandomPath;
  // List<Vector2> randomPath = [];
  // bool resetRandomPath = true;
  // double projectileDeltaRotationSpeed = 0;

  void additionalCountCheck() {
    if (countIncreaseWithTime) {
      additionalCount = getHoldDuration.round();
    }
  }

  double get fireRateSecondComparison => 1 / fireRate;

  TimerComponent? attackTimer;

  void attackTick() {
    attackCheck();
    attackTicks++;
  }

  bool holdAndReleaseTrigger = false;

  void attackFinishTick() {
    if (removeBackSpriteOnAttack) {
      parentEntity?.backJoint.spriteComponent?.opacity = 1;
    }

    attackTimer?.removeFromParent();
    attackTicks = 0;
    attackTimer = null;
    stopAttacking = false;
  }

  void startAttacking() {
    stopAttacking = false;
    if (attackTimer != null) return;

    attackTimer = TimerComponent(
      period: fireRate,
      repeat: true,
      onTick: () {
        if (stopAttacking) {
          attackFinishTick();
        } else {
          attackTick();
          additionalCountCheck();
          holdAndReleaseTrigger = true;
        }
      },
    );
    attackTick();
    add(attackTimer!);
  }

  bool stopAttacking = false;

  void endAttacking() {
    stopAttacking = true;
    if (holdAndRelease) {
      attackCheck();
    }
  }

  bool attackCheck() {
    final canShoot = ((!holdAndRelease && attackTimer != null) ||
        (stopAttacking && holdAndRelease && holdAndReleaseTrigger));

    if (removeBackSpriteOnAttack) {
      parentEntity?.backJoint.spriteComponent?.opacity = 0;
    }

    if (!canShoot || parentEntity == null) {
      return false;
    }

    if (this is ReloadFunctionality) {
      (this as ReloadFunctionality).spentAttacks++;
    }

    if (this is ProjectileFunctionality) {
      (this as ProjectileFunctionality).shoot();
    }
    if (this is MeleeFunctionality) {
      (this as MeleeFunctionality).melee();
    }
    holdAndReleaseTrigger = false;
    return true;
  }
}
