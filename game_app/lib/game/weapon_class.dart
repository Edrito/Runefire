import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:game_app/game/entity.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/weapons.dart';
import 'package:game_app/game/projectiles.dart';

import '../functions/vector_functions.dart';

abstract class Weapon extends SpriteComponent
    with HasAncestor<Entity>, HasGameRef<GameplayGame> {
  Weapon(this.weaponTypes, this.spriteString) {
    assert(
        !weaponTypes.contains(WeaponType.projectile) || projectileType != null,
        "Projectile weapon types need a projectile type");
  }

  //Weapon attributes
  abstract double distanceFromPlayer;
  abstract int count;
  abstract double damage;
  abstract double fireRate;
  abstract bool holdAndRelease;
  abstract int maxAmmo;
  abstract double maxSpreadDegrees;
  abstract int pierce;
  abstract double projectileVelocity;
  abstract double reloadTime;
  abstract double tipPositionPercent;
  abstract double weaponRandomnessPercent;
  abstract bool isHoming;
  abstract bool isChaining;

  //The longer the weapon is held, the more count
  abstract bool countIncreaseWithTime;
  int? additionalCount;

  //Sprites, types and things that bite
  final String spriteString;
  List<WeaponType> weaponTypes;
  abstract ProjectileType? projectileType;
  abstract Sprite projectileSprite;
  abstract bool allowProjectileRotation;
  late PositionComponent centerOfWeapon;
  late PositionComponent tipOfWeapon;
  abstract double length;

  //Weapon state info
  bool holding = false;
  bool isReloading = false;
  bool isShooting = false;
  abstract int spentAmmo;
  double holdDuration = 0;
  int projectilesFired = 0;
  double timeSinceLastFire = 0;

  // abstract bool followRandomPath;
  // List<Vector2> randomPath = [];
  // bool resetRandomPath = true;
  // double projectileDeltaRotationSpeed = 0;

  @override
  FutureOr<void> onLoad() async {
    timeSinceLastFire = fireRateSecondComparison;
    priority = 200;
    sprite = await Sprite.load(spriteString);
    size = sprite!.srcSize.scaled(length / sprite!.srcSize.y);
    anchor = Anchor.topCenter;
    tipPositionPercent = tipPositionPercent.clamp(0, 1);
    tipOfWeapon = PositionComponent(
        size: Vector2.zero(),
        position: Vector2(size.x * tipPositionPercent, size.y));
    centerOfWeapon = PositionComponent(
        size: Vector2.zero(), position: Vector2(size.x * .5, size.y));
    add(tipOfWeapon);
    add(centerOfWeapon);
    return super.onLoad();
  }

  void additionalCountCheck() {
    if (countIncreaseWithTime) {
      additionalCount = holdDuration.round();
    }
  }

  @override
  void update(double dt) {
    if (timeSinceLastFire < fireRateSecondComparison) {
      timeSinceLastFire += dt;
    }

    additionalCountCheck();
    reloadCheck();
    holdAndReleaseCheck(dt);

    if (isShooting) {
      isShooting = false;
    }

    super.update(dt);
  }

  double get fireRateSecondComparison => 1 / fireRate;
  int get remainingShots => maxAmmo - spentAmmo;

  List<BodyComponent> generateProjectileFunction() {
    var deltaDirection = (centerOfWeapon.absolutePosition -
            ancestor.aimingAnglePosition.absolutePosition)
        .normalized();

    List<BodyComponent> returnList = [];

    // if (followRandomPath && resetRandomPath) {
    // deltaListSaved = [...generateRandomDeltas(deltaDirection, 10, 100, 50)];
    //   resetRandomPath = false;
    // }

    List<Vector2> temp = splitVector2DeltaInCone(
        deltaDirection, count + (additionalCount ?? 0), maxSpreadDegrees);

    for (var deltaDirection in temp) {
      if (projectileType == null) continue;
      returnList.add(projectileType!.generateProjectile(
          speedVar:
              (randomizeVector2Delta(deltaDirection, weaponRandomnessPercent) *
                      projectileVelocity) +
                  ancestor.body.linearVelocity,
          originPositionVar:
              tipOfWeapon.absolutePosition + ancestor.body.position,
          ancestorVar: this,
          idVar: (deltaDirection.x + projectilesFired++).toString()));
    }

    return returnList;
  }

  void holdAndReleaseCheck(double dt) {
    if (!isShooting && holding) {
      holding = false;
      shootCheck(dt, true);
      holdDuration = 0;
      // resetRandomPath = true;
    }
  }

  void reloadCheck() {
    if (remainingShots != 0 || isReloading) return;
    isReloading = true;
    Future.delayed(Duration(milliseconds: (reloadTime * 1000).round()))
        .then((_) {
      isReloading = false;
      spentAmmo = 0;
    });
  }

  void shoot() {
    spentAmmo++;

    game.enemyManagement.addAll(generateProjectileFunction());
    add(MoveEffect.by(Vector2(0, -.05),
        EffectController(duration: .05, reverseDuration: .05)));
    add(RotateEffect.by(isFlippedHorizontally ? -.05 : .05,
        EffectController(duration: .1, reverseDuration: .1)));
    timeSinceLastFire = 0;
  }

  bool shootCheck(double dt, [bool releaseWeapon = false]) {
    isShooting = true;

    if (!releaseWeapon) {
      holdDuration += dt;
      holding = true;
      if (holdAndRelease) return false;
    }

    final canShoot = isLoaded &&
        !isReloading &&
        (timeSinceLastFire >= fireRateSecondComparison) &&
        (!holdAndRelease ||
            ((holdAndRelease && holdDuration > fireRateSecondComparison) &&
                !holding));

    if (!canShoot) {
      if (timeSinceLastFire < fireRateSecondComparison) {
        timeSinceLastFire += dt;
      }
      return false;
    }

    shoot();
    return true;
  }
}
