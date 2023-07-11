import 'package:flame/components.dart';
import 'package:flame_forge2d/body_component.dart';
import 'package:flutter/material.dart';
import 'package:game_app/entities/entity_mixin.dart';
import 'package:game_app/weapons/enemy_weapons.dart';
import 'package:game_app/weapons/weapon_mixin.dart';
import 'package:game_app/weapons/weapons.dart';

import '../entities/entity.dart';
import '../game/background.dart';
import '../game/enviroment.dart';
import '../game/forest_game.dart';
import '../weapons/projectiles.dart';
import '../weapons/secondary_abilities.dart';
import '../weapons/weapon_class.dart';

enum EntityType { player, enemy, npc }

enum FixtureType { sensor, body }

enum WeaponDescription {
  attackRate,
  damage,
  reloadTime,
  velocity,
  semiOrAuto,
  attackCount,
}

// enum SecondaryAbilityDescription{

// }

enum EntityStatus {
  dodge,
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

extension CharacterTypeFilename on CharacterType {}

enum GameLevel { forest, space, garden, menu }

enum CharacterType { wizard, rogue }

enum ExperienceAmount { small, medium, large }

enum InputType {
  keyboard,
  mouseMove,
  aimJoy,
  moveJoy,
  tapClick,
  secondaryClick,
  mouseDrag,
  mouseDragStart,
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

extension GameLevelExtension on GameLevel {
  // String getTileFilename() {
  //   switch (this) {
  //     case GameLevel.space:
  //       return 'isometric-sandbox-map.tmx';
  //     case GameLevel.forest:
  //       return 'isometric-sandbox-map.tmx';
  //     case GameLevel.home:
  //       return 'home-room.tmx';
  //     default:
  //       return '';
  //   }
  // }

  BackgroundComponent buildBackground(Enviroment gameRef) {
    switch (this) {
      // case GameLevel.space:
      //   return ForestBackground(gameRef);
      case GameLevel.forest:
        return ForestBackground(gameRef);
      case GameLevel.menu:
        return BlankBackground(gameRef);
      default:
        return ForestBackground(gameRef);
    }
  }
}

enum WeaponSpritePosition { hand, mouse, back }

enum AttackType { projectile, melee, special }

enum WeaponState { shooting, reloading, idle }

extension SecondaryWeaponTypeExtension on SecondaryType {
  dynamic build(Weapon? primaryWeaponAncestor, [int upgradeLevel = 0]) {
    switch (this) {
      case SecondaryType.reloadAndRapidFire:
        return RapidFire(primaryWeaponAncestor, 5, upgradeLevel);
      case SecondaryType.pistol:
        return Portal.create(
            upgradeLevel, primaryWeaponAncestor?.entityAncestor);
      case SecondaryType.explodeProjectiles:
        return ExplodeProjectile(primaryWeaponAncestor, 5, upgradeLevel);
    }
  }
}

enum WeaponType {
  pistol(Pistol.create, 'assets/images/weapons/pistol.png', 5,
      AttackType.projectile, 0),
  shotgun(Shotgun.create, 'assets/images/weapons/shotgun.png', 5,
      AttackType.projectile, 500),
  portal(Portal.create, 'assets/images/weapons/portal.png', 5,
      AttackType.projectile, 1000),
  shiv(Sword.create, 'assets/images/weapons/sword.png', 5, AttackType.melee, 0),
  bow(Bow.create, 'assets/images/weapons/bow.png', 10, AttackType.projectile,
      5000),
  blankMelee(BlankMelee.create, 'assets/images/weapons/bow.png', 5,
      AttackType.melee, 0);

  const WeaponType(this.createFunction, this.icon, this.maxLevel,
      this.attackType, this.baseCost);
  final String icon;
  final int maxLevel;
  final AttackType attackType;
  final Function createFunction;
  final int baseCost;
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

      case WeaponType.bow:
        returnWeapon = Bow.create(upgradeLevel, ancestor);
        break;

      case WeaponType.shiv:
        returnWeapon = Sword.create(upgradeLevel, ancestor);

        break;
      case WeaponType.portal:
        returnWeapon = Portal.create(upgradeLevel, ancestor);
        break;
      case WeaponType.blankMelee:
        returnWeapon = BlankMelee.create(upgradeLevel, ancestor);
        break;
    }
    if (returnWeapon is SecondaryFunctionality) {
      returnWeapon.setSecondaryFunctionality =
          secondaryWeaponType?.build(returnWeapon, upgradeLevel);
    }
    return returnWeapon;
  }
}

enum SemiAutoType { regular, release, charge }

enum DamageType { regular, magic, energy, psychic, fire }

typedef WeaponCreateFunction = Weapon Function(Entity);

class DamageInstance {
  DamageInstance(
      {required this.damageBase,
      required this.source,
      required this.damageType,
      this.duration = 1,
      this.sourceWeapon});

  Color getColor() {
    switch (damageType) {
      case DamageType.regular:
        return Colors.white;
      case DamageType.magic:
        return Colors.blue;
      case DamageType.psychic:
        return Colors.purple;
      case DamageType.fire:
        return Colors.red;
      case DamageType.energy:
        return Colors.yellow;
    }
  }

  Entity source;
  Weapon? sourceWeapon;

  double damageBase;
  double get damage => damageBase;

  DamageType damageType;
  double duration;
}

enum SecondaryType {
  reloadAndRapidFire(
      'assets/images/weapons/portal.png', 5, weaponIsReloadFunctionality, 500),
  pistol('assets/images/weapons/portal.png', 5, alwaysCompatible, 500),
  explodeProjectiles('assets/images/weapons/portal.png', 5,
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
