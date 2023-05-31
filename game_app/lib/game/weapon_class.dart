import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:game_app/functions/custom_timer_componenet.dart';
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
  abstract int spentAmmo;

  int attackTicks = 0;

  double get getHoldDuration => attackTicks * fireRate;

  // abstract bool followRandomPath;
  // List<Vector2> randomPath = [];
  // bool resetRandomPath = true;
  // double projectileDeltaRotationSpeed = 0;

  @override
  FutureOr<void> onLoad() async {
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
      additionalCount = getHoldDuration.round();
    }
  }

  double get fireRateSecondComparison => 1 / fireRate;
  int? get remainingShots => maxAmmo == null ? null : maxAmmo! - spentAmmo;

  List<BodyComponent> generateProjectileFunction() {
    var deltaDirection = (centerOfWeapon.absolutePosition -
            ancestor.aimingAnglePosition.absolutePosition)
        .normalized();

    List<BodyComponent> returnList = [];

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
          idVar: (deltaDirection.x + attackTicks).toString()));
    }

    return returnList;
  }

  CustomTimerComponent? reloadTimer;

  void reloadCheck() {
    if (remainingShots != 0 || reloadTimer != null) return;
    reloadTimer = CustomTimerComponent(
      period: reloadTime,
      removeOnFinish: true,
      onTick: () {
        spentAmmo = 0;
        reloadTimer = null;
        if (shootingTimer != null) {
          shootingTimer?.timer.start();
          attackTick();
        }
      },
    );
    add(reloadTimer!);
  }

  void shoot() {
    spentAmmo++;
    game.enemyManagement.addAll(generateProjectileFunction());
    add(MoveEffect.by(Vector2(0, -.05),
        EffectController(duration: .05, reverseDuration: .05)));
    add(RotateEffect.by(isFlippedHorizontally ? -.05 : .05,
        EffectController(duration: .1, reverseDuration: .1)));
  }

  CustomTimerComponent? shootingTimer;

  void attackTick() {
    if (reloadTimer != null) return;
    attackTicks++;
    additionalCountCheck();
    shootCheck();
    reloadCheck();
  }

  void startAttacking() {
    if (shootingTimer != null) return;
    shootingTimer = CustomTimerComponent(
      period: fireRate,
      repeat: true,
      onTick: attackTick,
    );
    attackTick();
    add(shootingTimer!);
  }

  void endAttacking() {
    shootingTimer?.removeFromParent();
    shootingTimer = null;
    if (holdAndRelease) {
      shootCheck();
    }
  }

  bool shootCheck() {
    final canShoot = isLoaded &&
        ((!holdAndRelease && shootingTimer != null) ||
            (shootingTimer == null && holdAndRelease && attackTicks > 0));

    if (!canShoot) {
      return false;
    }
    shoot();
    return true;
  }
}
