import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:game_app/game/games.dart';
import 'package:game_app/game/player.dart';
import 'package:game_app/game/projectile_weapons.dart';
import 'package:game_app/game/projectiles.dart';

import '../functions/functions.dart';

abstract class ProjectileWeapon extends RangedWeapon {
  ProjectileWeapon(this._weaponType) : super(_weaponType.getFilename());

  List<Vector2> deltaListSaved = [];
  abstract double fireRate;
  abstract bool holdAndRelease;
  double holdDuration = 0;
  bool holding = false;
  bool isShooting = false;
  abstract int maxAmmo;
  abstract BodyComponent projectile;
  abstract Sprite projectileSprite;
  abstract bool allowProjectileRotation;
  abstract double projectileVelocity;
  bool resetRandomPath = true;
  abstract int spentAmmo;
  double timeSinceLastFire = 0;
  abstract double weaponVariation;
  abstract double reloadTime;

  final ProjectileWeaponType _weaponType;

  @override
  FutureOr<void> onLoad() {
    timeSinceLastFire = fireRateSecondComparison;
    return super.onLoad();
  }

  void reload() {
    isReloading = true;
    Future.delayed(Duration(milliseconds: (reloadTime * 1000).round()))
        .then((_) {
      isReloading = false;
      spentAmmo = 0;
    });
  }

  @override
  void update(double dt) {
    if (timeSinceLastFire < fireRateSecondComparison) {
      timeSinceLastFire += dt;
    }

    if (remainingShots == 0 && !isReloading) {
      reload();
    }

    if (!isShooting && holding) {
      holding = false;
      shoot(dt, true);
      holdDuration = 0;
      resetRandomPath = true;
      isShooting = false;
    } else if (isShooting) {
      isShooting = false;
    }

    super.update(dt);
  }

  double get fireRateSecondComparison => 1 / fireRate;

  int get remainingShots => maxAmmo - spentAmmo;

  List<Vector2> generateAnglesInCone(
      Vector2 angle, int count, double maxAngleVarianceDegrees) {
    List<Vector2> angles = [];

    // Convert maxAngleVariance from degrees to radians
    double maxAngleVariance = radians(maxAngleVarianceDegrees);

    // Calculate the step size for evenly spreading the angles
    double stepSize = maxAngleVariance / (count - 1);

    // Calculate the starting angle
    double startAngle = radiansBetweenPoints(angle, Vector2(0.000001, -0.0000));

    // Generate the angles
    startAngle -= maxAngleVariance / 2;

    for (int i = 0; i < count; i++) {
      double currentAngle = startAngle + (stepSize * i);

      // Convert the angle back to Vector2
      double x = cos(currentAngle);
      double y = sin(currentAngle);

      angles.add(Vector2(x, y));
    }

    return angles;
  }

  List<BodyComponent> generateProjectileFunction() {
    var speed = (centerOfWeapon.absolutePosition -
        ancestor.handParentAnglePosition.absolutePosition);

    List<BodyComponent> returnList = [];

    if (randomPath && resetRandomPath) {
      deltaListSaved = [...generateRandomDeltas(speed, 20, 30, 5)];
      resetRandomPath = false;
    }

    if (count > 1) {
      List<Vector2> temp = generateAnglesInCone(speed, count, maxSpreadDegrees);

      for (var element in temp) {
        returnList.add(Projectile(
            speed: randomizeVector2(element) * projectileVelocity,
            originPosition:
                tipOfWeapon.absolutePosition + ancestor.body.position,
            projectileSprite: projectileSprite,
            ancestor: this));
      }
    } else {
      returnList.add(Projectile(
          speed: randomizeVector2(speed) * projectileVelocity,
          // speed: randomizeVector2(speed) * 1,
          originPosition: tipOfWeapon.absolutePosition + ancestor.body.position,
          projectileSprite: projectileSprite,
          ancestor: this));
    }

    return returnList;
  }

  Vector2 randomizeVector2(Vector2 element) {
    var random = Vector2.random() * weaponVariation;
    random -= Vector2.all(weaponVariation / 2);
    element = element + random;
    element = element.normalized();
    return element;
  }

  bool shoot(double dt, [bool releaseWeapon = false]) {
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
    spentAmmo++;
    game.enemyManagement.addAll(generateProjectileFunction());
    add(MoveEffect.by(Vector2(0, -.05),
        EffectController(duration: .05, reverseDuration: .05)));
    add(RotateEffect.by(isFlippedHorizontally ? -.05 : .05,
        EffectController(duration: .1, reverseDuration: .1)));
    timeSinceLastFire = 0;
    return true;
  }

  bool isReloading = false;
}

abstract class RangedWeapon extends SpriteComponent
    with HasGameRef<GameplayGame>, HasAncestor<Player> {
  RangedWeapon(this.spriteString);

  abstract final double distanceFromPlayer;
  final String spriteString;

  late PositionComponent centerOfWeapon;
  abstract int count;
  abstract double length;
  abstract double maxSpreadDegrees;
  double rotationSpeed = 0;
  abstract double damage;
  abstract bool isHoming;
  abstract int pierce;
  abstract bool randomPath;
  late PositionComponent tipOfWeapon;
  abstract double tipPositionPercent;

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
}
