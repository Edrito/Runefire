import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:game_app/functions/vector_functions.dart';
import 'package:game_app/weapons/weapon_class.dart';
import 'package:game_app/weapons/weapon_mixin.dart';

import '../entities/entity_mixin.dart';
import '../functions/functions.dart';
import '../resources/enums.dart';

typedef BodyComponentFunction = List<BodyComponent> Function();

class Portal extends Weapon
    with
        ProjectileFunctionality,
        SecondaryFunctionality,
        SemiAutomatic,
        ReloadFunctionality {
  Portal.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  WeaponType weaponType = WeaponType.portal;

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(5, 'weapons/portal.png', 1, true));
    }
  }

  @override
  // TODO: implement chainingTargets
  int get maxChainingTargets => 0;

  @override
  // TODO: implement isHoming
  bool get isHoming => false;

  @override
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand
  ];

  @override
  bool allowProjectileRotation = true;

  @override
  int projectileCount = 1;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.fire: (100, 125.0)
  };

  @override
  double baseAttackRate = 1;

  @override
  double length = 2;

  @override
  int? maxAmmo = 1;

  @override
  double maxSpreadDegrees = 270;

  @override
  int pierce = 0;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 10;

  @override
  ProjectileType? projectileType = ProjectileType.fireball;

  @override
  double tipPositionPercent = -0;

  @override
  double weaponRandomnessPercent = .0;

  @override
  double distanceFromPlayer = 0.2;

  @override
  FutureOr<void> onLoad() async {
    // circle = CircleComponent(
    //     radius: .2, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    // add(circle);
    return super.onLoad();
  }

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  double baseReloadTime = 3;
}

class Pistol extends Weapon
    with
        SemiAutomatic,
        ProjectileFunctionality,
        ReloadFunctionality,
        SecondaryFunctionality {
  Pistol.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);

  @override
  WeaponType weaponType = WeaponType.pistol;

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  bool allowProjectileRotation = true;

  @override
  int projectileCount = 1;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (3, 8),
    // DamageType.energy: (2, 4)
  };

  @override
  double baseAttackRate = .5;

  @override
  bool get isHoming => false;

  @override
  int get maxChainingTargets => 5;

  @override
  double length = .5;

  @override
  double maxSpreadDegrees = 40;

  @override
  int pierce = 5;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 25;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.8;

  @override
  double weaponRandomnessPercent = .05;

  @override
  double distanceFromPlayer = 0;

  @override
  FutureOr<void> onLoad() async {
    // circle = CircleComponent(
    //     radius: .2, paint: Paint()..color = Colors.blue, anchor: Anchor.center);
    // add(circle);
    return super.onLoad();
  }

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand
  ];

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, 'weapons/pistol.png', 1, true));
    }
  }

  @override
  int? maxAmmo = 20;

  @override
  double baseReloadTime = 2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class Shotgun extends Weapon
    with
        ProjectileFunctionality,
        SemiAutomatic,
        ReloadFunctionality,
        SecondaryFunctionality {
  Shotgun.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);
  @override
  WeaponType weaponType = WeaponType.shotgun;
  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
          parentJoint: parentJoint,
          idleAnimation:
              await buildSpriteSheet(1, 'weapons/shotgun.png', 1, true),
        );
    }
  }

  @override
  double distanceFromPlayer = 0;

  @override
  bool allowProjectileRotation = false;

  @override
  int projectileCount = 4;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (10, 20.0)
  };
  @override
  double baseAttackRate = .5;

  @override
  double length = 5;

  @override
  int? maxAmmo = 4;

  @override
  double maxSpreadDegrees = 50;

  @override
  int pierce = 4;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 200;

  @override
  double baseReloadTime = 1.5;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .1;

  @override
  bool countIncreaseWithTime = false;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;
}

class Bow extends Weapon
    with ProjectileFunctionality, SecondaryFunctionality, SemiAutomatic {
  Bow.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor);
  @override
  WeaponType weaponType = WeaponType.bow;
  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  bool allowProjectileRotation = true;
  @override
  ProjectileType? projectileType = ProjectileType.arrow;
  @override
  int projectileCount = 1;

  @override
  double distanceFromPlayer = .2;

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(5, 'weapons/bow.png', 1, true));
    }
  }

  @override
  double baseAttackRate = .5;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.back,
    WeaponSpritePosition.hand,
  ];

  @override
  double length = 2;

  @override
  double maxSpreadDegrees = 40;

  @override
  int pierce = 5;

  @override
  late Sprite projectileSprite;

  @override
  double projectileVelocity = 200;

  @override
  double tipPositionPercent = 0;

  @override
  double weaponRandomnessPercent = .0;

  @override
  bool countIncreaseWithTime = false;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (50, 100.0)
  };
}

class Sword extends Weapon
    with
        MeleeFunctionality,
        // ProjectileFunctionality,
        SecondaryFunctionality,
        FullAutomatic,
        ReloadFunctionality {
  Sword.create(
    int? newUpgradeLevel,
    AimFunctionality? ancestor,
  ) : super(newUpgradeLevel, ancestor) {
    attackHitboxPatterns = [
      (Vector2(.5, 0), -45),
      (Vector2(-1, 1), 45),
      // (Vector2(0, 0), 0),
      // (Vector2(0, 3), 0),
      (Vector2(-.5, 1), 45),
      (Vector2(1, 0), -45),
      (Vector2(.5, 1), -45),
      (Vector2(-.5, -1), 45),
    ];
    spirteComponentPositions.add(WeaponSpritePosition.back);

    maxAmmo = (attackHitboxPatterns.length / 2).round();

    assert(
        attackHitboxPatterns.length.isEven, "Must be an even number of coords");
  }

  @override
  void melee([double chargeAmount = 1]) {
    // if (entityAncestor is DashFunctionality) {
    //   (entityAncestor as DashFunctionality)
    //       .dashInit(power: chargeAmount, weapon: true);
    // }
    super.melee(chargeAmount);
  }

  @override
  FutureOr<void> onLoad() async {
    attackHitboxSpriteAnimations = [
      await buildSpriteSheet(1, 'weapons/sword.png', 1, true),
      await buildSpriteSheet(1, 'weapons/sword.png', 1, true),
      await buildSpriteSheet(1, 'weapons/sword.png', 1, true),
    ];

    attackHitboxSizes = attackHitboxSpriteAnimations.fold<List<Vector2>>(
        [],
        (previousValue, element) => [
              ...previousValue,
              element.frames.first.sprite.srcSize
                  .scaledToDimension(true, length)
            ]);
    return super.onLoad();
  }

  @override
  set setSecondaryFunctionality(item) {
    super.setSecondaryFunctionality = item;
    if (secondaryIsWeapon) {
      spirteComponentPositions.add(WeaponSpritePosition.hand);
      spirteComponentPositions.remove(WeaponSpritePosition.back);
    }
  }

  @override
  void applyWeaponUpgrade(int newUpgradeLevel) {
    removeWeaponUpgrade();
    switch (newUpgradeLevel) {
      case 0:
        break;
      default:
    }
    super.applyWeaponUpgrade(newUpgradeLevel);
  }

  @override
  void removeWeaponUpgrade() {
    switch (upgradeLevel) {
      case 0:
        break;
      default:
    }
  }

  @override
  Future<WeaponSpriteAnimation> buildSpriteAnimationComponent(
      PlayerAttachmentJointComponent parentJoint) async {
    switch (parentJoint.jointPosition) {
      case WeaponSpritePosition.back:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, 'weapons/sword.png', 1, true))
          ..position = Vector2(3.7, -4.5)
          ..angle = radians(45);
      default:
        return WeaponSpriteAnimation(
            parentJoint: parentJoint,
            idleAnimation:
                await buildSpriteSheet(1, 'weapons/sword.png', 1, true));
    }
  }

  @override
  bool get removeSpriteOnAttack => true;

  @override
  double distanceFromPlayer = .2;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (5, 10.0)
  };
  @override
  double baseAttackRate = .3;

  @override
  double length = 2;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  SemiAutoType semiAutoType = SemiAutoType.charge;

  @override
  WeaponType weaponType = WeaponType.shiv;

  @override
  bool allowProjectileRotation = false;

  @override
  bool countIncreaseWithTime = false;

  @override
  double maxSpreadDegrees = 50;

  @override
  int pierce = 1;

  @override
  int projectileCount = 3;

  @override
  ProjectileType? projectileType = ProjectileType.fireball;

  @override
  double projectileVelocity = 20;

  @override
  int? maxAmmo;

  @override
  // TODO: implement baseReloadTime
  double get baseReloadTime => 1;
}
