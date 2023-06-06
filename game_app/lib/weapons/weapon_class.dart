import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/weapons/swings.dart';
import 'package:game_app/weapons/weapons.dart';
import 'package:game_app/weapons/projectiles.dart';

import '../functions/vector_functions.dart';

enum WeaponSpritePosition { hand, mouse, back, none }

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
  // SpriteComponent? spriteComponentFront;
  bool isFrontVisible = false;

  // void calculateSpriteVisibility() {
  //   if (position.y > ancestor.center.y && isFrontVisible) {
  //     isFrontVisible = false;
  //     spriteComponentFront?.opacity = 1;
  //     print('here2');
  //     spriteComponent?.opacity = 0;
  //   } else if (position.y <= ancestor.center.y && !isFrontVisible) {
  //     isFrontVisible = true;
  //     spriteComponentFront?.opacity = 0;
  //     spriteComponent?.opacity = 1;
  //     print('here');
  //   }
  // }

  // SpriteComponent? get spriteComponent =>
  //     isFrontVisible && spriteComponentFront != null
  //         ? spriteComponentFront
  //         : spriteComponent;

  @override
  void update(double dt) {
    // if (jointPosition == WeaponSpritePosition.hand) {
    //   calculateSpriteVisibility();
    // }
    super.update(dt);
  }

  void removePreviousComponents() {
    weaponTip?.removeFromParent();
    spriteComponent?.removeFromParent();
    // spriteComponentFront?.removeFromParent();
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
        !attackTypes.contains(AttackType.projectile) || projectileType != null,
        "Projectile weapon types need a projectile type");
    parentEntity?.gameRef.add(this);

    assert(minDamage <= maxDamage, "Min damage must be lower than max damage");
  }

  abstract int upgradeLevel;

  FutureOr<SpriteComponent> buildSpriteComponent(WeaponSpritePosition position);
  //Weapon attributes
  abstract double distanceFromPlayer;
  abstract int count;
  abstract double minDamage;
  abstract double maxDamage;
  Random rng = Random();
  double get damage => (rng.nextDouble() * maxDamage - minDamage) + minDamage;
  abstract double fireRate; //every X second
  abstract bool holdAndRelease;
  abstract int? maxAmmo;
  abstract double maxSpreadDegrees;
  abstract int pierce;
  abstract double projectileVelocity;
  abstract double reloadTime;
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
  abstract List<AttackType> attackTypes;
  abstract ProjectileType? projectileType;
  abstract Sprite projectileSprite;
  abstract bool allowProjectileRotation;
  abstract double length;

  //Weapon state info
  int spentAttacks = 0;

  int attackTicks = 0;

  double get getHoldDuration => attackTicks * fireRate;

  ///An even number of pairs
  ///Next position - next angle
  ///
  ///...
  List<(Vector2, double)> attackPatterns = [];

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
  int? get remainingAttacks => maxAmmo == null ? null : maxAmmo! - spentAttacks;

  TimerComponent? reloadTimer;

  void reloadCheck() {
    currentSwingPosition = null;
    currentSwingAngle = null;
    if (remainingAttacks != 0 || reloadTimer != null || reloadTime == 0) return;
    if (removeBackSpriteOnAttack) {
      parentEntity?.backJoint.spriteComponent?.opacity = 1;
    }

    reloadTimer = TimerComponent(
      period: reloadTime,
      removeOnFinish: true,
      onTick: () {
        spentAttacks = 0;
        reloadTimer = null;
        if (stopAttacking) {
          attackFinishTick();
        }
        if (attackTimer != null) {
          attackTimer?.timer.start();
          attackTick();
        }
      },
    );
    add(reloadTimer!);
  }

  void shoot() {
    parentEntity?.ancestor.physicsComponent
        .addAll(generateProjectileFunction());
    parentEntity!.handJoint.add(MoveEffect.by(Vector2(0, -.05),
        EffectController(duration: .05, reverseDuration: .05)));
    parentEntity!.handJoint.add(RotateEffect.by(
        parentEntity!.handJoint.isFlippedHorizontally ? -.05 : .05,
        EffectController(duration: .1, reverseDuration: .1)));
  }

  void melee() {
    parentEntity?.add(generateMeleeSwing());
  }

  TimerComponent? attackTimer;

  void attackTick() {
    if (reloadTimer != null) return;
    attackCheck();
    attackTicks++;
  }

  bool holdAndReleaseTrigger = false;

  void attackFinishTick() {
    // attackTimer?.timer.stop();
    attackTimer?.removeFromParent();
    attackTimer = null;
    stopAttacking = false;
    currentSwingAngle = null;
    currentSwingPosition = null;
    attackTicks = 0;
    if (attackTypes.contains(AttackType.melee)) {
      spentAttacks = 0;
    }
  }

  void startAttacking() {
    stopAttacking = false;
    if (attackTimer != null) return;

    attackTimer = TimerComponent(
      period: fireRate,
      repeat: true,
      onTick: () {
        if (stopAttacking) {
          if (removeBackSpriteOnAttack) {
            parentEntity?.backJoint.spriteComponent?.opacity = 1;
          }
          attackFinishTick();
        } else {
          reloadCheck();
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
    spentAttacks++;
    if (attackTypes.contains(AttackType.melee)) {
      currentSwingPosition ??= parentEntity?.handJoint.position.clone();
      currentSwingAngle ??= parentEntity?.handJoint.angle;
      melee();
    }
    if (attackTypes.contains(AttackType.point)) {}
    if (attackTypes.contains(AttackType.projectile)) {
      shoot();
    }

    holdAndReleaseTrigger = false;
    return true;
  }

  Vector2? currentSwingPosition;
  double? currentSwingAngle;

  PositionComponent generateMeleeSwing() {
    int attackPatternIndex = (attackTicks -
            (((attackTicks / (maxAmmo ?? 0)).floor()) * (maxAmmo ?? 0))) *
        2;
    return MeleeAttack(
        (currentSwingPosition ?? Vector2.zero()) * distanceFromPlayer,
        currentSwingAngle,
        attackPatternIndex,
        this);
  }

  List<BodyComponent> generateProjectileFunction() {
    var deltaDirection =
        (parents[WeaponSpritePosition.hand]!.weaponTipCenter!.absolutePosition -
                parentEntity!.handJoint.absolutePosition)
            .normalized();

    List<BodyComponent> returnList = [];

    List<Vector2> temp = splitVector2DeltaInCone(
        deltaDirection, count + (additionalCount ?? 0), maxSpreadDegrees);

    for (var deltaDirection in temp) {
      if (projectileType == null) continue;
      returnList.add(projectileType!.generateProjectile(
          speedVar:
              ((randomizeVector2Delta(deltaDirection, weaponRandomnessPercent) *
                          projectileVelocity) +
                      parentEntity!.body.linearVelocity)
                  .clone(),
          originPositionVar:
              (parents[WeaponSpritePosition.hand]!.weaponTip!.absolutePosition +
                      parentEntity!.body.position)
                  .clone(),
          ancestorVar: this,
          idVar: (deltaDirection.x + attackTicks).toString()));
    }

    return returnList;
  }
}
