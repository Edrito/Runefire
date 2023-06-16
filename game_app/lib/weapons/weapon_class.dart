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
    if (!newWeapon.spirtePositions.contains(jointPosition)) return;
    weaponClass = newWeapon;
    anchor = Anchor.center;
    var tipPositionPercent = newWeapon.tipPositionPercent.clamp(-.5, .5);
    weaponBase = PositionComponent(
        anchor: Anchor.center,
        position: Vector2(0, newWeapon.distanceFromPlayer));
    spriteComponent = await newWeapon.buildSpriteComponent(jointPosition);

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
  Weapon(int newUpgradeLevel, this.parentEntity) {
    assert(
        this is! ProjectileFunctionality ||
            (this as ProjectileFunctionality).projectileType != null,
        "Projectile weapon types need a projectile type");
    parentEntity.gameRef.add(this);

    assert(minDamage <= maxDamage, "Min damage must be lower than max damage");
    newUpgradeLevel = upgradeLevel.clamp(0, maxLevel);
    applyWeaponUpgrade(newUpgradeLevel);

    assert(this is! SecondaryAbilityFunctionality ||
        this is! SecondaryWeaponFunctionality);
  }
  Random rng = Random();

  bool get isReloading => this is ReloadFunctionality
      ? (this as ReloadFunctionality).reloadTimer != null
      : false;

  //META INFORMATION

  bool get hasAltAttack =>
      this is SecondaryAbilityFunctionality ||
      this is SecondaryWeaponFunctionality;

  int upgradeLevel = 0;
  int maxLevel = 5;

  AimFunctionality parentEntity;

  double get durationHeld;

  //DAMAGE INFORMATION
  double damageIncrease = 1;
  abstract double minDamage;
  abstract double maxDamage;

  double get damage =>
      ((rng.nextDouble() * maxDamage - minDamage) + minDamage) * damageIncrease;

  //ATTRIBUTES
  bool isChaining = false;
  int chainingTargets = 1;
  abstract double baseAttackRate; //every X second
  double attackRatePercentIncrease = 1;

  double get attackRate => baseAttackRate / attackRatePercentIncrease;
  abstract double weaponRandomnessPercent;

  //VISUAL
  abstract List<WeaponSpritePosition> spirtePositions;
  FutureOr<SpriteComponent> buildSpriteComponent(WeaponSpritePosition position);
  abstract double distanceFromPlayer;
  abstract double tipPositionPercent;
  abstract double length;
  Map<WeaponSpritePosition, PlayerAttachmentJointComponent> parents = {};
  bool removeBackSpriteOnAttack = false;
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
  bool attackAttempt();
}
