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
  bool countIncreaseWithTime = false;

  late CircleComponent circle;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand
  ];

  @override
  bool allowProjectileRotation = true;

  @override
  int attackCount = 1;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.fire: (100, 125.0)
  };

  @override
  double baseAttackTickRate = 1;

  @override
  double length = 2;

  @override
  double maxSpreadDegrees = 270;

  @override
  int basePierce = 0;

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

  @override
  double baseWeaponRandomnessPercent = 0;

  @override
  int get baseAttackCount => 1;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => true;

  @override
  int get baseMaxAttacks => 1;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees => 20;
}

class Pistol extends Weapon
    with
        SemiAutomatic,
        ProjectileFunctionality,
        ReloadFunctionality,
        SecondaryFunctionality,
        MultiWeaponCheck {
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
  int attackCount = 1;

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (3, 8),
    // DamageType.energy: (2, 4)
  };

  @override
  double baseAttackTickRate = .5;

  @override
  int get maxChainingTargets => 5;

  @override
  double length = .5;

  @override
  double maxSpreadDegrees = 40;

  @override
  int basePierce = 5;

  @override
  double projectileVelocity = 25;

  @override
  ProjectileType? projectileType = ProjectileType.bullet;

  @override
  double tipPositionPercent = -.25;

  @override
  double weaponRandomnessPercent = .0;

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
  double baseReloadTime = 2;

  @override
  SemiAutoType semiAutoType = SemiAutoType.regular;

  @override
  double baseWeaponRandomnessPercent = 0.05;

  @override
  // TODO: implement baseAttackCount
  int get baseAttackCount => 1;

  @override
  // TODO: implement baseCountIncreaseWithTime
  bool get baseCountIncreaseWithTime => false;

  @override
  // TODO: implement baseIsHoming
  bool get baseIsHoming => false;

  @override
  // TODO: implement baseMaxAttacks
  int get baseMaxAttacks => 12;

  @override
  // TODO: implement baseMaxChainingTargets
  int get baseMaxChainingTargets => 0;

  @override
  // TODO: implement baseMaxSpreadDegrees
  double get baseMaxSpreadDegrees => 45;
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
  int attackCount = 4;

  @override
  List<WeaponSpritePosition> spirteComponentPositions = [
    WeaponSpritePosition.hand,
  ];

  @override
  Map<DamageType, (double, double)> baseDamageLevels = {
    DamageType.regular: (10, 20.0)
  };
  @override
  double baseAttackTickRate = .5;

  @override
  double length = 5;

  @override
  double baseWeaponRandomnessPercent = .05;

  @override
  int get baseAttackCount => 1;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => false;

  @override
  int baseMaxAttacks = 0;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees => 180;

  @override
  double weaponRandomnessPercent = .0;

  @override
  bool countIncreaseWithTime = false;

  @override
  double maxSpreadDegrees = 50;

  @override
  int basePierce = 4;

  @override
  double projectileVelocity = 200;

  @override
  double baseReloadTime = 1.5;

  @override
  double tipPositionPercent = -.02;

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
  int attackCount = 1;

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
  double baseAttackTickRate = .5;

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
  int basePierce = 5;

  @override
  double baseWeaponRandomnessPercent = .05;

  @override
  int get baseAttackCount => 1;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => false;

  @override
  int baseMaxAttacks = 0;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees => 180;

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

    baseMaxAttacks = (attackHitboxPatterns.length / 2).round();

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
  double baseAttackTickRate = .2;

  @override
  double length = 2;

  @override
  double tipPositionPercent = -.02;

  @override
  double weaponRandomnessPercent = .05;

  @override
  WeaponType weaponType = WeaponType.shiv;

  @override
  bool countIncreaseWithTime = false;

  @override
  double maxSpreadDegrees = 50;

  @override
  double get baseReloadTime => 1;

  @override
  int attackCount = 1;

  @override
  double baseWeaponRandomnessPercent = .05;

  @override
  int get baseAttackCount => 1;

  @override
  bool get baseCountIncreaseWithTime => false;

  @override
  bool get baseIsHoming => false;

  @override
  late int baseMaxAttacks;

  @override
  int get baseMaxChainingTargets => 0;

  @override
  double get baseMaxSpreadDegrees => 180;
}
