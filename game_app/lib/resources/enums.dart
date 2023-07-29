import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/player_melee_weapons.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:game_app/weapons/player_projectile_weapons.dart';

import '../entities/enemy.dart';
import '../entities/entity.dart';
import '../game/background.dart';
import '../game/enviroment.dart';
import '../game/enviroment_mixin.dart';
import '../game/forest_game.dart';
import '../game/menu_game.dart';
import '../weapons/projectiles.dart';
import '../weapons/secondary_abilities.dart';
import '../weapons/weapon_class.dart';

enum AudioType {
  sfx,
  music,
  voice,
  ui,
}

enum EnemyType {
  mushroomBrawler,
  mushroomBoss,
}

extension EnemyTypeExtension on EnemyType {
  Enemy build(Vector2 position, GameTimerFunctionality gameEnviroment) {
    switch (this) {
      case EnemyType.mushroomBrawler:
        return DummyTwo(initPosition: position, gameEnviroment: gameEnviroment);
      case EnemyType.mushroomBoss:
        return BossOne(initPosition: position, gameEnviroment: gameEnviroment);

      default:
        return DummyTwo(initPosition: position, gameEnviroment: gameEnviroment);
    }
  }
}

enum AudioScopeType { bgm, long, short }

enum EntityType { player, enemy, npc }

enum FixtureType { sensor, body }

enum WeaponDescription {
  attackRate,
  damage,
  reloadTime,
  velocity,
  staminaCost,
  semiOrAuto,
  maxAmmo,
  attackCount,
}

// enum SecondaryAbilityDescription{

// }

enum EntityStatus {
  dodge,
  custom,
  spawn,
  idle,
  run,
  walk,
  jump,
  dash,
  dead,
  damage,
  attack
}

enum WeaponStatus { attack, reload, charge, spawn, idle }

enum JoystickDirection {
  up,
  upLeft,
  upRight,
  right,
  down,
  downRight,
  downLeft,
  left,
  idle,
}

// extension CharacterTypeFilename on CharacterType {}

enum GameLevel { mushroomForest, dungeon, graveyard, menu }

enum GameDifficulty { easy, normal, hard, chaos }

extension GameDifficultyExtension on GameDifficulty {
  Color get color {
    switch (this) {
      case GameDifficulty.easy:
        return const Color.fromARGB(255, 154, 248, 255);
      case GameDifficulty.normal:
        return Colors.transparent;
      case GameDifficulty.hard:
        return const Color.fromARGB(255, 153, 0, 0);
      case GameDifficulty.chaos:
        return const Color.fromARGB(255, 108, 0, 122);
    }
  }
}

extension GameLevelExtension on GameLevel {
  Color get levelColor {
    switch (this) {
      case GameLevel.mushroomForest:
        return const Color.fromARGB(255, 117, 219, 156);
      case GameLevel.dungeon:
        return const Color.fromARGB(255, 102, 98, 98);
      case GameLevel.graveyard:
        return const Color.fromARGB(255, 188, 192, 207);
      default:
        return Colors.green;
    }
  }

  String get levelImage {
    switch (this) {
      case GameLevel.mushroomForest:
        return 'assets/images/background/forest.png';
      case GameLevel.dungeon:
        return 'assets/images/background/dungeon.png';
      case GameLevel.graveyard:
        return 'assets/images/background/graveyard.jpg';
      default:
        return 'assets/images/background/forest.png';
    }
  }

  Enviroment buildEnvrioment() {
    switch (this) {
      case GameLevel.mushroomForest:
        return ForestGame();
      // case GameLevel.dungeon:
      // return DungeonGame(gameDifficulty);
      // case GameLevel.graveyard:
      // return DungeonGame(gameDifficulty);

      case GameLevel.menu:
        return MenuGame();

      default:
        return ForestGame();
    }
  }

  BackgroundComponent buildBackground(Enviroment gameRef) {
    switch (this) {
      // case GameLevel.space:
      //   return ForestBackground(gameRef);
      case GameLevel.mushroomForest:
        return ForestBackground(gameRef);
      case GameLevel.menu:
        return BlankBackground(gameRef);
      default:
        return ForestBackground(gameRef);
    }
  }
}
// enum CharacterType { wizard, rogue }

enum ExperienceAmount { small, medium, large }

enum InputType {
  keyboard,
  mouseMove,
  aimJoy,
  moveJoy,
  tapClick,
  secondaryClick,
  mouseDrag,
  // mouseDragStart,
  ai,
}

extension ExperienceAmountExtension on ExperienceAmount {
  ShapeComponent getShapeComponent(double radius) {
    switch (this) {
      case ExperienceAmount.small:
        return CircleComponent(radius: radius, anchor: Anchor.center);
      case ExperienceAmount.medium:
        return RectangleComponent(
            size: Vector2.all(radius), anchor: Anchor.center);

      case ExperienceAmount.large:
        return PolygonComponent([
          Vector2(0, -radius),
          Vector2(radius, 0),
          Vector2(0, radius),
          Vector2(-radius, 0)
        ], anchor: Anchor.center);
    }
  }

  double get experienceAmount {
    switch (this) {
      case ExperienceAmount.small:
        return 5;
      case ExperienceAmount.medium:
        return 20;
      case ExperienceAmount.large:
        return 150;
    }
  }

  Color get color {
    switch (this) {
      case ExperienceAmount.small:
        return Colors.lightBlue.shade200;
      case ExperienceAmount.medium:
        return Colors.green.shade200;
      case ExperienceAmount.large:
        return Colors.purple.shade200;
    }
  }
}

enum ProjectileType { bullet, arrow, laser, fireball }

extension ProjectileTypeExtension on ProjectileType {
  BodyComponent generateProjectile(
      {required Vector2 delta,
      required Vector2 originPositionVar,
      required ProjectileFunctionality ancestorVar,
      double chargeAmount = 1}) {
    switch (this) {
      case ProjectileType.laser:
        return Laser(
            originPosition: originPositionVar,
            delta: delta,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
      case ProjectileType.bullet:
        return Bullet(
            originPosition: originPositionVar,
            delta: delta,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
      case ProjectileType.fireball:
        return Fireball(
            weaponAncestor: ancestorVar,
            originPosition: originPositionVar,
            delta: delta,
            power: chargeAmount);

      default:
        return Bullet(
            originPosition: originPositionVar,
            delta: delta,
            weaponAncestor: ancestorVar,
            power: chargeAmount);
    }
  }
}

enum WeaponSpritePosition { hand, mouse, back }

enum AttackType { projectile, melee, spell }

// enum WeaponState { shooting, reloading, idle }

extension SecondaryWeaponTypeExtension on SecondaryType {
  dynamic build(Weapon? primaryWeaponAncestor, [int upgradeLevel = 0]) {
    switch (this) {
      case SecondaryType.reloadAndRapidFire:
        return RapidFire(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.pistol:
        return ExplodeProjectile(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.explodeProjectiles:
        return ExplodeProjectile(primaryWeaponAncestor, 5, upgradeLevel);
    }
  }
}

enum WeaponType {
  pistol(Pistol.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 0),
  longRangeRifle(Pistol.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 0),
  assaultRifle(Pistol.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 0),
  laserRifle(Pistol.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 0),
  railgun(Pistol.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 0),
  rocketLauncher(Pistol.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 0),
  shotgun(Shotgun.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 500),
  energySword(EnergySword.create, 'assets/images/weapons/energy_sword.png', 5,
      AttackType.melee, 500),
  flameSword(FlameSword.create, 'assets/images/weapons/fire_sword.png', 5,
      AttackType.melee, 500),
  dagger(Dagger.create, 'assets/images/weapons/dagger.png', 5, AttackType.spell,
      0),

  largeSword(LargeSword.create, 'assets/images/weapons/large_sword.png', 5,
      AttackType.melee, 600),
  spear(
      Dagger.create, 'assets/images/weapons/spear.png', 5, AttackType.melee, 0),
  ;

  const WeaponType(this.createFunction, this.icon, this.maxLevel,
      this.attackType, this.baseCost);
  final String icon;
  final int maxLevel;
  final AttackType attackType;
  final Function createFunction;
  final int baseCost;

  String get flameImage {
    final split = icon.split('/');
    return "${split[2]}/${split[3]}";
  }
}

extension WeaponTypeFilename on WeaponType {
  Weapon build(AimFunctionality? ancestor, SecondaryType? secondaryWeaponType,
      [int upgradeLevel = 0]) {
    Weapon? returnWeapon;

    switch (this) {
      case WeaponType.pistol:
        returnWeapon = Pistol.create(upgradeLevel, ancestor);
        break;
      case WeaponType.shotgun:
        returnWeapon = Shotgun.create(upgradeLevel, ancestor);
        break;
      case WeaponType.railgun:
        returnWeapon = Railgun.create(upgradeLevel, ancestor);
        break;
      case WeaponType.assaultRifle:
        returnWeapon = AssaultRifle.create(upgradeLevel, ancestor);
        break;
      case WeaponType.longRangeRifle:
        returnWeapon = LongRangeRifle.create(upgradeLevel, ancestor);
        break;
      case WeaponType.rocketLauncher:
        returnWeapon = RocketLauncher.create(upgradeLevel, ancestor);
        break;
      case WeaponType.laserRifle:
        returnWeapon = LaserRifle.create(upgradeLevel, ancestor);
        break;

      case WeaponType.dagger:
        returnWeapon = Dagger.create(upgradeLevel, ancestor);

      case WeaponType.largeSword:
        returnWeapon = LargeSword.create(upgradeLevel, ancestor);

        break;
      case WeaponType.spear:
        returnWeapon = Spear.create(upgradeLevel, ancestor);
        break;
      case WeaponType.energySword:
        returnWeapon = EnergySword.create(upgradeLevel, ancestor);

        break;
      case WeaponType.flameSword:
        returnWeapon = FlameSword.create(upgradeLevel, ancestor);

        break;
    }
    if (returnWeapon is SecondaryFunctionality) {
      returnWeapon.setSecondaryFunctionality =
          secondaryWeaponType?.build(returnWeapon, upgradeLevel);
    }
    ancestor?.add(returnWeapon);
    return returnWeapon;
  }
}

enum SemiAutoType { regular, release, charge }

enum DamageType { physical, magic, fire, psychic, energy, frost }

extension DamageTypeExtension on DamageType {
  Color get color {
    switch (this) {
      case DamageType.physical:
        return Colors.white;
      case DamageType.energy:
        return const Color.fromARGB(255, 247, 255, 199);
      case DamageType.psychic:
        return Colors.purple;
      case DamageType.magic:
        return Colors.blue;
      case DamageType.fire:
        return Colors.orange;
      case DamageType.frost:
        return const Color.fromARGB(255, 170, 233, 248);
    }
  }
}

enum StatusEffects { burn, chill, electrified, stun, psychic }

typedef WeaponCreateFunction = Weapon Function(Entity);

class DamageInstance {
  DamageInstance(
      {required this.damageBase,
      required this.source,
      required this.damageType,
      this.duration = 1,
      this.sourceWeapon});

  Entity source;
  Weapon? sourceWeapon;

  double damageBase;
  double get damage => damageBase;

  DamageType damageType;
  double duration;
}

enum SecondaryType {
  reloadAndRapidFire(
      'assets/images/weapons/dagger.png', 5, weaponIsReloadFunctionality, 500),
  pistol('assets/images/weapons/dagger.png', 5, alwaysCompatible, 500),
  explodeProjectiles('assets/images/weapons/dagger.png', 5,
      weaponIsProjectileFunctionality, 500);

  const SecondaryType(
      this.icon, this.maxLevel, this.compatibilityCheck, this.baseCost);

  ///Based on a input weapon, return true or false to
  ///see if the weapon is compatible with the secondary ability
  final CompatibilityFunction compatibilityCheck;
  final String icon;
  final int maxLevel;
  final int baseCost;
}

typedef CompatibilityFunction = bool Function(Weapon);

bool alwaysCompatible(Weapon weapon) => true;

bool weaponIsReloadFunctionality(Weapon weapon) {
  bool test = weapon is ReloadFunctionality;
  return test;
}

bool weaponIsProjectileFunctionality(Weapon weapon) {
  bool test = weapon is ProjectileFunctionality;
  return test;
}
